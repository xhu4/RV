function discover-etl --wraps='bazel run -c opt //perf/etl/tools:discover_etl -- --log_id' --description 'alias discover-etl=bazel run -c opt //perf/etl/tools:discover_etl -- --log_id'
  bazel run -c opt //perf/etl/tools:discover_etl -- --log_id $argv
        
end
