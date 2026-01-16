set fish_greeting

if status is-interactive
    # Commands to run in interactive sessions can go here
end

abbr -a v nvim
abbr -a vim nvim

function git-update
    git add . && git commit -m "$argv" && git push
end


