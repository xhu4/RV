# Defined in /tmp/fish.FYMswz/bazel-test-all.fish @ line 2
function bazel-test-all
  for config in clang11 perception_dev 
    set_color blue; echo "> bazel test --config=$config $argv"; set_color normal;
    bazel test --config=$config --config=remote $argv
  end
end
