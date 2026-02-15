function ast --wraps='avrun localization/global_pose/tile_alignment/align_surfel_tile' --wraps='avrun localization/global_pose/tile_alignment/align_surfel_tiles' --description 'alias ast=avrun localization/global_pose/tile_alignment/align_surfel_tiles'
  avrun localization/global_pose/tile_alignment/align_surfel_tiles $argv; 
end
