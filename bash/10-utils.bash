#!/usr/bin/env bash

# Do not set global shell options here to avoid affecting interactive shells.
# Strict mode is applied only inside subshells where commands run.

## rv namespace
# Color helpers
_RV_BCOLOR_OK='\033[92m'
_RV_BCOLOR_WARN='\033[93m'
_RV_BCOLOR_INFO='\033[94m'
_RV_BCOLOR_ERR='\033[91m'
_RV_BCOLOR_END='\033[0m'
# Label backgrounds per level (soft, not too distracting)
_RV_BG_OK='\033[102m'   # bright green background
_RV_BG_WARN='\033[103m' # bright yellow background
_RV_BG_INFO='\033[104m' # bright blue background
_RV_BG_ERR='\033[101m'  # bright red background
# Label foreground kept neutral/dim
_RV_LABEL_FG='\033[30m' # black text for contrast
# Fixed label width for compact tags (IN/WR/ER/OK)
_RV_LABEL_WIDTH=2

rv._label() {
  # Usage: rv._label TEXT BG_COLOR
  local text="$1" bg="$2" padded=""
  printf -v padded "%-*s" "${_RV_LABEL_WIDTH}" "$text"
  printf "%b[%s]%b " "${bg}${_RV_LABEL_FG}" "$padded" "${_RV_BCOLOR_END}"
}

rv.warn() {
  # Usage: rv.warn msg...
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    rv.info "Usage: rv.warn <message>"
    return 0
  fi
  {
    rv._label "WR" "${_RV_BG_WARN}"
    printf "%b" "${_RV_BCOLOR_WARN}"
    printf "%s\n" "$*"
    printf "%b" "${_RV_BCOLOR_END}"
  } >&2
}

rv.okay() {
  # Usage: rv.okay msg...
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    rv.info "Usage: rv.okay <message>"
    return 0
  fi
  {
    rv._label "OK" "${_RV_BG_OK}"
    printf "%b" "${_RV_BCOLOR_OK}"
    printf "%s\n" "$*"
    printf "%b" "${_RV_BCOLOR_END}"
  } >&2
}

rv.info() {
  # Usage: rv.info msg...
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    printf "[IN] <message> to stderr\n" >&2
    return 0
  fi
  {
    rv._label "IN" "${_RV_BG_INFO}"
    printf "%b" "${_RV_BCOLOR_INFO}"
    printf "%s\n" "$*"
    printf "%b" "${_RV_BCOLOR_END}"
  } >&2
}

rv.error() {
  # Usage: rv.error msg...
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    rv.info "Usage: rv.error <message>"
    return 0
  fi
  {
    rv._label "ER" "${_RV_BG_ERR}"
    printf "%b" "${_RV_BCOLOR_ERR}"
    printf "%s\n" "$*"
    printf "%b" "${_RV_BCOLOR_END}"
  } >&2
}

RV_HOME_DIR="${HOME}"

# This file lives under bash/, so go one directory up to the repo root.
RV_SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

# OS detection
rv.this_os() {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    rv.info "Prints detected OS: Darwin/Linux/Windows/Unknown"
    return 0
  fi
  local sys
  sys="$(uname -s 2>/dev/null || echo Unknown)"
  case "$sys" in
  Darwin) echo "Darwin" ;;
  Linux) echo "Linux" ;;
  MINGW* | MSYS* | CYGWIN* | Windows_NT) echo "Windows" ;;
  *) echo "Unknown" ;;
  esac
}

# Choose a value based on OS
# Usage: os_pick "windows_val" "darwin_val" "linux_val" "other_val"
rv.os_pick() {
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    rv.info "Usage: rv.os_pick <windows_val> <darwin_val> <linux_val> [other_val]"
    return 0
  fi
  local windows="$1" darwin="$2" linux="$3" other="$4" os sel
  os="$(rv.this_os)"
  case "$os" in
  Windows) sel="$windows" ;;
  Darwin) sel="$darwin" ;;
  Linux) sel="$linux" ;;
  *) sel="$other" ;;
  esac
  if [[ -n "$sel" ]]; then
    printf "%s\n" "$sel"
  else
    printf "System %s not supported.\n" "$os" >&2
    return 1
  fi
}

# Check if a program or path exists
rv.has() {
  # Usage: rv.has prog_or_path
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    rv.info "Usage: rv.has <program-or-path>"
    return 0
  fi
  local target="$1"
  if command -v -- "$target" >/dev/null 2>&1; then
    return 0
  fi
  [[ -e "$target" ]]
}

# Compute SHA-256 of a file (portable across macOS/Linux)
rv.sha256() {
  # Usage: rv.sha256 <file>
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    rv.info "Usage: rv.sha256 <file> (prints SHA-256 hash)"; return 0; fi
  local file="${1:-}"
  if [[ -z "$file" || ! -f "$file" ]]; then rv.error "rv.sha256: file not found: $file"; return 2; fi
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$file" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | awk '{print $1}'
  else
    rv.error "Neither sha256sum nor shasum is available"; return 127
  fi
}

# Verify SHA-256
rv.verify_sha256() {
  # Usage: rv.verify_sha256 <file> <expected_sha256>
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    rv.info "Usage: rv.verify_sha256 <file> <expected_sha256>"; return 0; fi
  local file="${1:-}" expected="${2:-}" actual
  if [[ -z "$file" || -z "$expected" ]]; then rv.error "rv.verify_sha256 requires <file> and <expected>"; return 2; fi
  actual="$(rv.sha256 "$file")" || return $?
  if [[ "${actual,,}" == "${expected,,}" ]]; then
    rv.okay "SHA-256 verified: $actual"
    return 0
  else
    rv.error "SHA-256 mismatch: got $actual expected $expected"
    return 1
  fi
}

# Download a URL to a destination
rv.download() {
  # Usage: rv.download <url> <out_path>
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    rv.info "Usage: rv.download <url> <out_path>"; return 0; fi
  local url="${1:-}" out="${2:-}"
  if [[ -z "$url" || -z "$out" ]]; then rv.error "rv.download requires <url> and <out_path>"; return 2; fi
  rv.run "curl -fsSL --retry 3 --retry-delay 1 -o \"$out\" \"$url\""
}

# Run a command string with logging
rv.run() {
  # Usage: rv.run "command args..."
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    rv.info "Usage: rv.run \"cmd args...\" (strict mode in subshell)"
    return 0
  fi
  local cmd="$*"
  rv.info "🏃 $cmd"
  (
    # Strict mode confined to this subshell
    set -euo pipefail
    # Use eval to honor quoting within the provided string
    eval "$cmd"
  )
}

# Add a suffix to a file path's basename
rv.add_suffix() {
  # Usage: rv.add_suffix "/path/to/file" ".bk"
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    rv.info "Usage: rv.add_suffix <path> <suffix> (prints path with suffix)"
    return 0
  fi
  local path="$1" suffix="$2"
  local dir base
  dir="$(dirname -- "$path")"
  base="$(basename -- "$path")"
  printf "%s/%s%s\n" "$dir" "$base" "$suffix"
}

# Create a symlink, backing up existing targets
rv.link() {
  # Usage: rv.link [--backup-suffix SFX] [--sudo|--no-sudo] <src_rel_to_repo> <dst_path>
  # Flags: --backup-suffix SUFFIX, --sudo, --no-sudo
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    rv.info "Usage: rv.link [--backup-suffix SFX] [--sudo|--no-sudo] <src_rel_to_repo> <dst_path>"
    return 0
  fi
  local backup_suffix=".bk" sudo_flag="false" args=()
  while (($#)); do
    case "$1" in
    --backup-suffix)
      backup_suffix="${2:?}"
      shift 2
      ;;
    --sudo)
      sudo_flag="true"
      shift
      ;;
    --no-sudo)
      sudo_flag="false"
      shift
      ;;
    --)
      shift
      break
      ;;
    -h | --help)
      rv.link --help
      return 0
      ;;
    -*)
      rv.error "Unknown flag: $1"
      return 2
      ;;
    *)
      args+=("$1")
      shift
      ;;
    esac
  done
  set -- "${args[@]}" "$@"
  local src_rel="${1:-}" dst_path="${2:-}"
  if [[ -z "$src_rel" || -z "$dst_path" ]]; then
    rv.error "rv.link requires <src_rel> and <dst_path>"
    return 2
  fi
  local dst_dir src_abs mv_to prefix=""

  dst_dir="$(dirname -- "$dst_path")"
  src_abs="${RV_SCRIPT_DIR%/}/$src_rel"

  # If an existing symlink points to the same target, do nothing
  if [[ -L "$dst_path" ]]; then
    current_target="$(readlink "$dst_path" 2>/dev/null || true)"
    if [[ "$current_target" == "$src_abs" || "$current_target" == "$src_rel" || "$current_target" == *"$src_rel" ]]; then
      rv.okay "Already linked: $dst_path -> $current_target"
      return 0
    fi
  fi

  if rv.has "$dst_path"; then
    mv_to="$(rv.add_suffix "$dst_path" "$backup_suffix")"
    rv.run "mv -f -- \"$dst_path\" \"$mv_to\""
  elif [[ ! -d "$dst_dir" ]]; then
    rv.run "mkdir -p -- \"$dst_dir\""
  fi

  if [[ "$sudo_flag" == "true" || "$sudo_flag" == "sudo" ]]; then
    prefix="sudo "
  fi

  rv.run "${prefix}ln -s \"$src_abs\" \"$dst_path\""
  rv.okay "Created link:"
  rv.okay "$(ls -ld "$dst_path")"
}

# Link a path from repo root to the user's HOME, preserving subdirs
rv.link_to_home() {
  # Usage: rv.link_to_home [--backup-suffix SFX] <rel_path_from_repo_root>
  # Flags: --backup-suffix SUFFIX
  if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
    rv.info "Usage: rv.link_to_home [--backup-suffix SFX] <rel_path_from_repo_root>"
    return 0
  fi
  local backup_suffix=".bk" rel=""
  while (($#)); do
    case "$1" in
    --backup-suffix)
      backup_suffix="${2:?}"
      shift 2
      ;;
    -h | --help)
      rv.link_to_home --help
      return 0
      ;;
    --)
      shift
      break
      ;;
    -*)
      rv.error "Unknown flag: $1"
      return 2
      ;;
    *)
      rel="$1"
      shift
      ;;
    esac
  done
  if [[ -z "$rel" ]]; then
    rv.error "rv.link_to_home requires <rel_path>"
    return 2
  fi
  local dst_path
  dst_path="${RV_HOME_DIR%/}/$rel"
  rv.link --backup-suffix "$backup_suffix" "$rel" "$dst_path"
}
