package rv

import (
    "fmt"
    "os"
    "os/exec"
    "path/filepath"
    "runtime"
)

// InstallBrew installs Homebrew when missing.
func InstallBrew() error {
    if Has("brew") {
        Okay("Homebrew already installed")
        return nil
    }
    Info("Installing Homebrew...")
    // Use the official installer via curl. This requires network and user permission.
    return Run(`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`)
}

type FishOptions struct {
    ConfDir               string
    DoDefaultShell        bool
    DoStarship            bool
    StarshipSHA256        string
    AllowUnsignedStarship bool
}

func InstallFish(opts FishOptions) error {
    if opts.ConfDir == "" {
        opts.ConfDir = ConfDir()
    }

    if !Has("fish") {
        Info("Installing fish...")
        switch ThisOS() {
        case "Linux":
            if Has("apt-get") {
                if err := Run("sudo apt-get update"); err != nil { return err }
                if err := Run("sudo apt-get install -y software-properties-common curl"); err != nil { return err }
                if err := Run("sudo apt-add-repository -y ppa:fish-shell/release-3"); err != nil { return err }
                if err := Run("sudo apt-get update"); err != nil { return err }
                if err := Run("sudo apt-get install -y fish"); err != nil { return err }
            }
        case "Darwin":
            if Has("brew") {
                if err := Run("brew install fish"); err != nil { return err }
            }
        }
    } else {
        Okay("fish found")
    }

    if opts.DoStarship && !Has("starship") {
        Info("Installing starship...")
        if Has("brew") {
            _ = Run("brew install starship")
        } else if Has("apt-get") {
            _ = Run("sudo apt-get update && sudo apt-get install -y starship || true")
        }
        if !Has("starship") {
            // Fallback to official installer
            script := filepath.Join(os.TempDir(), "starship_install.sh")
            if err := Download("https://starship.rs/install.sh", script); err != nil {
                return err
            }
            if opts.StarshipSHA256 != "" {
                if err := VerifySha256(script, opts.StarshipSHA256); err != nil { return err }
            } else if !opts.AllowUnsignedStarship {
                return fmt.Errorf("refusing to run unsigned Starship installer; provide --starship-sha256 or --allow-unsigned-starship")
            } else {
                Warn("Running unsigned Starship installer")
            }
            if err := Run("sh \"" + script + "\" -y"); err != nil { return err }
            _ = os.Remove(script)
        }
    } else {
        Okay("starship found or skipped")
    }

    // Try installing fzf and bat
    if Has("brew") { _ = Run("brew install fzf bat || true") }
    if Has("apt-get") { _ = Run("sudo apt-get install -y fzf bat || true") }

    if opts.DoDefaultShell && Has("fish") {
        Info("Setting fish as default shell")
        fishPath, _ := LookPath("fish")
        _, _ = os.Stat("/etc/shells")
        _ = Run("grep -qxF '" + fishPath + "' /etc/shells 2>/dev/null || printf '%s\\n' '" + fishPath + "' | sudo tee -a /etc/shells > /dev/null")
        _ = Run("chsh -s '" + fishPath + "' || chsh -s '" + fishPath + "' '$USER'")
    }

    // Link all repo .config subdirectories
    Warn("Linking .config directories")
    if err := LinkDotconfig(opts.ConfDir, ".bk"); err != nil { return err }
    Okay("Config folders linked")

    if Has("fish") {
        _ = Run("fish -c 'fish_add_path \"$HOME/.local/bin\"'")
    }
    return nil
}

func InstallGCloud(doInit bool) error {
    if Has("gcloud") {
        Okay("gcloud already installed")
    } else {
        if Has("apt-get") {
            if err := Run("sudo apt-get update"); err != nil { return err }
            if err := Run("sudo apt-get install -y apt-transport-https ca-certificates gnupg curl"); err != nil { return err }
            if _, err := os.Stat("/usr/share/keyrings/cloud.google.gpg"); os.IsNotExist(err) {
                if err := Run("curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg"); err != nil { return err }
            }
            if _, err := os.Stat("/etc/apt/sources.list.d/google-cloud-sdk.list"); os.IsNotExist(err) {
                if err := Run("echo 'deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main' | sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list"); err != nil { return err }
            }
            if err := Run("sudo apt-get update"); err != nil { return err }
            if err := Run("sudo apt-get install -y google-cloud-cli"); err != nil { return err }
        } else if Has("brew") {
            _ = Run("brew install --cask google-cloud-sdk || brew install google-cloud-sdk || true")
        } else {
            Warn("No supported package manager found for gcloud")
        }
    }
    if doInit && Has("gcloud") {
        return Run("gcloud init")
    }
    return nil
}

type KmonadOptions struct {
    DoService          bool
    KbdRel             string
    ServicePath        string
    StackSHA256        string
    AllowUnsignedStack bool
}

func InstallKmonad(opts KmonadOptions) error {
    if !Has("kmonad") {
        Warn("Installing Haskell Stack...")
        if Has("brew") {
            _ = Run("brew install haskell-stack")
        } else if Has("apt-get") {
            _ = Run("sudo apt-get update")
            _ = Run("sudo apt-get install -y haskell-stack || sudo apt-get install -y stack || true")
        }
        if !Has("stack") {
            script := filepath.Join(os.TempDir(), "stack_install.sh")
            if err := Download("https://get.haskellstack.org/", script); err != nil { return err }
            if opts.StackSHA256 != "" {
                if err := VerifySha256(script, opts.StackSHA256); err != nil { return err }
            } else if !opts.AllowUnsignedStack {
                return fmt.Errorf("refusing to run unsigned Stack installer; provide --stack-sha256 or --allow-unsigned-stack")
            } else {
                Warn("Running unsigned Stack installer")
            }
            if err := Run("sh '" + script + "'"); err != nil { return err }
            _ = os.Remove(script)
        }
        Warn("Cloning kmonad and building...")
        tmpdir := filepath.Join(os.TempDir(), "kmonad-src")
        _ = os.RemoveAll(tmpdir)
        if err := Run("git clone https://github.com/kmonad/kmonad '" + tmpdir + "'"); err != nil { return err }
        if err := Run("stack install '" + tmpdir + "'"); err != nil { return err }
    }

    Warn("Linking keyboard files and service...")
    if opts.KbdRel == "" { opts.KbdRel = "kmonad/cherry.kbd" }
    if err := Link(opts.KbdRel, filepath.Join(HomeDir(), ".cherry.kbd"), ".bk"); err != nil { return err }
    if opts.DoService {
        if err := Link("kmonad/kmonad.service", opts.ServicePath, ".bk"); err != nil { return err }
        _ = Run("sudo systemctl daemon-reload")
        _ = Run("sudo systemctl start kmonad")
        _ = Run("sudo systemctl enable kmonad")
    }
    Okay("kmonad setup complete")
    return nil
}

// InstallNvim sets up neovim, links configs, installs tmux & fonts where possible.
func InstallNvim() error {
    // brew/apt handled in InstallLinux
    // Link configs
    if err := LinkDotconfig(ConfDir(), ".bk"); err != nil { return err }
    // Fonts and tmux
    _ = Run("mkdir -p '$HOME/.local/share/fonts'")
    // If FiraCode.zip exists, attempt unzip via available tools
    fira := filepath.Join(RepoRoot(), "fonts", "FiraCode.zip")
    if _, err := os.Stat(fira); err == nil {
        if Has("unzip") {
            _ = Run("unzip -o '" + fira + "' -d '$HOME/.local/share/fonts'")
        } else if Has("brew") {
            _ = Run("brew install unzip && unzip -o '" + fira + "' -d '$HOME/.local/share/fonts'")
        } else if Has("apt-get") {
            _ = Run("sudo apt-get install -y unzip && unzip -o '" + fira + "' -d '$HOME/.local/share/fonts'")
        }
    }
    if Has("brew") {
        _ = Run("brew install tmux lazygit")
    } else if Has("apt-get") {
        _ = Run("sudo apt-get install -y tmux xsel wl-clipboard")
    }
    if _, err := os.Stat(filepath.Join(HomeDir(), ".tmux", "plugins", "tpm")); os.IsNotExist(err) {
        _ = Run("git clone https://github.com/tmux-plugins/tpm '$HOME/.tmux/plugins/tpm'")
    }
    _ = Link(".tmux.conf", filepath.Join(HomeDir(), ".tmux.conf"), ".bk")
    _ = Run(`if [ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins.sh" ]; then "$HOME/.tmux/plugins/tpm/bin/install_plugins.sh"; fi`)
    return nil
}

// InstallLinux is the meta-setup for Linux machines.
func InstallLinux() error {
    if Has("brew") {
        _ = Run("brew install neovim")
    } else if Has("apt-get") {
        _ = Run("sudo apt-get install -y neovim")
    }
    return InstallNvim()
}

// Helpers
func ThisOS() string {
    switch runtime.GOOS {
    case "darwin":
        return "Darwin"
    case "linux":
        return "Linux"
    case "windows":
        return "Windows"
    default:
        return "Unknown"
    }
}

// ensure exec is referenced to silence unused import if functions are not used in some builds
var _ = exec.ErrNotFound
