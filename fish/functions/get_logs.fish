# Defined in /tmp/fish.rlacOg/get_logs.fish @ line 2
function get_logs
  argparse -i a/atlas= t/tiles=+ -- --atlas=/data/tiles/earth.sqlite $argv
  for tile in $_arg_tiles
    echo $tile
    avrun localization/global_pose/get_surfel_tile_build_input -a $_arg_atlas -t $tile --log_ids_only
  end
end
