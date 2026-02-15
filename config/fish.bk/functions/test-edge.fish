function test-edge
  argparse -N2 -X2 'a/atlas=' -- $argv
  or return

  if test -z "$_flag_a"
    echo "need -a/--atlas"
    return 1
  end

  set t1 $argv[1]
  set t2 $argv[2]

  echo testing align unweighted $t1 with weighted $t2
  avrun atlas/tools/delete_edges --edges "$t1:$t2" --atlas ~/tmp.sqlite
  remove-weight -t $t1 -a ~/tmp.sqlite
  avrun localization/global_pose/surfel_weighting/create_surfel_weights_main --node $t2 --input_atlas ~/tmp.sqlite || return 2
  avrun localization/global_pose/tile_alignment/align_surfel_tiles --edge "$t1:$t2" --atlas ~/tmp.sqlite --write_back "master weighted $t1"

end
