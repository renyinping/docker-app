#!/usr/bin/env bash
### every exit != 0 fails the script
set -e
set -u

tools() {
    echo "Install some common tools for further installation"
    apt-get update 
    apt-get install -y nano curl wget net-tools locales bzip2 openssh-client mosh sudo \
        ttf-wqy-zenhei \
        python-numpy #used for websockify/novnc

    echo "generate locales for zh_CN.UTF-8"
    locale-gen $LANG

    ln -s -f /usr/share/zoneinfo/$TIMEZONE /etc/localtime

    useradd -c "Default Application User" -d $HOME -G sudo -M -s /bin/bash -u 1000 a
    echo 'a:a' | chpasswd
}

vnc() {
    echo "Install TigerVNC server"
    wget -qO- https://dl.bintray.com/tigervnc/stable/tigervnc-1.9.0.x86_64.tar.gz | tar xz --strip 1 -C /
}

novnc() {
    echo "Install noVNC - HTML5 based VNC viewer"
    mkdir -p $NO_VNC_HOME/utils/websockify
    wget -qO- https://github.com/novnc/noVNC/archive/v1.2.0.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME
    # use older version of websockify to prevent hanging connections on offline containers, see https://github.com/ConSol/docker-headless-vnc-container/issues/50
    wget -qO- https://github.com/novnc/websockify/archive/v0.9.0.tar.gz | tar xz --strip 1 -C $NO_VNC_HOME/utils/websockify
    chmod +x -v $NO_VNC_HOME/utils/*.sh
    ## create index.html to forward automatically to `vnc_lite.html`
    ln -s $NO_VNC_HOME/vnc_lite.html $NO_VNC_HOME/index.html
}

xfceui() {
    echo "Install Xfce4 UI components"
    apt-get install -y supervisor xfce4 xfce4-terminal xterm mousepad
    apt-get purge -y pm-utils xscreensaver*
}

nss() {
    echo "Install nss-wrapper to be able to execute image as non-root user"
    apt-get install -y libnss-wrapper gettext

    echo "add 'source generate_container_user' to .bashrc"

    # have to be added to hold all env vars correctly
    echo 'source $HOME/generate_container_user' >> $HOME/.bashrc
}

set_user_permission() {
    for var in "$@"
    do
        echo "fix permissions for: $var"
        find "$var"/ -name '*.sh' -exec chmod a+x {} +
        find "$var"/ -name '*.desktop' -exec chmod a+x {} +
        chgrp -R 0 "$var" && chmod -R a+rw "$var" && find "$var" -type d -exec chmod a+x {} +
    done
}

chrome() {
    echo "Install Chrome Browser"

    wget -O ./chrome.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb 
    apt-get install -y ./chrome.deb 
    rm -rf ./chrome.deb 

    mkdir -p $HOME/Desktop/
    cp /usr/share/applications/google-chrome.desktop $HOME/Desktop/google-chrome.desktop
}

set_chrome_no_sandbox() {
    VNC_RES_W=${VNC_RESOLUTION%x*}
    VNC_RES_H=${VNC_RESOLUTION#*x}

    echo -e "\n------------------ update google chrome ------------------"
    echo -e "\n... set window size $VNC_RES_W x $VNC_RES_H as chrome window size!\n"

    CHROME_FLAGS=" --no-sandbox --disable-gpu --user-data-dir --window-size=$VNC_RES_W,$VNC_RES_H --window-position=0,0"

    sed -i "/chrome/ s/$/$CHROME_FLAGS/" /opt/google/chrome/google-chrome
}

wps() {
    echo "q" > ./wps.txt
    echo "yes" >> ./wps.txt
    wget -O ./wps.deb https://wdl1.cache.wps.cn/wps/download/ep/Linux2019/9719/wps-office_11.1.0.9719_amd64.deb
    apt-get install -y ./wps.deb < wps.txt
    rm -rf ./wps.deb ./wps.txt

    mkdir -p $HOME/Desktop/
    cp /usr/share/applications/wps-*.desktop $HOME/Desktop/
}

TAG=wps

build() {
    docker build --rm --no-cache -t yinping/xfce:$TAG .
}

run() {
    docker run --cap-add SYS_ADMIN --name $TAG -p 5901:5901 -p 6901:6901 -e VNC_RESOLUTION=1440x900 -e VNC_PW=vncpassword -d yinping/xfce:$TAG
    ### Use --cap-add SYS_ADMIN to support chrome's sandbox function
}

"$@"
