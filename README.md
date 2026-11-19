# DISTROVANTA

![Uploading image.png…]()

## Universal Linux Terminal Customizer

DISTROVANTA is a modular, multi-distribution Linux terminal customization tool.
It provides a centralized, interactive interface to personalize your terminal
environment without manually editing multiple configuration files.

It is **not** a security, intrusion, or vulnerability tool. Its purpose is
exclusively the personalization of terminal environments.

---

## Table of Contents

1. [Overview](#overview)
2. [Features](#features)
3. [Supported Environments](#supported-environments)
4. [Requirements](#requirements)
5. [Installation](#installation)
6. [Usage](#usage)
7. [Main Menu](#main-menu)
8. [Configuration](#configuration)
9. [Backup and Restore](#backup-and-restore)
10. [Security](#security)
11. [Troubleshooting](#troubleshooting)
12. [Project Structure](#project-structure)
13. [License](#license)
14. [Credits and Attribution](#credits-and-attribution)

---

## Overview

DISTROVANTA lets you customize:

- Terminal prompt (visual name, environment/host name, color, separator, directory).
- Startup panels (title, subtitle, welcome message, color).
- Themes and colors.
- Custom banners.
- Welcome messages.
- System information displayed on startup.
- Saved configurations.
- Backups and restoration of previous settings.

All changes are applied inside clearly marked managed blocks in your shell
configuration files (e.g. `~/.bashrc`), so they can be safely removed later.

---

## Features

- Interactive numeric menu with descriptions and compatibility notes.
- Dynamic banner centering based on terminal width (works on phones, Termux,
  small monitors, and large terminals).
- Automatic detection of distribution, version, architecture, shell, terminal,
  dependencies, and Termux/Android.
- Visual-only prompt customization (never changes real user or hostname).
- Custom startup panels.
- Theme presets and individual color selection.
- Custom banners with color.
- Welcome message configuration.
- System information display on startup.
- Configuration manager (view, reset, export, import).
- Backup manager (create, list, remove).
- Restore options (strip managed blocks, full restore from backup, restore all).
- About developer, social media, and about tool sections.
- No-color fallback for terminals without color support.

---

## Supported Environments

### Distributions (planned/targeted)

| Distribution | Status |
|---|---|
| Debian | Supported (Bash) |
| Ubuntu | Supported (Bash) |
| Linux Mint | Supported (Bash) |
| Kali Linux | Supported (Bash) |
| Parrot OS | Supported (Bash) |
| Fedora | Supported (Bash) |
| Arch Linux | Supported (Bash) |
| Manjaro | Supported (Bash) |
| Alpine Linux | Partial (busybox) |
| Termux (Android) | Detected; Bash features available if Bash is installed |

Compatibility statuses are planned/targeted. Always verify in your environment.

### Shells

- **Bash:** full support.
- **Zsh / Fish:** detected but not modified; limited/partial features.
- **Other shells:** detection only.

DISTROVANTA never modifies configurations of unsupported shells.

---

## Requirements

Required:
- Bash (for full features)
- `printf`, `awk`, `sed`, `grep`, `uname`, `id`

Optional:
- `tput`, `mktemp`, `cp`, `mv`

No root privileges are required for common user personalization.

---

## Installation

### Standard

```sh
git clone https://github.com/brianlewis-png/distrovanta-universal-linux-terminal-customizer.git
cd distrovanta-universal-linux-terminal-customizer
chmod +x distrovanta.sh install.sh
./install.sh
./distrovanta.sh
```

### Termux (Android)

```sh
pkg install bash coreutils
git clone https://github.com/brianlewis-png/distrovanta-universal-linux-terminal-customizer.git
cd distrovanta-universal-linux-terminal-customizer
chmod +x distrovanta.sh
./distrovanta.sh
```

### No-color mode

```sh
./distrovanta.sh --no-color
```

### Uninstall

Remove the symlink (if created) and delete the project directory. Review
`~/.distrovanta` (backups) before removing it.

---

## Usage

Run:

```sh
./distrovanta.sh
```

Navigate by typing the number of the desired option and pressing Enter.

### Example: customize the prompt

1. Run `./distrovanta.sh`.
2. Choose `02` (Customize Terminal Prompt).
3. Set visual name (e.g. `sombra`).
4. Set environment name (e.g. `terror`).
5. Choose color (e.g. `blue`).
6. Set separator (e.g. `@`).
7. Choose `6` to apply to `~/.bashrc`.
8. Open a new terminal or run `source ~/.bashrc`.

The prompt changes only visually; your real username and hostname are never
modified.

---

## Main Menu

| # | Option | Description |
|---|---|---|
| 01 | Create Terminal Panel | Create a custom startup panel |
| 02 | Customize Terminal Prompt | Customize visual user/environment identification |
| 03 | Themes & Colors | Configure colors and themes |
| 04 | Custom Banner | Create and configure banners |
| 05 | Welcome Message | Configure welcome messages |
| 06 | System Information | Configure info shown in terminal |
| 07 | Configuration Manager | Manage saved configurations |
| 08 | Backup Manager | Create and manage backups |
| 09 | Restore Default Settings | Restore previous configurations |
| 10 | About The Developer | Information about the creator |
| 11 | Social Media | Social networks and projects |
| 12 | About DISTROVANTA | Information about the tool |
| 00 | Exit | Exit the tool |

Each option shows number, name, objective description, compatibility, and
success/error messages.

---

## Configuration

Settings are stored in `config/settings.conf` (key=value format). The state
directory is `~/.distrovanta` (backups, logs).

Configuration Manager allows you to:
- View current settings.
- Reset settings to defaults.
- Export settings to a file.
- Import settings from a file.

---

## Backup and Restore

Before modifying any file, DISTROVANTA:
1. Checks that the file exists.
2. Reads current configuration.
3. Creates a backup.
4. Records the previous state.
5. Applies the change.
6. Verifies the result.

Backups are stored in `~/.distrovanta/backups/` with a manifest log.

Restore options:
- Remove DISTROVANTA managed blocks from `~/.bashrc` (safe).
- Restore `~/.bashrc` from latest backup (full).
- Restore a specific file from backup.
- Restore all managed files.

DISTROVANTA never deletes entire configuration files just to remove
customizations; it only removes its own marked blocks.

---

## Security

- No execution of user input as code.
- No `eval` of configurations.
- No modification of files outside authorized areas.
- No root required for common personalization.
- No silent changes.
- No personal data collection.
- No external data transmission.
- No overwrite without backup.
- Input validation and safe path handling.

---

## Troubleshooting

- **Full features require Bash:** install/use Bash. Other shells are detected
  but not modified.
- **Missing dependencies:** install required tools (`awk`, `sed`, `grep`, etc.).
- **No colors:** use `--no-color` or set `NO_COLOR=1`.
- **Terminal width issues:** ensure `COLUMNS` or `tput` works; fallback is 80.
- **Restore after problems:** use option `09` or remove managed blocks manually
  between `# >>> DISTROVANTA BEGIN >>>` and `# <<< DISTROVANTA END <<<`.

---

## Project Structure

```
distrovanta/
├── distrovanta.sh
├── install.sh
├── README.md
├── LICENSE
├── SECURITY.md
├── CHANGELOG.md
├── ATTRIBUTION.md
├── core/
│   ├── detection.sh
│   ├── interface.sh
│   ├── backup.sh
│   └── restore.sh
├── modules/
│   ├── panel.sh
│   ├── prompt.sh
│   ├── themes.sh
│   ├── banner.sh
│   ├── welcome.sh
│   ├── system-info.sh
│   ├── config-manager.sh
│   ├── backup-manager.sh
│   ├── restore-menu.sh
│   ├── about-developer.sh
│   └── social.sh
├── config/
│   └── settings.conf
├── docs/
│   ├── INSTALLATION.md
│   ├── USAGE.md
│   ├── POLICIES.md
│   └── COMPATIBILITY.md
└── tests/
```

---

## License

This project is licensed under the **GNU General Public License v3.0 (GPL-3.0)**.
See `LICENSE` for the full text.

## Credits and Attribution

- **Original creator:** Brian Lewis
- **Partner:** BRJ Dev
- **Official GitHub:** https://github.com/brianlewis-png
- **Official Website:** https://brianlewisdev.netlify.app
- **LinkedIn:** https://linkedin.com/in/brian-lewis-4ba63739a
- **Telegram:** https://t.me/brianlewisdev
- **Instagram:** https://www.instagram.com/Brian_lewis_2
- **X (Twitter):** https://x.com/brianlewisdev
- **YouTube:** https://www.youtube.com/@brianlewisdeveloper

Redistribution and modification are allowed under GPL-3.0, provided original
copyright and attribution notices are preserved. See `ATTRIBUTION.md`.
