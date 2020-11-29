FROM yinping/xfce:ubuntu1604

USER 0

ADD ./ /
RUN find / -name '*.sh' -exec chmod a+x {} + \
    && /install.sh qb \
    && /install.sh set_user_permission $HOME \
    && apt-get autoremove -y \
    && apt-get autoclean -y \
    && apt-get clean -y

USER 1000
