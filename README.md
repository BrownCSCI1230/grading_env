# CS1230 Docker Grading Environment 
Unified grading environment that has 
 * Compatibility with Gradescope 
 * Ability to show graphical output (including OpenGL) 
 * Contains the Qt library and the tools to compile Qt projects 

## Setup 
Get docker [here](https://docs.docker.com/get-docker/)

Pull the unified class grading environment with `docker pull anc2001/cs1230_env:latest`

## Usage Scripts
To build and run a student's project first build a docker image containing the compiled executable with `build.sh` and then run that image in a container with a graphical output with `run.sh` 

**Example - Graphical App**

Build project: this will take the source code, build it, and write that image to a docker image called `cs1230_qt_project` (default)

```
./build.sh -s /path/to/src
```

Run project: this will run the previously build docker image (`cs1230_qt_project`) in a docker container and connect it to a graphical display accessible within any modern browser at `http://localhost:6080` by default. The executable name is the name specified in the projects `CMakeLists.txt` by `add_executable`
```
./run.sh -e executable_name
```

When you're done with the docker container you can either stop the shell script with `SIGQUIT` or run `docker stop qt_app`

**Example - Command Line App**

Instead of linking this application to a graphical display, the following example will build a CLI executable (Ray in this case), mounts a local volume containing the output image results, and opens an interactive sesion in docker container. 

Like before, build with the `build.sh` script. This will build the image to a local image called `ray:latest`
```
./build.sh -s /path/to/src -i ray
```

Instead of using the `run.sh` script which by default sets up a graphical display, run a docker container from the previously built image with `docker run`
```
docker run --rm -it --platform=linux/amd64 -v "/path/to/results:/tmp/results" ray /bin/bash
```

By default the Ray executable is built to `/tmp/build` so you can render images with 
```
/tmp/build/Ray test.ini
```

## Usage Script Documentation

Below is a more verbose documentation of each script's usage

Usage for `build.sh`

```
  Usage: build.sh [-h] [-s SRC] [-c CONTAINER] [-i IMAGE]

  This script is a convenience script to build Qt based projects in a docker environment.
  It will

  - Based on 

  Options:

    -h             Display this help and exit.
    -s             Path to source code locally (required)
    -c             Container name to use and delete immediately (default silly_container).
    -i             Image name to write to (default cs1230_qt_project).
```

Usage for `run.sh` 

```
  Usage: run.sh [-h] [-q] [-c CONTAINER] [-i IMAGE] [-p PORT] [-r DOCKER_RUN_FLAGS]

  This script is a convenience script to run Docker images based on
  thewtex/opengl. It:

  - Makes sure docker is available
  - On Windows and Mac OSX, creates a docker machine if required
  - Informs the user of the URL to access the container with a web browser
  - Stops and removes containers from previous runs to avoid conflicts
  - Mounts the present working directory to /home/user/work on Linux and Mac OSX
  - Prints out the graphical app output log following execution
  - Exits with the same return code as the graphical app

  Options:

    -h             Display this help and exit.
    -c             Container name to use (default qt_app).
    -i             Image name (default cs1230_qt_project).
    -p             Port to expose HTTP server (default 6080). If an empty
                  string, the port is not exposed.
    -r             Extra arguments to pass to 'docker run'. E.g.
                  --env="APP=glxgears"
    -e			       Executable name
    -q             Do not output informational messages.
```

## Image details
Build the image with `docker build --platform=linux/amd64 -t username/image_name:tag .`

Please also note that for all executables at runtime the working directory is `/home/user/work`. Put any necessary files in this directory. 

### Gradescope
The specifications for creating a custom Docker image for Gradescope can be found [here](https://gradescope-autograders.readthedocs.io/en/latest/manual_docker/). 

The Docker image is based on `gradescope/autograder-base:ubuntu-20.04`. It requires that the script `run_autograder` (written in any valid language available with `!#`) be installed at `/autograder`. The `run_autograder` for this image attempts to compile the project with `cmake` and returing whether the compilation was successful. This script can of course be overwritten for more complex test suites. 

See the Gradescope docs for running the autograder locally. 

### Graphical Output
The image displays graphical output using the methods found in the Dockerfile [here](https://github.com/thewtex/docker-opengl/tree/webgl). The image looks for the executable specified by the `APP` environment variable and displays that to the local host. More in depth information on the specifics can be found [here](https://github.com/thewtex/docker-opengl/blob/master/README.rst)

There are a lot of unncessary things that come from this repo that can be cleaned up (i.e. Mozilla, Google Chrome, Nodejs)

### Qt Headless Installation
The `get_qt.sh` script comes from [here](https://github.com/state-of-the-art/qt6-docker)

The script relies on [aqt](https://github.com/miurahr/aqtinstall) which is a codebase for installing Qt headlessly. Unfortunately it is unofficial and not associated with the Qt company. 

The Dockerfile copies the script and installs Qt to `/opt/Qt`