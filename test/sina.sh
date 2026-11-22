#!/usr/bin/env bash
# Bu araç @keyiflerolsun tarafından | @KekikAkademi için yazılmıştır.

# Liste sırası ve biçimi sahte makinelerle (sahte/: tmux, ssh, tailscale, uname): yerel önce, makine adı ilk satırda, "+" ve onay
# satırı başta, son kullanılan oturum üstte, pencereleri altında. Kapalı ve Windows makine listede yok.
cd "$(dirname "$0")" || exit 1
beklenen='laptop  + yeni oturum  ctrl-f: dizin seç
        notlar   1 pencere
        └ 1 zsh •
        blog     2 pencere
        ├ 1 nvim •
        └ 2 zsh
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
cikti=$(PATH="$PWD/sahte:$PATH" XDG_RUNTIME_DIR=$gecici LC_ALL=C.UTF-8 ../scripts/oturum liste | cut -f2 | sed 's/\x1b\[[0-9;]*m//g')
if [[ $cikti == "$beklenen" ]]; then echo "tamam"; else diff <(echo "$beklenen") <(echo "$cikti"); exit 1; fi
