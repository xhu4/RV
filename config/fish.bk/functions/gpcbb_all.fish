function gpcbb_all
  argparse -i 'm/map_build_id=' 't/bbox_timestamp_sec=' 'o/output_dir=' 'b/bbox_size_m=' 'p/point_stride=' -- -b100 -p4 $argv
  for spline in initialized_gps initialized_final optimized_gps optimized_final
    gpcbb --map_build_id $_flag_m --spline_type {$spline}_spline_trajectory --bbox_timestamp_sec $_flag_t --output_dir $_flag_o/$spline/ --bbox_size_m $_flag_b --point_stride $_flag_p $argv
  end
end
