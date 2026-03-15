
dirstack-cd-widget() {
  emulate -L zsh
  local dir orig_buffer orig_cursor

  orig_buffer=$BUFFER
  orig_cursor=$CURSOR

  zle -I

  dir="$({
    local i=0 d
    while IFS= read -r d; do
      printf '%d\t%s\n' "$i" "$d"
      (( i++ ))
    done < <(dirs -p)
  } | fzf --delimiter=$'\t' --with-nth=1,2 --nth=2.. \
          --height 40% --reverse --prompt='dir> ' \
          --bind 'enter:become(printf "%s\\n" {2})' \
          2>/dev/tty)" || { BUFFER=$orig_buffer; CURSOR=$orig_cursor; zle reset-prompt; return 0; }

  # Intentionally unquoted so `~` expands (as configured in your shell).
  builtin cd -- ${~dir} || { zle -M "cd failed: $dir"; BUFFER=$orig_buffer; CURSOR=$orig_cursor; zle reset-prompt; return 0; }

  BUFFER=$orig_buffer
  CURSOR=$orig_cursor

  # Force prompt to recompute (powerlevel10k updates prompt in precmd hooks).
  if typeset -p precmd_functions >/dev/null 2>&1; then
    local f
    for f in $precmd_functions; do
      (( $+functions[$f] )) && "$f"
    done
  fi

  # If p10k is available, ask it to redraw as well.
  (( $+functions[p10k] )) && p10k display -r >/dev/null 2>&1
  zle reset-prompt
}
zle -N dirstack-cd-widget

# Bindings
bindkey $'\e\C-d' dirstack-cd-widget # Ctrl-Alt-d (if your terminal sends Esc+Ctrl-d)