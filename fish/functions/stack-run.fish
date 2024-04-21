function stack-run
  set -l target (string replace -r '([\w/]+)/(\w+)\.stack' '//$1:$2_stack' $argv[1])
  set -l build_target_cmd bazel build --config=intel-cuda $target
  set -l build_stack_run_cmd bazel build //common/framework:stack_run
  set -l stack_run_cmd \
  GLOG_logtostderr=1 avrun common/framework/stack_run \
      --config $argv[1] \
      --offline \
      --logger \
      --logtostderr \
      --out.write_locations \
      /data/logs/local \
      --atlas \
      /data/atlas/earth.sqlite \
      --in.log_id \
      \"$argv[2]\" \
      $argv[3..]
    for var in build_target_cmd build_stack_run_cmd stack_run_cmd
        set -l cmd (eval echo \$$var)
        echo -e "\033[36m$cmd\033[0m"
        eval $cmd; or return 1
    end
end
