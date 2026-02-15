function gfpcp --wraps='git fetch origin master:master && git pull --no-edit && bonsai cascade && bonsai push' --description 'alias gfpcp=git fetch origin master:master && git pull --no-edit && bonsai cascade && bonsai push'
  git fetch origin master:master && git pull --no-edit && bonsai cascade && bonsai push $argv
        
end
