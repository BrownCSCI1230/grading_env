FROM gradescope/autograder-base:ubuntu-20.04

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
  apt-transport-https \
  curl \
  git \
  libgl1-mesa-dri \
  menu \
  net-tools \
  openbox \
  python3-pip \
  sudo \
  supervisor \
  tint2 \
  x11-xserver-utils \
  x11vnc \
  xinit \
  xserver-xorg-video-dummy \
  xserver-xorg-input-void \
  websockify \
  wget && \
  rm -f /usr/share/applications/x11vnc.desktop && \
  apt-get remove -y python3-pip && \
  wget https://bootstrap.pypa.io/get-pip.py && \
  python3 get-pip.py && \
  pip3 install git+https://github.com/coderanger/supervisor-stdout@973ba19967cdaf46d9c1634d1675fc65b9574f6e && \
  apt-get -y clean

RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
  sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list' && \
  apt-get update && \
  apt-get install -y google-chrome-stable

RUN curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add - && \
  VERSION=node_16.x && DISTRO="focal" && \
  echo "deb https://deb.nodesource.com/$VERSION $DISTRO main" | sudo tee /etc/apt/sources.list.d/nodesource.list && \
  echo "deb-src https://deb.nodesource.com/$VERSION $DISTRO main" | sudo tee -a /etc/apt/sources.list.d/nodesource.list && \
  sudo apt-get update && \
  sudo apt-get install -y nodejs

COPY etc/skel/.xinitrc /etc/skel/.xinitrc

#Cypress dependencies
RUN sudo apt-get install -y libgtk2.0-0 libgtk-3-0 libgbm-dev libnotify-dev libgconf-2-4 libnss3 libxss1 libasound2 libxtst6 xauth xvfb

RUN useradd -m -s /bin/bash user
USER user

RUN cd /home/user && npm install --prefix /home/user --global "cypress@9.5.2"

RUN cp /etc/skel/.xinitrc /home/user/
USER root
RUN echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/user


RUN git clone https://github.com/kanaka/noVNC.git /opt/noVNC && \
  cd /opt/noVNC && \
  git checkout 6a90803feb124791960e3962e328aa3cfb729aeb && \
  ln -s vnc_auto.html index.html

# noVNC (http server) is on 6080, and the VNC server is on 5900
EXPOSE 6080 5900

COPY etc /etc
COPY usr /usr

# For karma testing
ENV CHROME_BIN "/usr/local/bin/google-chrome"

ENV DISPLAY :0

WORKDIR /root

# Install Qt into the image
ARG QT_VERSION=6.2.4
ARG QT_PATH=/opt/Qt

ENV ENV DEBIAN_FRONTEND=noninteractive \
    DEBCONF_NONINTERACTIVE_SEEN=true \
    QT_PATH=${QT_PATH} \
    PATH=${QT_PATH}/Tools/CMake/bin:${QT_PATH}/Tools/Ninja:${QT_PATH}/${QT_VERSION}/gcc_64/bin:$PATH

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install \
build-essential libgl1-mesa-dev \
libglib2.0-0 libglu1-mesa-dev libglu1-mesa libxi-dev libxkbcommon-dev \
libxkbcommon-x11-dev libxkbfile-dev dbus libbsd-dev

COPY image_scripts/get_qt.sh /tmp/
RUN chmod +x /tmp/*
RUN /tmp/get_qt.sh

# Setup autograder
COPY image_scripts/run_autograder /autograder/
RUN dos2unix /autograder/run_autograder
RUN chmod +x /autograder/run_autograder

# Setup build script 
COPY image_scripts/build_project.sh /opt/
RUN chmod +x /opt/build_project.sh

# Install gcc 10, to my knowledge this does not work, see README for workaround I used 
RUN sudo apt update -y && sudo apt upgrade -y \
  sudo install -y gcc-10 g++-10 cpp-10 \
  sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 100 --slave /usr/bin/g++ g++ /usr/bin/g++-10 --slave /usr/bin/gcov gcov /usr/bin/gcov-10
