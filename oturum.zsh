# Bu araç @keyiflerolsun tarafından | @KekikAkademi için yazılmıştır.

# tmux-oturum zsh'ta ctrl-g ile (tmux içinde de dışında da). ~/.zshrc: source ~/.tmux/plugins/tmux-oturum/oturum.zsh
_oturum_betik=${${(%):-%x}:A:h}/scripts/oturum
oturum-sec() { "$_oturum_betik" </dev/tty; zle reset-prompt; }
zle -N oturum-sec
bindkey '^G' oturum-sec
