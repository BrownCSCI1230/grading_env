#!/bin/bash

src_dir=""
executable=""
image_name=cs1230_qt_project
container=silly_container

show_help() {
cat << EOF
Usage: ${0##*/} [-h] [-s SRC] [-c CONTAINER] [-i IMAGE]

This script is a convenience script to build Qt based projects in a docker environment.
It will

- Based on 

Options:

  -h             Display this help and exit.
  -s             Path to source code locally (required)
  -c             Container name to use and delete immediately (default ${container}).
  -i             Image name to write to (default ${image_name}).
EOF
}

while [ $# -gt 0 ]; do
	case "$1" in
		-h)
			show_help
			exit 0
			;;
        -s) 
            src_dir=$2
            shift
            ;;
		-c)
			container=$2
			shift
			;;
		-i)
			image_name=$2
			shift
			;;
	esac
	shift
done

# Delete 
docker image rm "${image_name}"

# Run container and build project
docker run \
    --name "${container}" \
    --platform=linux/amd64 \
    -v "${src_dir}:/tmp/src" \
    anc2001/cs1230_env:latest \
    /opt/build_project.sh

# Remove 
docker commit "${container}" "${image_name}"
# Remove the temporary container 
docker container rm "${container}"


