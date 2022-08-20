# CS1230 Docker Grading Environment 
Unified grading environment that has 
 * Compatibility with Gradescope 
 * Ability to show graphical output (including OpenGL) 
 * Contains the Qt library and the tools to compile Qt projects 

To build the image run `docker buildx build --platform=linux/amd64 -t username/image_name:tag .`

Otherwise the Docker is image available with `docker pull anc2001/cs1230_env:latest`

## Gradescope 
The specifications for creating a custom Docker image for Gradescope can be found [here](https://gradescope-autograders.readthedocs.io/en/latest/manual_docker/). 

### Running autograder locally

## Graphical Output
The image displays graphical output using the methods found [here](https://github.com/thewtex/docker-opengl/tree/webgl). To customize 

## Qt Headless Installation
The `get_qt.sh` script comes from [here](https://github.com/state-of-the-art/qt6-docker)

The script relies on [aqt](https://github.com/miurahr/aqtinstall) which is a codebase for installing Qt headlessly. Unfortunately it is unofficial and not associated with the Qt company. 

The Dockerfile copies the script and installs Qt to `/opt/Qt`