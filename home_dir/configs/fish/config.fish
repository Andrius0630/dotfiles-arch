set fish_greeting

if status is-interactive
    # Commands to run in interactive sessions can go here
end

function v
	nvim "$argv"
end

function git-update
    git add . && git commit -m "$argv" && git push
end


