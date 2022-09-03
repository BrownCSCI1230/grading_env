# CS1230 Docker Grading Environment 
Unified grading environment that has 
 * Compatibility with Gradescope 
 * Ability to show graphical output (including OpenGL) 
 * Contains the Qt library and the tools to compile Qt projects 

## Setup 
Get docker [here](https://docs.docker.com/get-docker/)

Pull the unified class grading environment with `docker pull anc2001/cs1230_env:latest`

## Convenience Scripts
I've added 2 convenience python scripts `build.py` and `run.py` that should abstract away all of the explicit docker commands below. 

Example usage is
```
python3 build.py -s /path/to/src
```

and

```
python3 run.py -e executable_name
```

Usage of the two scripts
```
usage: build.py [-h] -s SOURCE [-c CONTAINER] [-i IMAGE]

optional arguments:
  -h, --help            show this help message and exit
  -s SOURCE, --source SOURCE
                        absolute filepath to source code (required)
  -c CONTAINER, --container CONTAINER
                        name of temporary container (default qt_build)
  -i IMAGE, --image IMAGE
                        name of image (default qt_project)
```

```
usage: run.py [-h] [--mode MODE] -e EXECUTABLE [-c CONTAINER] [-i IMAGE]

optional arguments:
  -h, --help            show this help message and exit
  --mode MODE           either graphical or cli
  -e EXECUTABLE, --executable EXECUTABLE
                        name of executable (required)
  -c CONTAINER, --container CONTAINER
                        name of container (default qt_app)
  -i IMAGE, --image IMAGE
                        name of image (default qt_project)
```

## Usage 
**Note** If you are on Windows, you must run these commands in Git Bash. All filepaths must be specified with `//`. This includes the path to the source code `SRC_PATH` and the the other filepaths present in the command. Included are windows variations of each of these commands in a dropdown menu. 

### Building 
First setup some environment variables for naming. You will need to specify the path to the source code `SRC_PATH` (make sure they have `//` if you're on windows) and the name of the executable `EXECUTABLE`. The others you can really name anything you want. 
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
  <summary>Windows Git Bash Version</summary>
docker run \
    --name ${CONTAINER} \
    --platform=linux/amd64 \
    -v "${SRC_PATH}://tmp//src" \
    anc2001/cs1230_env:latest \
    //opt//build_project.sh

docker image rm ${IMAGE}
docker commit ${CONTAINER} ${IMAGE}
docker container rm ${CONTAINER}

</details>

<details>
  <summary>What am I looking at?</summary>

`--name` specifices the name of the container 

`--platform` specifies the architecture the docker container will run on

`-v "${SRC_PATH}:/tmp/src"` mounts a volume in the container. The files at `SRC_PATH` (the project source code) will be accessible at `/tmp/src` within the container 

`anc2001/cs1230_env:latest` is the name of the Docker Image the container is based on

`/opt/build_project.sh` is the script the docker container will run upon starting 

`docker image rm ${IMAGE}` - deletes the previous image at `IMAGE`

`docker commit ${CONTAINER} ${IMAGE}` - saves the container as permanent memory at `IMAGE`, otherwise the compiled executable will disappear after the container is removed 

`docker container rm ${CONTAINER}` - Remove the container 
</details>

### Running 
#### Graphical Output (2D projects and Realtime)
This will run the previously build docker image (`cs1230_qt_project`) in a docker container and connect it to a graphical display accessible within any modern browser at `http://localhost:6080` by default. 
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
  <summary>Windows Git Bash Version</summary>
docker run \
  --platform=linux/amd64 \
  -d \
  --name ${CONTAINER} \
  --env="APP=//tmp//build//${EXECUTABLE}" \
  -p 6080:6080 \
  ${IMAGE} \
  //usr//bin//supervisord -c //etc//supervisor//supervisord.conf

</details>

<details>
  <summary>What am I looking at?</summary>

`-d` means the container runs in detached mode (i.e. in the background)

`--env` sets the environment variable `APP` inside the container. The container will by default look at 

`-p` opens up a port at 6080 by default, you can change this if you really want by changing the first argument number

`/usr/bin/supervisord -c /etc/supervisor/supervisord.conf` is the command to open up a graphical session and expose it at the corresponding sport 
</details>

The application should now be available at `http://localhost:6080`

When you're done with the docker container you can run `docker stop ${CONTAINER}` and `docker container rm ${CONTAINER}`

#### Command Line (Ray)
This will open up the previously built image with an interactive terminal session that allows you to run the executable. Since the example is Ray, It will also mount a volume so that you can see the resulting images. 

```
export RESULTS_PATH=/path/to/results

docker run \
  --rm \
  -it \
  --platform=linux/amd64 \
  -v "${RESULTS_PATH}:/tmp/results" \
  ${IMAGE} \
  /bin/bash
```

<details>
  <summary>Windows Git Bash Version</summary>
export RESULTS_PATH=//path//to//results

docker run \
  --rm \
  -it \
  --platform=linux/amd64 \
  -v "${RESULTS_PATH}://tmp//results" \
  ${IMAGE} \
  //bin//bash
  
</details>

<details>
  <summary>What am I looking at?</summary>

`-it` specifies an interactive session 

`--rm` will remove the container when exited 

`/bin/bash` is the command to open up `bash` upon starting the container 
</details>

Ray specific: Make sure your ini files point to an output image at `/tmp/results` so that you can you see your images! 

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