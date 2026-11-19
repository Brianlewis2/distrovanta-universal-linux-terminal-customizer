# Installation

## Requirements

- Bash (full features)
- POSIX tools: printf, awk, sed, grep, uname, id
- Optional: tput, mktemp, cp, mv

## Steps

1. Extract project.
2. `cd distrovanta`
3. `chmod +x distrovanta.sh install.sh`
4. Run `./install.sh` (optional).
5. Run `./distrovanta.sh`.

## Termux

Install bash and coreutils if needed:
`pkg install bash coreutils`

## No root required

Common user customization does not require root.

## Uninstall

Remove symlink if created and delete project/state dir `~/.distrovanta` (backups included - review first).