# Copyright (c) 2026 Gecko Robotics, Inc. All rights reserved.
from enum import Enum
from dataclasses import dataclass
from sys import stderr
import shlex
from subprocess import check_call, check_output
from copy import copy


class TMode(Enum):
    RESET = 0
    BLACK = 30
    RED = 31
    GREEN = 32
    YELLOW = 33
    BLUE = 34
    MAGENTA = 35
    CYAN = 36
    WHITE = 37
    DEFAULT = 39

    BG_BLACK = 40
    BG_RED = 41
    BG_GREEN = 42
    BG_YELLOW = 43
    BG_BLUE = 44
    BG_MAGENTA = 45
    BG_CYAN = 46
    BG_WHITE = 47
    BG_DEFAULT = 49

    BOLD = 1
    DIM = 2

    def __str__(self):
        return str(self.value)


def _tmode(*modes):
    return f"\033[{';'.join([str(m) for m in modes])}m"


def _treset():
    return _tmode(TMode.RESET)


def _tstring(modes, msg) -> str:
    return _tmode(*modes) + msg + _treset()


def _tprint(modes, *args, **kwargs):
    print(_tmode(*modes), *args, _treset(), **kwargs)


@dataclass
class LogMode:
    tag_modes: list[TMode]
    txt_modes: list[TMode]
    tag_name: str | None = None

    def _tag(self) -> str:
        if not self.tag_name:
            return ""
        return _tstring(self.tag_modes, f" {self.tag_name} ")

    def log(self, *args, **kwargs):
        print(
            self._tag(),
            _tmode(*self.txt_modes),
            *args,
            _treset(),
            file=stderr,
            **kwargs,
        )


INFO = LogMode(
    tag_modes=[TMode.BOLD, TMode.BG_CYAN, TMode.BLACK],
    txt_modes=[TMode.CYAN],
    tag_name="INFO",
)

OKAY = LogMode(
    tag_modes=[TMode.BOLD, TMode.BG_GREEN, TMode.BLACK],
    txt_modes=[TMode.GREEN],
    tag_name="OKAY",
)

WARN = LogMode(
    tag_modes=[TMode.BOLD, TMode.BG_YELLOW, TMode.BLACK],
    txt_modes=[TMode.YELLOW],
    tag_name="WARN",
)

FAIL = LogMode(
    tag_modes=[TMode.BOLD, TMode.BG_MAGENTA, TMode.BLACK],
    txt_modes=[TMode.MAGENTA],
    tag_name="FAIL",
)

ERROR = LogMode(
    tag_modes=[TMode.BOLD, TMode.BG_RED, TMode.BLACK],
    txt_modes=[TMode.RED],
    tag_name="FAIL",
)
ERROR.tag_name = "ERRR"


info = INFO.log
warn = WARN.log
okay = OKAY.log
fail = FAIL.log
error = ERROR.log


def run(commands: str, **kwargs) -> int:
    info("🏃 ", commands)
    return check_call(shlex.split(commands), **kwargs)


if __name__ == "__main__":
    info("this is info")
    warn("this is a warning")
    okay("this is okay")
    fail("this is a failure")
    error("this is an error")
    run("echo yes")
