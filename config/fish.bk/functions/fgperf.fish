function fgperf
  set -l tmpf (mktemp /tmp/perf-XXX.out)
  set -l fgdir /home/xihu/FlameGraph/
  sudo -E perf record -F 500 -g -o $tmpf $argv
  perf script -i $tmpf | $fgdir/stackcollapse-perf.pl | $fgdir/flamegraph.pl
end
