# Rice Hyprland + Quickshell

Barra, painéis e notificações em Quickshell. As cores são geradas do wallpaper pelo matugen.
Tudo vale **só na sessão Hyprland**: o KDE Plasma não lê nada daqui.

## Estrutura
```
~/.config/hypr/rice/        session.conf (modo) · rice.conf · waybar.conf · layerrules.conf
~/.config/quickshell/rice/  shell.qml · services/ · widgets/ · bar/ · panels/ · notifications/ · osd/ · wallpaper/
~/.config/matugen/          config.toml · templates/ (quickshell, hyprland, rofi, kitty, qt, gtk3, btop, nvim)
~/.config/scripts/          apply-theme.sh · rice-session.sh · rice-mode.sh · rice-rollback.sh
                            rice-thumbs.sh · rice-kde-audit.sh · bin/{waypaper,btop} (wrappers, PATH só no Hyprland)
~/.local/state/rice/        arquivos gerados (colors.json, hyprland-colors.conf, kitty/rofi/Qt/btop…)
~/.local/share/themes/Matugen  tema GTK3 gerado (ativado por GTK_THEME no rice.conf)
```

## Atalhos novos (os antigos não mudaram)
| Atalho | Ação |
|---|---|
| SUPER+SHIFT+W | seletor de wallpapers |
| SUPER+C | central de controle |
| SUPER+N | central de notificações |
| SUPER+Escape | menu de energia |
| SUPER+SHIFT+R | reinicia o Quickshell |

SUPER+O voltou a funcionar (`layoutmsg, togglesplit` no Hyprland 0.56).

## Tema e wallpaper
- Trocar wallpaper: SUPER+SHIFT+W, SUPER+W (Waypaper) ou `waypaper --wallpaper arq`.
  O `post_command` do Waypaper roda o `apply-theme.sh`, que atualiza ao vivo a barra/painéis, as
  bordas do Hyprland, o kitty, os apps Qt abertos e o btop. Rofi e GTK3 pegam as cores novas
  na próxima abertura.
- Modo claro/escuro e esquema (Auto/Tonal/Vibrante/Fiel/Mono): central de controle.
  As preferências ficam em `~/.local/state/rice/theme.env`.
- Neovim: colorscheme opcional, `:colorscheme matugen`.

## Rollback
```
~/.config/scripts/rice-rollback.sh          # volta à Waybar + hyprpaper (setup original)
~/.config/scripts/rice-mode.sh quickshell   # reativa o rice
~/.config/scripts/rice-mode.sh status
```
Backup completo do estado anterior: `~/backup-rice-2026-09-18/`.
Commits no branch local `rice/quickshell` do `~/dotfiles`.

## Diagnóstico
`qs log -c rice` · `qs ipc call rice status` · `~/.local/state/rice/{session,apply-theme}.log`
Isolamento do KDE: `rice-kde-audit.sh snapshot <dir>` e depois
`rice-kde-audit.sh compare ~/backup-rice-2026-09-18/audit/baseline <dir>`.
