FROM anc2001/cs1230_env:latest

ARG QT_PATH=/opt/Qt
ARG QT_VERSION=6.2.4
ENV PATH=${QT_PATH}/Tools/CMake/bin:${QT_PATH}/Tools/Ninja:${QT_PATH}/${QT_VERSION}/gcc_64/bin:$PATH 

RUN git clone https://github.com/BrownCSCI1230/projects_2D.git

RUN cmake -DCMAKE_PREFIX_PATH=${QT_PATH}/${QT_VERSION}/gcc_64 -S /root/projects_2D -B /tmp/build
RUN cmake --build /tmp/build

ENV APP /tmp/build/2dprojects 