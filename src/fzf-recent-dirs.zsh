typeset -gA _fzf_recent_dirs

function _frd.widget() {
  emulate -L zsh
  local idx sign orig_buffer orig_cursor

  orig_buffer=$BUFFER
  orig_cursor=$CURSOR

  zle -I

  idx="$(dirs -v | fzf --delimiter=$'\t' --with-nth=1,2 --nth=2.. \
          --height 40% --reverse --prompt='dir> ' \
          --bind 'enter:become(printf "%s\\n" {1})' \
          2>/dev/tty)" || {
    BUFFER=$orig_buffer
    CURSOR=$orig_cursor
    zle reset-prompt
    return 0
  }

  [[ $idx == <-> ]] || {
    zle -M "fzf-recent-dirs: invalid index: $idx"
    BUFFER=$orig_buffer
    CURSOR=$orig_cursor
    zle reset-prompt
    return 0
  }

  if [[ -o pushdminus ]]; then
    sign='-'
  else
    sign='+'
  fi

  if [[ ${_fzf_recent_dirs[QUIET_CD]:-true} == true ]]; then
    builtin cd ${sign}${idx} >/dev/null
  else
    builtin cd ${sign}${idx}
  fi

  if (( $? != 0 )); then
    zle -M "cd failed: ${sign}${idx}"
    BUFFER=$orig_buffer
    CURSOR=$orig_cursor
    zle reset-prompt
    return 0
  fi

  BUFFER=$orig_buffer
  CURSOR=$orig_cursor

  # Force prompt to recompute (powerlevel10k updates prompt in precmd hooks).
  if [[ ${_fzf_recent_dirs[PRECMD_REFRESH]:-true} == true ]]; then
    if typeset -p precmd_functions >/dev/null 2>&1; then
      local f
      for f in $precmd_functions; do
        (( $+functions[$f] )) && "$f"
      done
    fi
  fi

  zle reset-prompt
}
