# Defined in /tmp/fish.NSMHUh/latest-job.fish @ line 2
function latest-job --wraps=infra\ batch\ scan-jobs\ \|\ tail\ -1\ \|\ awk\ \'\{print\ \;\}\' --description alias\ latest-job=infra\ batch\ scan-jobs\ \|\ tail\ -1\ \|\ awk\ \'\{print\ \;\}\'
  infra batch scan-jobs | tail -1 | awk '{print $1;}' $argv; 
end
