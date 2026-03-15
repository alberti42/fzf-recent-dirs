# fzf-recent-dirs

Zsh plugin that adds a single ZLE widget, `fzf-recent-dirs`, to switch to a recently visited directory using `fzf` over the directory stack (`dirs -v`).

Requirements
- Zsh
- fzf 0.38.0+ (uses `become(...)`)

> [!NOTE]
> Minimal footprint by design.
> This plugin does not set Zsh options and does not install keybindings.
> You opt in by binding the widget and (optionally) enabling Zsh directory-stack options yourself.

## Install

### Manual

Clone this repository somewhere:

```sh
git clone https://github.com/<you>/fzf-recent-dirs.git
```

Then add to your `~/.zshrc`:

```zsh
source /path/to/fzf-recent-dirs/fzf-recent-dirs.plugin.zsh
```

### Oh My Zsh

1) Clone into your custom plugins directory:

```sh
git clone https://github.com/<you>/fzf-recent-dirs.git "$ZSH_CUSTOM/plugins/fzf-recent-dirs"
```

2) Enable it in `~/.zshrc`:

```zsh
plugins=(
  # ...
  fzf-recent-dirs
)
```

3) Restart your shell.

## Usage

Bind a key to the widget (example: Ctrl-Alt-d if your terminal sends Esc+Ctrl-d):

```zsh
bindkey $'\e\C-d' fzf-recent-dirs
```

To make your directory stack useful, consider these user-side options:

```zsh
setopt AUTO_CD        # navigate directories without needing "cd" command
setopt AUTO_PUSHD     # make cd push the old directory onto the directory stack
setopt PUSHD_SILENT   # do not print the directory stack after pushd or popd

# Optional: if you use stack indices (e.g. `cd -1`) and prefer `-N` syntax.
setopt PUSHD_MINUS
```

## Configuration

`FRD_PRECMD_REFRESH` (default: enabled)

This plugin refreshes the prompt by running `precmd_functions` after changing directories, which is important for themes such as powerlevel10k.

To disable:

```zsh
export FRD_PRECMD_REFRESH=false
```

Set this before sourcing `fzf-recent-dirs.plugin.zsh`.
