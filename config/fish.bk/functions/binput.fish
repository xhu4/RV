function binput --wraps='avrun localization/global_pose/get_surfel_tile_build_input' --wraps='avrun localization/global_pose/get_surfel_tile_build_input --extract_optimized_trajectory_logs' --description 'alias binput=avrun localization/global_pose/get_surfel_tile_build_input --extract_optimized_trajectory_logs'
  avrun localization/global_pose/get_surfel_tile_build_input --atlas /data/atlas/earth.sqlite --extract_optimized_trajectory_logs $argv; 
end
