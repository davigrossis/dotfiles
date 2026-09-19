#!/usr/bin/env bash
# rice-thumbs.sh — gera miniaturas dos wallpapers para o seletor do Quickshell.
# Uso: rice-thumbs.sh [pasta]   (padrão: pasta configurada no Waypaper)
# Saída: ~/.cache/rice/wallpapers/<md5 do caminho>-{thumb,preview}.jpg (refeitas só se o
# wallpaper for mais novo que a miniatura).
set -u
dir="${1:-}"
if [ -z "$dir" ]; then
    dir=$(sed -n 's/^folder = //p' "$HOME/.config/waypaper/config.ini" | head -n1)
    dir="${dir/#\~/$HOME}"
fi
out="$HOME/.cache/rice/wallpapers"
mkdir -p "$out"
[ -d "$dir" ] || exit 0

make_one() {
    f="$1"
    out="$2"
    k=$(printf '%s' "$f" | md5sum | cut -d' ' -f1)
    t="$out/$k-thumb.jpg"
    p="$out/$k-preview.jpg"
    if [ ! "$p" -nt "$f" ]; then
        magick "${f}[0]" -auto-orient -resize '1280x720^' -gravity center -extent 1280x720 -strip -quality 86 "$p.tmp.jpg" && mv -f "$p.tmp.jpg" "$p"
    fi
    if [ ! "$t" -nt "$f" ]; then
        magick "$p" -resize '480x270^' -gravity center -extent 480x270 -strip -quality 84 "$t.tmp.jpg" && mv -f "$t.tmp.jpg" "$t"
    fi
}
export -f make_one

find -L "$dir" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \
    -o -iname '*.bmp' -o -iname '*.gif' -o -iname '*.jxl' \) -print0 |
    xargs -0 -r -P "$(nproc)" -I{} bash -c 'make_one "$1" "$2"' _ {} "$out"
