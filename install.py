#!/usr/bin/env python3

import os
import shutil
from pathlib import Path

# Paths
HOME = Path.home()
DOTFILES = HOME / ".dotfiles"
CONFIG_DIR = DOTFILES / ".config"
HOME_CONFIG = HOME / ".config"

# Files/folders to ignore
IGNORED = {
    ".git", ".gitignore", "README.md", "install.py", "install.sh", "track.sh"
}

def backup_existing(path: Path):
    """If file or folder exists (and is not a symlink), back it up"""
    if path.exists() and not path.is_symlink():
        backup_path = path.with_suffix(".backup")
        print(f"📦 Backing up {path} → {backup_path}")
        shutil.move(str(path), str(backup_path))

def create_symlink(source: Path, target: Path):
    """Create symlink if it doesn't exist already"""
    if target.is_symlink():
        print(f"✅ Already linked: {target}")
        return

    backup_existing(target)

    target.parent.mkdir(parents=True, exist_ok=True)
    target.symlink_to(source)
    print(f"🔗 Linked: {source} → {target}")

def link_top_level_dotfiles():
    print("📁 Linking top-level dotfiles...")
    for item in DOTFILES.iterdir():
        name = item.name

        if name in IGNORED:
            print(f"⏭️  Ignored: {name}")
            continue

        # Skip .config — handled separately
        if item == CONFIG_DIR:
            continue

        target = HOME / name
        create_symlink(item, target)

def link_config_items():
    print("📁 Linking .config/ contents...")
    HOME_CONFIG.mkdir(exist_ok=True)

    for item in CONFIG_DIR.iterdir():
        target = HOME_CONFIG / item.name
        create_symlink(item, target)

def main():
    link_top_level_dotfiles()
    link_config_items()
    print("🎉 All done!")

if __name__ == "__main__":
    main()

