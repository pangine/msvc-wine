FROM ubuntu:20.04

# Ubuntu 20.04 (currently?) requires a separate apt-get upgrade first before
# installing libc6:i386, otherwise that package fails to install.
RUN apt-get update && \
    apt-get upgrade -y && \
    dpkg --add-architecture i386 && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ca-certificates \
    msitools \
    python \
    python-simplejson \
    python-six \
    unzip \
    wget \
    winbind \
    wine-development \
    && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /opt/msvc

COPY lowercase fixinclude install.sh vsdownload.py ./
COPY wrappers/* ./wrappers/

RUN ./vsdownload.py --accept-license --dest /opt/msvc && \
    ./install.sh /opt/msvc && \
    rm lowercase fixinclude install.sh vsdownload.py && \
    rm -rf wrappers

RUN wget https://github.com/Kitware/CMake/releases/download/v3.17.2/cmake-3.17.2-win64-x64.zip && \
    unzip cmake-3.17.2-win64-x64.zip -d /opt && \
    rm cmake-3.17.2-win64-x64.zip

RUN wget https://github.com/ninja-build/ninja/releases/download/v1.10.0/ninja-win.zip && \
    unzip ninja-win.zip -d /opt/ninja && \
    rm ninja-win.zip

# Initialize the wine environment. Wait until the wineserver process has
# exited before closing the session, to avoid corrupting the wine prefix.
RUN wine wineboot --init && \
    while pgrep wineserver > /dev/null; do sleep 1; done

# Later stages which actually uses MSVC can ideally start a persistent
# wine server like this:
#RUN wineserver -p && \
#    wine wineboot && \
