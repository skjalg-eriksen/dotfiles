#!/usr/bin/env python3
"""
dots.py - single file dot file management CLI/TUI

commands
dots -> TUI with interactive checklist, [q] to quit, [enter] or [space] to toggle config, [/] to fuzzy search
dots --list -> lists active configs
dots --enable <name>
dots --disable <name>
"""

# list of ignored paths
IGNORE_RULES = [".git", ".gitignore", "README.md", "dots.py", "__pycache__"]
# list of paths that will be symlinked as modules
DIR_MODULES = [".config/*", ".emacs.d"]

from argparse import ArgumentParser
from curses import (
    A_REVERSE,
    KEY_BACKSPACE,
    KEY_DOWN,
    KEY_UP,
    curs_set,
    error as curses_error,
    window as Window,
    wrapper,
)
from enum import IntEnum
from os import walk
from pathlib import Path
from re import Pattern, error as ReError
from re import compile as re_compile
from sys import argv
from typing import Iterator, List, Tuple

HOME = Path.home()
DOTFILES = Path(__file__).resolve().parent
def is_enabled(path: Path) -> bool:
    target = HOME / path 
    return target.is_symlink() and target.resolve() == path.resolve()


def is_ignored(path: Path):
    return any(path.match(ignore_rule) for ignore_rule in IGNORE_RULES)


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

    for root, dirs, files in walk(DOTFILES, topdown=True):
        relative_root = Path(root).relative_to(DOTFILES)

        # Prune ignored directories before descending into them.
        dirs[:] = [
            dirname
            for dirname in dirs
            if not is_ignored(relative_root / dirname)
        ]

        if relative_root != Path(".") and is_ignored(relative_root):
            dirs[:] = []
            continue

        # A matched directory module is emitted once and its descendants are skipped.
        if relative_root != Path(".") and any(
            relative_root.match(dir_module_rule) for dir_module_rule in DIR_MODULES
        ):
            yield (is_enabled(relative_root), relative_root)
            dirs[:] = []
            continue

        for raw_path in files:
            path = relative_root / raw_path
            if is_ignored(path):
                continue

            yield (is_enabled(path), path)


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

    relative_source = source_root.relative_to(DOTFILES)
    target = HOME / relative_source
    if not is_enabled(relative_source):
        print("config not enabled")
        return
    assert target.is_symlink(), "an enabled config must be a symlink"

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

    relative_source = source_root.relative_to(DOTFILES)
    target = HOME / relative_source

    if is_enabled(relative_source):
        print(f"config {relative_path} is already enabled")
        return

    if is_ignored(relative_source):
        print(f"confing {relative_path} is in IGNORE_LIST, edit dots.py")
        return

    if target.exists():
        target_bak = target.with_suffix(".bak")
        assert (
            not target_bak.exists()
        ), "Cant backup file as .bak suffixed file already exists"
        target.rename(target_bak)

    target.parent.mkdir(parents=True, exist_ok=True)
    target.symlink_to(source_root)


class Key(IntEnum):
    q = ord("q")
    Q = ord("Q")
    k = ord("k")
    j = ord("j")
    SLASH = ord("/")
    COLON = ord(":")
    ESC = 27
    ENTER = 10
    ENTER2 = 13
    SPACE = ord(" ")
    BACKSPACE = KEY_BACKSPACE
    BACKSPACE2 = 127
    BACKSPACE3 = 8
    # curses navigation
    UP = KEY_UP
    DOWN = KEY_DOWN


def tui_render_selection(
    window: Window, selected: int, slash_search: Pattern | None
) -> List[Tuple[bool, Path]]:
    configs = [
        (enabled, path)
        for enabled, path in itr_dotfiles()
        if slash_search is None or slash_search.search(str(path)) is not None
    ]
    configs.sort(key=lambda x: x[0])
    height, _ = window.getmaxyx()

    # clear line 1 to height - 2
    for y in range(1, height - 2):
        window.move(y, 0)
        window.clrtoeol()

    # Clamp selection if list shrinks
    if selected >= len(configs):
        selected = max(0, len(configs) - 1)

    max_rows = height - 3
    for idx, (enabled, path) in enumerate(configs[:max_rows]):
        name = str(path)
        status = "[X]" if enabled else "[ ]"

        if idx == selected:
            window.addstr(idx + 2, 0, f"> {status} {name}", A_REVERSE)
        else:
            window.addstr(idx + 2, 0, f"  {status} {name}")
    window.refresh()
    return configs


def is_backspace_key(key: int):
    return key in (Key.BACKSPACE, Key.BACKSPACE2, Key.BACKSPACE3)


def is_valid_pattern_key(key: int):
    if is_backspace_key(key):
        return True
    if key in (Key.UP, Key.DOWN):
        return False
    if 32 <= key <= 126:
        return True
    return False


def tui(window: Window):
    try:
        curs_set(0)  # no cursor
    except curses_error:
        pass

    slash_search: Pattern | None = None
    slash_search_text = ""
    selected = 0
    selected_before_slash = 0
    filter_mode = -1

    while True:
        height, _ = window.getmaxyx()
        window.addstr(0, 0, " Toggle dotfiles (Space, Enter = toggle, q = quit, / = filter)")

        configs = tui_render_selection(window, selected, slash_search)

        key = window.getch()

        # exit filter mode
        if selected == filter_mode and key in (Key.ENTER, Key.ENTER2, Key.ESC):
            selected = selected_before_slash
            key = 0

        configs = tui_render_selection(window, selected, slash_search)

        # filter mode
        if selected == filter_mode and is_valid_pattern_key(key):
            current = slash_search_text
            if is_backspace_key(key):
                current = current[:-1]
            else:
                current = current + chr(key)
            slash_search_text = current
            try:
                slash_search = re_compile(current) if current else None
            except ReError:
                # Keep the raw input visible while treating invalid regex as no filter.
                slash_search = None

        window.move(height - 1, 0)
        window.clrtoeol()
        if slash_search_text:
            block = "█" if selected == filter_mode else ""
            try:
                window.addstr(height - 1, 0, f"/{slash_search_text}{block}")
            except Exception:
                pass

        match key:
            case Key.UP | Key.k:
                if configs:
                    selected = (selected - 1) % len(configs)

            case Key.DOWN | Key.j:
                if configs:
                    selected = (selected + 1) % len(configs)

            case Key.ENTER | Key.ENTER2 | Key.SPACE:
                if selected < len(configs) and selected >= 0:
                    enabled, path = configs[selected]
                    if enabled:
                        disable(str(path))
                    else:
                        enable(str(path))

            case Key.SLASH | Key.COLON:
                current = slash_search_text
                window.addstr(height - 1, 0, f"/{current}█")  # display filter
                selected_before_slash = selected
                selected = filter_mode  # select none
                continue

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
    parser.add_argument(
        "--doctor",
        action="store_true",
        help="Validate .dots_rules.json",
    )

    args = parser.parse_args()

    if args.list:
        for enabled, path in itr_dotfiles():
            status = "[X]" if enabled else "[ ]"
            print(f"\t{status} {path}")
        return

    if args.enable:
        enable(args.enable)
        return

    if args.disable:
        disable(args.disable)
        return

    if args.doctor:
        print("validating...")
        return


if __name__ == "__main__":
    main()
