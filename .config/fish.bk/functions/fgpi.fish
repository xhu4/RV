# Defined via `source`
function fgpi --wraps='avrun localization/global_pose/find_global_pose_intervals' --description 'alias fgpi=avrun localization/global_pose/find_global_pose_intervals'
  avrun localization/global_pose/find_global_pose_intervals $argv; 
end
