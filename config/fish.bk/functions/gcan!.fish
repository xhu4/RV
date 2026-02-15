# Defined via `source`
function gcan! --wraps='git commit -v -a --amend --no-edit' --description 'alias gcan!=git commit -v -a --amend --no-edit'
  git commit -v -a --amend --no-edit $argv; 
end
