package main

import (
    "flag"
    "fmt"
    "os"
    "strings"

    "rv/internal/rv"
)

func usage() {
    fmt.Fprintf(os.Stderr, "Usage: %s <command> [args]\n", os.Args[0])
    fmt.Fprintln(os.Stderr, "Commands:")
    fmt.Fprintln(os.Stderr, "  link-dotconfig     Link all .config subdirectories to user config dir")
    fmt.Fprintln(os.Stderr, "  fish               Install/configure fish & starship")
    fmt.Fprintln(os.Stderr, "  brew               Install Homebrew")
    fmt.Fprintln(os.Stderr, "  gcloud             Install and optionally init gcloud")
    fmt.Fprintln(os.Stderr, "  kmonad             Install kmonad and service")
    fmt.Fprintln(os.Stderr, "  nvim               Setup neovim, tmux, fonts, links")
    fmt.Fprintln(os.Stderr, "  linux              General Linux setup (nvim, fonts, tmux)")
    fmt.Fprintln(os.Stderr, "  all                Run brew, fish, linux")
}

func main() {
    if len(os.Args) < 2 {
        usage()
        os.Exit(2)
    }

    cmd := os.Args[1]
    args := os.Args[2:]

    switch cmd {
    case "-h", "--help", "help":
        usage()
        return

    case "link-dotconfig":
        fs := flag.NewFlagSet("link-dotconfig", flag.ExitOnError)
        confdir := fs.String("confdir", rv.ConfDir(), "target config directory")
        backup := fs.String("backup-suffix", ".bk", "backup suffix for existing targets")
        _ = fs.Parse(args)
        if err := rv.LinkDotconfig(*confdir, *backup); err != nil {
            rv.Error("link-dotconfig: %v", err)
            os.Exit(1)
        }

    case "brew":
        if err := rv.InstallBrew(); err != nil {
            rv.Error("brew: %v", err)
            os.Exit(1)
        }

    case "fish":
        fs := flag.NewFlagSet("fish", flag.ExitOnError)
        confdir := fs.String("confdir", rv.ConfDir(), "target config directory")
        noDefaultShell := fs.Bool("no-default-shell", false, "do not set fish as default shell")
        noStarship := fs.Bool("no-starship", false, "skip starship install")
        starshipSHA := fs.String("starship-sha256", "", "starship install script SHA-256")
        allowUnsigned := fs.Bool("allow-unsigned-starship", false, "allow unsigned starship installer")
        _ = fs.Parse(args)
        opts := rv.FishOptions{ConfDir: *confdir, DoDefaultShell: !*noDefaultShell, DoStarship: !*noStarship, StarshipSHA256: strings.TrimSpace(*starshipSHA), AllowUnsignedStarship: *allowUnsigned}
        if err := rv.InstallFish(opts); err != nil {
            rv.Error("fish: %v", err)
            os.Exit(1)
        }

    case "gcloud":
        fs := flag.NewFlagSet("gcloud", flag.ExitOnError)
        noInit := fs.Bool("no-init", false, "do not run gcloud init")
        _ = fs.Parse(args)
        if err := rv.InstallGCloud(!*noInit); err != nil {
            rv.Error("gcloud: %v", err)
            os.Exit(1)
        }

    case "kmonad":
        fs := flag.NewFlagSet("kmonad", flag.ExitOnError)
        doService := fs.Bool("service", true, "install and enable systemd service")
        kbdRel := fs.String("kbd", "kmonad/cherry.kbd", "keyboard file path relative to repo")
        servicePath := fs.String("service-path", "/etc/systemd/system/kmonad.service", "systemd service path")
        stackSHA := fs.String("stack-sha256", "", "stack installer SHA-256")
        allowUnsigned := fs.Bool("allow-unsigned-stack", false, "allow unsigned stack installer")
        _ = fs.Parse(args)
        opts := rv.KmonadOptions{DoService: *doService, KbdRel: *kbdRel, ServicePath: *servicePath, StackSHA256: strings.TrimSpace(*stackSHA), AllowUnsignedStack: *allowUnsigned}
        if err := rv.InstallKmonad(opts); err != nil {
            rv.Error("kmonad: %v", err)
            os.Exit(1)
        }

    case "nvim":
        if err := rv.InstallNvim(); err != nil {
            rv.Error("nvim: %v", err)
            os.Exit(1)
        }

    case "linux":
        if err := rv.InstallLinux(); err != nil {
            rv.Error("linux: %v", err)
            os.Exit(1)
        }

    case "all":
        if err := rv.InstallBrew(); err != nil {
            rv.Error("all: brew: %v", err)
            os.Exit(1)
        }
        if err := rv.InstallFish(rv.FishOptions{ConfDir: rv.ConfDir(), DoDefaultShell: true, DoStarship: true}); err != nil {
            rv.Error("all: fish: %v", err)
            os.Exit(1)
        }
        if err := rv.InstallLinux(); err != nil {
            rv.Error("all: linux: %v", err)
            os.Exit(1)
        }

    default:
        usage()
        os.Exit(2)
    }
}
