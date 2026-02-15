rv (Go)

Overview
- Go rewrite of the previous bash utilities for environment setup and dotfile linking.
- Provides a single CLI with subcommands and reusable helpers.

Build
- From repo root: `go build ./cmd/rv`

Usage
- `rv link-dotconfig [--confdir DIR] [--backup-suffix SFX]`
  - Links every directory under repo `.config/` into your config dir (XDG or `$HOME/.config`).

- `rv fish [--confdir DIR] [--no-default-shell] [--no-starship] [--starship-sha256 SHA | --allow-unsigned-starship]`
  - Installs/configures fish, optional starship, then links configs via `link-dotconfig`.

- `rv brew`
  - Installs Homebrew if missing.

- `rv gcloud [--no-init]`
  - Installs gcloud and optionally runs `gcloud init`.

- `rv kmonad [--kbd PATH] [--service] [--service-path PATH] [--stack-sha256 SHA | --allow-unsigned-stack]`
  - Builds/installs kmonad, links keyboard file, and optionally sets up systemd service.

- `rv nvim`
  - Links configs and sets up neovim, tmux, fonts when tools are available.

- `rv linux`
  - Installs neovim, then runs `nvim` setup.

- `rv all`
  - Runs `brew`, `fish`, then `linux`.

Notes
- The CLI uses absolute symlink targets under the repo root.
- Default config directory is `XDG_CONFIG_HOME` or `$HOME/.config`.
- Network-requiring steps (e.g., downloads, package installs) are best-effort and may require privileges.
