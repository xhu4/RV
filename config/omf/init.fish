starship init fish | source
fzf --fish | source
fish_vi_key_bindings
set -xg EDITOR nvim
eval (brew shellenv)

bind \ca beginning-of-line
bind \ce end-of-line

abbr erc nvim ~/.config/omf/init.fish
abbr gco git checkout
abbr gst git status
abbr gcan! git commit -a --amend --no-edit
abbr gb git branch -vv
abbr killport --set-cursor "lsof -ti:% | xargs kill -9"
