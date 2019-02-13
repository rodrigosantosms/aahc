#!/bin/bash
aa="pocsqlserver01"
bb="localadmin"
cc="P@ssw0rd0101#"

# Phase 1 - Install dotnet core
echo "--------------------------------------------------------" >> /tmp/install.log
echo "Phase 1 - Install dotnet core" >> /tmp/install.log
cd /tmp
wget https://download.visualstudio.microsoft.com/download/pr/c0957a2b-cac6-44d8-b1cc-0dad4420c825/8dc69e33f8cf44152fdf173d3bf0b746/dotnet-dev-ubuntu-x64.1.1.11.tar.gz
sudo mkdir /opt/dotnet
export PATH=$PATH:/opt/dotnet
sudo tar zxf dotnet-dev-ubuntu-x64.1.1.11.tar.gz -C /opt/dotnet
sudo apt-key adv --keyserver packages.microsoft.com --recv-keys EB3E94ADBE1229CF
sudo apt-key adv --keyserver packages.microsoft.com --recv-keys 52E16F86FEE04B979B07E28DB02C46DF417A0893
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-bionic-prod bionic main" > /etc/apt/sources.list.d/dotnetdev.list'
sudo apt-get update
sudo apt-get install apt-transport-https
sudo apt-get update && sudo apt-get install -y libicu52 libcurl3 liblldb-3.6 libunwind8-dev >> /tmp/install.log
sudo apt-get install dotnet-dev-1.1.11
dotnet --version  >> /tmp/install.log

# Phase 2 - Download application
echo "--------------------------------------------------------" >> /tmp/install.log
echo "Phase 2 - Download application" >> /tmp/install.log
sudo wget -P /tmp https://raw.githubusercontent.com/rodrigosantosms/aahc/master/2-poc/2-1-maintrack/templates/vmscaleset/music-store-azure-demo-pub.tar --append-output=/tmp/install.log
sudo mkdir /opt/music
sudo tar -xf /tmp/music-store-azure-demo-pub.tar -C /opt/music

# Phase 3 - Install nginx, update config file
echo "--------------------------------------------------------" >> /tmp/install.log
echo "Phase 3 - Install nginx, update config file" >> /tmp/install.log
sudo apt-get install -y nginx >> /tmp/install.log
sudo service nginx start >> /tmp/install.log
sudo touch /etc/nginx/sites-available/default >> /tmp/install.log
sudo cp /etc/nginx/sites-available/default /tmp/bkp_nginx_sites-available_default >> /tmp/install.log
sudo wget -P /tmp https://raw.githubusercontent.com/Microsoft/dotnet-core-sample-templates/master/dotnet-core-music-linux/music-app/nginx-config/default --append-output=/tmp/install.log
sudo mkdir /opt/music/nginx-config >> /tmp/install.log
sudo cp /tmp/default /opt/music/nginx-config/default >> /tmp/install.log
sudo cp /tmp/default /etc/nginx/sites-available/default >> /tmp/install.log
sudo nginx -s reload >> /tmp/install.log

# 4 update and secure music config file
echo "--------------------------------------------------------" >> /tmp/install.log
echo "Phase 4 - Update and secure music config file" >> /tmp/install.log
sudo sed -i "s/<replaceserver>/$aa/g" /opt/music/config.json >> /tmp/install.log
sudo sed -i "s/<replaceuser>/$bb/g" /opt/music/config.json >> /tmp/install.log
sudo sed -i "s/<replacepass>/$cc/g" /opt/music/config.json >> /tmp/install.log
sudo chown $bb /opt/music/config.json >> /tmp/install.log
sudo chmod 0400 /opt/music/config.json >> /tmp/install.log

# 5 config supervisor
echo "--------------------------------------------------------" >> /tmp/install.log
echo "Phase 5 - Config supervisor" >> /tmp/install.log
sudo apt-get install -y supervisor
sudo touch /etc/supervisor/conf.d/music.conf >> /tmp/install.log
sudo wget -P /etc/supervisor/conf.d/music.conf https://raw.githubusercontent.com/Microsoft/dotnet-core-sample-templates/master/dotnet-core-music-linux/music-app/supervisor/music.conf --append-output=/tmp/install.log
sudo service supervisor stop >> /tmp/install.log
sudo service supervisor start >> /tmp/install.log

# 6 pre-create music store database
echo "--------------------------------------------------------" >> /tmp/install.log
echo "Phase 6 - Pre-create music store database" >> /tmp/install.log
dotnet /opt/music/MusicStore.dll &