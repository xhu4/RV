function tf --wraps='avrun cloud/mapping/temp_data_store/cli/tds_blob_transfer_cli' --description 'alias tf=avrun cloud/mapping/temp_data_store/cli/tds_blob_transfer_cli'
  avrun cloud/mapping/temp_data_store/cli/tds_blob_transfer_cli --uri $argv; 
end
