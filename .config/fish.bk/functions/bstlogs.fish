function bstlogs --wraps='avrun localization/global_pose/get_tile_global_pose_amendment_info -a /data/atlas/earth.sqlite' --description 'alias bstlogs=avrun localization/global_pose/get_tile_global_pose_amendment_info -a /data/atlas/earth.sqlite'
  avrun localization/global_pose/get_tile_global_pose_amendment_info -a /data/atlas/earth.sqlite $argv
        
end
