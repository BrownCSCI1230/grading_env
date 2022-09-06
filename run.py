from http.server import executable
import subprocess
from argparse import ArgumentParser
import subprocess
from sys import platform

def parseArguments():
    parser = ArgumentParser()
    parser.add_argument('--mode', type=str, default="graphical", 
        help="either graphical or cli")
    parser.add_argument('--demo', action="store_true",
        help="")
    parser.add_argument('-e', '--executable', type=str, required=True, 
        help="name of executable (required)")
    parser.add_argument('-c', '--container', type=str, default="qt_app", 
        help="name of container (default qt_app)")
    parser.add_argument('-i', '--image', type=str, default="qt_project", 
        help="name of image (default qt_project)")
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
    exec_cmd = ["", "", ""]
    env_cmd = ""
    if platform == "linux" or platform == "linux2" or platform == "darwin":
        # linux or OS X
        if args.mode == 'graphical':
            exec_cmd[0] = "/usr/bin/supervisord"
            exec_cmd[1] = "-c"
            exec_cmd[2] = "/etc/supervisor/supervisord.conf"
            env_cmd = f"APP=/tmp/build/{args.executable}"
        else:
            exec_cmd[0] = "/bin/bash"
        
        if args.demo:
            executable = "projects_2d"
            env_cmd = f"APP=/demos/{args.executable}/build/{executable}"
    elif platform == "win32":
        # Windows...
        if args.mode == 'graphical' or args.mode == 'demo':
            exec_cmd[0] = "//usr//bin//supervisord"
            exec_cmd[1] = "-c"
            exec_cmd[2] = "//etc//supervisor//supervisord.conf"
            env_cmd = f"APP=//tmp//build//{args.executable}"
        else:
            exec_cmd[0] = "//bin//bash"
        
        if args.demo:
            env_cmd = f"APP=//demos//{args.executable}"

    print("Cleaning: it's ok if Docker tries to stop and remove a container that doesn't exist!")
    run_command(["docker", "stop", args.container])
    run_command(["docker", "container", "rm", args.container])
    
    if args.mode == 'graphical' or args.mode == 'demo':
        cmd = [
            "docker", "run",
            "--platform=linux/amd64",
            "-d", 
            "--name", args.container,
            "--env", env_cmd,
            "-p", "6080:6080",
            args.image,
            exec_cmd[0], exec_cmd[1], exec_cmd[2]
        ]
        print(' '.join(cmd))
        rc = run_command(cmd)

        if rc:
            print("Something went wrong!")
            run_command(["docker", "container", "rm", args.container])
        else:
            print(f"Container {args.container} running!")
            print()
            print("App exposed at http://localhost:6080")
            print("You can stop the app with: ")
            print(f"    docker stop {args.container}")
    
    elif args.mode == 'cli':
        cmd = [
            "docker", "run",
            "--platform=linux/amd64",
            "--rm", "-t", 
            args.args,
            args.image,
            exec_cmd[0]
        ]
        print(' '.join(cmd))
        print("Not implemented! Sorry")
        print("You can run it with the actual command directly: it will look something like:")
        print(f"docker run --rm -it --platform=linux/amd64 -v /path/to/results:/tmp/results {args.image} /bin/bash")
    else:
        print("mode not recognized")
        exit(1)

if __name__ == '__main__':
    args = parseArguments()
    main(args)