# CS1230 Docker Grading Environment 
Unified grading environment that has 
 * Compatibility with Gradescope 
 * Ability to show graphical output (including OpenGL) 
 * Contains the Qt library and the tools to compile Qt projects 

To build the image run `docker buildx build --platform=linux/amd64 -t username/image_name:tag .`

Otherwise the Docker is image available with `docker pull anc2001/cs1230_env:latest`

## Usage Scripts

## Gradescope 
The specifications for creating a custom Docker image for Gradescope can be found [here](https://gradescope-autograders.readthedocs.io/en/latest/manual_docker/). 

The Docker image is based on `gradescope/autograder-base:ubuntu-20.04`. It requires that the script `run_autograder` (written in any valid language available with `!#`) be installed at `/autograder`. The `run_autograder` for this image attempts to compile the project with `cmake` and returing whether the compilation was successful. This script can of course be overwritten for more complex test suites. 

See the Gradescope docs for running the autograder locally. 

## Graphical Output
The image displays graphical output using the methods found in the Dockerfile [here](https://github.com/thewtex/docker-opengl/tree/webgl). The image looks for the executable specified by the `APP` environment variable and displays that to the local host. More in depth information on the specifics can be found [here](https://github.com/thewtex/docker-opengl/blob/master/README.rst)

Usage for `run.sh` is 

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
    -c             Container name to use (default opengl).
    -i             Image name (default thewtex/opengl).
    -p             Port to expose HTTP server (default 6080). If an empty
                   string, the port is not exposed.
    -r             Extra arguments to pass to 'docker run'. E.g.
                   --env="APP=glxgears"
    -q             Do not output informational messages.
```

There are a lot of unncessary things that come from this repo that can be cleaned up (i.e. Mozilla, Google Chrome, Nodejs)

## Qt Headless Installation
The `get_qt.sh` script comes from [here](https://github.com/state-of-the-art/qt6-docker)

The script relies on [aqt](https://github.com/miurahr/aqtinstall) which is a codebase for installing Qt headlessly. Unfortunately it is unofficial and not associated with the Qt company. 

The Dockerfile copies the script and installs Qt to `/opt/Qt`