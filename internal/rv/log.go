package rv

import (
    "fmt"
    "os"
)

const (
    colorOk   = "\033[92m"
    colorWarn = "\033[93m"
    colorInfo = "\033[94m"
    colorErr  = "\033[91m"
    colorEnd  = "\033[0m"
    bgOk      = "\033[102m"
    bgWarn    = "\033[103m"
    bgInfo    = "\033[104m"
    bgErr     = "\033[101m"
    labelFg   = "\033[30m"
)

func label(text, bg string) string {
    padded := fmt.Sprintf("%-2s", text)
    return fmt.Sprintf("%s%s[%s]%s ", bg, labelFg, padded, colorEnd)
}

func Warn(format string, a ...any) {
    fmt.Fprintf(os.Stderr, "%s%s%s\n", label("WR", bgWarn), colorWarn, fmt.Sprintf(format, a...))
    fmt.Fprint(os.Stderr, colorEnd)
}

func Okay(format string, a ...any) {
    fmt.Fprintf(os.Stderr, "%s%s%s\n", label("OK", bgOk), colorOk, fmt.Sprintf(format, a...))
    fmt.Fprint(os.Stderr, colorEnd)
}

func Info(format string, a ...any) {
    fmt.Fprintf(os.Stderr, "%s%s%s\n", label("IN", bgInfo), colorInfo, fmt.Sprintf(format, a...))
    fmt.Fprint(os.Stderr, colorEnd)
}

func Error(format string, a ...any) {
    fmt.Fprintf(os.Stderr, "%s%s%s\n", label("ER", bgErr), colorErr, fmt.Sprintf(format, a...))
    fmt.Fprint(os.Stderr, colorEnd)
}

