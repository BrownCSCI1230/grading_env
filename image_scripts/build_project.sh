#!/usr/bin/env bash
export LDFLAGS="-Wl,--copy-dt-needed-entries"

rm -rf /tmp/build
mkdir -p /tmp/build

QT_PATH=/opt/Qt
QT_VERSION=6.2.4
PATH=${QT_PATH}/Tools/CMake/bin:${QT_PATH}/Tools/Ninja:${QT_PATH}/${QT_VERSION}/gcc_64/bin:$PATH 

cmake -DCMAKE_PREFIX_PATH=${QT_PATH}/${QT_VERSION}/gcc_64 -S /tmp/src -B /tmp/build
cmake --build /tmp/build

cp -a /tmp/src /home/user/work
ls /home/user/work