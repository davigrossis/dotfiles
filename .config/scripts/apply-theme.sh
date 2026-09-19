#!/usr/bin/env bash
[ "$XDG_CURRENT_DESKTOP" = "Hyprland" ] || exit 0
# apply-theme.sh — gera a paleta do wallpaper (matugen) e aplica ao vivo no rice do Hyprland.
#
# Uso: apply-theme.sh [caminho-do-wallpaper]
#   Sem argumento (ou caminho inválido) usa o wallpaper salvo pelo Waypaper (fonte de verdade).
#   Chamado pelo post_command do Waypaper — inclusive quando o seletor do Quickshell aplica
#   um wallpaper via "waypaper --wallpaper".
#
# Preferências (alteradas pelo painel do Quickshell) em ~/.local/state/rice/theme.env:
#   RICE_MODE=dark|light        RICE_SCHEME=auto|scheme-tonal-spot|scheme-content|...
#   "auto" = monocromático para wallpapers preto-e-branco, tonal-spot para os coloridos.
#
# Só roda na sessão Hyprland (linha 2) e só no modo Quickshell (no modo Waybar/rollback, sai).

set -u
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/rice"
LOG="$STATE/apply-theme.log"
SETTINGS="$STATE/theme.env"
MATUGEN_CFG="$HOME/.config/matugen/config.toml"
WAYPAPER_CFG="$HOME/.config/waypaper/config.ini"
SESSION_CONF="$HOME/.config/hypr/rice/session.conf"
QT6CT_CONF="$HOME/.config/qt6ct/qt6ct.conf"

mkdir -p "$STATE"
# mantém o log pequeno
[ -f "$LOG" ] && [ "$(stat -c %s "$LOG")" -gt 262144 ] && tail -n 400 "$LOG" > "$LOG.tmp" && mv -f "$LOG.tmp" "$LOG"
exec >>"$LOG" 2>&1
log() { printf '[%s] %s\n' "$(date '+%F %T')" "$*"; }

# Serializa execuções (o seletor pode disparar várias em sequência).
exec 9>"$STATE/.apply-theme.lock"
flock -w 30 9 || { log "timeout esperando outra execução"; exit 1; }

if grep -q 'rice/waybar.conf' "$SESSION_CONF" 2>/dev/null; then
    log "modo Waybar (rollback) ativo — nada a fazer"
    exit 0
fi

# 1) Wallpaper: argumento ou o salvo pelo Waypaper
WALL="${1:-}"
if [ -z "$WALL" ] || [ ! -f "$WALL" ]; then
    WALL=$(sed -n 's/^wallpaper = //p' "$WAYPAPER_CFG" | head -n1)
    WALL="${WALL/#\~/$HOME}"
fi
if [ ! -f "$WALL" ]; then
    log "ERRO: wallpaper não encontrado: '$WALL'"
    exit 1
fi

# 2) Preferências + escolha do esquema
RICE_MODE=dark
RICE_SCHEME=auto
# shellcheck disable=SC1090
[ -f "$SETTINGS" ] && . "$SETTINGS"
SCHEME="$RICE_SCHEME"
if [ "$SCHEME" = auto ]; then
    sat=$(magick "${WALL}[0]" -resize 128x128\! -colorspace HSL -channel G -separate -format '%[fx:mean]' info: 2>/dev/null || echo 1)
    if awk -v s="$sat" 'BEGIN { exit !(s < 0.05) }'; then SCHEME=scheme-monochrome; else SCHEME=scheme-tonal-spot; fi
fi

# 3) Gera todos os templates (Quickshell, Hyprland, rofi, kitty, Qt, GTK3, btop, nvim)
if ! matugen image "$WALL" -c "$MATUGEN_CFG" -m "$RICE_MODE" -t "$SCHEME" --prefer saturation -q; then
    log "ERRO: matugen falhou para $WALL"
    exit 1
fi
printf '%s\n' "$WALL" > "$STATE/wallpaper"
printf 'scheme=%s\nmode=%s\n' "$SCHEME" "$RICE_MODE" > "$STATE/theme-effective"

# 4) Arquivos estáticos do tema GTK "Matugen" (GTK4 fica idêntico ao Breeze-Dark de antes,
#    porque ~/.config/gtk-4.0/gtk.css é compartilhado com o KDE e não pode ser tocado).
GTK_DIR="$HOME/.local/share/themes/Matugen"
mkdir -p "$GTK_DIR/gtk-4.0"
[ -f "$GTK_DIR/index.theme" ] || printf '[Desktop Entry]\nType=X-GNOME-Metatheme\nName=Matugen\nComment=Tema GTK3 do rice (cores do wallpaper) — só Hyprland\nEncoding=UTF-8\n\n[X-GNOME-Metatheme]\nGtkTheme=Matugen\n' > "$GTK_DIR/index.theme"
[ -f "$GTK_DIR/gtk-4.0/gtk.css" ] || printf '/* GTK4 sem alterações: mesmo Breeze-Dark de antes. */\n@import url("file:///usr/share/themes/Breeze-Dark/gtk-4.0/gtk.css");\n' > "$GTK_DIR/gtk-4.0/gtk.css"

# 5) Recarregamentos ao vivo
J="$STATE/colors.json"
col() { jq -r ".colors.$1" "$J" | tr -d '#'; }

#   Hyprland: bordas e sombras sem "hyprctl reload" (não reinicia nada)
hyprctl --batch "keyword general:col.active_border rgba($(col primary)ee) rgba($(col tertiary)ee) 45deg ; keyword general:col.inactive_border rgba($(col outline_variant)aa) ; keyword decoration:shadow:color rgba($(col shadow)cc) ; keyword decoration:shadow:color_inactive rgba($(col shadow)88)" >/dev/null

#   kitty: SIGUSR1 = recarregar config (o envinclude KITTY_RICE_* traz as cores novas)
pkill -USR1 -x kitty 2>/dev/null

#   Qt (qt6ct-kde): o plugin observa o diretório do qt6ct; recriar o arquivo dispara o reload
if [ -f "$QT6CT_CONF" ] && grep -q 'rice/Matugen.colors' "$QT6CT_CONF"; then
    cp -p "$QT6CT_CONF" "$QT6CT_CONF.rice-tmp" && mv -f "$QT6CT_CONF.rice-tmp" "$QT6CT_CONF"
fi

#   btop (via wrapper do rice): SIGUSR2 = recarregar config/tema
pkill -USR2 -x btop 2>/dev/null

#   Neovim: só instâncias que já usam ":colorscheme matugen" são atualizadas
for sock in "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"/nvim.*.0; do
    [ -S "$sock" ] || continue
    timeout 2 nvim --server "$sock" --remote-expr \
        'execute("if get(g:, \"colors_name\", \"\") ==# \"matugen\" | colorscheme matugen | endif")' >/dev/null 2>&1 &
done

#   Quickshell observa ~/.local/state/rice/colors.json sozinho; rofi e GTK3 leem na próxima abertura.
log "ok: $(basename "$WALL") | esquema=$SCHEME modo=$RICE_MODE"
wait
exit 0
