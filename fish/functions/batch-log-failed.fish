# Defined in /tmp/fish.Mbgz4d/batch-log-failed.fish @ line 1
function batch-log-failed
  set -l job_name $argv[1]
  set -l failed_task (infra batch scan-tasks $job_name | grep Failed | cut -d ' ' -f1)
  infra batch task-logs $job_name $failed_task
end
