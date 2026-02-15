function get-weight-node
  argparse 't/tile=' 'a/atlas=' -- $argv
  if test -z "$_flag_t" 
    echo "need -t/--tile" >&2
    return 1
  end
  if test -n "$_flag_a"
    set atlas_param -a "$_flag_a"
  end
  atlas list --nodes_only --node_types surfel_weight -n "$_flag_t" "$atlas_param" --list_element_types=0
end
