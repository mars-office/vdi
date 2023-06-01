#!/usr/bin/env bash
set -ex
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


#     tee -a $HOME/.local/share/applications/chromium.desktop << END
# [Desktop Entry]
# Type=Application
# Icon=chromium-browser
# Name=Chromium
# Comment=Chromium Browser
# Categories=Internet;
# Exec=chromium-browser
# Path=$HOME
# StartupNotify=true
# Terminal=false
# END

    touch $HOME/.customized
fi

# unknown option ==> call command
echo -e "\n\n------------------ EXECUTE AFTER CUSTOMIZATION COMMAND ------------------"
echo "Executing command: '$@'"
exec "$@"