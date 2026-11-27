#!/usr/bin/env bash
# Bu araç @keyiflerolsun tarafından | @KekikAkademi için yazılmıştır.

# Liste sırası ve biçimi sahte makinelerle (sahte/: tmux, ssh, tailscale, uname): yerel önce, makine adı ilk satırda, "+" ve onay
# satırı başta, son kullanılan oturum üstte, pencereleri altında; yerelde kayıtlı (açık
# olmayan) oturumlar en altta, yeniden eskiye. Kapalı ve Windows makine listede yok; tmux'suz makine satırsız, yanıt vermeyen
# makine listeyi süresinden (2 sn) uzun bekletmez ve başlıkta sayılır.
cd "$(dirname "$0")" || exit 1
beklenen='laptop  + yeni oturum  ctrl-f: dizin seç
        notlar   1 pencere
        └ 1 zsh •
        blog     2 pencere
        ├ 1 nvim •
        └ 2 zsh
        eski     2 pencere  ↺ kayıtlı 23.11 18:46
        deneme   1 pencere  ↺ kayıtlı 21.11 22:07
ev-pc   ! Tailscale onayı bekliyor  enter: onayla
nas     + yeni oturum  ctrl-f: dizin seç
        yedek    1 pencere
        └ 1 borg •
pi      + yeni oturum  ctrl-f: dizin seç
vps     + yeni oturum  ctrl-f: dizin seç
        web      2 pencere  ● bağlı
        ├ 1 logs •
        └ 2 deploy'
gecici=$(mktemp -d); trap 'rm -rf "$gecici"' EXIT
# resurrect kayıtları: açık "blog" listede yok; "eski" en yeni kaydından (2 pencere), "deneme" yalnız eski dosyada
kayit=$gecici/.local/share/tmux/resurrect; mkdir -p "$kayit"
printf 'pane\teski\t1\t1\t:*\t1\t\t:/tmp\t1\tzsh\t:\nwindow\teski\t1\t:a\t1\t:*\tx\t:\n' >"$kayit/tmux_resurrect_20261121T220745.txt"
printf 'pane\tdeneme\t1\t1\t:*\t1\t\t:/tmp\t1\tzsh\t:\nwindow\tdeneme\t1\t:a\t1\t:*\tx\t:\n' >>"$kayit/tmux_resurrect_20261121T220745.txt"
printf 'window\teski\t1\t:a\t1\t:*\tx\t:\nwindow\teski\t2\t:b\t0\t:-\tx\t:\nwindow\tblog\t1\t:a\t1\t:*\tx\t:\n' >"$kayit/tmux_resurrect_20261123T184621.txt"
export OTURUM_HATA=$gecici/hata
bas=$(date +%s)
cikti=$(PATH="$PWD/sahte:$PATH" HOME=$gecici XDG_DATA_HOME= XDG_RUNTIME_DIR=$gecici LC_ALL=C.UTF-8 ../scripts/oturum liste | cut -f2 | sed 's/\x1b\[[0-9;]*m//g')
sure=$(( $(date +%s) - bas ))
[[ $cikti == "$beklenen" ]] || { diff <(echo "$beklenen") <(echo "$cikti"); exit 1; }
(( sure <= 4 )) || { echo "liste $sure sn sürdü, yanıt vermeyen makine beklenmemeli"; exit 1; }
[[ $(<"$OTURUM_HATA") == kutu ]] || { echo "yanıt vermeyenler: $(<"$OTURUM_HATA"), beklenen kutu"; exit 1; }
bas=$(PATH="$PWD/sahte:$PATH" LC_ALL=C.UTF-8 ../scripts/oturum baslik | sed 's/\x1b\[[0-9;]*m//g' | sed -n 3p)
[[ $bas == '✗ 1 makine yanıt vermedi: kutu  ctrl-t yeniden dene' ]] || { echo "başlık: $bas"; exit 1; }
# Arama alanı (3.): makine adı her satırda, "nas" yazınca nas'ın bütün satırları kalır
arama=$(PATH="$PWD/sahte:$PATH" HOME=$gecici XDG_DATA_HOME= XDG_RUNTIME_DIR=$gecici LC_ALL=C.UTF-8 ../scripts/oturum liste | cut -f3 \
    | sed 's/\x1b\[[0-9;]*m//g' | awk '$1 == "nas"' | wc -l)
[[ $arama == 3 ]] || { echo "arama alanında nas satırı $arama, beklenen 3"; exit 1; }
echo tamam
