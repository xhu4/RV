# Defined via `source`
function vla --wraps='avrun localization/global_pose/visualize_lidar_alignment' --description 'alias vla=avrun localization/global_pose/visualize_lidar_alignment'
  avrun localization/global_pose/visualize_lidar_alignment --atlas /data/atlas/earth.sqlite $argv; 
end
