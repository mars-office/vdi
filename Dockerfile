FROM kasmweb/core-ubuntu-jammy:1.13.1
USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########
RUN apt-get update
RUN apt-get install -y sudo \
    && rm -rf /var/lib/apt/list/*
RUN apt-get install -y unzip wget curl busybox nano libfuse2
RUN echo "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/home/kasm-user/Software" > /etc/environment
RUN echo 'TEMP=/home/kasm-user/tmp' >> /etc/environment
COPY ./sudoers /etc/sudoers
######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME



ENTRYPOINT ["/dockerstartup/kasm_default_profile.sh", "/dockerstartup/customize_at_boot.sh", "/dockerstartup/vnc_startup.sh", "/dockerstartup/kasm_startup.sh"]

LABEL org.opencontainers.image.source=https://github.com/mars-office/vdi

COPY ./customize_at_boot.sh /dockerstartup/customize_at_boot.sh
RUN chmod +x /dockerstartup/customize_at_boot.sh

USER 1000
