function lpi --wraps='avrun cloud/mapping/temp_data_store/cli/list_part_ids' --wraps='avrun cloud/mapping/temp_data_store/cli/tds_list_part_ids' --wraps='avrun cloud/mapping/temp_data_store/cli/tds_list_part_ids --uri' --description 'alias lpi=avrun cloud/mapping/temp_data_store/cli/tds_list_part_ids --uri'
  avrun cloud/mapping/temp_data_store/cli/tds_list_part_ids --uri $argv; 
end
