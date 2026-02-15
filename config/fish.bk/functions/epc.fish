function epc --wraps='avrun common/lidar/tools/extract_point_clouds --log_id' --wraps='avrun localization/na/tools/generate_pointclouds_from_log/generate_pointclouds_from_log' --description 'alias epc=avrun localization/na/tools/generate_pointclouds_from_log/generate_pointclouds_from_log'
  avrun localization/na/tools/generate_pointclouds_from_log/generate_pointclouds_from_log $argv; 
end
