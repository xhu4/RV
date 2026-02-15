function bcal --wraps='avrun experimental/kylelutz/query_best_calibration --cloud_read --log_id' --description 'alias bcal=avrun experimental/kylelutz/query_best_calibration --cloud_read --log_id'
  avrun experimental/kylelutz/query_best_calibration --cloud_read --log_id $argv; 
end
