#!/usr/bin/env bash
# Bu araç @keyiflerolsun tarafından | @KekikAkademi için yazılmıştır.

# tmux-oturum: prefix + @oturum-tus (varsayılan g) yerel makinenin, Tailscale'deki ve @oturum-makineler'deki makinelerin oturumlarını açılır pencerede listeler.
DIZIN="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

secenek() { local deger; deger=$(tmux show-option -gqv "$1"); echo "${deger:-$2}"; }

tmux bind-key "$(secenek @oturum-tus g)" display-popup -E -d '#{pane_current_path}' \
    -w "$(secenek @oturum-genislik 90%)" -h "$(secenek @oturum-yukseklik 75%)" "$DIZIN/scripts/oturum"

# Oturum kapanınca (Ctrl-D ile son kabuk çıkınca) istemci ayrılıp kabuğa düşmez, bir önceki oturuma geçer. tmux 3.4+;
# başka oturum yoksa tmux yine ayrılır.
[ "$(secenek @oturum-onceye-don on)" = on ] && tmux set-option -g detach-on-destroy previous
