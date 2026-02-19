#!/usr/bin/env python3

import glob
import os

from color import okay, info
from sysutil import run_cmd, has, link, SCRIPT_DIR
from tempfile import TemporaryDirectory


def install_stack():
    if has("stack"):
        return
    info("Installing stack...")
    run_cmd("curl -sSL https://get.haskellstack.org/ | sh")
    okay("Success.")


def install_kmonad():
    if has("kmonad"):
        return
    info("Cloning kmonad...")
    with TemporaryDirectory() as tmpdir:
        install_stack()
        run_cmd(f"git clone https://github.com/kmonad/kmonad {tmpdir}")
        info("Building and installing kmonad...")
        run_cmd(f"stack install {tmpdir}")


def symlink_config():
    print("start")
    for file in glob.glob("../config/kmonad/*.kbd"):
        print(file)
        basename = os.path.basename(file)
        link(file, f"/etc/kmonad/{basename}", sudo=True)
    else:
        print("No file found in", "../config/kmonad/*.kbd")


if __name__ == "__main__":
    install_kmonad()
    symlink_config()
