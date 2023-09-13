# Defined in /tmp/fish.fAkjFF/bazel-test-rdeps.fish @ line 2
function bazel-test-rdeps
  set -l target (bazel query --noshow_loading_progress --noshow_progress $argv[1])
  echo "Testing target $target"
  bazel test $argv[2..] (bazel query --universe_scope=//localization/...,//atlas/... --order_output=no "tests(//localization/... + //atlas/...) intersect allrdeps($target)")
end
