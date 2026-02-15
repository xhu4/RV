function srs-amendments
    argparse "t/task=" "o/output=" -- $argv
    rm -f "$_flag_o"
    for task in (aws s3 cp s3://aurora-cloud-swe-prod-batch-artifacts/logs/$_flag_t/subtask_ids -)
        srsctl logs $task | grep "Output log_id" | awk '{if (NR == 1) {print substr($3, 2, length($3)-2)}}' >>"$_flag_o"
    end
end
