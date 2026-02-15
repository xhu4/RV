#!/usr/bin/env bash
set -euo pipefail

# Link each subfolder in ./config to $XDG_CONFIG_DIR (or $XDG_CONFIG_HOME) or $HOME/.config
# Then, if possible, load GNOME dconf settings from dconf-settings.ini

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
REPO_CONFIG_DIR="$SCRIPT_DIR/config"

if [[ ! -d "$REPO_CONFIG_DIR" ]]; then
  echo "No config directory found at $REPO_CONFIG_DIR" >&2
  exit 1
fi

# Determine target config directory with sensible precedence
# Honor XDG_CONFIG_HOME first, then XDG_CONFIG_DIR (as requested), else fallback to ~/.config
TARGET_CONFIG_DIR="${XDG_CONFIG_HOME:-${XDG_CONFIG_DIR:-$HOME/.config}}"
mkdir -p "$TARGET_CONFIG_DIR"

echo "Linking config folders into: $TARGET_CONFIG_DIR"

# Iterate subdirectories in ./config and create symlinks in target
shopt -s nullglob
for src in "$REPO_CONFIG_DIR"/*; do
  [[ -d "$src" ]] || continue
  name="$(basename -- "$src")"
  dest="$TARGET_CONFIG_DIR/$name"

  if [[ -L "$dest" ]]; then
    # Update existing symlink to point to our repo source
    ln -sfn "$src" "$dest"
    echo "Updated symlink: $dest -> $src"
  elif [[ -e "$dest" ]]; then
    # Don't clobber existing real files/dirs
    echo "Skipping existing path (not a symlink): $dest" >&2
  else
    ln -s "$src" "$dest"
    echo "Created symlink: $dest -> $src"
  fi
done

# Load dconf settings when appropriate
DCONF_FILE="$SCRIPT_DIR/dconf-settings.ini"
if [[ -f "$DCONF_FILE" ]]; then
  if command -v dconf >/dev/null 2>&1; then
    # Load only when running under GNOME sessions to avoid unwanted changes elsewhere
    if [[ "${XDG_CURRENT_DESKTOP:-}" == *GNOME* ]] || [[ "${DESKTOP_SESSION:-}" == *gnome* ]]; then
      echo "Loading dconf settings from $DCONF_FILE (may overwrite existing keys)..."
      dconf load / < "$DCONF_FILE"
      echo "dconf settings loaded."
    else
      echo "GNOME session not detected; skipping dconf load." >&2
    fi
  else
    echo "'dconf' not found; skipping dconf load." >&2
  fi
else
  echo "No dconf-settings.ini found; skipping dconf load."
fi

echo "Setup complete."

