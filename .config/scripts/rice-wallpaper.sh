#!/usr/bin/env bash
[ "$XDG_CURRENT_DESKTOP" = "Hyprland" ] || exit 0
# rice-wallpaper.sh — troca/restaura o wallpaper sem passar pelo Waypaper (Python leva ~2 s
# só para iniciar). Usa o awww direto com as MESMAS transições salvas no config do Waypaper
# (swww_transition_*), grava o wallpaper nesse mesmo config (continua sendo a fonte de verdade)
# e aplica o tema uma única vez.
#   rice-wallpaper.sh set <arquivo>   aplica com transição + tema
#   rice-wallpaper.sh restore         reaplica o wallpaper salvo sem transição (login)
set -u
CFG="$HOME/.config/waypaper/config.ini"

get() { sed -n "s/^$1 = //p" "$CFG" | head -n1; }

ensure_daemon() {
    awww query >/dev/null 2>&1 && return 0
    awww-daemon >/dev/null 2>&1 &
    disown
    for _ in $(seq 1 50); do awww query >/dev/null 2>&1 && return 0; sleep 0.1; done
    return 1
}

# maior monitor (LxA) — as cópias em cache são reduzidas para cobrir esse tamanho
screen_size() {
    hyprctl monitors -j 2>/dev/null | jq -r 'max_by(.width * .height) | "\(.width)x\(.height)"' 2>/dev/null
}

# cópia já reduzida ao tamanho da tela (gerada pelo rice-thumbs.sh), se existir e estiver em dia
fast_source() {
    local k c
    k=$(printf '%s' "$1" | md5sum | cut -d' ' -f1)
    c="$HOME/.cache/rice/wallpapers/$k-screen-$(screen_size).png"
    if [ "$c" -nt "$1" ]; then echo "$c"; else echo "$1"; fi
}

resize_mode() {
    case "$(get fill)" in
    fit) echo fit ;;
    center | tile) echo no ;;
    *) echo crop ;;
    esac
}

case "${1:-}" in
set)
    wall="${2:-}"
    wall="${wall/#\~/$HOME}"
    [ -f "$wall" ] || { echo "arquivo não encontrado: $wall" >&2; exit 1; }
    ensure_daemon || exit 1
    color=$(get color); color="${color#\#}"
    awww img "$(fast_source "$wall")" --resize "$(resize_mode)" --fill-color "${color:-000000}" \
        --transition-type "$(get swww_transition_type)" \
        --transition-step "$(get swww_transition_step)" \
        --transition-angle "$(get swww_transition_angle)" \
        --transition-duration "$(get swww_transition_duration)" \
        --transition-fps "$(get swww_transition_fps)" &
    # grava no config do Waypaper (mesmo formato "~/..."); escrita no mesmo inode para o
    # Quickshell (que observa o arquivo) perceber a mudança
    short="${wall/#$HOME/\~}"
    new=$(sed "s#^wallpaper = .*#wallpaper = $short#" "$CFG") && printf '%s\n' "$new" > "$CFG"
    "$HOME/.config/scripts/apply-theme.sh" "$wall" &
    wait
    ;;
restore)
    ensure_daemon || exit 1
    wall=$(get wallpaper)
    wall="${wall/#\~/$HOME}"
    [ -f "$wall" ] && awww img "$(fast_source "$wall")" --resize "$(resize_mode)" --transition-type none
    # prepara miniaturas/cópias que faltarem, sem atrasar o login
    "$HOME/.config/scripts/rice-thumbs.sh" >/dev/null 2>&1 &
    disown
    ;;
screen-size)
    screen_size
    ;;
*)
    echo "uso: $0 set <arquivo> | restore" >&2
    exit 2
    ;;
esac
