#!/bin/bash
# Sanity check
[ $(id -g) != "0" ] && die "Script must be run as root.";
echo -e "\033[46m NBY的安装脚本 \033[0m"
echo -e "\033[46m1.Prepare\n2.MySQL 5.5\n3.MySQL 5.7\n4.Nginx&PHP 5.6\n5.Nginx&PHP 7.2\n6.mail\n7.ssr\n8.SB Aliyun33[0m"
select selected in 'Prepare' 'MySQL55' 'MySQL57' 'PHP56' 'PHP72' 'opendkim' 'shadowsocksr' 'sbaliyun'; do
break;
done;

if [ "$selected" == 'Prepare' ]; then
  echo -e "\033[46m Closed ssh password login \033[0m"
  sed -i 's:PasswordAuthentication yes:PasswordAuthentication no:g' /etc/ssh/sshd_config
  systemctl restart sshd
  echo -e "\033[46m set hostname \033[0m"
  read newhostname
  hostname $newhostname
  echo "$newhostname" > /proc/sys/kernel/hostname
  sysctl kernel.hostname=$newhostname
  sed -i "\$a HOSTNAME=$newhostname" /etc/sysconfig/network 
  hostnamectl --static set-hostname $newhostname
  echo -e "\033[46m input mysql keys \033[0m"
  read mysql
  yum install -y wget 
  wget -P /usr/sbin https://raw.github.com/andreafabrizi/Dropbox-Uploader/master/dropbox_uploader.sh 
  chmod +x /usr/sbin/dropbox_uploader.sh 
  echo -e "\033[46m [Notice] Close selinux \033[0m"
  [ -s /etc/selinux/config ] && sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config;
  setenforce 0 >/dev/null 2>&1;
  echo -e "\033[46m [Notice] set datetime \033[0m"
  yum install -y screen 
  yum install -y firewalld 
  yum install -y epel-release 
  yum install -y ntp 
  yum install -y crontabs 
  yum install -y libsodium 
  yum install -y git 
  yum install -y fail2ban 
  yum install -y vnstat 
  yum install -y libaio 
  yum install -y net-tools 
  yum install -y yum-utils 
  yum install -y python-devel 
  yum install -y python-setuptools
  vnstat -u -i eth0
  systemctl enable vnstat
  systemctl start vnstat
  systemctl enable firewalld
  systemctl start firewalld
  yum -y groupinstall 'Development Tools';
  ntpdate -u pool.ntp.org;
  rm -rf /etc/localtime;
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime;
  echo -e "\033[46m [Notice] install epel remi nginx repo \033[0m"
  rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
  rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
  yum clean all
  yum makecache
  systemctl disable httpd 
  systemctl stop httpd
  wget -P /usr/sbin/ https://raw.githubusercontent.com/NBY/tools/master/tools/panel 
  chmod +x /usr/sbin/panel
  wget -P /usr/sbin/ https://raw.githubusercontent.com/NBY/tools/master/tools/vhost 
  chmod +x /usr/sbin/vhost
  cd /root
  mkdir /root/tmp
  mkdir /root/tools
  cat > /root/tools/backup.sh<<EOF
  #!/bin/bash
  SCRIPT_DIR="/usr/sbin" #这个改成你存放刚刚下载下来的dropbox_uploader.sh的文件夹位置
  DROPBOX_DIR="/" #这个改成你的备份文件想要放在Dropbox下面的文件夹名称，如果不存在，脚本会自动创建
  BACKUP_SRC="/home /etc/nginx/conf.d /etc/php-fpm.d" #这个是你想要备份的本地VPS上的文件，不同的目录用空格分开
  BACKUP_DST="/root/tmp" #这个是你暂时存放备份压缩文件的地方，一般用/tmp即可
  MYSQL_SERVER="localhost" #这个是你mysql服务器的地址，一般填这个本地地址即可
  MYSQL_USER="root" #这个是你mysql的用户名名称，比如root或admin之类的
  MYSQL_PASS="$mysql" #这个是你mysql用户的密码
  # 下面的一般不用改了
  NOW=\$(date +"%Y.%m.%d")
  DESTFILE="\$BACKUP_DST/\$NOW.tar.gz"
  # 备份mysql数据库并和其它备份文件一起压缩成一个文件
  mysqldump -u \$MYSQL_USER -h \$MYSQL_SERVER -p\$MYSQL_PASS --all-databases > "\$NOW-Databases.sql"
  echo "Databases Package Done,Package Website..."
  tar cfzP "\$DESTFILE" \$BACKUP_SRC "\$NOW-Databases.sql"
  echo "Package Done,Uploading..."
  # 用脚本上传到dropbox
  \$SCRIPT_DIR/dropbox_uploader.sh upload "\$DESTFILE" "\$DROPBOX_DIR/\$NOW.tar.gz"
  if [ \$? -eq 0 ];then
       echo "Upload Successful"
  else
       echo "Upload Fail"
  fi
  # 删除本地的临时文件
  rm -f "\$NOW-Databases.sql" "\$DESTFILE"
EOF
  chmod +x /root/tools/backup.sh
  systemctl enable crond
  systemctl start crond
  wget --no-check-certificate https://github.com/teddysun/across/raw/master/bbr.sh
  chmod +x bbr.sh
  sh /root/bbr.sh
  rm /root/bbr.sh
  echo -e "\033[46mneed set mysql mysql_secure_installation\nset dropbox key\ncrontab -e [0 5 * * * /bin/bash /root/tools/backup.sh]\033[0m"
  exit;
elif [ "$selected" == 'MySQL55' ]; then
  echo -e "\033[46m input mysql keys \033[0m"
  read mysql
  yum remove -y mysql* mariadb*
  rpm -Uvh http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
  yum clean all
  yum makecache
  yum-config-manager --disable mysql57-community-dmr
  yum-config-manager --disable mysql56-community
  yum-config-manager --enable mysql55-community
  yum install -y mysql mysql-devel mysql-server mysql-utilities
  mysql --version
  systemctl start mysqld
  systemctl enable mysqld
  cat > /root/mysql.sql<<EOF
  update mysql.user set Password=password('$mysql') where User="root";
  flush privileges;
  grant all on *.* to 'root'@'%' identified by '$mysql';
  flush privileges;
EOF
  mysql -uroot < /root/mysql.sql
  rm /root/mysql.sql -rf
  echo -e "\033[46m [Notice]Install MySQL5.5 Successful! \033[0m"
  exit;
elif [ "$selected" == 'MySQL57' ]; then
  echo -e "\033[46m input mysql keys \033[0m"
  read mysql
  yum remove -y mysql* mariadb*
  rpm -Uvh http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
  yum-config-manager --enable mysql57-community-dmr
  yum-config-manager --disable mysql56-community
  yum-config-manager --disable mysql55-community
  yum install -y mysql mysql-devel mysql-server mysql-utilities
  mysql --version
  systemctl start mysql
  systemctl enable mysql
  echo -e "\033[46mmysql key is $mysql\nneed set mysql mysql_secure_installation\033[0m"
  echo -e "\033[46m [Notice]Install MySQL5.7 Successful! \033[0m"
  mysql_secure_installation
  exit;
elif [ "$selected" == 'PHP56' ]; then
  yum-config-manager --disable remi-php55
  yum-config-manager --disable remi-php72
  yum-config-manager --enable remi-php56
  yum clean all
  yum makecache
  echo -e "\033[46m [Notice] install service \033[0m"
  yum install -y nginx php php-opcache php-pecl-apcu php-devel php-mbstring php-mcrypt php-mysqlnd php-json php-phpunit-PHPUnit php-pecl-xdebug php-pecl-xhprof php-pdo php-pdo_dblib php-pear php-fpm php-cli php-xml php-bcmath php-process php-gd php-common php-pecl-zip php-recode php-snmp php-soap memcached libmemcached libmemcached-devel php-pecl-memcached redis php-pecl-redis ImageMagick ImageMagick-devel php-pecl-imagick
  sed -i '4a return 500;' /etc/nginx/conf.d/default.conf
  sed -i "/^return/ s/^/    / " /etc/nginx/conf.d/default.conf
  sed -i '23a server_tokens off;' /etc/nginx/nginx.conf
  sed -i '23a fastcgi_connect_timeout 300;' /etc/nginx/nginx.conf
  sed -i '23a fastcgi_send_timeout 300;' /etc/nginx/nginx.conf
  sed -i '23a fastcgi_read_timeout 300;' /etc/nginx/nginx.conf
  sed -i '23a fastcgi_buffer_size 64k;' /etc/nginx/nginx.conf
  sed -i '23a fastcgi_buffers 4 64k;' /etc/nginx/nginx.conf
  sed -i "/^server_tokens/ s/^/    / " /etc/nginx/nginx.conf
  sed -i 's:#gzip  on;:gzip  on;:g' /etc/nginx/nginx.conf
  sed -i 's:short_open_tag = Off:short_open_tag = On:g' /etc/php.ini
  sed -i 's:expose_php = On:expose_php = Off:g' /etc/php.ini
  sed -i 's:;cgi.fix_pathinfo=1:cgi.fix_pathinfo=0:g' /etc/php.ini
  sed -i 's:;date.timezone =:date.timezone = "Asia/Hong_Kong":g' /etc/php.ini
  sed -i 's:; max_input_vars = 1000:max_input_vars = 10000:g' /etc/php.ini
  sed -i 's@;open_basedir =@open_basedir = /data/wwwroot/:/tmp/:/proc/@g' /etc/php.ini
  sed -i 's@listen = 127.0.0.1:9000@listen = /var/run/php-fpm/php-fpm.sock@g' /etc/php-fpm.d/www.conf
  sed -i 's:user = apache:user = nginx:g' /etc/php-fpm.d/www.conf
  sed -i 's:group = apache:group = nginx:g' /etc/php-fpm.d/www.conf
  sed -i 's:;listen.owner = nobody:listen.owner = nobody:g' /etc/php-fpm.d/www.conf
  sed -i 's:;listen.group = nobody:listen.group = nobody:g' /etc/php-fpm.d/www.conf
  wget /usr/lib64/php/modules https://raw.githubusercontent.com/engineyard/php-ioncube-loader/master/ioncube/ioncube_loader_lin_5.6.so
  sed -i "\$a [ionCube Loader]" /etc/php.ini
  sed -i "\$a zend_extension = /usr/lib64/php/modules/ioncube_loader_lin_5.6.so" /etc/php.ini
  echo -e "\033[46m [Notice] Start service \033[0m"
  systemctl enable php-fpm.service;
  systemctl enable nginx.service;
  systemctl enable firewalld.service;
  systemctl start firewalld.service
  firewall-cmd --permanent --zone=public --add-service=http;
  firewall-cmd --permanent --zone=public --add-service=https;
  firewall-cmd --reload;
  systemctl start php-fpm.service;
  systemctl start nginx.service;
  mkdir -p /var/lib/php/session
  chown -R nginx:nginx /var/lib/php/session/
  chown -R nginx:nginx /var/run/php-fpm/
  echo -e "\033[46m [Notice]Ningx PHP5.6 Install Successful! \033[0m"
  exit;
elif [ "$selected" == 'PHP72' ]; then
  yum-config-manager --disable remi-php55
  yum-config-manager --disable remi-php56
  yum-config-manager --enable remi-php72
  yum clean all
  yum makecache
  echo -e "\033[46m [Notice] install service \033[0m"
  yum install -y nginx php php-opcache php-pecl-apcu php-devel php-mbstring php-mcrypt php-mysqlnd php-json php-phpunit-PHPUnit php-pecl-xdebug php-pecl-xhprof php-pdo php-pdo_dblib php-pear php-fpm php-cli php-xml php-bcmath php-process php-gd php-common php-pecl-zip php-recode php-snmp php-soap memcached libmemcached libmemcached-devel php-pecl-memcached redis php-pecl-redis ImageMagick ImageMagick-devel php-pecl-imagick
  sed -i '4a return 500;' /etc/nginx/conf.d/default.conf
  sed -i "/^return/ s/^/    / " /etc/nginx/conf.d/default.conf
  sed -i '23a server_tokens off;' /etc/nginx/nginx.conf
  sed -i '23a fastcgi_connect_timeout 300;' /etc/nginx/nginx.conf
  sed -i '23a fastcgi_send_timeout 300;' /etc/nginx/nginx.conf
  sed -i '23a fastcgi_read_timeout 300;' /etc/nginx/nginx.conf
  sed -i '23a fastcgi_buffer_size 64k;' /etc/nginx/nginx.conf
  sed -i '23a fastcgi_buffers 4 64k;' /etc/nginx/nginx.conf
  sed -i "/^server_tokens/ s/^/    / " /etc/nginx/nginx.conf
  sed -i 's:#gzip  on;:gzip  on;:g' /etc/nginx/nginx.conf
  sed -i 's:short_open_tag = Off:short_open_tag = On:g' /etc/php.ini
  sed -i 's:expose_php = On:expose_php = Off:g' /etc/php.ini
  sed -i 's:;cgi.fix_pathinfo=1:cgi.fix_pathinfo=0:g' /etc/php.ini
  sed -i 's:;date.timezone =:date.timezone = "Asia/Hong_Kong":g' /etc/php.ini
  sed -i 's:; max_input_vars = 1000:max_input_vars = 10000:g' /etc/php.ini
  sed -i 's@;open_basedir =@open_basedir = /data/wwwroot/:/tmp/:/proc/@g' /etc/php.ini
  sed -i 's@listen = 127.0.0.1:9000@listen = /var/run/php-fpm/php-fpm.sock@g' /etc/php-fpm.d/www.conf
  sed -i 's:user = apache:user = nginx:g' /etc/php-fpm.d/www.conf
  sed -i 's:group = apache:group = nginx:g' /etc/php-fpm.d/www.conf
  sed -i 's:;listen.owner = nobody:listen.owner = nobody:g' /etc/php-fpm.d/www.conf
  sed -i 's:;listen.group = nobody:listen.group = nobody:g' /etc/php-fpm.d/www.conf
  echo -e "\033[46m [Notice] Start service \033[0m"
  systemctl enable php-fpm.service;
  systemctl enable nginx.service;
  systemctl enable firewalld.service;
  systemctl start firewalld.service
  firewall-cmd --permanent --zone=public --add-service=http;
  firewall-cmd --permanent --zone=public --add-service=https;
  firewall-cmd --reload;
  systemctl start php-fpm.service;
  systemctl start nginx.service;
  mkdir -p /var/lib/php/session
  chown -R nginx:nginx /var/lib/php/session/
  chown -R nginx:nginx /var/run/php-fpm/  
  echo -e "\033[46m [Notice]Ningx PHP7.2 Install Successful! \033[0m"
  exit;
elif [ "$selected" == 'opendkim' ]; then
  echo -e "\033[46m [Notice] install postfix opendkim \033[0m"
  yum install -y postfix opendkim mailx
  sed -i "s/#myhostname = virtual.domain.tld/myhostname = `hostname -f`/g" /etc/postfix/main.cf
  sed -i "s/#mydomain = domain.tld/mydomain = `hostname -f`/g" /etc/postfix/main.cf
  sed -i 's:inet_interfaces = localhost:inet_interfaces = all:g' /etc/postfix/main.cf
  sed -i 's:inet_protocols = all:inet_protocols = ipv4:g' /etc/postfix/main.cf
  sed -i 's:mydestination =:#mydestination =:g' /etc/postfix/main.cf
  sed -i 's:#relay_domains = $mydestination:relay_domains = $mydomain:g' /etc/postfix/main.cf
  sed -i 's:#myorigin = $mydomain:myorigin = $mydomain:g' /etc/postfix/main.cf

  rm /etc/opendkim.conf -rf
  wget -P /etc/ https://raw.githubusercontent.com/NBY/tools/master/tools/opendkim.conf

  mkdir -p /etc/opendkim/keys/`hostname -f`
  opendkim-genkey -D /etc/opendkim/keys/`hostname -f`/ -d `hostname -f` -s default
  chown opendkim:opendkim -R /etc/opendkim/
  chmod -R 700 /etc/opendkim
  echo "default._domainkey.`hostname -f` `hostname -f`:default:/etc/opendkim/keys/`hostname -f`/default.private" >> /etc/opendkim/KeyTable
  echo "*@`hostname -f` default._domainkey.`hostname -f`" >> /etc/opendkim/SigningTable
  echo "localhost" >> /etc/opendkim/TrustedHosts
  echo "`hostname -f`" >> /etc/opendkim/TrustedHosts
  cat >> /etc/postfix/main.cf<<EOF
  mynetworks = 127.0.0.0/8
  home_mailbox = Maildir/
  mydestination = $myhostname, localhost.$mydomain, localhost, $mydomain, mail.$mydomain, www.$mydomain, ftp.$mydomain
  #DKIM
  milter_default_action = accept
  milter_protocol = 2
  smtpd_milters = inet:8891
  non_smtpd_milters = inet:8891
EOF
  hash -r
  systemctl enable postfix
  systemctl start postfix
  systemctl enable opendkim
  systemctl start opendkim
  cp /etc/opendkim/keys/`hostname -f`/default.txt /root/`hostname -f`-dkim-signature_default.txt
  echo -e "\033[46m open '/root/`hostname -f`-dkim-signature_default.txt', then add the TXT record to you DNS resolution system. \033[0m"
  echo -e "\033[46m [Notice] install postfix opendkim successful \033[0m"
  exit;
elif [ "$selected" == 'shadowsocksr' ]; then
  wget -P /usr/sbin/ https://raw.githubusercontent.com/NBY/tools/master/tools/forward
  chmod +x /usr/sbin/forward
  git clone -b manyuser https://github.com/ToyoDAdoubi/shadowsocksr.git
  cd shadowsocksr
  bash setup_cymysql.sh
  bash initcfg.sh
  firewall-cmd --zone=public --permanent --add-service=mysql
  firewall-cmd --zone=public --add-port=10000-11000/tcp --permanent
  firewall-cmd --zone=public --add-port=10000-11000/udp --permanent
  firewall-cmd --reload
  ulimit -n 51200 && echo ulimit -n 51200 >> /etc/rc.local
  echo "bash /root/shadowsocksr/run.sh" >> /etc/rc.local
  echo "* soft nofile 51200" >> /etc/security/limits.conf
  echo "* hard nofile 51200" >> /etc/security/limits.conf
  echo "fs.file-max = 51200
  net.core.rmem_max = 67108864
  net.core.wmem_max = 67108864
  net.core.netdev_max_backlog = 250000
  net.core.somaxconn = 4096
  net.ipv4.tcp_tw_reuse = 1
  net.ipv4.tcp_tw_recycle = 0
  net.ipv4.tcp_fin_timeout = 30
  net.ipv4.tcp_keepalive_time = 1200
  net.ipv4.ip_local_port_range = 10000 65000
  net.ipv4.tcp_max_syn_backlog = 8192
  net.ipv4.tcp_max_tw_buckets = 5000
  net.ipv4.tcp_syncookies = 1
  net.ipv4.tcp_fastopen = 3
  net.ipv4.tcp_rmem = 4096 87380 67108864
  net.ipv4.tcp_wmem = 4096 65536 67108864
  net.ipv4.tcp_mtu_probing = 1" >> /etc/sysctl.conf
  exit;
  elif [ "$selected" == 'sbaliyun' ]; then
    curl -sSL http://update.aegis.aliyun.com/download/quartz_uninstall.sh | sudo bash
    rm -rf /usr/local/aegis
    rm -rf /usr/sbin/aliyun-service
    rm -rf /lib/systemd/system/aliyun.service
    killall aliyun-service && echo "" >/usr/sbin/aliyun-service
    echo "" >/etc/motd
  exit;
fi;
