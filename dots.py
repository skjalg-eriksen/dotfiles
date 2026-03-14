#!/usr/bin/env python3

from argparse import ArgumentParser
from curses import (
    A_REVERSE,
    KEY_BACKSPACE,
    KEY_DOWN,
    KEY_UP,
    curs_set,
    window as Window,
    wrapper,
)
from enum import IntEnum
from os import walk
from pathlib import Path
from re import Pattern
from re import compile as re_compile, escape as re_escape
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


def compile_segment_pattern(raw: str) -> Pattern:
    # Escape user input, then match only whole path segments
    escaped = re_escape(raw)
    # Allow match at start or after a slash, and end or before a slash
    regex = rf"(?:^|/){escaped}(?:/|$)"
    return re_compile(regex)


def load_ignore() -> List[Pattern]:
    """READS .dotsignore into global IGNORE_PATTERNS variable"""
    if IGNORE.exists() and len(IGNORE_PATTERNS) == 0:
        for line in IGNORE.read_text().splitlines():
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            IGNORE_PATTERNS.append(compile_segment_pattern(line))
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

    target = HOME / source_root.relative_to(DOTFILES)

    if is_enabled(source_root):
        print(f"config {relative_path} is already enabled")
        return

    if is_ignored(str(source_root.relative_to(DOTFILES))):
        print(f"confing {relative_path} is in .dotsignore")
        return

    if target.exists():
        target_bak = target.with_suffix(".bak")
        assert not target_bak.exists(), (
            "Cant backup file as .bak suffixed file already exists"
        )
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

    for idx, (enabled, path) in enumerate(configs):
        name = str(path.relative_to(DOTFILES))
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
    curs_set(0)  # no cursor

    slash_search: Pattern | None = None
    selected = 0
    selected_before_slash = 0
    filter_mode = -1

    while True:
        height, _ = window.getmaxyx()
        window.addstr(0, 0, " Toggle dotfiles (Enter = toggle, q = quit, / = filter)")

        configs = tui_render_selection(window, selected, slash_search)

        key = window.getch()

        # exit filter mode
        if selected == filter_mode and key in (Key.ENTER, Key.ENTER2, Key.ESC):
            selected = selected_before_slash
            key = 0

        configs = tui_render_selection(window, selected, slash_search)

        # filter mode
        if selected == filter_mode and is_valid_pattern_key:
            current = str(slash_search.pattern) if slash_search is not None else ""
            if is_backspace_key(key):
                current = current[:-1]
                slash_search = re_compile(current)
            else:
                slash_search = re_compile(
                    current + chr(key)
                )  # compile pattern with re module

        window.move(height - 1, 0)
        window.clrtoeol()
        if slash_search is not None:
            block = "█" if selected == filter_mode else ""
            try:
                window.addstr(
                    height - 1, 0, f":{slash_search.pattern}{block}"
                )  # display filter
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
                current = slash_search.pattern if slash_search is not None else ""
                window.addstr(height - 1, 0, f":{current}█")  # display filter
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

    args = parser.parse_args()

    if args.list:
        for enabled, path in itr_dotfiles():
            status = "[X]" if enabled else "[ ]"
            print(f"\t{status} {path.relative_to(DOTFILES)}")
        return

    if args.enable:
        enable(args.enable)
        return

    if args.disable:
        disable(args.disable)
        return


if __name__ == "__main__":
    main()
