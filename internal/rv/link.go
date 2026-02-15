package rv

import (
    "errors"
    "fmt"
    "os"
    "path/filepath"
)

// Link creates a symlink from dstPath to srcRel (relative to repo root), backing up existing targets.
func Link(srcRel, dstPath, backupSuffix string) error {
    if srcRel == "" || dstPath == "" {
        return errors.New("link requires srcRel and dstPath")
    }
    repo := RepoRoot()
    srcAbs := filepath.Join(repo, srcRel)
    dstDir := filepath.Dir(dstPath)

    // If existing symlink points to same target, do nothing
    if fi, err := os.Lstat(dstPath); err == nil && (fi.Mode()&os.ModeSymlink) != 0 {
        if cur, err := os.Readlink(dstPath); err == nil {
            if cur == srcAbs || cur == srcRel || filepath.Base(cur) == filepath.Base(srcRel) {
                Okay("Already linked: %s -> %s", dstPath, cur)
                return nil
            }
        }
    }

    if _, err := os.Stat(dstPath); err == nil {
        mvTo := addSuffix(dstPath, backupSuffix)
        if err := os.MkdirAll(filepath.Dir(mvTo), 0o755); err != nil {
            return err
        }
        if err := os.Rename(dstPath, mvTo); err != nil {
            return fmt.Errorf("backup existing target: %w", err)
        }
    } else if os.IsNotExist(err) {
        if err := os.MkdirAll(dstDir, 0o755); err != nil {
            return err
        }
    } else if err != nil {
        return err
    }

    // Remove any stale symlink before creating a new one
    _ = os.Remove(dstPath)
    if err := os.Symlink(srcAbs, dstPath); err != nil {
        return err
    }
    Okay("Created link: %s -> %s", dstPath, srcAbs)
    return nil
}

// LinkToHome links a path from repo root to the user's HOME, preserving subdirs
func LinkToHome(rel string, backupSuffix string) error {
    if rel == "" {
        return errors.New("link_to_home requires rel path")
    }
    dst := filepath.Join(HomeDir(), rel)
    return Link(rel, dst, backupSuffix)
}

// LinkDotconfig links each immediate directory under repo .config to user's config dir
func LinkDotconfig(confdir, backupSuffix string) error {
    if confdir == "" {
        confdir = ConfDir()
    }
    cfgRoot := filepath.Join(RepoRoot(), ".config")
    st, err := os.Stat(cfgRoot)
    if err != nil || !st.IsDir() {
        Warn("No .config directory found at repo root: %s", cfgRoot)
        return nil
    }
    entries, err := os.ReadDir(cfgRoot)
    if err != nil {
        return err
    }
    Warn("Linking config directories to: %s", confdir)
    for _, e := range entries {
        if !e.IsDir() {
            continue
        }
        name := e.Name()
        if err := Link(filepath.Join(".config", name), filepath.Join(confdir, name), backupSuffix); err != nil {
            return err
        }
    }
    return nil
}

