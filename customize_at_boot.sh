#!/usr/bin/env bash
set -ex

# if [ -f /sys/fs/cgroup/cgroup.controllers ]; then
#   echo "[$(date -Iseconds)] [CgroupV2 Fix] Evacuating Root Cgroup ..."
# 	# move the processes from the root group to the /init group,
#   # otherwise writing subtree_control fails with EBUSY.
#   sudo mkdir -p /sys/fs/cgroup/init
#   sudo xargs -rn1 < /sys/fs/cgroup/cgroup.procs > /sys/fs/cgroup/init/cgroup.procs || :
#   # enable controllers
#   sudo sed -e 's/ / +/g' -e 's/^/+/' <"/sys/fs/cgroup/cgroup.controllers" >"/sys/fs/cgroup/cgroup.subtree_control"
#   echo "[$(date -Iseconds)] [CgroupV2 Fix] Done"
# fi

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


    # Brave
    if [ ! -d "$HOME/Software/brave" ] 
    then
        echo "Installing Brave..."
        cd $HOME/Software
        mkdir -p $HOME/Software/brave
        cd $HOME/Software/brave
        wget https://github.com/brave/brave-browser/releases/download/v1.46.153/brave-browser-1.46.153-linux-$(dpkg --print-architecture).zip
        unzip ./brave-browser-1.46.153-linux-$(dpkg --print-architecture).zip
        rm -rf ./brave-browser-1.46.153-linux-$(dpkg --print-architecture).zip
        chmod +x ./brave
        chmod +x ./brave-browser
        ln -s $HOME/Software/brave/brave-browser $HOME/Software/brave-browser
        touch $HOME/.local/share/applications/brave.desktop
        tee -a $HOME/.local/share/applications/brave.desktop << END
[Desktop Entry]
Type=Application
Icon=/home/kasm-user/Software/brave/product_logo_64.png
Name=Brave
Comment=Brave Browser
Categories=Network;
Exec=/home/kasm-user/Software/brave/brave-browser --no-sandbox
Path=/home/kasm-user/Software/brave
StartupNotify=true
Terminal=false
END
        touch $HOME/.config/mimeapps.list
        tee -a $HOME/.config/mimeapps.list << END
[Default Applications]
x-scheme-handler/http=brave.desktop
x-scheme-handler/https=brave.desktop
END
        touch $HOME/Software/brave-browser-ns
        tee -a $HOME/Software/brave-browser-ns << END
#!/bin/bash
brave-browser --no-sandbox
END
        chmod +x $HOME/Software/brave-browser-ns
        grep -qxF 'export BROWSER=brave-browser-ns' $HOME/.bashrc || echo 'export BROWSER=brave-browser-ns' >> $HOME/.bashrc
    fi

    
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

    # k3s
    if [ ! -f "$HOME/Software/k3s" ]
    then
        cd $HOME/Software
        mkdir -p $HOME/.rancher/k3s
        arch=$(dpkg --print-architecture)
        if [ "$arch" = "amd64" ]; then
            curl -L --output k3s "https://github.com/k3s-io/k3s/releases/download/v1.27.1%2Bk3s1/k3s"
        else
            curl -L --output k3s "https://github.com/k3s-io/k3s/releases/download/v1.27.1%2Bk3s1/k3s-$(dpkg --print-architecture)"
        fi
        
        chmod +x ./k3s
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