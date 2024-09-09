starship init fish | source
fzf --fish | source
fish_vi_key_bindings
set -xg EDITOR nvim

abbr erc nvim ~/.config/omf/init.fish
abbr gst git status
abbr gco git checkout
abbr gb git branch -v
abbr gcan git commit --amend --no-edit
abbr gcan! git commit --amend --no-edit -a
abbr xa xrandr --auto
abbr ofsc xrandr --output DP-3-1 --mode 1920x1080 --left-of DP-3-3 --output DP-3-3 --mode 1920x1080 --output eDP-1 --off
# eval (direnv hook fish)
