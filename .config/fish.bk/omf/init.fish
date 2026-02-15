starship init fish | source
fzf --fish | source
fish_vi_key_bindings
set -xg EDITOR nvim
eval (brew shellenv)

bind \ca beginning-of-line
bind \ce end-of-line

bind super-comma "nvim ~/.config/ghostty/config" repaint
bind -M insert super-comma "nvim ~/.config/ghostty/config" repaint

bind ctrl-comma "nvim ~/.config/omf/init.fish" repaint
bind -M insert ctrl-comma "nvim ~/.config/omf/init.fish" repaint

bind ctrl-shift-comma "omf reload" repaint
bind -M insert ctrl-shift-comma "omf reload" repaint

abbr erc.fish nvim ~/.config/omf/init.fish
abbr erc.ghostty nvim ~/.config/ghostty/config

abbr gco git checkout
abbr gst git status
abbr gcan! git commit -a --amend --no-edit
abbr gb git branch -vv
abbr killport --set-cursor "lsof -ti:% | xargs kill -9"
# eval (direnv hook fish)
