function vst-all
  set -l MAPBUILD_ID $argv[1]
  set -l LOGS (goto-input-logs $MAPBUILD_ID)
  for spline_type in initialized_gps_spline_trajectory optimized_gps_spline_trajectory initialized_final_spline_trajectory optimized_final_spline_trajectory
    echo "Extracting $spline_type..."
    vst --map_build_id $MAPBUILD_ID --spline_type $spline_type --log_ids $LOGS --output_ply_dir ~/mapbuild/goto-debug/$MAPBUILD_ID/$spline_type/
  end
  echo "Done"
end
