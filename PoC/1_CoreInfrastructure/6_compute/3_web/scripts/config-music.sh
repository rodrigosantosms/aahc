#!/bin/bash

# Phase 1 - Install dotnet core
echo "--------------------------------------------------------" >> /tmp/install.log
echo "Phase 1 - Install dotnet core and Create Azure Database" >> /tmp/install.log
cd /tmp
sudo mkdir /opt/dotnet
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:/opt/dotnet
sudo wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt-get update
sudo curl -s "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x52E16F86FEE04B979B07E28DB02C46DF417A0893" | sudo apt-key add -
sudo curl -L https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-bionic-prod bionic main" > /etc/apt/sources.list.d/dotnetdev.list'
sudo apt-get update
sudo apt-get install -y apt-transport-https
sudo apt-get update && sudo apt-get install -y libicu52 libcurl3 liblldb-3.6 libunwind8-dev libunwind
sudo apt-get install apt-transport-https
sudo apt-get install -y dotnet-dev-1.1.11
sudo wget -O /tmp/dotnet-dev-ubuntu-x64.1.1.11.tar.gz https://download.visualstudio.microsoft.com/download/pr/c0957a2b-cac6-44d8-b1cc-0dad4420c825/8dc69e33f8cf44152fdf173d3bf0b746/dotnet-dev-ubuntu-x64.1.1.11.tar.gz  --append-output=/tmp/install.log
sudo tar zxf dotnet-dev-ubuntu-x64.1.1.11.tar.gz -C /opt/dotnet
dotnet --version  >> /tmp/install.log

# Phase 2 - Download application
echo "--------------------------------------------------------" >> /tmp/install.log
echo "Phase 2 - Download application" >> /tmp/install.log
sudo wget -O /tmp/music-store-azure-demo-pub.tar.gz https://raw.githubusercontent.com/rodrigosantosms/aahc/master/PoC/1_CoreInfrastructure/6_compute/3_web/music-app/music-store-azure-demo-pub.tar.gz --append-output=/tmp/install.log
sleep 30
sudo tar -xzvf /tmp/music-store-azure-demo-pub.tar.gz -C /opt

# Phase 3 - Install nginx, update config files -l /
echo "--------------------------------------------------------" >> /tmp/install.log
echo "Phase 3 - Install nginx, update config file" >> /tmp/install.log
sudo apt-get install -y nginx >> /tmp/install.log
sudo service nginx start >> /tmp/install.log
sudo touch /etc/nginx/sites-available/default >> /tmp/install.log
sudo cp /etc/nginx/sites-available/default /tmp/bkp_nginx_sites-available_default >> /tmp/install.log
sudo wget -O /tmp/default https://raw.githubusercontent.com/rodrigosantosms/aahc/master/PoC/1_CoreInfrastructure/6_compute/3_web/music-app/nginx-config/default --append-output=/tmp/install.log
sudo mkdir /opt/music/nginx-config >> /tmp/install.log
sudo cp /tmp/default /opt/music/nginx-config/default >> /tmp/install.log
sudo cp /tmp/default /etc/nginx/sites-available/default >> /tmp/install.log
sudo nginx -s reload >> /tmp/install.log

# 4 update and secure music config file
echo "--------------------------------------------------------" >> /tmp/install.log
echo "Phase 4 - Update and secure music config file" >> /tmp/install.log
sudo sed -i "s/<replaceserver>/$1/g" /opt/music/config.json >> /tmp/install.log
sudo sed -i "s/<replaceuser>/$2/g" /opt/music/config.json >> /tmp/install.log
sudo sed -i "s/<replacepass>/$3/g" /opt/music/config.json >> /tmp/install.log
sudo chown $2 /opt/music/config.json
sudo chmod 0400 /opt/music/config.json

# 5 config supervisor
echo "--------------------------------------------------------" >> /tmp/install.log
echo "Phase 5 - Config supervisor" >> /tmp/install.log
sudo apt-get install -y supervisor
sudo touch /etc/supervisor/conf.d/music.conf >> /tmp/install.log
sudo wget -O /etc/supervisor/conf.d/music.conf https://raw.githubusercontent.com/rodrigosantosms/aahc/master/PoC/1_CoreInfrastructure/6_compute/3_web/music-app/supervisor/music.conf --append-output=/tmp/install.log
sudo service supervisor stop >> /tmp/install.log
sudo service supervisor start >> /tmp/install.log

# 6 pre-create music store database and Start the App
echo "--------------------------------------------------------" >> /tmp/install.log
echo "Phase 6 - Pre-create music store database" >> /tmp/install.log
dotnet --version >> /tmp/dotnetversion.log
sudo wget -O /etc/init.d/musicstorestopstart.sh https://raw.githubusercontent.com/rodrigosantosms/aahc/master/PoC/1_CoreInfrastructure/6_compute/3_web/scripts/musicstorestopstart.sh --append-output=/tmp/install.log
chmod a+x /etc/init.d/musicstorestopstart.sh
sudo update-rc.d musicstorestopstart.sh defaults
sudo /etc/init.d/musicstorestopstart.sh start