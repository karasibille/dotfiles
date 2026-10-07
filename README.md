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

On Ubuntu, `./install-fonts.sh` installs Source Code Pro and Font Awesome 7
into `~/.local/share/fonts` (`--dry-run` to check first), and Source Han Sans
JP if neither it nor Noto Sans CJK JP is installed. It skips the fonts
fontconfig already knows, and checks the archives against pinned checksums.
`./install-themes.sh` does the same for the Nordic GTK theme
(`~/.local/share/themes`) and the capitaine cursors (`~/.icons`, the only
user directory X11 reads cursors from).

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

## Automatic lock

`bin/autolock`, started by i3, is off unless `AUTOLOCK` is set in
`~/.profile.local`:

```sh
export AUTOLOCK=presence     # or idle
export AUTOLOCK_CHECK=20     # presence: seconds without input before a webcam check
export AUTOLOCK_IDLE=600     # always: lock after this many seconds without input
```

In `presence` mode, after `AUTOLOCK_CHECK` seconds without keyboard or mouse
input it looks at the webcam for about a second and locks if no face is seen,
then checks again every `AUTOLOCK_CHECK` seconds while idle. Frames stay in
memory and are never saved. Faces are detected with OpenCV's YuNet model
(`share/autolock`, MIT licensed, OpenCV >= 4.8), or its Haar cascades on older
OpenCV versions. If the webcam can't be read (e.g. busy in a video
call), only `AUTOLOCK_IDLE` applies. `autolock --check` tests the detection
once.

## Machine-specific settings

These files are sourced when present and are not versioned:

| File                        | For                                   |
|-----------------------------|---------------------------------------|
| `~/.profile.local`          | environment variables, extra `PATH`   |
| `~/.zshrc.local`            | zsh settings, aliases                 |
| `~/.config/aliases/secrets/`| aliases containing tokens or passwords|
| `~/.p10k.zsh`               | powerlevel10k prompt instead of fwalch (`p10k configure`) |

## Content

| Directory     | Program                                   |
|---------------|-------------------------------------------|
| `zshrc`, `zsh_plugins.txt`, `aliases/` | zsh + [antidote](https://github.com/mattmc3/antidote) / oh-my-zsh |
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
