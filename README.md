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

From inside the dotfiles repository, symlink the script:

```sh
ln -s ./dots.py ~/.local/bin/dots
```

Ensure `~/.local/bin` is in your `$PATH`.

---

# 🛠️ Usage

## 📋 List all configurations

```sh
dots --list
```

Example output:

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

Calling `dots` with **no arguments** launches the interactive TUI:

```sh
dots
```

The TUI supports:

- interactive checklist  
- toggle with `<enter>`  
- search with `/`  
- quit with `q`

---

# 📁 How Dotfiles Are Detected

The tool walks the repository and treats files as configuration items.

### Folder-level configs

Any directory inside:

```
./.config/*
```

is installed as a **directory symlink**, e.g.:

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

The file:

```
./.dotsignore
```

contains **regular expressions**, one per line.

Example:

```
# ignore tool metadata
dots.py
\.dotsignore

# ignore private patterns
private/.*
```

Any path matching any regex is skipped during scanning.

---

# 🔍 Enabled/Disabled Detection

A configuration is considered **enabled** if:

- a symlink exists at the expected location in your home directory  
- that symlink resolves back to the correct file inside the repository  

---
