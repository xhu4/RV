function initav
  set -l CACHE_FILE /tmp/av-initialized
  if not test -f $CACHE_FILE
    DISPLAY="" infra auth refresh
    cd $AV
    ./tools/bin/gen_compile_commands
    git fetch master origin:master
    cd -
    touch $CACHE_file
  end
end
