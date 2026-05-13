# Dotfiles

A minimal and simple dotfile manager written in Python.

It handles:

- **Symlink-based dotfiles**
- **Automatic backups** (`file → file.bak`)
- **Directory-level installs for `.config/*`**
- **Built-in ignore rules**
- **Enable/disable commands**
- **Optional TUI selector**

This project is intentionally lightweight — no external dependencies except Python.

---

# 🚀 Installation

From inside the dotfiles repository, symlink `dots.py` using its **absolute path**:

```sh
ln -s "$(pwd)/dots.py" ~/.local/bin/dots
```

Ensure `~/.local/bin` is in your `$PATH`.

---

# 🛠️ Usage

## 📋 List all configurations

```sh
dots --list
```

Example:

```
[X]   .tmux.conf
[ ]  .zshrc
[X]   .config/nvim
```

---

## ➕ Enable a configuration

```sh
dots --enable .tmux.conf
```

This will:  
- back up any existing file in your home directory  
- create the symlink to the config inside your dotfile repo  

---

## ➖ Disable a configuration

```sh
dots --disable .tmux.conf
```

This will:  
- remove the symlink  
- restore any `*.bak` backup file  

---

## 🎛️ TUI Mode

Running `dots` with **no arguments** launches the interactive TUI:

```sh
dots
```

TUI features:

- interactive checklist  
- toggle with `<enter>`, `<space>`
- regex filter with `/` or `:`  
- finish filtering with `<enter>` or `<esc>`
- invalid regex stays visible without crashing the TUI
- quit with `q`

---

# 📁 How Dotfiles Are Detected

The tool walks the repository and treats paths as configuration items.

### Directory-level configs

Directory-level configs are defined in `DIR_MODULES` at the top of `dots.py`

```
# list of paths that will be symlinked as modules
DIR_MODULES = [".config/*", ".emacs.d"]
```

are installed as **directory symlinks**, e.g.:

```
~/.config/nvim → <repo>/.config/nvim
```

### File-level configs

Everything else is installed as individual file symlinks, e.g.:

```
<repo>/.tmux.conf → ~/.tmux.conf
```

---

# 🚫 Ignored paths

The scanner skips a paths defined in `IGNORE_RULES` at the top of `dots.py`.

```
# list of ignored paths
IGNORE_RULES = [".git", ".gitignore", "README.md", "dots.py"]
```

---

# 🔍 Enabled/Disabled Detection

A configuration is considered **enabled** when:

- a symlink exists at the expected location in your home directory, **and**
- that symlink resolves back to the correct file inside the repository

The filesystem is the single source of truth; no cache file is required.

---
