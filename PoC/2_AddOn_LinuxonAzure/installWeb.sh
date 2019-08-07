sudo yum -y install http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm -y
sudo yum update -y
sudo yum install nginx -y
sudo echo "[nginx]
name=nginx repo
baseurl=http://nginx.org/packages/mainline/centos/7/\$basearch/
gpgcheck=0
enabled=1" > /etc/yum.repos.d/nginx.repo
sudo yum update -y
sudo yum install nginx -y
sudo yum -y install epel-release
sudo systemctl enable nginx.service
sudo systemctl start nginx.service