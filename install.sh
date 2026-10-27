#!/usr/bin/env bash
set -euo pipefail

# Update these together from https://github.com/neovim/neovim/releases.
readonly NVIM_VERSION="0.12.0"
readonly NVIM_ARM64_SHA256="89024e7be2ef3c8f08e9c002b1eb3e3b36672ee44bd6343cf2d168d38b3736b2"
readonly NVIM_X86_64_SHA256="160b69125defb16e60b283b69be112fd4850d67ac8f9a752328c20ad43ec34af"
readonly TREE_SITTER_CLI_VERSION="0.27.1"

version_at_least() {
  [[ "$(printf '%s\n' "$1" "$2" | sort --version-sort | head --lines=1)" == "$2" ]]
}

case "$(uname --machine)" in
  aarch64)
    readonly NVIM_ARCHIVE="nvim-linux-arm64.tar.gz"
    readonly NVIM_SHA256="${NVIM_ARM64_SHA256}"
    ;;
  x86_64)
    readonly NVIM_ARCHIVE="nvim-linux-x86_64.tar.gz"
    readonly NVIM_SHA256="${NVIM_X86_64_SHA256}"
    ;;
  *)
    echo "Unsupported architecture for Neovim: $(uname --machine)" >&2
    exit 1
    ;;
esac

readonly NVIM_DOWNLOAD="https://github.com/neovim/neovim/releases/download/v${NVIM_VERSION}/${NVIM_ARCHIVE}"

installed_version=""
if command -v nvim >/dev/null 2>&1; then
  installed_version="$(nvim --version | sed --quiet --regexp-extended '1s/^NVIM v([0-9.]+)$/\1/p')"
fi

if [[ -z "${installed_version}" ]] || ! version_at_least "${installed_version}" "${NVIM_VERSION}"; then
  readonly NVIM_DIRECTORY="/opt/${NVIM_ARCHIVE%.tar.gz}"
  archive="$(mktemp)"
  trap 'rm --force "${archive}"' EXIT

  curl --fail --location --silent --show-error --output "${archive}" "${NVIM_DOWNLOAD}"
  printf '%s  %s\n' "${NVIM_SHA256}" "${archive}" | sha256sum --check

  if [[ "${EUID}" -eq 0 ]]; then
    tar --extract --gzip --file "${archive}" --directory /opt
    ln --symbolic --force "${NVIM_DIRECTORY}/bin/nvim" /usr/local/bin/nvim
  elif command -v sudo >/dev/null 2>&1; then
    sudo tar --extract --gzip --file "${archive}" --directory /opt
    sudo ln --symbolic --force "${NVIM_DIRECTORY}/bin/nvim" /usr/local/bin/nvim
  else
    echo "Neovim ${NVIM_VERSION} requires root access to install." >&2
    exit 1
  fi
fi

if ! command -v npm >/dev/null 2>&1; then
  echo "npm is required to install tree-sitter-cli." >&2
  exit 1
fi

installed_tree_sitter_version=""
if command -v tree-sitter >/dev/null 2>&1; then
  installed_tree_sitter_version="$(tree-sitter --version | sed --quiet --regexp-extended '1s/^[^0-9]*([0-9.]+).*$/\1/p')"
fi

if [[ "${installed_tree_sitter_version}" != "${TREE_SITTER_CLI_VERSION}" ]]; then
  if [[ "${EUID}" -eq 0 ]]; then
    npm install --global "tree-sitter-cli@${TREE_SITTER_CLI_VERSION}"
  elif command -v sudo >/dev/null 2>&1; then
    sudo npm install --global "tree-sitter-cli@${TREE_SITTER_CLI_VERSION}"
  else
    echo "tree-sitter-cli ${TREE_SITTER_CLI_VERSION} requires root access to install." >&2
    exit 1
  fi
fi

./dots.py --enable .config/nvim
