function count_angular_fail
  argparse --name="count_angular_fail" "m/mapbuild_id=" "s/spline=" -- $argv
  set -q _flag_m; or begin; echo "-m/--mapbuild_id is required"; return 121; end
  set -q _flag_s; or begin; echo "-s/--spline is required"; return 121; end
  fr tds:///context/$_flag_m/feature/goto_{$_flag_s}_spline_trajectory_verification_data/quality_check | tr ' ' '\n' | grep -c "Angular"
end
