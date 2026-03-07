// deploy-bedtime.go
// Usage: sudo go run . --window 21:00-06:00
// Or build: go build -o deploy-bedtime && sudo ./deploy-bedtime --window 21:00-06:00

package main

import (
	"flag"
	"fmt"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"runtime"
	"strconv"
	"strings"
	"text/template"
	"time"
)

// ---- Sleep window ----------------------------------------------------------

type SleepWindow struct {
	BedtimeHour   int
	BedtimeMinute int
	WakeupHour    int
	WakeupMinute  int
	// 5 minutes before bedtime — used for pre-shutdown notification
	PreBedtimeHour   int
	PreBedtimeMinute int
}

func parseSleepWindow(s string) SleepWindow {
	halves := strings.SplitN(s, "-", 2)
	if len(halves) != 2 {
		log.Fatalf("invalid --window %q: expected HH:MM-HH:MM", s)
	}
	parseHHMM := func(hhmm, side string) (int, int) {
		parts := strings.SplitN(hhmm, ":", 2)
		if len(parts) != 2 {
			log.Fatalf("invalid %s time %q in --window: expected HH:MM", side, hhmm)
		}
		h, err := strconv.Atoi(parts[0])
		if err != nil || h < 0 || h > 23 {
			log.Fatalf("invalid hour in %s time %q", side, hhmm)
		}
		m, err := strconv.Atoi(parts[1])
		if err != nil || m < 0 || m > 59 {
			log.Fatalf("invalid minute in %s time %q", side, hhmm)
		}
		return h, m
	}
	bh, bm := parseHHMM(halves[0], "bedtime")
	wh, wm := parseHHMM(halves[1], "wakeup")
	// Compute 5 minutes before bedtime for pre-shutdown notification
	pre := time.Date(0, 1, 1, bh, bm, 0, 0, time.UTC).Add(-5 * time.Minute)
	return SleepWindow{bh, bm, wh, wm, pre.Hour(), pre.Minute()}
}

// ---- Guard script ----------------------------------------------------------

// guardSnippets holds the OS-specific bash commands injected into the guard script.
type guardSnippets struct {
	ScheduleShutdown string // bash command to schedule a delayed shutdown
	IsPending        string // bash expression: true if a shutdown is already pending
	NotifyCmd        string // bash command to send a user notification
}

// guardScriptData is the complete template data for the guard script.
// It combines the sleep window timings with the platform bash snippets.
type guardScriptData struct {
	SleepWindow
	guardSnippets
}

// ---- Platform config -------------------------------------------------------

// fileSpec describes a single file to be written during deployment.
type fileSpec struct {
	path string
	tmpl string
	mode os.FileMode
}

// cmdSpec describes a shell command to run during the enable phase.
type cmdSpec struct {
	args        []string
	ignoreError bool
}

// platform describes everything deploy needs to know about a target OS.
type platform struct {
	Guard      guardSnippets
	FileSpecs  []fileSpec
	EnableMsg  string
	EnableCmds []cmdSpec
	HelpText   string
}

// Populated by each OS file's init().
var platforms = map[string]platform{}

func deploy(w SleepWindow, dryRun bool) {
	p, ok := platforms[runtime.GOOS]
	if !ok {
		log.Fatalf("unsupported platform: %s", runtime.GOOS)
	}

	g := guardScriptData{
		SleepWindow:   w,
		guardSnippets: p.Guard,
	}

	applyFiles(p.FileSpecs, g, dryRun)
	if dryRun {
		return
	}

	fmt.Println(p.EnableMsg)
	for _, cmd := range p.EnableCmds {
		if cmd.ignoreError {
			exec.Command(cmd.args[0], cmd.args[1:]...).Run()
		} else {
			run(cmd.args[0], cmd.args[1:]...)
		}
	}
	fmt.Print(p.HelpText)
}

// ---- Helpers ---------------------------------------------------------------

func renderTemplate(tmplStr string, data any) string {
	t := template.Must(template.New("").Parse(tmplStr))
	var b strings.Builder
	if err := t.Execute(&b, data); err != nil {
		log.Fatalf("template error: %v", err)
	}
	return b.String()
}

func writeFile(path, content string, mode os.FileMode) {
	if err := os.MkdirAll(filepath.Dir(path), 0755); err != nil {
		log.Fatalf("mkdir %s: %v", filepath.Dir(path), err)
	}
	if err := os.WriteFile(path, []byte(content), mode); err != nil {
		log.Fatalf("write %s: %v", path, err)
	}
	fmt.Printf("  wrote  %s\n", path)
}

func run(name string, args ...string) {
	cmd := exec.Command(name, args...)
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		log.Fatalf("%q failed: %v",
			strings.Join(append([]string{name}, args...), " "), err)
	}
}

func applyFiles(specs []fileSpec, g guardScriptData, dryRun bool) {
	for _, s := range specs {
		content := renderTemplate(s.tmpl, g)
		if dryRun {
			fmt.Printf("──── %s (mode %04o) ────\n%s\n", s.path, s.mode, content)
		} else {
			writeFile(s.path, content, s.mode)
		}
	}
}

// ---- Main ------------------------------------------------------------------

func main() {
	window := flag.String("window", "21:00-06:00", "sleep window as bedtime-wakeup (HH:MM-HH:MM, 24h)")
	dryRun := flag.Bool("dry-run", false,         "print files without writing them")
	flag.Parse()

	if os.Geteuid() != 0 && !*dryRun {
		log.Fatal("must be run as root (or with --dry-run). Try: sudo go run .")
	}

	w := parseSleepWindow(*window)

	fmt.Printf("\n=== Bedtime Shutdown Deployer ===\n")
	fmt.Printf("Platform     : %s\n", runtime.GOOS)
	fmt.Printf("Sleep window : %02d:%02d  →  %02d:%02d\n\n",
		w.BedtimeHour, w.BedtimeMinute, w.WakeupHour, w.WakeupMinute)

	deploy(w, *dryRun)

	if *dryRun {
		fmt.Println("\n[dry-run] No files written. Re-run without --dry-run as root to deploy.")
		return
	}

	fmt.Printf(`
=== Done! ===
Your laptop will shut down at %02d:%02d every night.
If turned on between %02d:%02d and %02d:%02d it will shut down after 5 minutes.
`,
		w.BedtimeHour, w.BedtimeMinute,
		w.BedtimeHour, w.BedtimeMinute,
		w.WakeupHour,  w.WakeupMinute,
	)
}
