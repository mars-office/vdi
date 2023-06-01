FROM kasmweb/core-ubuntu-jammy:1.13.1
USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########
ENV CHROMIUM_USER_FLAGS --no-sandbox

COPY ./customize.sh /customize.sh
RUN chmod +x /customize.sh
RUN /customize.sh

RUN mkdir -p /home/kasm-default-profile/.config/Code/User
COPY ./vscode-settings.json /home/kasm-default-profile/.config/Code/User/settings.json

######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000

LABEL org.opencontainers.image.source=https://github.com/mars-office/vdi