#!/usr/bin/env bash

# Defina aqui os "perfis" de waybar
options="main\nminimal\nwork\ngaming"

choice=$(echo -e "$options" | rofi -dmenu -p "Waybar profile:")

[ -z "$choice" ] && exit 0   # usuário cancelou

killall -9 waybar 2>/dev/null

case "$choice" in
  main)
    waybar -c ~/.config/waybar/config-main.jsonc -s ~/.config/waybar/style-main.css &
    ;;
  minimal)
    waybar -c ~/.config/waybar/config-minimal.jsonc -s ~/.config/waybar/style-minimal.css &
    ;;
  work)
    waybar -c ~/.config/waybar/config-work.jsonc -s ~/.config/waybar/style-work.css &
    ;;
  gaming)
    waybar -c ~/.config/waybar/config-gaming.jsonc -s ~/.config/waybar/style-gaming.css &
    ;;
esac