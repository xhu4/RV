function plotgps
  argparse --name=plotgps 'm/mapbuild_id=' 'l/log=' 'o/out_dir=' -- $argv
  set -q $_flag_o; and set -l out $_flag_o; or set -l out /home/xihu/mapbuild/gps_splines/$_flag_m/$_flag_l/
  echo out_dir: $out
  set -l tds_base tds:///context/$_flag_m/container/log/$_flag_l/feature
  avrun localization/goto/debug/gps_splines_python/plot_gps_spline -- --debug-info-uri $tds_base/goto_gps_spline_debug_info --gps-pos-uri $tds_base/goto_position_estimates --debiased-gps-pos-uri $tds_base/goto_gps_spline_debiased_position_estimates --save-dir $out
end
