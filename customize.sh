apt-get update
apt-get install -y sudo \
    && echo 'kasm-user ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers \
    && rm -rf /var/lib/apt/list/*


# Tools
apt-get install -y wget git curl ca-certificates nano jq

# Repos
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /etc/apt/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list

curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list

curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -

wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
rm -f packages.microsoft.gpg

add-apt-repository ppa:saiarcot895/chromium-beta

# Update again
apt-get update

# Chromium
ENV CHROMIUM_USER_FLAGS --no-sandbox
apt-get install -y chromium-browser



# NodeJS and NPM
apt-get install -y nodejs

npm i -g typescript @angular/cli gitfox

# VSCode
apt-get install -y code

# Kubectl
apt-get install -y kubectl

# Helm
wget -q https://get.helm.sh/helm-v3.12.0-linux-$(dpkg --print-architecture).tar.gz
tar -zxvf ./helm-v3.12.0-linux-$(dpkg --print-architecture).tar.gz
mv ./linux-$(dpkg --print-architecture)/helm /usr/bin/helm
chmod +x /usr/bin/helm
rm ./helm-v3.12.0-linux-$(dpkg --print-architecture).tar.gz
rm -rf ./linux-$(dpkg --print-architecture)

# TerraForm
sudo apt-get install -y terraform


echo "export NODE_ENV=development" >> /home/kasm-default-profile/.bashrc
echo "export CHROMIUM_USER_FLAGS=--no-sandbox" >> /home/kasm-default-profile/.bashrc
echo "export HELM_EXPERIMENTAL_OCI=1" >> /home/kasm-default-profile/.bashrc
echo "export ASPNETCORE_ENVIRONMENT=Development" >> /home/kasm-default-profile/.bashrc
echo "export DOTNET_ENVIRONMENT=Development" >> /home/kasm-default-profile/.bashrc
echo "export FUNCTIONS_ENVIRONMENT=Development" >> /home/kasm-default-profile/.bashrc
mkdir -p /home/kasm-default-profile/Software
echo "export PATH=\$PATH:~/Software" >> /home/kasm-default-profile/.bashrc