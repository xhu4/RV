function goto-input-logs
  fr tds:///context/$argv[1]/feature/extended_input_log_uris | grep "uri:" | awk '{print $2}'
end
