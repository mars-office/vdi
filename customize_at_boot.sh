#!/usr/bin/env bash
set -ex
architecture=$(dpkg --print-architecture)
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

    rm -rf $HOME/Desktop/Uploads
    rm -rf $HOME/Desktop/Downloads
    mkdir -p $HOME/Software
    grep -qxF 'export PATH=$PATH:$HOME/Software' $HOME/.bashrc || echo 'export PATH=$PATH:$HOME/Software' >> $HOME/.bashrc
    grep -qxF 'export NODE_ENV=development' $HOME/.bashrc || echo 'export NODE_ENV=development' >> $HOME/.bashrc
    grep -qxF 'export ASPNETCORE_ENVIRONMENT=Development' $HOME/.bashrc || echo 'export ASPNETCORE_ENVIRONMENT=Development' >> $HOME/.bashrc
    grep -qxF 'export DOTNET_ENVIRONMENT=Development' $HOME/.bashrc || echo 'export DOTNET_ENVIRONMENT=Development' >> $HOME/.bashrc
    grep -qxF 'export FUNCTIONS_ENVIRONMENT=Development' $HOME/.bashrc || echo 'export FUNCTIONS_ENVIRONMENT=Development' >> $HOME/.bashrc

    mkdir -p $HOME/.local/share/applications
    source $HOME/.bashrc
    
    # kubectl
    if [ ! -f "$HOME/Software/kubectl" ] 
    then
        cd $HOME/Software
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$(dpkg --print-architecture)/kubectl"
        chmod +x ./kubectl
    fi

    # nodejs
    if [ ! -d "$HOME/Software/nodejs" ] 
    then
        cd $HOME/Software
        mkdir -p $HOME/Software/nodejs
        cd $HOME/Software/nodejs
        if [[ $architecture == "amd64" ]]; then
            curl -L -o node.tar.xz https://nodejs.org/dist/v18.16.0/node-v18.16.0-linux-x64.tar.xz
        else
            curl -L -o node.tar.xz https://nodejs.org/dist/v18.16.0/node-v18.16.0-linux-$(dpkg --print-architecture).tar.xz
        fi
        tar -xvf ./node.tar.xz
        rm -rf ./node.tar.xz
        mv node-*/* .
        rm -rf node-*
        chmod +x ./bin/node
        chmod +x ./bin/npm
        chmod +x ./bin/npx
        ln -s $HOME/Software/nodejs/bin/node $HOME/Software/node
        ln -s $HOME/Software/nodejs/bin/npm $HOME/Software/npm
        ln -s $HOME/Software/nodejs/bin/npx $HOME/Software/npx
        mkdir -p $HOME/.npm-packages
        $HOME/Software/nodejs/bin/npm config set prefix "${HOME}/.npm-packages"
        $HOME/Software/nodejs/bin/npm i -g gitfox eslint typescript
        grep -qxF 'export PATH=$PATH:$HOME/.npm-packages/bin' $HOME/.bashrc || echo 'export PATH=$PATH:$HOME/.npm-packages/bin' >> $HOME/.bashrc
    fi

    # opa
    if [ ! -f "$HOME/Software/opa" ] 
    then
        cd $HOME/Software
        curl -L -o opa https://openpolicyagent.org/downloads/v0.53.0/opa_linux_$(dpkg --print-architecture)_static
        chmod +x ./opa
    fi

    # terraform
    if [ ! -f "$HOME/Software/terraform" ] 
    then
        cd $HOME/Software
        curl -L -o terraform.zip https://releases.hashicorp.com/terraform/1.4.6/terraform_1.4.6_linux_$(dpkg --print-architecture).zip
        unzip terraform.zip
        rm -rf terraform.zip
        chmod +x ./terraform
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

    # Code
    if [ ! -d "$HOME/Software/vscode" ]
    then
        cd $HOME/Software
        mkdir -p $HOME/Software/vscode
        cd $HOME/Software/vscode
        if [[ $architecture == "amd64" ]]; then
            wget --content-disposition -O code.tar.gz "https://code.visualstudio.com/sha/download?build=stable&os=linux-x64"
        else
            wget --content-disposition -O code.tar.gz "https://code.visualstudio.com/sha/download?build=stable&os=linux-$(dpkg --print-architecture)"
        fi
        tar -xzvf ./code.tar.gz
        rm -rf ./code.tar.gz
        mv VSCode*/* .
        rm -rf VSCode*
        chmod +x ./bin/code
        ln -s $HOME/Software/vscode/bin/code $HOME/Software/code
        touch $HOME/.local/share/applications/code.desktop
        chmod +x $HOME/.local/share/applications/code.desktop
        ln -s $HOME/.local/share/applications/code.desktop $HOME/Desktop/code.desktop
        tee $HOME/.local/share/applications/code.desktop << END
[Desktop Entry]
Type=Application
Icon=/home/kasm-user/Software/vscode/resources/app/resources/linux/code.png
Name=VS Code
Comment=VS Code IDE
Categories=Development;
Exec=/home/kasm-user/Software/code
Path=/home/kasm-user/Software
StartupNotify=true
Terminal=false
END

        $HOME/Software/vscode/bin/code --install-extension mikestead.dotenv
        $HOME/Software/vscode/bin/code --install-extension EditorConfig.EditorConfig
        $HOME/Software/vscode/bin/code --install-extension dsznajder.es7-react-js-snippets
        $HOME/Software/vscode/bin/code --install-extension dbaeumer.vscode-eslint
        $HOME/Software/vscode/bin/code --install-extension donjayamanne.githistory
        $HOME/Software/vscode/bin/code --install-extension hashicorp.terraform
        $HOME/Software/vscode/bin/code --install-extension ecmel.vscode-html-css
        $HOME/Software/vscode/bin/code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
        $HOME/Software/vscode/bin/code --install-extension tsandall.opa
        $HOME/Software/vscode/bin/code --install-extension nitayneeman.playwright-snippets
        $HOME/Software/vscode/bin/code --install-extension Postman.postman-for-vscode
        $HOME/Software/vscode/bin/code --install-extension esbenp.prettier-vscode
        $HOME/Software/vscode/bin/code --install-extension ZixuanChen.vitest-explorer
        $HOME/Software/vscode/bin/code --install-extension vscode-icons-team.vscode-icons
        $HOME/Software/vscode/bin/code --install-extension redhat.vscode-xml
        $HOME/Software/vscode/bin/code --install-extension christian-kohler.npm-intellisense

        mkdir -p $HOME/.config/Code/User
        touch $HOME/.config/Code/User/settings.json
        tee $HOME/.config/Code/User/settings.json << END
{
  "window.autoDetectColorScheme": true,
  "telemetry.telemetryLevel": "off",
  "workbench.iconTheme": "vscode-icons",
  "git.enableSmartCommit": true,
  "git.autofetch": true,
  "git.confirmSync": false,
  "workbench.startupEditor": "none",
  "explorer.confirmDelete": false,
  "[typescriptreact]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[html]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "editor.tabSize": 2,
  "[json]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "playwright.reuseBrowser": true,
  "[jsonc]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "extensions.ignoreRecommendations": true,
  "vsicons.dontShowNewVersionMessage": true
}

END
    fi



    # Librewolf
    if [ ! -f "$HOME/Software/librewolf" ]
    then
        cd $HOME/Software
        if [[ $architecture == "amd64" ]]; then
            curl -L -o librewolf https://gitlab.com/api/v4/projects/24386000/packages/generic/librewolf/113.0.2-1/LibreWolf.x86_64.AppImage
        else
            curl -L -o librewolf https://gitlab.com/api/v4/projects/24386000/packages/generic/librewolf/113.0.2-1/LibreWolf.aarch64.AppImage
        fi
        chmod +x ./librewolf
        touch $HOME/.local/share/applications/librewolf.desktop
        chmod +x $HOME/.local/share/applications/librewolf.desktop
        ln -s $HOME/.local/share/applications/librewolf.desktop $HOME/Desktop/librewolf.desktop
        tee $HOME/.local/share/applications/librewolf.desktop << END
[Desktop Entry]
Type=Application
Icon=/home/kasm-user/Software/librewolf
Name=Librewolf
Comment=Librewolf browser
Categories=Network;
Exec=/home/kasm-user/Software/librewolf
Path=/home/kasm-user/Software
StartupNotify=true
Terminal=false
END
        touch $HOME/.config/mimeapps.list
        tee $HOME/.config/mimeapps.list << END
[Default Applications]
x-scheme-handler/http=librewolf.desktop
x-scheme-handler/https=librewolf.desktop
END
        grep -qxF 'export BROWSER=librewolf' $HOME/.bashrc || echo 'export BROWSER=librewolf' >> $HOME/.bashrc
  fi




    touch $HOME/.customized
fi

# unknown option ==> call command
echo -e "\n\n------------------ EXECUTE AFTER CUSTOMIZATION COMMAND ------------------"
echo "Executing command: '$@'"
exec "$@"
