## Change log

First stable release of `fzf-recent-dirs` — a minimal Zsh plugin for fuzzy-jumping to recently visited directories.

### What it does

Invoke a single ZLE widget (`fzf-recent-dirs`) and get an interactive `fzf` picker over your directory stack. Select a directory and you land there instantly — your partially-typed command line is preserved, and your prompt updates correctly.

### Features

- **Fuzzy directory picker** — browse your recent directories with `fzf` and jump with a single keystroke.
- **Command-line preservation** — whatever you were typing stays intact after switching directories.
- **Prompt compatibility** — works out of the box with powerlevel10k and other prompt frameworks that rely on `precmd` hooks.
- **Lazy loading** — the core module is sourced only on first use; sourcing the plugin adds ~1 ms to shell startup.
- **No side effects** — no default keybindings, no forced `setopt` changes. You stay in control of your shell config.
- **Runtime compilation** — on first use the plugin compiles itself to a `.zwc` file, making subsequent loads faster. Opt out with `FRD_COMPILE=false`.

### Requirements

- Zsh
- fzf 0.38.0 or later (uses the `become(...)` binding)
