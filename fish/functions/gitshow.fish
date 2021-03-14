# Defined via `source`
function gitshow --wraps='git show $argv | bat -l rs' --description 'alias gitshow=git show $argv | bat -l rs'
  git show $argv | bat -l rs $argv; 
end
