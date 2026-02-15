starship init fish | source
fzf --fish | source
fish_vi_key_bindings
set -xg EDITOR nvim
eval (brew shellenv)

bind \ca beginning-of-line
bind \ce end-of-line

abbr erc nvim ~/.config/omf/init.fish
abbr xa xrandr --auto
abbr ofsc xrandr --output DP-3-1 --mode 1920x1080 --left-of DP-3-3 --output DP-3-3 --mode 1920x1080 --output eDP-1 --off
abbr prn poetry run nvim

abbr gco git checkout
abbr gst git status
abbr gcan git commit --amend --no-edit
abbr gcan! git commit -a --amend --no-edit
abbr gb git branch -vv
abbr da --set-cursor "docker exec -it % bash"
abbr killport --set-cursor "lsof -ti:% | xargs kill -9"
abbr cf nvim ~/.config/omf/init.fish
# eval (direnv hook fish)
