alias ec='nvim ~/.oh-my-zsh/custom/custom.zsh'
alias ag='alias | grep'
alias av='nvim ~/codes/av'
alias sc='source ~/.zshrc'
alias nvrc='nvim ~/.config/nvim/init.vim'
alias gb='git br'
alias gbd='git br -d'
alias buildserver='gcloud compute --project "aurora-localization-dev" ssh --zone "us-east1-d" --ssh-flag="-ServeAliveInterval=30" xihu-mapbuild-0 -- -L 8081:localhost:80'

findtile() {
    radius=${3:-100}
    ~/codes/av/bazel-bin/atlas/tools/find_tiles_near_latlon --atlas /data/atlas/earth.sqlite --latitude ${1%,} --longitude $2 --radius ${radius}
}

visatlas(){
    ~/codes/av/bazel-bin/atlas/tools/visualize_atlas --atlas $@
}

vistile() {
    atlas="${2:-/data/atlas/earth.sqlite}"
    ~/codes/av/bazel-bin/atlas/tools/visualize_atlas --atlas ${atlas} --root $1
}
fosctl() {
    ~/codes/av/bazel-bin/cloud/fan_out_service/fosctl/fosctl -- $@
}
