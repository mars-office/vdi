FROM kasmweb/core-ubuntu-jammy:1.13.1
USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########

RUN apt-get update
RUN apt-get install -y sudo \
    && echo 'kasm-user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
    && rm -rf /var/lib/apt/list/*

RUN apt-get install -y wget git curl nano

RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_$(dpkg --print-architecture).deb
RUN apt install -y ./google-chrome-stable_current_$(dpkg --print-architecture).deb
RUN rm ./google-chrome-stable_current_$(dpkg --print-architecture).deb
RUN truncate -s-1 /usr/bin/google-chrome
RUN echo -n " --no-sandbox" >> /usr/bin/google-chrome

RUN echo "export NODE_ENV=development" >> /home/kasm-default-profile/.bashrc
RUN echo "export HELM_EXPERIMENTAL_OCI=1" >> /home/kasm-default-profile/.bashrc
RUN echo "export ASPNETCORE_ENVIRONMENT=Development" >> /home/kasm-default-profile/.bashrc
RUN echo "export DOTNET_ENVIRONMENT=Development" >> /home/kasm-default-profile/.bashrc
RUN echo "export FUNCTIONS_ENVIRONMENT=Development" >> /home/kasm-default-profile/.bashrc
RUN mkdir -p /home/kasm-default-profile/Software
RUN echo "export PATH=\$PATH:~/Software" >> /home/kasm-default-profile/.bashrc
######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000

LABEL org.opencontainers.image.source=https://github.com/mars-office/vdi