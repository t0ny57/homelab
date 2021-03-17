#!/usr/bin/env bash
set -euo pipefail

ABSPATH=$(readlink -f $0)
ABSDIR=$(dirname $ABSPATH)

### functions ###

root_confirm() {

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

}

repo_install() {

if [[ $(lsb_release -rs) == "20.04" ]]; then # Ubuntu release detection

	echo "Ubuntu 20.04"
	
	curl https://repo.zabbix.com/zabbix/5.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.2-1+ubuntu20.04_all.deb -o $ABSDIR/zabbix-release_5.2-1+ubuntu20.04_all.deb && 
	dpkg -i zabbix-release_5.2-1+ubuntu20.04_all.deb && 
	apt update &&
	echo "repo install is succeed"
elif [[ $(lsb_release -rs) == "18.04" ]]; then

	echo "Ubuntu 18.04"
	
	curl https://repo.zabbix.com/zabbix/5.2/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.2-1+ubuntu18.04_all.deb -o $ABSDIR/zabbix-release_5.2-1+ubuntu18.04_all.deb  &&
	dpkg -i zabbix-release_5.2-1+ubuntu18.04_all.deb &&
	apt update 
else
     echo "Non-compatible distro!"
fi

}


zabbix_install() {

if [[ $(lsb_release -rs) == "20.04" ]]; then # Ubuntu release detection

	echo "Ubuntu 20.04"
	
	apt install zabbix-server-pgsql zabbix-frontend-php php7.4-pgsql zabbix-nginx-conf zabbix-agent postgresql postgresql-contrib &&
	echo "zabbix install is succeed"
elif [[ $(lsb_release -rs) == "18.04" ]]; then

	echo "Ubuntu 18.04"
	
	apt install zabbix-server-pgsql zabbix-frontend-php php7.2-pgsql zabbix-nginx-conf zabbix-agent postgresql postgresql-contrib &&
	echo "zabbix install is succeed"
else
      echo "Non-compatible distro!"
fi

}

db_create() {

	#sudo -u postgres createuser zabbix &&  ##
	sudo -u postgres createuser --pwprompt zabbix
	sudo -u postgres createdb -O zabbix zabbix &&
	zcat /usr/share/doc/zabbix-server-pgsql*/create.sql.gz | sudo -u zabbix psql zabbix 
	
}

nginx_conf() {

	cp $ABSDIR/nginx.conf /etc/zabbix/nginx.conf &&
	cp $ABSDIR/php-fpm.conf /etc/zabbix/php-fpm.conf &&	
	rm /etc/nginx/sites-enabled/default 

if [[ $(lsb_release -rs) == "20.04" ]]; then
	
	echo "Ubuntu 20.04"

	systemctl restart zabbix-server zabbix-agent nginx php7.4-fpm &&
	systemctl enable zabbix-server zabbix-agent nginx php7.4-fpm 

elif [[ $(lsb_release -rs) == "18.04" ]]; then

	echo "Ubuntu 18.04"
	
	systemctl restart zabbix-server zabbix-agent nginx php7.2-fpm &&
	systemctl enable zabbix-server zabbix-agent nginx php7.2-fpm

else
      echo "Non-compatible distro!"
fi			
}

### THE ACTUAL SCRIPT ###
### This is how everything happens in an intuitive format and order.

root_confirm || echo "Please run as root"
repo_install || echo "repo install is not succeed"
zabbix_install || echo "zabbix install is not succeed"
db_create || echo "psql db creation is not succeed"
nginx_conf || echo "ngix configuration is not succeed"
