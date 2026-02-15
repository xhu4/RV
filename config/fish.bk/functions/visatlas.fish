# Defined in /tmp/fish.VphKRG/visatlas.fish @ line 2
function visatlas
  argparse -i 'a/atlas=' 't/tile=?' -- --atlas=/data/atlas/earth.sqlite $argv
  test -n "$_flag_tile"; and echo "tile specified as $_flag_tile"; or echo "tile not specified"
  avrun atlas/tools/visualize_atlas --atlas $_flag_atlas (test -n "$_flag_tile"; and echo "--root=$_flag_tile") $argv
end
