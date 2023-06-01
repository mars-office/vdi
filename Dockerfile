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


# Tools
RUN apt-get install -y wget git curl ca-certificates nano jq

# Repos
RUN curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list

RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list

RUN curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -

RUN wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
RUN sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
RUN sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
RUN rm -f packages.microsoft.gpg

# Update again
RUN apt-get update

# NodeJS and NPM
RUN apt-get install -y nodejs

RUN npm i -g typescript @angular/cli gitfox

# VSCode
RUN apt-get install -y code

# Kubectl
RUN apt-get install -y kubectl

# Helm
RUN wget -q https://get.helm.sh/helm-v3.12.0-linux-$(dpkg --print-architecture).tar.gz
RUN tar -zxvf ./helm-v3.12.0-linux-$(dpkg --print-architecture).tar.gz
RUN mv ./linux-$(dpkg --print-architecture)/helm /usr/bin/helm
RUN chmod +x /usr/bin/helm
RUN rm ./helm-v3.12.0-linux-$(dpkg --print-architecture).tar.gz
RUN rm -rf ./linux-$(dpkg --print-architecture)

# TerraForm
RUN sudo apt-get install -y terraform

# Chrome
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