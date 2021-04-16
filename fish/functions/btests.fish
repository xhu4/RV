# Defined in /tmp/fish.YVRjCs/btests.fish @ line 2
function btests
  for file in (git diff --name-only HEAD master)
    echo "Testing all rdeps of $file"
    bazel-test-rdeps $file
  end
end
