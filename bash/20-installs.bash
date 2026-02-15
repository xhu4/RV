#!/usr/bin/env bash

# Aggregate installer using rv utils

rv.install_brew() {
  # Flags: -h|--help
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    rv.info "Usage: rv.install_brew"
    rv.info "Installs Homebrew and updates PATH if needed."
    return 0
  fi
  if rv.has brew; then
    rv.okay "Homebrew already installed"
    return 0
  fi
  rv.info "Installing Homebrew..."
  rv.run "/bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
  # Update PATH for current and future shells
  if [[ -d /home/linuxbrew/.linuxbrew/bin ]]; then
    rv.info "Adding homebrew bin to PATH (bash)"
    rv.run "echo 'export PATH=\"\$PATH:/home/linuxbrew/.linuxbrew/bin\"' >> \"$HOME/.bashrc\""
    # Update fish path if fish exists
    if rv.has fish; then
      rv.info "Adding homebrew bin to PATH (fish)"
      rv.run "fish -c 'fish_add_path -a /home/linuxbrew/.linuxbrew/bin/'"
    fi
  fi
  rv.okay "Homebrew setup done."
}

rv.install_fish() {
  # Flags:
  #   --confdir DIR
  #   --no-default-shell
  #   --no-bazel-completion
  #   --no-starship
  #   --starship-sha256 SHA | --allow-unsigned-starship
  #   -h|--help
  local confdir="${XDG_CONFIG_HOME:-$HOME/.config}" do_default_shell=1 do_bazel=1 do_starship=1
  local starship_sha="" allow_unsigned_starship=0
  while (($#)); do
    case "$1" in
    --confdir)
      confdir="${2:?}"
      shift 2
      ;;
    --no-default-shell)
      do_default_shell=0
      shift
      ;;
    --no-bazel-completion)
      do_bazel=0
      shift
      ;;
    --no-starship)
      do_starship=0
      shift
      ;;
    --starship-sha256)
      starship_sha="${2:?}"
      shift 2
      ;;
    --allow-unsigned-starship)
      allow_unsigned_starship=1
      shift
      ;;
    -h | --help)
      rv.info "Usage: rv.install_fish [--confdir DIR] [--no-default-shell] [--no-bazel-completion] [--no-starship] [--starship-sha256 SHA | --allow-unsigned-starship]"
      return 0
      ;;
    *)
      rv.error "Unknown flag: $1"
      return 2
      ;;
    esac
  done

  if ! rv.has fish; then
    rv.info "Installing fish..."
    if rv.has apt-get; then
      rv.run "sudo apt-get update"
      rv.run "sudo apt-get install -y software-properties-common curl"
      rv.run "sudo apt-add-repository -y ppa:fish-shell/release-3"
      rv.run "sudo apt-get update"
      rv.run "sudo apt-get install -y fish"
    elif rv.has brew; then
      rv.run "brew install fish"
    else
      rv.error "No supported package manager found for fish"
    fi
  else
    rv.okay "fish found"
  fi

  if ((do_starship)) && ! rv.has starship; then
    rv.info "Installing starship..."
    if rv.has brew; then
      rv.run "brew install starship"
    elif rv.has apt-get; then
      rv.run "sudo apt-get update"
      rv.run "sudo apt-get install -y starship || true"
    fi
    if ! rv.has starship; then
      local script
      script="$(mktemp)"
      rv.download "https://starship.rs/install.sh" "$script"
      if [[ -n "$starship_sha" ]]; then
        rv.verify_sha256 "$script" "$starship_sha" || {
          rm -f "$script"
          return 1
        }
      elif ((!allow_unsigned_starship)); then
        rm -f "$script"
        rv.error "Refusing to run unsigned Starship installer. Provide --starship-sha256 or --allow-unsigned-starship."
        return 2
      else
        rv.warn "Running unsigned Starship installer"
      fi
      rv.run "sh \"$script\" -y"
      rm -f "$script"
    fi
  else
    rv.okay "starship found"
  fi

  # Try installing fzf and bat
  if rv.has brew; then
    rv.run "brew install fzf bat || true"
  elif rv.has apt-get; then
    rv.run "sudo apt-get install -y fzf bat || true"
  fi

  if ((do_default_shell)) && rv.has fish; then
    rv.info "Setting fish as default shell"
    fish_path="$(command -v fish)"
    if ! grep -qxF "$fish_path" /etc/shells 2>/dev/null; then
      rv.run "printf '%s\\n' \"$fish_path\" | sudo tee -a /etc/shells > /dev/null"
    fi
    # Try both chsh variants for broader compatibility
    rv.run "chsh -s \"$fish_path\" || chsh -s \"$fish_path\" \"$USER\""
  fi

  # Bazel completion
  if ((do_bazel)) && rv.has bazel && rv.has python3; then
    rv.warn "Setting up bazel completion"
    rv.run "pip3 install --user absl-py"
    rv.run "mkdir -p \"$confdir/fish/completions\""
    rv.run "python3 \"$RV_SCRIPT_DIR/generate_fish_completion.py\" --bazel=\"$(command -v bazel)\" --output=\"$confdir/fish/completions/bazel.fish\""
  fi

  # Link fish config and omf
  rv.warn "Linking fish config folders"
  rv.run "mkdir -p \"$confdir/fish\""
  rv.link "fish/functions" "$confdir/fish/functions"
  rv.run "rm -rf \"$confdir/omf\" || true"
  rv.link ".config/omf" "$confdir/omf"
  rv.okay "Fish config linked"

  if rv.has fish; then
    rv.run "fish -c 'fish_add_path \"$HOME/.local/bin\"'"
  fi
}

rv.install_gcloud() {
  # Flags: --no-init, -h|--help
  local do_init=1
  while (($#)); do
    case "$1" in
    --no-init)
      do_init=0
      shift
      ;;
    -h | --help)
      rv.info "Usage: rv.install_gcloud [--no-init]"
      return 0
      ;;
    *)
      rv.error "Unknown flag: $1"
      return 2
      ;;
    esac
  done
  if rv.has gcloud; then
    rv.okay "gcloud already installed"
  else
    if rv.has apt-get; then
      rv.run "sudo apt-get update"
      rv.run "sudo apt-get install -y apt-transport-https ca-certificates gnupg curl"
      if [[ ! -f /usr/share/keyrings/cloud.google.gpg ]]; then
        rv.run "curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg"
      fi
      if [[ ! -f /etc/apt/sources.list.d/google-cloud-sdk.list ]]; then
        rv.run "echo 'deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main' | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list"
      fi
      rv.run "sudo apt-get update"
      rv.run "sudo apt-get install -y google-cloud-cli"
    elif rv.has brew; then
      rv.run "brew install --cask google-cloud-sdk || brew install google-cloud-sdk || true"
    else
      rv.warn "No supported package manager found for gcloud"
    fi
  fi
  if ((do_init)) && rv.has gcloud; then
    rv.run "gcloud init"
  fi
}

rv.install_kmonad() {
  # Flags: --no-service, --kbd FILE, --service-path PATH, --stack-sha256 SHA | --allow-unsigned-stack, -h|--help
  local do_service=1 kbd_rel="kmonad/cherry.kbd" service_path="/etc/systemd/system/kmonad.service"
  local stack_sha="" allow_unsigned_stack=0
  while (($#)); do
    case "$1" in
    --no-service)
      do_service=0
      shift
      ;;
    --kbd)
      kbd_rel="${2:?}"
      shift 2
      ;;
    --service-path)
      service_path="${2:?}"
      shift 2
      ;;
    -h | --help)
      rv.info "Usage: rv.install_kmonad [--no-service] [--kbd FILE] [--service-path PATH] [--stack-sha256 SHA | --allow-unsigned-stack]"
      return 0
      ;;
    --stack-sha256)
      stack_sha="${2:?}"
      shift 2
      ;;
    --allow-unsigned-stack)
      allow_unsigned_stack=1
      shift
      ;;
    *)
      rv.error "Unknown flag: $1"
      return 2
      ;;
    esac
  done
  if ! rv.has kmonad; then
    rv.warn "Installing Haskell Stack..."
    if rv.has brew; then
      rv.run "brew install haskell-stack"
    elif rv.has apt-get; then
      rv.run "sudo apt-get update"
      rv.run "sudo apt-get install -y haskell-stack || sudo apt-get install -y stack || true"
    fi
    if ! rv.has stack; then
      local script
      script="$(mktemp)"
      rv.download "https://get.haskellstack.org/" "$script"
      if [[ -n "$stack_sha" ]]; then
        rv.verify_sha256 "$script" "$stack_sha" || {
          rm -f "$script"
          return 1
        }
      elif ((!allow_unsigned_stack)); then
        rm -f "$script"
        rv.error "Refusing to run unsigned Stack installer. Provide --stack-sha256 or --allow-unsigned-stack."
        return 2
      else
        rv.warn "Running unsigned Stack installer"
      fi
      rv.run "sh \"$script\""
      rm -f "$script"
    fi
    rv.warn "Cloning kmonad..."
    local tmpdir
    tmpdir="$(mktemp -d)"
    rv.run "git clone https://github.com/kmonad/kmonad \"$tmpdir\""
    rv.warn "Building and installing kmonad..."
    rv.run "stack install \"$tmpdir\""
  fi

  rv.warn "Linking keyboard files and service..."
  rv.link "$kbd_rel" "$HOME/.cherry.kbd"
  if ((do_service)); then
    rv.link "kmonad/kmonad.service" "$service_path" ".bk" sudo
    rv.warn "Starting and enabling kmonad service..."
    rv.run "sudo systemctl daemon-reload"
    rv.run "sudo systemctl start kmonad"
    rv.run "sudo systemctl enable kmonad"
  fi
  rv.okay "kmonad setup complete"
}

rv.install_nvim() {
  rv.install_brew
  rv.install_fish

  # neovim
  if rv.has brew; then
    rv.run "brew install neovim"
  elif rv.has apt-get; then
    rv.run "sudo apt-get install -y neovim"
  fi
  rv.link ".config/nvim" "$confdir/nvim"

  # Fonts
  rv.run "mkdir -p \"$HOME/.local/share/fonts\""
  if [[ -f \"$RV_SCRIPT_DIR/fonts/FiraCode.zip\" ]]; then
    if rv.has unzip; then
      rv.run "unzip -o \"$RV_SCRIPT_DIR/fonts/FiraCode.zip\" -d \"$HOME/.local/share/fonts\""
    elif rv.has brew; then
      rv.run "brew install unzip && unzip -o \"$RV_SCRIPT_DIR/fonts/FiraCode.zip\" -d \"$HOME/.local/share/fonts\""
    elif rv.has apt-get; then
      rv.run "sudo apt-get install -y unzip && unzip -o \"$RV_SCRIPT_DIR/fonts/FiraCode.zip\" -d \"$HOME/.local/share/fonts\""
    fi
  fi

  # tmux and clipboard tools
  if rv.has brew; then
    rv.run "brew install tmux lazygit"
  elif rv.has apt-get; then
    rv.run "sudo apt-get install -y tmux xsel wl-clipboard"
  fi
  if [[ ! -d \"$HOME/.tmux/plugins/tpm\" ]]; then
    rv.run "git clone https://github.com/tmux-plugins/tpm \"$HOME/.tmux/plugins/tpm\""
  fi
  rv.link ".tmux.conf" "$HOME/.tmux.conf"
  if [[ -x \"$HOME/.tmux/plugins/tpm/bin/install_plugins.sh\" ]]; then
    rv.run "\"$HOME/.tmux/plugins/tpm/bin/install_plugins.sh\""
  fi
}

usage() {
  cat <<EOF
Usage: $(basename "$0") <command> [args]

Commands:
  brew        Install Homebrew
  fish        Install and configure fish + starship
  gcloud      Install and init gcloud CLI
  kmonad      Install kmonad and service
  linux       General Linux setup (neovim, fonts, tmux, lazygit)
  all         Run brew, fish, linux

Use "$(basename "$0") <command> --help" for command-specific options.
EOF
}

main() {
  local cmd="${1:-}"
  shift || true
  case "$cmd" in
  -h | --help | "")
    usage
    return 0
    ;;
  brew) rv.install_brew "$@" ;;
  fish) rv.install_fish "$@" ;;
  gcloud) rv.install_gcloud "$@" ;;
  kmonad) rv.install_kmonad "$@" ;;
  linux) rv.install_linux "$@" ;;
  all)
    rv.install_brew
    rv.install_fish
    rv.install_linux "$@"
    ;;
  *)
    usage
    return 1
    ;;
  esac
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  # Ensure rv.* functions are available when executed directly
  if ! type -t rv.run >/dev/null 2>&1; then
    script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
    for f in "$script_dir"/*.bash "$script_dir"/*.sh; do
      [[ -r "$f" ]] && source "$f"
    done
  fi
  main "$@"
fi
