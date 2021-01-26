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
        
def cprint(color: bcolors, *args, **kwargs):
    print(color, *args, bcolors.ENDC, **kwargs)
    
def info(*args, **kwargs):
    print(*args, **kwargs)

def okay(*args, **kwargs):
    cprint(bcolors.OKGREEN, *args, **kwargs)

def warn(*args, **kwargs):
    cprint(bcolors.WARNING, *args, **kwargs)