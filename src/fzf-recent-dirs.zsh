typeset -gA _fzf_recent_dirs

function _frd.widget() {
  # ZLE widget implementation.
  #
  # Behavior:
  # - shows `dirs -v` in fzf (authoritative stack indices)
  # - on selection, jumps by stack index with `cd +/-N`
  #   - respects PUSHD_MINUS: `cd -N` when set, otherwise `cd +N`
  # - preserves the current command line (BUFFER/CURSOR)
  # - optionally forces prompt recomputation via precmd_functions (p10k, etc.)
  # - redraws prompt at the end
  #
  # Notes:
  # - We use `become(...)` so fzf outputs only the index, not the full line.
  # - We run fzf UI on the real tty (stderr) so it doesn't fight ZLE.
  # - We do not alter shell options globally; user config is read from
  #   `_fzf_recent_dirs[...]` which is populated by the bootstrap entrypoint.

  emulate -L zsh
  local idx sign orig_buffer orig_cursor

  # Preserve user's partially typed command line.
  orig_buffer=$BUFFER
  orig_cursor=$CURSOR

  # Clear any pending input and get ZLE out of the way before full-screen fzf.
  zle -I

  # `dirs -v` output is tab-separated: "<idx>\t<path>".
  # We keep fuzzy matching on the path field only (`--nth=2..`).
  #
  # Important: Do NOT redirect stdin to /dev/tty. fzf needs stdin to read the
  # candidate list. We instead force the UI to render on tty by sending stderr
  # to /dev/tty.
  idx="$(dirs -v | fzf --delimiter=$'\t' --with-nth=1,2 --nth=2.. \
          --height 40% --reverse --prompt='dir> ' \
          --bind 'enter:become(printf "%s\\n" {1})' \
          2>/dev/tty)" || {
    # User aborted fzf (Esc/C-c) or fzf returned non-zero.
    BUFFER=$orig_buffer
    CURSOR=$orig_cursor
    zle reset-prompt
    return 0
  }

  # fzf should return a numeric stack index. Be defensive.
  [[ $idx == <-> ]] || {
    zle -M "fzf-recent-dirs: invalid index: $idx"
    BUFFER=$orig_buffer
    CURSOR=$orig_cursor
    zle reset-prompt
    return 0
  }

  # `cd +/-N` semantics depend on PUSHD_MINUS.
  # - default (PUSHD_MINUS unset): `cd +1` jumps to stack index 1
  # - with PUSHD_MINUS set:       `cd -1` jumps to stack index 1
  if [[ -o pushdminus ]]; then
    sign='-'
  else
    sign='+'
  fi

  # Use stack-jump `cd` to avoid duplicating entries when AUTO_PUSHD is enabled.
  # This matches native behavior: the selected entry moves to the top of stack.
  if [[ ${_fzf_recent_dirs[QUIET_CD]:-true} == true ]]; then
    # `cd +/-N` can print the destination path on stdout. Suppress it by
    # redirecting stdout; keep stderr intact so errors remain visible.
    builtin cd ${sign}${idx} >/dev/null
  else
    builtin cd ${sign}${idx}
  fi

  # `cd` failure (e.g. out-of-range index) should not destroy the command line.
  if (( $? != 0 )); then
    zle -M "cd failed: ${sign}${idx}"
    BUFFER=$orig_buffer
    CURSOR=$orig_cursor
    zle reset-prompt
    return 0
  fi

  # Restore the user's command line after changing directory.
  BUFFER=$orig_buffer
  CURSOR=$orig_cursor

  # Force prompt to recompute.
  #
  # Many prompt frameworks (notably powerlevel10k) compute prompt segments in
  # precmd hooks. When we `cd` inside a widget, precmd doesn't run
  # automatically, so the prompt can show a stale directory.
  #
  # Running all precmd_functions here is a deliberate, opt-out tradeoff:
  # it provides correctness for prompt state at the cost of running whatever the
  # user has registered in precmd.
  if [[ ${_fzf_recent_dirs[PRECMD_REFRESH]:-true} == true ]]; then
    if typeset -p precmd_functions >/dev/null 2>&1; then
      local f
      for f in $precmd_functions; do
        (( $+functions[$f] )) && "$f"
      done
    fi
  fi

  # Redraw the prompt and keep the editor state consistent.
  zle reset-prompt
}
