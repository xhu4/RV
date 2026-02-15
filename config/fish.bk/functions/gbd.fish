# Defined via `source`
function gbd --wraps='git br -d' --description 'alias gbd=git br -d'
  git br -d $argv; 
end
