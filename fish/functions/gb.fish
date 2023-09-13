# Defined via `source`
function gb --wraps='git br' --wraps='bonsai show' --description 'alias gb=bonsai show'
  bonsai show $argv; 
end
