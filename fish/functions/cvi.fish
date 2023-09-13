function cvi
  argparse 'o/out_dir=' 'b/build_id=' 'i/index=' -- $argv
  set -l out_dir $_flag_o
  set -l build_id $_flag_b
  set -l cvi $_flag_i
  set -l tar $cvi.tar.gz

  tf tds:///context/$build_id/feature/goto_compare_verification_intervals_plys/$tar --output_file /tmp/$tar; and \
  mkdir -p $out_dir/$cvi; and \
  tar -xzvf /tmp/$tar -C $out_dir/$cvi; and \
  rm /tmp/$tar
end
