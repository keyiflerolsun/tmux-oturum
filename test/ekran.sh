#!/usr/bin/env bash
# Bu araç @keyiflerolsun tarafından | @KekikAkademi için yazılmıştır.

# README ekran görüntüsü (.github/ekran.png): kendi tmux görünümünle, sahte makinelerle (sahte/). Gerçek makine adın, oturumların
# ve süreçlerin görünmez: tmux ayrı UTS ad alanında "laptop" adıyla, eklentisiz ve ayrı soketle koşar (continuum/resurrect
# kayıtlarına dokunmaz). Açılır pencere capture-pane'e girmediği için iç tmux dıştaki ikinci bir tmux'ta açılıp o yakalanır.
#   test/ekran.sh [çıktı.png]
# Ortam: EKRAN_CONF (tmux görünümü, varsayılan ~/.tmux.conf.local; @plugin satırları atlanır), EKRAN_FONT, EKRAN_ARKA, EKRAN_ON.
# Gerekenler: unshare (util-linux), aha, chromium, bat (yoksa cat).
set -e
DEPO=$(cd "$(dirname "$0")/.." && pwd)
CIKTI=$(readlink -f "${1:-$DEPO/.github/ekran.png}")
CONF=${EKRAN_CONF:-$HOME/.tmux.conf.local}
FONT=${EKRAN_FONT:-JetBrainsMono Nerd Font Mono} ARKA=${EKRAN_ARKA:-#232627} ON=${EKRAN_ON:-#fcfcfc}
for arac in unshare aha chromium; do command -v $arac >/dev/null || { echo "gerekli: $arac" >&2; exit 1; }; done

# Kısa yol: soket yolu 108 baytı geçemez
G=$(mktemp -d /tmp/ekran.XXXXXX)
DIS=(env -u TMUX tmux -L "ekran-$$" -f /dev/null)
trap '"${DIS[@]}" kill-server 2>/dev/null; env -u TMUX tmux -S "$G/sock" kill-server 2>/dev/null; rm -rf "$G"' EXIT
mkdir -p "$G/bin" "$G/blog" "$G/notlar" "$G/kayit"
# Kayıtlı oturum: açık olmayan "api", üç bölmeli penceresiyle; kayıt yeri @resurrect-dir ile $G'de, gerçek kayıtlar okunmaz
printf '%s\n' $'pane\tapi\t1\t1\t:*\t1\t\t:/srv/api\t1\tnvim\t:' $'pane\tapi\t1\t1\t:*\t2\t\t:/srv/api\t0\tgo\t:' \
    $'pane\tapi\t1\t1\t:*\t3\t\t:/var/log/api\t0\ttail\t:' $'pane\tapi\t2\t0\t:-\t1\t\t:/srv/api/db\t1\tpsql\t:' \
    $'window\tapi\t1\t:kod\t1\t:*\tb25d,170x40,0,0{85x40,0,0,1,84x40,86,0[84x20,86,0,2,84x19,86,21,3]}\t:' \
    $'window\tapi\t2\t:db\t0\t:-\t9a1c,170x40,0,0,4\t:' >"$G/kayit/tmux_resurrect_20261124T093000.txt"
ln -s "$DEPO/test/sahte/ssh" "$DEPO/test/sahte/tailscale" "$G/bin/"

{ [[ -r $CONF ]] && grep -vE '@plugin|@continuum|@resurrect' "$CONF"
  printf '%s\n' "set -g @resurrect-dir '$G/kayit'" 'set -g base-index 1' 'setw -g pane-base-index 1' 'set -g automatic-rename off' 'set -g allow-rename off' \
                "set -as terminal-features ',tmux-256color:RGB'" "run-shell '$DEPO/oturum.tmux'"; } >"$G/tmux.conf"

command -v bat >/dev/null && goster="bat --paging=never --style=plain --color=always --line-range :38" || goster="head -38"
cat >"$G/ic.sh" <<EOF
hostname laptop
export PATH="$G/bin:\$PATH" XDG_RUNTIME_DIR="$G" LANG=tr_TR.UTF-8 TERM=tmux-256color
T=(tmux -S "$G/sock" -f "$G/tmux.conf")
"\${T[@]}" new-session -d -x 170 -y 43 -s notlar -n zsh -c "$G/notlar" "sleep infinity"
"\${T[@]}" new-session -d -s blog -n nvim -c "$G/blog" "$goster '$DEPO/README.md'; sleep infinity"
"\${T[@]}" new-window -d -t blog: -n zsh -c "$G/blog" "sleep infinity"
exec "\${T[@]}" attach -t blog
EOF

# prefix g, sonra imleç laptop'taki kayıtlı "api" oturumuna (7. satır): önizlemede bölme düzeni
"${DIS[@]}" new-session -d -x 170 -y 44 "unshare -Ur --uts bash '$G/ic.sh'; sleep 60"
"${DIS[@]}" set -g status off
"${DIS[@]}" set -g default-terminal tmux-256color
sleep 3; "${DIS[@]}" send-keys C-b g
sleep 6; for _ in $(seq 6); do "${DIS[@]}" send-keys Down; done
sleep 2; "${DIS[@]}" capture-pane -e -p >"$G/ekran.ans"

{ printf '<!doctype html><meta charset="utf-8"><style>html,body{margin:0;background:%s}' "$ARKA"
  printf 'pre{margin:0;font:15px/18px "%s","DejaVu Sans Mono",monospace;color:%s}i{display:inline-block;width:1ch;font-style:inherit}</style><pre>' "$FONT" "$ON"
  # ASCII dışı her karakter bir hücre: yazı tipinde olmayan (▶ ❯) başka yazı tipinden geniş gelip satırı kaydırıyordu
  aha -n <"$G/ekran.ans" | perl -CSD -pe 's/([^\x00-\x7F])/<i>$1<\/i>/g'; printf '</pre>'; } >"$G/ekran.html"
chromium --headless --disable-gpu --hide-scrollbars --force-device-scale-factor=2 --window-size=1540,792 \
    --screenshot="$CIKTI" "file://$G/ekran.html" 2>/dev/null
echo "$CIKTI"
