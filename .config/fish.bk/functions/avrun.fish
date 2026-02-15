function avrun --description 'bazel run av binary in current folder'
    argparse -i "R/force_rebuild" -- $argv
    if test -n "$_flag_force_rebuild"; or not test -f $AV/bazel-bin/$argv[1]
        set -l cwd $PWD
        cd $AV
        string match -rq '(?<dir>[\w/]*)/(?<bin>\w+)' $argv[1]
        bazel build //$dir:$bin; or begin; cd $cwd; return 1; end;
        cd $cwd
    end
    $AV/bazel-bin/$argv[1] $argv[2..]
end
