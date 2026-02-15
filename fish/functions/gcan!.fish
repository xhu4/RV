function gcan! --wraps='git commit --amend --no-edit' --wraps='git commit -m --amend --no-edit' --wraps='git commit -a --amend --no-edit' --description 'alias gcan!=git commit -a --amend --no-edit'
  git commit -a --amend --no-edit $argv; 
end
