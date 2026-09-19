#!/usr/bin/env bash
# rice-kde-audit.sh — prova de isolamento do KDE para o rice do Hyprland.
#
#   rice-kde-audit.sh snapshot <dir>          grava um snapshot (sha256 + metadados)
#   rice-kde-audit.sh compare  <base> <novo>  compara dois snapshots e imprime diferenças
#
# Cobre: todo arquivo de ~/.config que NÃO é de apps conhecidos não-KDE (ou seja, tudo do
# KDE/Plasma + arquivos compartilhados GTK/Qt/dconf/xsettingsd), ~/.local/share do KDE,
# ~/.local/state do KDE, gtk-3.0/gtk-4.0 (seguindo symlinks), serviços systemd --user,
# arquivos de ambiente, SDDM/sessões e a lista de pacotes (pacman -Q).
set -u
export LC_ALL=C

CFG="$HOME/.config"
SHR="$HOME/.local/share"
STA="$HOME/.local/state"

# Entradas de ~/.config que NÃO pertencem ao KDE (apps de terceiros ou dotfiles do rice).
# Tudo o que não estiver aqui é tratado como KDE/compartilhado e auditado.
NON_KDE_CONFIG=(
  Antigravity BraveSoftware btop chromium Code composer configstore create-next-app-nodejs
  Cursor Deskreen discord Electron figma-linux fish github-copilot go google-chrome
  hypr hypr.bak kitty kitty.bak libreoffice microsoft-edge mpv nextjs-nodejs nvim nwg-look
  obs-studio opera pavucontrol.ini pulse qt5ct qt6ct rofi solaar spotify starship.toml
  vivaldi vlc wal waybar waypaper Windsurf yay zathura zed zen zoom.conf zoomus.conf
  quickshell matugen scripts
)

# ~/.local/share e ~/.local/state do KDE / compartilhados relevantes
KDE_SHARE=(
  plasma plasma-systemmonitor color-schemes konsole kwin aurorae kxmlgui5 kactivitymanagerd
  kded6 knewstuff3 kwalletd klipper dolphin kate kwrite krunnerstaterc remoteview krdpserver
  libkunitconversion ark drkonqi gwenview desktop-directories user-places.xbel
  user-places.xbel.bak kservices6 kpackage icons fonts applications mime
)

in_list() { local x="$1"; shift; for i in "$@"; do [[ "$i" == "$x" ]] && return 0; done; return 1; }

config_targets() {
  local e name
  for e in "$CFG"/* "$CFG"/.[!.]*; do
    [[ -e "$e" || -L "$e" ]] || continue
    name="${e##*/}"
    in_list "$name" "${NON_KDE_CONFIG[@]}" && continue
    printf '%s\n' "$e"
  done
}

share_targets() {
  local n
  for n in "${KDE_SHARE[@]}"; do [[ -e "$SHR/$n" || -L "$SHR/$n" ]] && printf '%s\n' "$SHR/$n"; done
  # estado do KDE (k*, plasma*, dolphin*, UserFeedback.org.kde.*, etc.)
  for n in "$STA"/*; do
    case "${n##*/}" in
      claude|nvim|waypaper|wireplumber|lesshst) ;;
      *) printf '%s\n' "$n" ;;
    esac
  done
}

snapshot() {
  local out="$1"; mkdir -p "$out"
  local list="$out/targets.txt"
  { config_targets; share_targets; } > "$list"

  # 1) hashes (segue symlinks: gtk-3.0/gtk-4.0 apontam para ~/dotfiles)
  : > "$out/files.sha256"
  while IFS= read -r t; do
    find -L "$t" -type f -print0 2>/dev/null | sort -z | xargs -0 -r sha256sum 2>/dev/null
  done < "$list" >> "$out/files.sha256"

  # 2) estrutura: tipo, caminho, alvo de symlink, tamanho, mtime (para atribuir mudanças)
  : > "$out/tree.txt"
  while IFS= read -r t; do
    find "$t" -printf '%y\t%p\t%l\t%s\t%TY-%Tm-%Td %TH:%TM:%TS\n' 2>/dev/null
  done < "$list" | sort >> "$out/tree.txt"
  # symlinks de primeiro nível em ~/.config (gtk-3.0 -> dotfiles etc.)
  find "$CFG" -maxdepth 1 -type l -printf '%p -> %l\n' | sort > "$out/config-symlinks.txt"

  # 3) serviços systemd --user (estado de habilitação/mascaramento)
  systemctl --user list-unit-files --no-pager --no-legend 2>/dev/null | awk '{print $1, $2}' | sort > "$out/systemd-user-unit-files.txt"
  { ls -la "$CFG/systemd/user" 2>&1; ls -laR /etc/systemd/user 2>&1; } > "$out/systemd-user-dirs.txt"

  # 4) arquivos de ambiente / autostart / sessões / SDDM
  {
    for f in /etc/environment /etc/profile /etc/profile.d/* "$HOME/.profile" "$HOME/.bash_profile" \
             "$HOME/.bashrc" "$HOME/.zprofile" "$HOME/.pam_environment" "$HOME/.xprofile" \
             /etc/sddm.conf /etc/sddm.conf.d/* /usr/lib/sddm/sddm.conf.d/* \
             /usr/share/wayland-sessions/* /usr/share/xsessions/*; do
      [[ -f "$f" ]] && sha256sum "$f"
    done
    for d in "$CFG/environment.d" "$CFG/autostart" "$CFG/plasma-workspace" "$HOME/.config/systemd"; do
      if [[ -e "$d" ]]; then find -L "$d" -type f -print0 | sort -z | xargs -0 -r sha256sum; else echo "AUSENTE $d"; fi
    done
  } > "$out/env-session.sha256" 2>/dev/null

  # 5) pacotes
  pacman -Q > "$out/packages.txt"
  date '+%F %T %z' > "$out/timestamp.txt"
  echo "snapshot gravado em $out ($(wc -l < "$out/files.sha256") arquivos)"
}

compare() {
  local a="$1" b="$2" rc=0
  echo "== Comparando $a  ->  $b"
  echo "-- Arquivos KDE/compartilhados com conteúdo alterado, adicionados ou removidos:"
  if diff <(sort -k2 "$a/files.sha256") <(sort -k2 "$b/files.sha256") > /tmp/.rice-audit-diff.$$; then
    echo "   (nenhum) ✔"
  else
    rc=1; sed 's/^/   /' /tmp/.rice-audit-diff.$$
  fi
  rm -f /tmp/.rice-audit-diff.$$
  echo "-- Estrutura (tipos/symlinks; ignora mtime/tamanho de diretórios):"
  if diff <(cut -f1-3 "$a/tree.txt") <(cut -f1-3 "$b/tree.txt") >/dev/null && diff -q "$a/config-symlinks.txt" "$b/config-symlinks.txt" >/dev/null; then
    echo "   (sem mudanças) ✔"
  else
    rc=1; diff <(cut -f1-3 "$a/tree.txt") <(cut -f1-3 "$b/tree.txt") | sed 's/^/   /'; diff "$a/config-symlinks.txt" "$b/config-symlinks.txt" | sed 's/^/   /'
  fi
  echo "-- Serviços systemd --user:"
  if diff -q "$a/systemd-user-unit-files.txt" "$b/systemd-user-unit-files.txt" >/dev/null && diff -q "$a/systemd-user-dirs.txt" "$b/systemd-user-dirs.txt" >/dev/null; then
    echo "   (sem mudanças) ✔"
  else
    rc=1; diff "$a/systemd-user-unit-files.txt" "$b/systemd-user-unit-files.txt" | sed 's/^/   /'; diff "$a/systemd-user-dirs.txt" "$b/systemd-user-dirs.txt" | sed 's/^/   /'
  fi
  echo "-- Ambiente / autostart / SDDM / sessões:"
  if diff -q "$a/env-session.sha256" "$b/env-session.sha256" >/dev/null; then
    echo "   (sem mudanças) ✔"
  else
    rc=1; diff "$a/env-session.sha256" "$b/env-session.sha256" | sed 's/^/   /'
  fi
  echo "-- Pacotes (só adições são permitidas):"
  local removed changed
  removed=$(join -v1 <(sort "$a/packages.txt") <(sort "$b/packages.txt") -j1 | awk '{print $1}')
  changed=$(join <(sort "$a/packages.txt") <(sort "$b/packages.txt") | awk '$2!=$3{print $1": "$2" -> "$3}')
  if [[ -z "$removed" && -z "$changed" ]]; then echo "   nenhum removido/alterado ✔"; else rc=1; echo "   REMOVIDOS: $removed"; echo "   ALTERADOS: $changed"; fi
  echo "   adicionados: $(join -v2 <(sort "$a/packages.txt") <(sort "$b/packages.txt") | awk '{print $1}' | paste -sd' ')"
  return $rc
}

case "${1:-}" in
  snapshot) snapshot "${2:?diretório}";;
  compare)  compare "${2:?base}" "${3:?novo}";;
  *) echo "uso: $0 snapshot <dir> | compare <base> <novo>"; exit 2;;
esac
