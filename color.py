class bcolors:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


def _cprint(color: bcolors, *args, **kwargs):
    print(color, *args, bcolors.ENDC, **kwargs)


def _getprintf(color: bcolors):
    def f(*args, **kwargs):
        _cprint(color, *args, **kwargs)

    return f


info = print
okay = _getprintf(bcolors.OKGREEN)
warn = _getprintf(bcolors.WARNING)
fail = _getprintf(bcolors.FAIL)
