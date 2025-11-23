# Dotfiles

A minimal, simple, deterministic dotfile manager written in Python.

It handles:

- **Symlink-based dotfiles**
- **Automatic backups** (`file → file.bak`)
- **Directory-level installs for `.config/*`**
- **Regex-based `.dotsignore`**
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
[ENABLED]   .tmux.conf
[DISABLED]  .zshrc
[ENABLED]   .config/nvim
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
- toggle with `<enter>`  
- search with `/`  
- quit with `q`

---

# 📁 How Dotfiles Are Detected

The tool walks the repository and treats paths as configuration items.

### Folder-level configs

Directories under:

```
./.config/*
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

# 🚫 Ignoring files: `.dotsignore`

Place a `.dotsignore` file in the repository containing **regex patterns**, one per line.

Example:

```
# ignore the manager itself
dots.py
\.dotsignore

# ignore custom private files
private/.*
```

Paths matching any pattern are skipped during scanning.

---

# 🔍 Enabled/Disabled Detection

A configuration is considered **enabled** when:

- a symlink exists at the expected location in your home directory, **and**
- that symlink resolves back to the correct file inside the repository

The filesystem is the single source of truth; no cache file is required.

---
