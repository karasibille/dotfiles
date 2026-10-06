# dotfiles

Kára's configuration files, used on Arch Linux (EndeavourOS, i3) and Ubuntu.

## Install

```sh
git clone git@github.com:karasibille/dotfiles.git ~/Projects/github.com/karasibille/dotfiles
cd ~/Projects/github.com/karasibille/dotfiles
./install.sh --packages --dry-run   # check what will change
./install.sh --packages             # install missing packages, then link
```

`--packages` installs what is missing from `packages.txt`, with pacman (and
yay or paru for the AUR) on Arch, or apt on Ubuntu. It lists what has to be
installed by hand: on Ubuntu, Source Code Pro, Font Awesome 7 (Ubuntu only
packages 4.7), the capitaine cursors and the Nordic GTK theme. Without
`--packages`, only the links are created.

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
running programs; i3 reads the colors from xrdb. The theme's GTK theme
(`theme.gtk`) is sent to running GTK applications through
[xsettingsd](https://github.com/derat/xsettingsd) when it is installed;
otherwise new applications use `gtk-3.0/settings.ini`.

`theme.wallpaper` sets the theme's wallpaper (e.g.
`theme.wallpaper: ~/Pictures/wallpapers/nord.png`); without it, or if the
image is missing, the background is the theme's background color. Wallpapers
are not versioned: copy them to each machine.

To add a theme, copy `xrdb/colors/nord` and change the colors: `background`,
`foreground` and `color0`–`color15` are required, the `theme.*` roles
(accent, bar colors…) are optional and listed in `bin/theme`.

## Screen lock

`$mod+l` runs `lock` (`bin/lock`): i3lock with a blurred, darkened copy of
the theme's wallpaper (cached in `~/.cache/lock`, built when the theme
changes and at i3 startup), or the theme's background color with a solid
background or without ImageMagick. `LOCK_WALLPAPER` sets another source image.

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
| `picom/`      | compositor                                |
| `gtk-3.0/`    | GTK 3 theme, icons, font                  |
| `xrdb/`, `Xresources` | Nord and Laser color themes       |
| `redshift/`, `ranger/`, `fontconfig/`, `npmrc` | misc     |
