# Defined via `source`
function batdiff --wraps='git diff --name-only --diff-filter=d | xargs bat --diff' --description 'alias batdiff=git diff --name-only --diff-filter=d | xargs bat --diff'
  git diff --name-only --diff-filter=d | xargs bat --diff $argv; 
end
