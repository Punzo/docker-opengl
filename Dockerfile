FROM ubuntu:18.04

ENV DEFAULT_DOCKCROSS_IMAGE SlicerAstro/opengl \
    LANG=en_US.UTF-8 \
    LC_ALL=en_US.UTF-8 \
    LANGUAGE=en_US.UTF-8

ARG DEBIAN_FRONTEND=noninteractive

RUN \
  apt-get update && \
  \
  (LANG=C LANGUAGE=C LC_ALL=C apt-get install -y locales) && \
  locale-gen ${LANG%.*} ${LANG} && \
  \
  apt-get -y upgrade && \
  apt-get update && \
  apt-get install -y \
    build-essential \
    curl \
    gosu \
    openssh-client \
    unzip \
    gettext \
    libssl-dev \
    libcurl4-gnutls-dev \
    libexpat1-dev \
    zlib1g-dev \
    git \
    libgl1-mesa-dri \
    menu \
    net-tools \
    openbox \
    python-pip \
    sudo \
    supervisor \
    tint2 \
    x11-xserver-utils \
    x11vnc \
    xinit \
    xserver-xorg-video-dummy \
    xserver-xorg-input-void \
    websockify \
    wget \
    libnss3 \
    libpulse-mainloop-glib0 \
    libasound2 \
    gcc \
    git-core \
    git-svn \
    g++ \
    libfontconfig-dev \
    libglu1-mesa-dev \
    libgl1-mesa-dev \
    libosmesa6-dev \
    libncurses5-dev\
    libxrender-dev \
    make \
    subversion \
    nano \
  && \
  #
  # cleanup
  #
  rm -rf /var/lib/apt/lists/* && \
  rm -f /usr/share/applications/x11vnc.desktop && \
  apt-get remove -y python-pip && \
  wget https://bootstrap.pypa.io/get-pip.py && \
  python get-pip.py && \
  pip install supervisor-stdout && \
  apt-get -y clean

ENV AR=/usr/bin/ar \
    AS=/usr/bin/as \
    CC=/usr/bin/gcc \
    CPP=/usr/bin/cpp \
    CXX=/usr/bin/g++

COPY etc/skel/.xinitrc /etc/skel/.xinitrc

RUN useradd -m -s /bin/bash user
USER user

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

ENV DISPLAY :0

WORKDIR /root

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]

# Build-time metadata as defined at http://label-schema.org
ARG BUILD_DATE
ARG IMAGE
ARG VCS_REF
ARG VCS_URL
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name=$IMAGE \
      org.label-schema.description="An image based on debian/jessie containing an X_Window_System which supports rendering graphical applications, including OpenGL apps" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.schema-version="1.0"
