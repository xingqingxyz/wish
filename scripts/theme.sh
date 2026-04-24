#!/bin/bash
# $1 get|set
# $2 name
# $3 theme
# $4? light|dark default light
set -e

# $1 name
# $2 light|dark
get_theme() {
  case "$1" in
    alacritty)
      config_file="$CONFIG_DIR/alacritty/alacritty.toml"
      sed -En 's|^import = \[".*/([^/]+)\.toml"\]\r?$|\1|p' "$config_file"
      ;;
    bat)
      config_file="$CONFIG_DIR/bat/config"
      sed -En "s/^--theme-$2=\"(.+)\"$/\1/p" "$config_file"
      ;;
    windows_terminal)
      config_file="$LOCALAPPDATA/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
      sed -En "s/^ {12}\"colorScheme\": \"(.+)\",?$/\1/p" "$config_file"
      ;;
    *) return 1 ;;
  esac
}

# $1 name
# $2 theme
# $3 light|dark
set_theme() {
  case "$1" in
    alacritty)
      config_file="$CONFIG_DIR/alacritty/alacritty.toml"
      sed -Ei --follow-symlinks "s|^import = \[\".+\"\](\r?)$|import = \[\"alacritty-theme/themes/$2.toml\"\]\1|" "$config_file"
      ;;
    bat)
      config_file="$CONFIG_DIR/bat/config"
      sed -Ei --follow-symlinks "s/^--theme-$3=.+$/--theme-$3=\"$2\"/" "$config_file"
      ;;
    windows_terminal)
      config_file="$LOCALAPPDATA/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
      sed -Ei --follow-symlinks "s/^( {12}\"colorScheme\": \").+(\",?)$/\1$2\2/" "$config_file"
      ;;
    *) return 1 ;;
  esac
}

# $1 name
# $2 theme
# $3 light|dark
preview_theme() {
  case "$1" in
    alacritty | windows_terminal)
      set_theme "$@"
      "$CONFIG_DIR/alacritty/alacritty-theme/print_colors.sh"
      ;;
    bat)
      bat --theme="$2" -plsh --color=always ~/.bashrc
      ;;
    *) return 1 ;;
  esac
}

CONFIG_DIR=$HOME/.config
case "$OSTYPE" in
  cygwin | msys)
    CONFIG_DIR=$APPDATA
    ;;
  *)
    if [ "$1" = windows_terminal ]; then
      echo "windows_terminal theme is not supported on $OSTYPE" >&2
      exit
    fi
    ;;
esac
case "$1" in
  get)
    get_theme "$2" "${3:-light}"
    ;;
  set | preview)
    "${1}_theme" "$2" "$3" "${4:-light}"
    ;;
  *) exit 1 ;;
esac
