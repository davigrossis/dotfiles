#!/usr/bin/env bash
# rice-mode.sh — alterna entre o rice (Quickshell) e o setup original (Waybar).
#
#   rice-mode.sh waybar       ROLLBACK em um comando: para o Quickshell, volta Waybar +
#                             hyprpaper (autostart original), tema original do rofi e do
#                             qt6ct, e remove atalhos/cores/regras do rice (hyprctl reload).
#   rice-mode.sh quickshell   reativa o rice.
#   rice-mode.sh status       mostra o modo atual.
#
# Pode rodar fora do Hyprland (TTY): nesse caso só troca os arquivos, e vale no próximo login.
set -u
HYPR="$HOME/.config/hypr/rice"
SESSION="$HYPR/session.conf"
ROFI="$HOME/.config/rofi/config.rasi"
QT6CT="$HOME/.config/qt6ct/qt6ct.conf"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/rice"
BIN="$HOME/.config/scripts/bin"
in_hypr() { [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && hyprctl version >/dev/null 2>&1; }

# troca uma linha "chave=..." (ou regex) de forma atômica, preservando o resto do arquivo
set_line() { # arquivo regex nova_linha
    [ -f "$1" ] || return 0
    sed "s#$2#$3#" "$1" > "$1.rice-tmp" && mv -f "$1.rice-tmp" "$1"
}

mode_now() {
    if grep -q 'rice/waybar.conf' "$SESSION" 2>/dev/null; then echo waybar; else echo quickshell; fi
}

case "${1:-status}" in
waybar)
    printf '# Modo da sessão (reescrito por ~/.config/scripts/rice-mode.sh):\n#   rice.conf  = Quickshell (padrão)      waybar.conf = setup original com Waybar\nsource = ~/.config/hypr/rice/waybar.conf\n' > "$SESSION"
    set_line "$ROFI" '^@theme .*' '@theme "/home/davigrossi/.config/rofi/themes/rounded-template.rasi"'
    set_line "$QT6CT" '^color_scheme_path=.*' 'color_scheme_path=/usr/share/color-schemes/BreezeDark.colors'
    if in_hypr; then
        qs kill -c rice >/dev/null 2>&1
        pkill -x awww-daemon 2>/dev/null
        pgrep -x waybar >/dev/null || { waybar >/dev/null 2>&1 & disown; }
        pgrep -x hyprpaper >/dev/null || { hyprpaper >/dev/null 2>&1 & disown; }
        # variáveis do rice (não dá para "desdefinir" via hyprctl; neutraliza)
        clean=$(printf '%s' "$PATH" | tr ':' '\n' | grep -vxF "$BIN" | paste -sd:)
        hyprctl --batch "keyword env KITTY_RICE_COLORS, ; keyword env GTK_THEME,Breeze-Dark ; keyword env PATH,$clean" >/dev/null
        hyprctl reload >/dev/null
    fi
    echo "Modo Waybar ativo (rollback). Para voltar ao rice: ~/.config/scripts/rice-mode.sh quickshell"
    ;;
quickshell | rice)
    printf '# Modo da sessão (reescrito por ~/.config/scripts/rice-mode.sh):\n#   rice.conf  = Quickshell (padrão)      waybar.conf = setup original com Waybar\nsource = ~/.config/hypr/rice/rice.conf\n' > "$SESSION"
    set_line "$ROFI" '^@theme .*' '@theme "~/.config/rofi/themes/rice.rasi"'
    [ -f "$STATE/Matugen-a.colors" ] || cp -f "$STATE/Matugen.colors" "$STATE/Matugen-a.colors" 2>/dev/null
    set_line "$QT6CT" '^color_scheme_path=.*' "color_scheme_path=$STATE/Matugen-a.colors"
    if in_hypr; then
        pkill -x hyprpaper 2>/dev/null
        hyprctl reload >/dev/null
        sleep 0.5
        # rice-session.sh repõe o PATH, o wallpaper do Waypaper e o Quickshell (e fecha a Waybar)
        setsid -f "$HOME/.config/scripts/rice-session.sh" >/dev/null 2>&1
        "$HOME/.config/scripts/apply-theme.sh" >/dev/null 2>&1 &
        hyprctl --batch "keyword env KITTY_RICE_COLORS,include ~/.local/state/rice/kitty-colors.conf ; keyword env GTK_THEME,Matugen" >/dev/null
    fi
    echo "Rice (Quickshell) ativo."
    ;;
status)
    echo "modo: $(mode_now)"
    ;;
*)
    echo "uso: $0 waybar|quickshell|status"
    exit 2
    ;;
esac
