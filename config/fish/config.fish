if status is-interactive
    # Commands to run in interactive sessions can go here
    starship init fish | source
    abbr --add od nvim ~/Obsidian/brain/Daily/(date +%Y-%m-%d).md
    abbr --add ot --set-cursor "nvim ~/Obsidian/brain/Thoughts/%.md"
    abbr --add oi --set-cursor "nvim ~/Obsidian/brain/Inbox/%.md"
    abbr --add op --set-cursor "nvim ~/Obsidian/brain/Projects/%.md"
end

# bun
set -Ux BUN_INSTALL "/Users/HuXiukun/.bun"
fish_add_path "/Users/HuXiukun/.bun/bin"

#set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME ; set -gx PATH $HOME/.cabal/bin /Users/HuXiukun/.ghcup/bin $PATH # ghcup-env
set -q GHCUP_INSTALL_BASE_PREFIX[1]; or set GHCUP_INSTALL_BASE_PREFIX $HOME
set -gx PATH $HOME/.cabal/bin /Users/HuXiukun/.ghcup/bin $PATH # ghcup-env

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
if test -f /opt/homebrew/Caskroom/miniconda/base/bin/conda
    eval /opt/homebrew/Caskroom/miniconda/base/bin/conda "shell.fish" hook $argv | source
else
    if test -f "/opt/homebrew/Caskroom/miniconda/base/etc/fish/conf.d/conda.fish"
        . "/opt/homebrew/Caskroom/miniconda/base/etc/fish/conf.d/conda.fish"
    else
        set -x PATH /opt/homebrew/Caskroom/miniconda/base/bin $PATH
    end
end
# <<< conda initialize <<<
