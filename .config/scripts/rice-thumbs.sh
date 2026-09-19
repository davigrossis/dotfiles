#!/usr/bin/env bash
# rice-thumbs.sh — prepara os wallpapers para o seletor do Quickshell.
# Uso: rice-thumbs.sh [pasta]   (padrão: pasta configurada no Waypaper)
# Saída em ~/.cache/rice/wallpapers/<md5 do caminho>-…:
#   -thumb.jpg (480x270, grade + análise de cor), -preview.jpg (1280x720, prévia grande) e
#   -screen-<L>x<A>.png: cópia já reduzida ao maior monitor, só para imagens maiores que ele —
#   o awww decodifica ~4x mais rápido e a transição começa quase na hora (resultado idêntico,
#   pois o awww reduziria a imagem para o monitor de qualquer forma).
# Tudo é refeito só se o wallpaper for mais novo que o arquivo em cache.
set -u
dir="${1:-}"
if [ -z "$dir" ]; then
    dir=$(sed -n 's/^folder = //p' "$HOME/.config/waypaper/config.ini" | head -n1)
    dir="${dir/#\~/$HOME}"
fi
out="$HOME/.cache/rice/wallpapers"
mkdir -p "$out"
[ -d "$dir" ] || exit 0

screen=$("$HOME/.config/scripts/rice-wallpaper.sh" screen-size 2>/dev/null)
export RICE_SCREEN="${screen:-1920x1080}"

make_one() {
    f="$1"
    out="$2"
    k=$(printf '%s' "$f" | md5sum | cut -d' ' -f1)
    t="$out/$k-thumb.jpg"
    p="$out/$k-preview.jpg"
    s="$out/$k-screen-$RICE_SCREEN.png"
    if [ ! "$p" -nt "$f" ]; then
        magick "${f}[0]" -auto-orient -resize '1280x720^' -gravity center -extent 1280x720 -strip -quality 86 "$p.tmp.jpg" && mv -f "$p.tmp.jpg" "$p"
    fi
    if [ ! "$t" -nt "$f" ]; then
        magick "$p" -resize '480x270^' -gravity center -extent 480x270 -strip -quality 84 "$t.tmp.jpg" && mv -f "$t.tmp.jpg" "$t"
    fi
    if [ ! "$s" -nt "$f" ]; then
        read -r w h < <(magick identify -format '%w %h\n' "${f}[0]" 2>/dev/null)
        W=${RICE_SCREEN%x*}
        H=${RICE_SCREEN#*x}
        if [ "${w:-0}" -gt "$W" ] && [ "${h:-0}" -gt "$H" ]; then
            magick "${f}[0]" -auto-orient -filter Lanczos -resize "${W}x${H}^" -strip "$s.tmp.png" && mv -f "$s.tmp.png" "$s"
        fi
    fi
}
export -f make_one

find -L "$dir" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \
    -o -iname '*.bmp' -o -iname '*.gif' -o -iname '*.jxl' \) -print0 |
    xargs -0 -r -P "$(nproc)" -I{} bash -c 'make_one "$1" "$2"' _ {} "$out"
