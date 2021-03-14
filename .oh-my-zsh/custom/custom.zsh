alias ec='$EDITOR ~/.oh-my-zsh/custom/custom.zsh'
alias ag='alias | grep'
alias av='$EDITOR $AV'
alias sc='source ~/.zshrc'
alias nvrc='nvim ~/.config/nvim/init.vim'
alias gb='git br'
alias gbd='git br -d'
function buildserver() {gcloud compute --project "aurora-localization-dev" ssh --zone "us-east1-d" --ssh-flag="-ServeAliveInterval=30" xihu-mapbuild-${1} -- -L 808${1}:localhost:80}

bzlrun() {
  rel_bin=$1
  shift 1
  bin=${AV%/}/bazel-bin/$rel_bin
  if [ ! -f $bin ]; then
    pushd $AV
    bazel build //$(echo $rel_bin | sed 's/\(.*\)\//\1:/')
    popd
  fi
  $bin $@
}

findtile() {
  radius=${3:-100}
  bzlrun atlas/tools/find_tiles_near_latlon --atlas /data/atlas/earth.sqlite --latitude ${1%,} --longitude $2 --radius ${radius}
}

visatlas(){
  bzlrun atlas/tools/visualize_atlas --atlas $@
}

vistile() {
  atlas="${2:-/data/atlas/earth.sqlite}"
  bzlrun atlas/tools/visualize_atlas --atlas ${atlas} --root $1
}

fosctl() {
  bzlrun cloud/fan_out_service/fosctl/fosctl -- $@
}

cloudrun() {
  gcloud compute --project "aurora-localization-dev" $1 --zone "us-east1-d" ${@[2,-1]}
}
