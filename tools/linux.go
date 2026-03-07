package main

func init() {
	platforms["linux"] = platform{
		Guard: guardSnippets{
			ScheduleShutdown: `shutdown +5 "Bedtime guard: shutting down in 5 minutes..."`,
			IsPending:        `shutdown --show 2>/dev/null | grep -q "shutdown scheduled"`,
		},
		FileSpecs: []fileSpec{
			{"/usr/local/bin/bedtime-shutdown.sh",         guardScriptTmpl,           0755},
			{"/etc/systemd/system/bedtime.service",         linuxServiceUnitTmpl,      0644},
			{"/etc/systemd/system/bedtime.timer",           linuxTimerUnitTmpl,        0644},
			{"/etc/systemd/system/bedtime-guard.service",   linuxGuardServiceUnitTmpl, 0644},
		},
		EnableMsg: "\n=== Enabling systemd units ===",
		EnableCmds: []cmdSpec{
			{args: []string{"systemctl", "daemon-reload"}},
			{args: []string{"systemctl", "enable", "--now", "bedtime.timer"}},
			{args: []string{"systemctl", "enable", "--now", "bedtime-guard.service"}},
		},
		HelpText: `
Useful commands:
  sudo shutdown -c                      # cancel a pending 5-min shutdown
  sudo systemctl stop  bedtime.timer    # skip tonight's hard shutdown
  sudo systemctl start bedtime.timer    # re-arm it
  systemctl list-timers                 # see when next trigger fires
`,
	}
}
