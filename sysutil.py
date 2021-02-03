from color import warn, okay
import os
import shutil
import shlex
from subprocess import run, check_call

SCRIPT_DIR = os.path.abspath(os.path.dirname(__file__))
HOME = os.getenv('HOME')


def has(prog: str):
    return run(["which", prog]).returncode == 0 or os.path.exists(prog)


def run_cmd(commands: str):
    check_call(shlex.split(commands))


def link(path_from_this: str, dst_path: str, backup: str):
    if os.path.exists(dst_path):
        warn(f'{dst_path} already exists. Moving it to {backup}')
        shutil.move(dst_path, backup)
    src_path = os.path.join(SCRIPT_DIR, path_from_this)
    run_cmd(f'ln -s {src_path} {dst_path}')
    okay("Created link:\n\t{src_path} ->\n\t\t{dst_path}")


def link_to_home(path_from_this: str, backup_suffix: str):
    link(path_from_this, os.path.join(HOME, path_from_this),
         os.path.join(HOME, path_from_this + backup_suffix))
