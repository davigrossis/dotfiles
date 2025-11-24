#!/bin/bash

DOTFILES_DIR="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"

declare -A DOTFILES
DOTFILES=(
    ["hypr"]="$CONFIG_DIR/hypr"
    ["waybar"]="$CONFIG_DIR/waybar"
    ["rofi"]="$CONFIG_DIR/rofi"
    ["kitty"]="$CONFIG_DIR/kitty"
    ["fish"]="$CONFIG_DIR/fish"
    ["gtk-3.0"]="$CONFIG_DIR/gtk-3.0"
    ["gtk-4.0"]="$CONFIG_DIR/gtk-4.0"
    ["zathura"]="$CONFIG_DIR/zathura"
    ["waypaper"]="$CONFIG_DIR/waypaper"
    ["nwg-look"]="$CONFIG_DIR/nwg-look"
    ["qt5ct"]="$CONFIG_DIR/qt5ct"
    ["qt6ct"]="$CONFIG_DIR/qt6ct"
    ["starship.toml"]="$CONFIG_DIR/starship.toml"
)

echo "==> Setting up dotfiles..."

for folder in "${!DOTFILES[@]}"; do
    TARGET="${DOTFILES[$folder]}"
    SOURCE="$DOTFILES_DIR/.config/$folder"

    echo "--- $folder ---"

    if [ -e "$TARGET" ]; then
        echo "Backup de $TARGET -> $TARGET.bak"
        mv "$TARGET" "$TARGET.bak"
    fi

    ln -sfn "$SOURCE" "$TARGET"
    echo "Link criado: $SOURCE -> $TARGET"
done

echo "==> Reloading Hyprland..."
hyprctl reload

echo "==> Dotfiles instaladas com sucesso!"
