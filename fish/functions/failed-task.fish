# Defined in /tmp/fish.7AA50e/failed-task.fish @ line 2
function failed-task --wraps=infra\ batch\ scan-tasks\ \ \|\ grep\ Failed\ \|\ cut\ -d\ \'\ \'\ -f1
  infra batch scan-tasks $argv | grep Failed | cut -d ' ' -f1; 
end
