#!/usr/bin/env bash
set -ex

whoami
sudo su - -c "
if [ -f /sys/fs/cgroup/cgroup.controllers ]; then
  mkdir -p /sys/fs/cgroup/init
  busybox xargs -rn1 < /sys/fs/cgroup/cgroup.procs > /sys/fs/cgroup/init/cgroup.procs || :
  sed -e 's/ / +/g' -e 's/^/+/' <\"/sys/fs/cgroup/cgroup.controllers\" >\"/sys/fs/cgroup/cgroup.subtree_control\"
fi
"

rm -rf $HOME/.customized
if  [ -f "$HOME/.customized" ]; then
    echo "Customizations already exist."
else
    echo "Customizing..."

    mkdir -p $HOME/Software
    grep -qxF 'export PATH=$PATH:$HOME/Software' $HOME/.bashrc || echo 'export PATH=$PATH:$HOME/Software' >> $HOME/.bashrc
    grep -qxF 'export NODE_ENV=development' $HOME/.bashrc || echo 'export NODE_ENV=development' >> $HOME/.bashrc
    grep -qxF 'export ASPNETCORE_ENVIRONMENT=Development' $HOME/.bashrc || echo 'export ASPNETCORE_ENVIRONMENT=Development' >> $HOME/.bashrc
    grep -qxF 'export DOTNET_ENVIRONMENT=Development' $HOME/.bashrc || echo 'export DOTNET_ENVIRONMENT=Development' >> $HOME/.bashrc
    grep -qxF 'export FUNCTIONS_ENVIRONMENT=Development' $HOME/.bashrc || echo 'export FUNCTIONS_ENVIRONMENT=Development' >> $HOME/.bashrc

    mkdir -p $HOME/.local/share/applications

    
    # kubectl
    if [ ! -f "$HOME/Software/kubectl" ] 
    then
        cd $HOME/Software
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$(dpkg --print-architecture)/kubectl"
        chmod +x ./kubectl
    fi

    # helm
    if [ ! -f "$HOME/Software/helm" ] 
    then
        cd $HOME/Software
        curl -LO "https://get.helm.sh/helm-v3.12.0-linux-$(dpkg --print-architecture).tar.gz"
        tar -zxvf ./helm-v3.12.0-linux-$(dpkg --print-architecture).tar.gz
        mv ./linux-$(dpkg --print-architecture)/helm ./helm
        rm -rf ./linux-$(dpkg --print-architecture)
        rm -rf ./helm-v3.12.0-linux-$(dpkg --print-architecture).tar.gz
        chmod +x ./helm
    fi

    # telepresence
    if [ ! -f "$HOME/Software/telepresence" ]
    then
        cd $HOME/Software
        curl -L --output telepresence "https://app.getambassador.io/download/tel2/linux/$(dpkg --print-architecture)/latest/telepresence"
        chmod +x ./telepresence
    fi
    
    touch $HOME/.customized
fi

# unknown option ==> call command
echo -e "\n\n------------------ EXECUTE AFTER CUSTOMIZATION COMMAND ------------------"
echo "Executing command: '$@'"
exec "$@"
