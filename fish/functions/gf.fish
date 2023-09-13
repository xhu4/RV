# Defined in /tmp/fish.WIarAh/gf.fish @ line 2
function gf --wraps='bonsai cascade' --description 'alias gf=bonsai cascade'
  set branch (git symbolic-ref HEAD)
  gco master && bonsai cascade
  gco "$branch"
end
