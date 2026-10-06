# dotfiles

Kára's configuration files, used on Arch Linux (EndeavourOS, i3) and Ubuntu.

## Install

```sh
git clone git@github.com:karasibille/dotfiles.git ~/Projects/github.com/karasibille/dotfiles
cd ~/Projects/github.com/karasibille/dotfiles
./install.sh --dry-run   # check what will change
./install.sh
```

`install.sh` symlinks each config into `$HOME` / `~/.config`, only for the
programs installed on the machine. It can be run again at any time: existing
files are moved to `<name>.bak.<date>`, never overwritten.

## Color themes

```sh
theme          # pick a theme (rofi, also bound to $mod+Shift+t in i3)
theme laser    # switch directly
theme --list
```

Each theme is a single X resources file in `xrdb/colors/`. `theme` generates
the color files of kitty, alacritty, rofi, dunst and polybar from it
(`*.generated*`, not versioned), points `xrdb/current` to it and reloads the
running programs; i3 reads the colors from xrdb.

To add a theme, copy `xrdb/colors/nord` and change the colors: `background`,
`foreground` and `color0`–`color15` are required, the `theme.*` roles
(accent, bar colors…) are optional and listed in `bin/theme`.

## Machine-specific settings

These files are sourced when present and are not versioned:

| File                        | For                                   |
|-----------------------------|---------------------------------------|
| `~/.profile.local`          | environment variables, extra `PATH`   |
| `~/.zshrc.local`            | zsh settings, aliases                 |
| `~/.config/aliases/secrets/`| aliases containing tokens or passwords|

`PA_CARD` sets the sound card used by the polybar `pa-switch` module
(`pactl list cards short`).

## Content

| Directory     | Program                                   |
|---------------|-------------------------------------------|
| `zshrc`, `aliases/` | zsh + [antigen](https://github.com/zsh-users/antigen) / oh-my-zsh |
| `profile`     | login environment                         |
| `i3/`         | i3 window manager                         |
| `polybar/`    | status bar                                |
| `rofi/`       | launcher                                  |
| `dunst/`      | notifications                             |
| `kitty/`, `alacritty/` | terminals                        |
| `xrdb/`, `Xresources` | Nord and Laser color themes       |
| `redshift/`, `ranger/`, `fontconfig/`, `npmrc` | misc     |
