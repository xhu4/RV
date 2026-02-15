package rv

import (
    "crypto/sha256"
    "encoding/hex"
    "errors"
    "fmt"
    "io"
    "net/http"
    "os"
    "os/exec"
    "path/filepath"
    "strings"
)

func HomeDir() string {
    if h, err := os.UserHomeDir(); err == nil && h != "" {
        return h
    }
    if h := os.Getenv("HOME"); h != "" {
        return h
    }
    return "/"
}

// ConfDir returns XDG_CONFIG_HOME or $HOME/.config
func ConfDir() string {
    if v := os.Getenv("XDG_CONFIG_HOME"); v != "" {
        return v
    }
    return filepath.Join(HomeDir(), ".config")
}

// RepoRoot returns the repository root. Prefers RV_REPO_ROOT; else CWD.
func RepoRoot() string {
    if v := os.Getenv("RV_REPO_ROOT"); v != "" {
        return v
    }
    dir, err := os.Getwd()
    if err != nil {
        return "."
    }
    return dir
}

func Has(prog string) bool {
    if _, err := exec.LookPath(prog); err == nil {
        return true
    }
    // also treat existing path as available
    if _, err := os.Stat(prog); err == nil {
        return true
    }
    return false
}

func LookPath(prog string) (string, error) {
    return exec.LookPath(prog)
}

// Run executes a shell command with logging.
func Run(cmd string) error {
    Info("🏃 %s", cmd)
    c := exec.Command("bash", "-lc", cmd)
    c.Stdout = os.Stdout
    c.Stderr = os.Stderr
    return c.Run()
}

func Sha256(path string) (string, error) {
    f, err := os.Open(path)
    if err != nil {
        return "", err
    }
    defer f.Close()
    h := sha256.New()
    if _, err := io.Copy(h, f); err != nil {
        return "", err
    }
    return hex.EncodeToString(h.Sum(nil)), nil
}

func VerifySha256(path, expected string) error {
    got, err := Sha256(path)
    if err != nil {
        return err
    }
    if strings.EqualFold(got, expected) {
        Okay("SHA-256 verified: %s", got)
        return nil
    }
    return fmt.Errorf("SHA-256 mismatch: got %s expected %s", got, expected)
}

func Download(url, out string) error {
    Info("Downloading %s -> %s", url, out)
    resp, err := http.Get(url)
    if err != nil {
        return err
    }
    defer resp.Body.Close()
    if resp.StatusCode < 200 || resp.StatusCode >= 300 {
        return fmt.Errorf("download failed: %s", resp.Status)
    }
    if err := os.MkdirAll(filepath.Dir(out), 0o755); err != nil {
        return err
    }
    f, err := os.Create(out)
    if err != nil {
        return err
    }
    defer f.Close()
    _, err = io.Copy(f, resp.Body)
    return err
}

func addSuffix(path, suffix string) string {
    dir := filepath.Dir(path)
    base := filepath.Base(path)
    return filepath.Join(dir, base+suffix)
}

var ErrUnsupported = errors.New("unsupported platform")
