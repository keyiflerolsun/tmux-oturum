# Bu araç @keyiflerolsun tarafından | @KekikAkademi için yazılmıştır.

# tmux-oturum zsh'ta ctrl-g ile (tmux içinde de dışında da). ~/.zshrc: source ~/.tmux/plugins/tmux-oturum/oturum.zsh
_oturum_betik=${${(%):-%x}:A:h}/scripts/oturum
# Girdi terminalin kendi adıyla ($TTY, /dev/pts/N) ve okuma-yazma: tmux istemcisi /dev/tty adıyla açılmış girdide "can't use
# /dev/tty" deyip duruyor, sunucu ekranı istemcinin girdisine yazdığından salt okunur girdide bağlanıp hiçbir şey çizmiyor
oturum-sec() { "$_oturum_betik" <>"$TTY"; zle reset-prompt; }
zle -N oturum-sec
bindkey '^G' oturum-sec
