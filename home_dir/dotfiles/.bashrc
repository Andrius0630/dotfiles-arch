#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias v='nvim'
alias git-update='git add . && git commit -m "Updated configs" && git push'
PS1='[\u@\h \W]\$ '
export TERM=xterm-256color
