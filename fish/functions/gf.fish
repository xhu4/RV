# Defined in /tmp/fish.zipBY0/gf.fish @ line 1
function gf
  set current_branch (git rev-parse --abbrev-ref HEAD)
  git checkout master && git pull && git flow
  git checkout $current_branch
end
