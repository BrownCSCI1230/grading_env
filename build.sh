#!/bin/bash

src_dir="/Users/adrianchang/CS/CS1230_dev/projects_2D"
executable="2dprojects"
image_name="test"
container="temp"

echo ${src_dir}
echo ${image_name}

# Run container and
docker run \
    --name ${container} \
    --platform=linux/amd64 \
    -v "${src_dir}:/tmp/src" \
    anc2001/cs1230_env:latest \
    /opt/build_project.sh

# Remove 
docker commit ${container} ${image_name}
# Remove the temporary container 
docker container rm ${container}


