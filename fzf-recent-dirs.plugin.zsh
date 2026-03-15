[[ -o interactive ]] || return 0

typeset -gA _fzf_recent_dirs

# meta.plugin_dir: absolute directory containing this plugin entrypoint
_fzf_recent_dirs[meta.plugin_dir]=${${(%):-%x}:a:h}

# cfg: imported once at bootstrap
: ${_fzf_recent_dirs[PRECMD_REFRESH]:=true}
if [[ -n ${FRD_PRECMD_REFRESH-} ]]; then
  case ${(L)FRD_PRECMD_REFRESH} in
    0|false|no|off) _fzf_recent_dirs[PRECMD_REFRESH]=false ;;
    1|true|yes|on)  _fzf_recent_dirs[PRECMD_REFRESH]=true  ;;
  esac
fi

function _frd.widget() {
  local core
  core="${_fzf_recent_dirs[meta.plugin_dir]}/src/fzf-recent-dirs.zsh"
  if [[ -r $core ]]; then
    builtin source "$core" || return 0
    _frd.widget
  else
    zle -M "fzf-recent-dirs: missing $core"
    return 0
  fi
}

zle -N fzf-recent-dirs _frd.widget
