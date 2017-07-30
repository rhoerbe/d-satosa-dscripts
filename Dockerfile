FROM ubuntu:16.04

RUN apt-get update && \
    apt-get -y dist-upgrade && \
    apt-get install -y --no-install-recommends \
    git \
    python3-dev \
    build-essential \
    python3-pip \
    libffi-dev \
    libssl-dev \
    xmlsec1 \
    libyaml-dev && \
    apt-get clean

RUN apt-get -y install vim
RUN mkdir -p /src/satosa
COPY install/SATOSA/* /src/satosa/
COPY install/SATOSA/docker/setup.sh /setup.sh
WORKDIR /
RUN pip3 install --upgrade virtualenv \
 && virtualenv -p python3 /opt/satosa \
 && /opt/satosa/bin/pip install --upgrade pip setuptools
 # the following pip install is there to speed up debugging satosa setup.py - do not use otherwise
 #&& /opt/satosa/bin/pip install pyop==2.0.5 pysaml2==4.4.0 pycryptodomex requests \
 #                               PyYAML gunicorn Werkzeug click pystache
RUN /opt/satosa/bin/python /src/satosa/setup.py install

COPY install/SATOSA/docker/start.sh /start.sh
COPY install/SATOSA/docker/attributemaps /opt/satosa/attributemaps
COPY install/config1 /opt/config1

ARG USERNAME=satosa
ARG UID=343053
RUN groupadd -g $UID $USERNAME \
 && adduser --gid $UID --disabled-password --gecos "satosa proxy service" --uid $UID $USERNAME \
 && mkdir /opt/satosa/etc \
 && chown -R $USERNAME:$USERNAME /opt

USER $USERNAME
export PYTHONPATH=/src/satosa/
CMD /bin/bash
VOLUME /opt/satosa/etc
