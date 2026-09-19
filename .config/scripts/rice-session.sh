#!/usr/bin/env bash
[ "$XDG_CURRENT_DESKTOP" = "Hyprland" ] || exit 0
# rice-session.sh — sobe o rice na sessão Hyprland (chamado por exec-once em rice.conf).
#   (sem argumentos)   autostart: PATH dos wrappers, wallpaper do Waypaper e Quickshell
#   --restart-shell    reinicia só o Quickshell (atalho SUPER+SHIFT+R)
# Se o Quickshell não subir, a Waybar é iniciada automaticamente (nunca fica sem barra).

STATE="${XDG_STATE_HOME:-$HOME/.local/state}/rice"
LOG="$STATE/session.log"
BIN="$HOME/.config/scripts/bin"
mkdir -p "$STATE"
[ -f "$LOG" ] && [ "$(stat -c %s "$LOG")" -gt 131072 ] && tail -n 200 "$LOG" > "$LOG.tmp" && mv -f "$LOG.tmp" "$LOG"
log() { printf '[%s] %s\n' "$(date '+%F %T')" "$*" >> "$LOG"; }

# PATH com os wrappers do rice na frente, sem duplicar (vale para binds/apps lançados depois)
clean=$(printf '%s' "$PATH" | tr ':' '\n' | grep -vxF "$BIN" | paste -sd:)
export PATH="$BIN:$clean"
hyprctl keyword env "PATH,$PATH" >/dev/null 2>&1

bar_up() {
    hyprctl layers -j 2>/dev/null | grep -qE '"namespace": *"rice-bar"'
}

start_shell() {
    # O Quickshell é o servidor de notificações nesta sessão: encerra concorrentes
    # (o dunst pode ter sido ativado via D-Bus antes do Quickshell subir).
    pkill -x dunst 2>/dev/null
    pkill -x mako 2>/dev/null
    pkill -x swaync 2>/dev/null
    qs kill -c rice >/dev/null 2>&1
    sleep 0.3
    qs -c rice -n -d >/dev/null 2>&1
    for _ in $(seq 1 30); do
        if bar_up; then
            log "Quickshell ok"
            pkill -x waybar 2>/dev/null
            return 0
        fi
        sleep 0.5
    done
    log "ERRO: Quickshell não subiu em 15 s — iniciando a Waybar como fallback (veja: qs log -c rice)"
    pgrep -x waybar >/dev/null || { waybar >/dev/null 2>&1 & disown; }
    notify-send -u critical "Rice" "O Quickshell não iniciou; a Waybar foi aberta como fallback. Veja: qs log -c rice" 2>/dev/null
    return 1
}

start_wallpaper() {
    # Waypaper é a fonte de verdade; backend awww (o swww foi renomeado para awww).
    # O hyprpaper (autostart antigo) não aplicava wallpaper algum no 0.8; sai de cena aqui.
    pkill -x hyprpaper 2>/dev/null
    # (detecta pelo socket desta sessão, não por nome de processo)
    awww query >/dev/null 2>&1 || { awww-daemon >/dev/null 2>&1 & disown; }
    for _ in $(seq 1 50); do awww query >/dev/null 2>&1 && break; sleep 0.1; done
    waypaper --restore --no-post-command >/dev/null 2>&1
    # primeira execução: garante que a paleta existe
    [ -f "$STATE/colors.json" ] || "$HOME/.config/scripts/apply-theme.sh"
    log "wallpaper restaurado: $(sed -n 's/^wallpaper = //p' "$HOME/.config/waypaper/config.ini" | head -n1)"
}

case "${1:-}" in
--restart-shell)
    start_shell
    ;;
*)
    log "---- início da sessão"
    start_wallpaper &
    start_shell
    wait
    ;;
esac
