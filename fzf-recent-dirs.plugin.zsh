# fzf-recent-dirs.plugin.zsh
#
# Bootstrap entrypoint (sourced by plugin managers).
#
# Goals:
# - minimal footprint: no keybindings, no setopt changes
# - interactive-only: do nothing in scripts
# - lazy-load the core module on first widget invocation

[[ -o interactive ]] || return 0

# Single global state/config map (see AGENTS.md).
typeset -gA _fzf_recent_dirs

# meta.plugin_dir: absolute directory containing this plugin entrypoint.
# Used to locate the core module regardless of $PWD.
_fzf_recent_dirs[meta.plugin_dir]=${${(%):-%x}:a:h}

# -----------------------------------------------------------------------------
# Configuration (imported once at bootstrap)
#
# User provides environment variables (set before sourcing this file):
# - FRD_PRECMD_REFRESH: whether to run precmd_functions after cd (default: true)
# - FRD_QUIET_CD: whether to silence stdout from `cd +/-N` (default: true)
#
# Internally we store boolean-like strings in _fzf_recent_dirs:
# - _fzf_recent_dirs[PRECMD_REFRESH] = true|false
# - _fzf_recent_dirs[QUIET_CD] = true|false
# -----------------------------------------------------------------------------

: ${_fzf_recent_dirs[PRECMD_REFRESH]:=true}
if [[ -n ${FRD_PRECMD_REFRESH-} ]]; then
  case ${(L)FRD_PRECMD_REFRESH} in
    0|false|no|off) _fzf_recent_dirs[PRECMD_REFRESH]=false ;;
    1|true|yes|on)  _fzf_recent_dirs[PRECMD_REFRESH]=true  ;;
  esac
fi

: ${_fzf_recent_dirs[QUIET_CD]:=true}
if [[ -n ${FRD_QUIET_CD-} ]]; then
  case ${(L)FRD_QUIET_CD} in
    0|false|no|off) _fzf_recent_dirs[QUIET_CD]=false ;;
    1|true|yes|on)  _fzf_recent_dirs[QUIET_CD]=true  ;;
  esac
fi

# -----------------------------------------------------------------------------
# Lazy widget stub
#
# This function is registered as the ZLE widget initially. On first invocation
# it sources the core module which re-defines `_frd.widget` with the real
# implementation. We then call `_frd.widget` again, which now executes the real
# widget code.
# -----------------------------------------------------------------------------

function _frd.widget() {
  local core
  core="${_fzf_recent_dirs[meta.plugin_dir]}/src/fzf-recent-dirs.zsh"

  if [[ -r $core ]]; then
    builtin source "$core" || return 0
    _frd.widget
  else
    # zle -M writes a message in the editor area without disturbing the buffer.
    zle -M "fzf-recent-dirs: missing $core"
    return 0
  fi
}

# Public widget name. Users bind keys themselves.
zle -N fzf-recent-dirs _frd.widget
