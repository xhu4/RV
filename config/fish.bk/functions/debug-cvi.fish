function debug-cvi
  argparse 't/tds=' 'i/id=' -- $argv
  set -l out_dir /home/xihu/mapbuild/output_verif/$_flag_t/
  mkdir -p $out_dir
  tf tds:///context/$_flag_t/feature/goto_compare_verification_intervals_plys/$_flag_i.tar.gz --output_file $out_dir/$_flag_i.tar.gz
  tar -xzvf $out_dir/$_flag_i.tar.gz -C $out_dir/
  rm $out_dir/$_flag_i.tar.gz
end
