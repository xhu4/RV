package main

func init() {
	const launchdDir = "/Library/LaunchDaemons"

	platforms["darwin"] = platform{
		Guard: guardSnippets{
			ScheduleShutdown: `touch /tmp/bedtime-shutdown.lock` +
				` && shutdown -h +5 "Bedtime guard: shutting down in 5 minutes..."` +
				` ; rm -f /tmp/bedtime-shutdown.lock`,
			IsPending: `[ -f /tmp/bedtime-shutdown.lock ]`,
			NotifyCmd: `osascript -e 'display notification "Shutting down in 5 minutes — save your work!" with title "Bedtime" sound name "Basso"'`,
		},
		FileSpecs: []fileSpec{
			{"/usr/local/bin/bedtime-shutdown.sh",            guardScriptTmpl,        0755},
			{launchdDir + "/com.bedtime.shutdown.plist",      macOSShutdownPlistTmpl, 0644},
			{launchdDir + "/com.bedtime.guard.plist",         macOSGuardPlistTmpl,    0644},
		},
		EnableMsg: "\n=== Loading launchd daemons ===",
		EnableCmds: []cmdSpec{
			{args: []string{"launchctl", "unload", launchdDir + "/com.bedtime.shutdown.plist"}, ignoreError: true},
			{args: []string{"launchctl", "load", "-w", launchdDir + "/com.bedtime.shutdown.plist"}},
			{args: []string{"launchctl", "unload", launchdDir + "/com.bedtime.guard.plist"}, ignoreError: true},
			{args: []string{"launchctl", "load", "-w", launchdDir + "/com.bedtime.guard.plist"}},
		},
		HelpText: `
Useful commands:
  sudo launchctl unload /Library/LaunchDaemons/com.bedtime.shutdown.plist
                                        # disable bedtime shutdown
  sudo launchctl load   /Library/LaunchDaemons/com.bedtime.shutdown.plist
                                        # re-enable it
  sudo shutdown -c                      # cancel a pending 5-min shutdown
`,
	}
}
