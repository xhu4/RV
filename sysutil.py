from color import warn, okay
import os
import shutil
import shlex
from subprocess import run, check_call, check_output

SCRIPT_DIR = os.path.abspath(os.path.dirname(__file__))
HOME = os.getenv('HOME')


def has(prog: str):
    return run(["which", prog]).returncode == 0 or os.path.exists(prog)


def run_cmd(commands: str):
    warn("Running command:", commands)
    check_call(shlex.split(commands))


def add_suffix(path:str, suffix:str):
    return os.path.join(os.path.dirname(path), os.path.basename(path)+suffix)


def link(src: str, dst_path: str, backup_suffix: str = '.bk'):
    run_cmd(f'ln -bs --suffix={backup_suffix} {os.path.join(SCRIPT_DIR, src)} {dst_path}')
    okay(f"Created link:")
    okay(check_output(f'ls -l {os.path.join(dst_path, os.path.basename(src))}'.split()))


def link_to_home(path_from_this: str, backup_suffix: str = '.bk'):
    link(path_from_this, os.path.join(HOME, os.path.dirname(path_from_this), os.path.basename(path_from_this)), backup_suffix)
