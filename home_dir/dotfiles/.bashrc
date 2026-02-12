#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias v='nvim'
alias vim='nvim'
alias docker='podman'
alias :q=exit

bind "set completion-ignore-case on"
PS1='[\u@\h \W]\$ '
export TERM=xterm-256color
export PATH=$PATH:~/.cargo/bin/
export PATH=$PATH:~/.config/emacs/bin
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/dotfiles-arch/scripts:$PATH

git-update() {
    git add . && git commit -m "$1" && git push
}

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export PATH=/home/andrey/.local/bin:$PATH
