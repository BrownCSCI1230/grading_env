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

First setup some environment variables for naming. You will need to specify the path to the source code `SRC_PATH` and the name of the executable `EXECUTABLE`. The others you can really name anything you want. 
```
export SRC_PATH=/path/to/src \
  EXECUTABLE=executable_name
  CONTAINER=qt_app \
  IMAGE=cs1230_qt_project 
```

Build project: this will take the source code, build it, and write that image to a docker image called `IMAGE`. The executable name is the name specified in the projects `CMakeLists.txt` by `add_executable`

```
docker run \
    --name ${CONTAINER} \
    --platform=linux/amd64 \
    -v "${SRC_PATH}:/tmp/src" \
    anc2001/cs1230_env:latest \
    /opt/build_project.sh

docker image rm ${IMAGE}
docker commit ${CONTAINER} ${IMAGE}
docker container rm ${CONTAINER}
```

<details>
  <summary>What do all of these commands mean?</summary>


</details>

Run project: this will run the previously build docker image (`cs1230_qt_project`) in a docker container and connect it to a graphical display accessible within any modern browser at `http://localhost:6080` by default. 
```
docker run \
  --platform=linux/amd64 \
  -d \
  --name ${CONTAINER} \
  --env="APP=/tmp/build/${EXECUTABLE}" \
  -p 6080:6080 \
  ${IMAGE} \
  /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
```

<details>
  <summary>What do all of these commands mean?</summary>

</details>

The application should now be available at `http://localhost:6080`

When you're done with the docker container you can run `docker stop ${CONTAINER}` and `docker container rm ${CONTAINER}`

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