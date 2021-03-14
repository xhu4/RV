set -xg FZF_DEFAULT_OPTS '--preview "bat --color=always --style=numbers --line-range=:500 {}" --height 40% --ansi'
set -xg FZF_DEFAULT_COMMAND 'fd --type file --color=always'
set -xg FZF_CTRL_T_COMMAND $FZF_DEFAULT_COMMAND
