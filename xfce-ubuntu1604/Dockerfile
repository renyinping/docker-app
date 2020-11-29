FROM ubuntu:16.04

### Connection ports for controlling the UI:
# VNC port:5901
# noVNC webport, connect via http://IP:6901/?password=vncpassword
### Envrionment config
ENV DISPLAY=:1 \
    VNC_PORT=5901 \
    NO_VNC_PORT=6901 \
    HOME=/headless \
    TERM=xterm \
    NO_VNC_HOME=/headless/noVNC \
    DEBIAN_FRONTEND=noninteractive \
    VNC_COL_DEPTH=24 \
    VNC_RESOLUTION=1440x900 \
    VNC_PW=vncpassword \
    VNC_VIEW_ONLY=false \
    LANG='zh_CN.UTF-8' \
    LANGUAGE='zh_CN' \
    LC_ALL='zh_CN.UTF-8' \
    TIMEZONE=Asia/Shanghai

EXPOSE $VNC_PORT $NO_VNC_PORT
WORKDIR $HOME
ADD ./ /
RUN find / -name '*.sh' -exec chmod a+x {} + \
    && /install.sh tools \
    && /install.sh vnc \
    && /install.sh novnc \
    && /install.sh chrome \
    && /install.sh xfceui \
    && /install.sh nss \
    && /install.sh set_user_permission $HOME \
    && apt-get autoremove -y \
    && apt-get autoclean -y \
    && apt-get clean -y

USER 1000

ENTRYPOINT ["/docker-entrypoint.sh"]
