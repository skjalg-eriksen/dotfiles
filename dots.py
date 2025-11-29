#!/usr/bin/env python3

from argparse import ArgumentParser
from curses import A_REVERSE, KEY_DOWN, KEY_UP, curs_set, window, wrapper
from enum import IntEnum
from os import walk
from pathlib import Path
from re import Pattern
from re import compile as re_compile
from sys import argv
from typing import Iterator, List, Tuple

# dots.py
# dots -> tui with interactive checklist, [q] to quit, [enter] to toggle config, [/] to fuzzy search
# dots --list -> lists active configs
# dots --enable <name>
# dots --disable <name>

HOME = Path.home()
DOTFILES = Path(__file__).resolve().parent
IGNORE = DOTFILES / ".dotsignore"
CONFIG_DIR = DOTFILES / ".config"

# .dotsignore
IGNORE_PATTERNS: List[Pattern] = []


def load_ignore() -> List[Pattern]:
    """READS .dotsignore into global IGNORE_PATTERNS variable"""
    if IGNORE.exists() and len(IGNORE_PATTERNS) == 0:
        for line in IGNORE.read_text().splitlines():
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            IGNORE_PATTERNS.append(re_compile(line))
    return IGNORE_PATTERNS


def is_ignored(path: str):
    return any(regex.search(path) for regex in load_ignore())


def is_enabled(source_root: Path) -> bool:
    target = HOME / source_root.relative_to(DOTFILES)
    return target.is_symlink() and target.resolve() == source_root.resolve()


def itr_dotfiles() -> Iterator[Tuple[bool, Path]]:
    """
    Discover and return all available configuration modules.

    Returns
    -------
    List[(bool, Path)]
        A list of tuples with enabled/disabled and relative
        paths inside the .dotfiles directory that represent
        individual configuration modules.

    Notes
    -----
    - `.config/<module>/` directories are treated as folder-level modules and
      will be symlinked as whole directories.
    - All other files in modules are treated as file-level links.
    - Any paths listed in `.ignore` should be excluded from the result.
    """

    for root, _, files in walk(DOTFILES, topdown=True):
        if is_ignored(root):
            continue
        root_path = Path(root)

        # handle .config modules as dir symlinks
        if root_path.parent == CONFIG_DIR:
            yield (is_enabled(root_path), root_path)

        # otherwise skip .config
        if root_path.is_relative_to(CONFIG_DIR):
            continue

        # handle normal files
        for f in files:
            if is_ignored(f):
                continue

            file_path = root / Path(f)
            yield (is_enabled(file_path), file_path)


def disable(relative_path: str):
    """
    Disable (uninstall) a configuration module by removing its symlinks.

    Parameters
    ----------
    relative_path : str
        The module's path relative to the .dotfiles directory.

    Behavior
    --------
    - Removes symlinks previously created for this module under $HOME.
    - Restores any corresponding `{path}.bak` files if they exist.
    - Cleans up empty directories left after removing symlinks.
    """
    source_root = DOTFILES / Path(relative_path)
    assert source_root.exists(), "config not found"

    target = HOME / source_root.relative_to(DOTFILES)
    if not is_enabled(source_root):
        print("config not enabled")
        return
    assert target.is_symlink, "an enabled config must be a symlink"

    target.unlink()
    target_bak = target.with_suffix(".bak")

    if target_bak.exists():
        target_bak.rename(target)


def enable(relative_path: str):
    """
    Activate (install) a configuration module by creating symlinks in $HOME.

    Parameters
    ----------
    relative_path : str
        The module's path relative to the .dotfiles directory.

    Behavior
    --------
    - If a target file already exists in $HOME, it is renamed to `{path}.bak`.
    - A symlink is created from the dotfiles module to the corresponding
      location in $HOME.
    - Directory-level linking is performed only for `.config/<module>/`,
      all other files are linked individually.
    """
    source_root = DOTFILES / Path(relative_path)
    assert source_root.exists(), "config not found"

    target = HOME / source_root.relative_to(DOTFILES)

    if is_enabled(source_root):
        print(f"config {relative_path} is already enabled")
        return

    if is_ignored(str(source_root.relative_to(DOTFILES))):
        print(f"confing {relative_path} is in .dotsignore")
        return

    if target.exists():
        target_bak = target.with_suffix(".bak")
        assert (
            not target_bak.exists()
        ), "Cant backup file as .bak suffixed file already exists"
        target.rename(target_bak)

    target.symlink_to(source_root)


class Key(IntEnum):
    q = ord("q")
    Q = ord("Q")
    k = ord("k")
    j = ord("j")
    SLASH = ord("/")

    ENTER = 10
    ENTER2 = 13

    # curses navigation
    UP = KEY_UP
    DOWN = KEY_DOWN


def tui(std: window):
    curs_set(0)

    slash_search: Pattern | None = None
    selected = 0

    while True:
        std.clear()
        std.addstr(0, 0, " Toggle dotfiles (Enter = toggle, q = quit)")

        configs = [
            (enabled, path)
            for enabled, path in itr_dotfiles()
            if slash_search is None or slash_search.search(str(path)) is not None
        ]
        configs = sorted(configs)

        # Clamp selection if list shrinks
        if selected >= len(configs):
            selected = max(0, len(configs) - 1)

        for idx, (enabled, path) in enumerate(configs):
            name = str(path.relative_to(DOTFILES))
            status = "[X]" if enabled else "[ ]"

            if idx == selected:
                std.addstr(idx + 2, 0, f"> {status} {name}", A_REVERSE)
            else:
                std.addstr(idx + 2, 0, f"  {status} {name}")

        key = std.getch()

        match key:
            case Key.UP | Key.k:
                if configs:
                    selected = (selected - 1) % len(configs)

            case Key.DOWN | Key.j:
                if configs:
                    selected = (selected + 1) % len(configs)

            case Key.ENTER | Key.ENTER2:
                if configs:
                    enabled, path = configs[selected]
                    if enabled:
                        disable(str(path))
                    else:
                        enable(str(path))

            case Key.SLASH:
                # todo implement search/filter
                pass

            case Key.q | Key.Q:
                return
            case _:
                pass


def main():
    if len(argv) == 1:
        wrapper(tui)
        return

    parser = ArgumentParser()

    parser.add_argument(
        "--list", action="store_true", help="Lists configs and their status"
    )
    parser.add_argument(
        "--enable", metavar="NAME", help="Enable (creates symlink in the system)"
    )
    parser.add_argument(
        "--disable", metavar="NAME", help="Disable (removes symlink in the system)"
    )

    args = parser.parse_args()

    if args.list:
        for enabled, path in itr_dotfiles():
            status = "[X]" if enabled else "[ ]"
            print(f"{status}\t{path.relative_to(DOTFILES)}")
        return

    if args.enable:
        enable(args.enable)
        return

    if args.disable:
        disable(args.disable)
        return


if __name__ == "__main__":
    main()
