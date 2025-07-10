#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias v='nvim'
PS1='[\u@\h \W]\$ '
export TERM=xterm-256color

git-update() {
    git add . && git commit -m "$1" && git push
}
