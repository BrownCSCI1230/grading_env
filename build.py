import subprocess
from argparse import ArgumentParser
import subprocess
from sys import platform

def parseArguments():
    parser = ArgumentParser()
    parser.add_argument('--s', type=str, required=True, help="absolute filepath to source code")
    parser.add_argument('--c', type=str, default="qt_build", help="name of container")
    parser.add_argument('--i', type=str, default="qt_project", help="name of image")
    args = parser.parse_args()
    return args

def run_command(cmd):
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, universal_newlines=True)
    while True:
        output = process.stdout.readline()
        if output == '' and process.poll() is not None:
            break
        if output:
            print(output.strip())
    rc = process.poll()
    return rc

def main(args):
    volume = args.s
    container = args.c
    image = args.i

    exec_cmd = ""
    volume_cmd = ""
    if platform == "linux" or platform == "linux2" or platform == "darwin":
        # linux or OS X
        exec_cmd = "/opt/build_project.sh"
        volume_cmd = f"{volume}:/tmp/src"
    elif platform == "win32":
        # Windows...
        exec_cmd = "//opt//build_project.sh"
        volume_cmd = f"{volume}://tmp//src"

    print("Cleaning: it's ok if the images/container are not found!")
    run_command(["docker", "image", "rm", image])
    run_command(["docker", "container", "rm", container])

    print("Building project to image:", image)
    cmd = ["docker", 
        "run", 
        "--name", container, 
        "--platform=linux/amd64", 
        "-v", volume_cmd,
        "anc2001/cs1230_env:latest",
        exec_cmd
    ]
    rc = run_command(cmd)

    if rc:
         print("Something went wrong building the project :(")
    else:
        print("Successfully built project to image:", image)
    
    run_command(["docker", "commit", container, image])
    run_command(["docker", "container", "rm", container])

if __name__ == '__main__':
    args = parseArguments()
    main(args)