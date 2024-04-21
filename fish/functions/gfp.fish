function gfp --wraps='git fetch origin master:master && git pull' --wraps='git fetch && git pull --no-edit' --description 'alias gfp=git fetch && git pull --no-edit'
  git fetch && git pull --no-edit $argv
        
end
