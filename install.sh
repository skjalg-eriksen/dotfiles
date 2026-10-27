#!/usr/bin/env bash
set -euo pipefail

if ! command -v nvim >/dev/null 2>&1; then
  if [[ "${EUID}" -eq 0 ]]; then
    apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get install --yes neovim
  elif command -v sudo >/dev/null 2>&1; then
    sudo apt-get update
    sudo DEBIAN_FRONTEND=noninteractive apt-get install --yes neovim
  else
    echo "Neovim is not installed and sudo is unavailable." >&2
    exit 1
  fi
fi

./dots.py --enable .config/nvim
