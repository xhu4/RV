# Copyright (c) 2026 Gecko Robotics, Inc. All rights reserved.
from enum import Enum
from sys import stderr


class Mode(Enum):
    RESET = (0, None)
    BOLD = (1, 22)
    DIM = (2, 22)
    ITALIC = (3, 23)
    UNDERLINE = (4, 24)


class Color(Enum):
    HEADER = "\033[95m"
    OKBLUE = "\033[94m"
    OKCYAN = "\033[96m"
    OKGREEN = "\033[92m"
    WARNING = "\033[93m"
    FAIL = "\033[91m"
    ENDC = "\033[0m"
    BOLD = "\033[1m"
    UNDERLINE = "\033[4m"


def color_print(color: Color, *args, **kwargs):
    print(color, *args, Color.ENDC, **kwargs)


def color_log(color: Color, *args, **kwargs):
    print(color, *args, Color.ENDC, file=stderr, **kwargs)


def _getprintf(color: Color):
    def f(*args, **kwargs):
        _cprint(color, *args, **kwargs)

    return f


info = print
okay = _getprintf(Color.OKGREEN)
warn = _getprintf(Color.WARNING)
fail = _getprintf(Color.FAIL)
