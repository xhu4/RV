function remove-weight
  argparse 't/tile=' 'a/atlas=' -- $argv
  if ! test -n "$_flag_t" 
    echo "need -t/--tile" >&2
    return 1
  end

  if test -n "$_flag_a"
    set atlas_param -a $_flag_a
  end

  set -l weight_node (get-weight-node -t $_flag_t $atlas_param)
  if test -n "$weight_node"
    echo deleting node $weight_node
    avrun atlas/tools/delete_nodes -n $weight_node $atlas_param
  else
    echo weight node not found for tile $_flag_t
  end
end
