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
# eval (direnv hook fish)
