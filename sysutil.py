from color import warn, okay

import os
import shutil
import shlex
from subprocess import run, check_call, check_output
from enum import Enum
from platform import system

SCRIPT_DIR = os.path.abspath(os.path.dirname(__file__))
HOME = os.getenv("HOME")


class OS(Enum):
    Darwin = 1
    Windows = 2
    Linux = 3
    Unknown = 999


def this_os():
    sys = system()
    if sys == "Darwin":
        return OS.Darwin
    if sys == "Windows":
        return OS.Windows
    if sys == "Linux":
        return OS.Linux
    else:
        return OS.Unknown


def os_pick(windows=None, darwin=None, linux=None, other=None):
    """Return function based on this system"""
    os = this_os()
    if os == OS.Windows:
        result = windows
    if os == OS.Darwin:
        result = darwin
    if os == OS.Linux:
        result = linux
    if result is None:
        result = other
    if result is None:
        raise NotImplementedError(f"System {system} not supported.")
    else:
        return result


def has(prog: str):
    return run(["which", prog]).returncode == 0 or os.path.exists(prog)


def run_cmd(commands: str):
    warn("Running command:", commands)
    check_call(shlex.split(commands))


def add_suffix(path: str, suffix: str):
    return os.path.join(os.path.dirname(path), os.path.basename(path) + suffix)


def link(src: str, dst_path: str, backup_suffix: str = ".bk"):
    dst_dir = os.path.dirname(dst_path)
    if has(dst_path):
        shutil.move(dst_path, add_suffix(dst_path, backup_suffix))
    elif not os.path.isdir(dst_dir):
        os.makedirs(dst_dir)
    run_cmd(f"ln -s {os.path.join(SCRIPT_DIR, src)} {dst_path}")
    okay(f"Created link:")
    okay("\t", check_output(f"ls -ld1 {dst_path}".split()).decode("utf-8"))


def link_to_home(path_from_this: str, backup_suffix: str = ".bk"):
    link(
        path_from_this,
        os.path.join(
            HOME, os.path.dirname(path_from_this), os.path.basename(path_from_this)
        ),
        backup_suffix,
    )
