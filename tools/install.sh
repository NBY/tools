#!/bin/bash
echo -e "\033[46m set hostname \033[0m"
read newhostname
hostname $newhostname
echo "$newhostname" > /proc/sys/kernel/hostname
sysctl kernel.hostname=$newhostname
sed -i "\$a HOSTNAME=$newhostname" /etc/sysconfig/network 
hostnamectl --static set-hostname $newhostname
echo -e "\033[46m input mysql keys (write in backup shell) \033[0m"
read mysql
yum install -y wget 
wget -P /usr/sbin https://raw.github.com/andreafabrizi/Dropbox-Uploader/master/dropbox_uploader.sh 
chmod +x /usr/sbin/dropbox_uploader.sh 
echo -e "\033[46m [Notice] Close selinux \033[0m"
[ -s /etc/selinux/config ] && sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config;
setenforce 0 >/dev/null 2>&1;
echo -e "\033[46m [Notice] set datetime \033[0m"
yum install -y epel-release ntp crontabs;
yum -y groupinstall 'Development Tools';
ntpdate -u pool.ntp.org;
rm -rf /etc/localtime;
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime;
echo -e "\033[46m [Notice] install epel remi nginx repo \033[0m"
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
rpm -Uvh http://nginx.org/packages/centos/7/noarch/RPMS/nginx-release-centos-7-0.el7.ngx.noarch.rpm
rpm -Uvh http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
rm /etc/yum.repos.d/remi.repo -f
cat > /etc/yum.repos.d/remi.repo <<"EOF"
# Repository: http://rpms.remirepo.net/
# Blog:       http://blog.remirepo.net/
# Forum:      http://forum.remirepo.net/

[remi]
name=Remi's RPM repository for Enterprise Linux 7 - $basearch
#baseurl=http://rpms.remirepo.net/enterprise/7/remi/$basearch/
#mirrorlist=https://rpms.remirepo.net/enterprise/7/remi/httpsmirror
mirrorlist=http://rpms.remirepo.net/enterprise/7/remi/mirror
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi

[remi-php55]
name=Remi's PHP 5.5 RPM repository for Enterprise Linux 7 - $basearch
#baseurl=http://rpms.remirepo.net/enterprise/7/php55/$basearch/
#mirrorlist=https://rpms.remirepo.net/enterprise/7/php55/httpsmirror
mirrorlist=http://rpms.remirepo.net/enterprise/7/php55/mirror
# NOTICE: common dependencies are in "remi-safe"
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi

[remi-php56]
name=Remi's PHP 5.6 RPM repository for Enterprise Linux 7 - $basearch
#baseurl=http://rpms.remirepo.net/enterprise/7/php56/$basearch/
#mirrorlist=https://rpms.remirepo.net/enterprise/7/php56/httpsmirror
mirrorlist=http://rpms.remirepo.net/enterprise/7/php56/mirror
# NOTICE: common dependencies are in "remi-safe"
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi

[remi-test]
name=Remi's test RPM repository for Enterprise Linux 7 - $basearch
#baseurl=http://rpms.remirepo.net/enterprise/7/test/$basearch/
name=Remi's test RPM repository for Enterprise Linux 7 - $basearch
#baseurl=http://rpms.remirepo.net/enterprise/7/test/$basearch/
#mirrorlist=https://rpms.remirepo.net/enterprise/7/test/mirror
mirrorlist=http://rpms.remirepo.net/enterprise/7/test/mirror
# WARNING: If you enable this repository, you must also enable "remi"
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi

[remi-debuginfo]
name=Remi's RPM repository for Enterprise Linux 7 - $basearch - debuginfo
baseurl=http://rpms.remirepo.net/enterprise/7/debug-remi/$basearch/
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi

[remi-php55-debuginfo]
name=Remi's PHP 5.5 RPM repository for Enterprise Linux 7 - $basearch - debuginfo
baseurl=http://rpms.remirepo.net/enterprise/7/debug-php55/$basearch/
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi

[remi-php56-debuginfo]
name=Remi's PHP 5.6 RPM repository for Enterprise Linux 7 - $basearch - debuginfo
baseurl=http://rpms.remirepo.net/enterprise/7/debug-php56/$basearch/
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi

[remi-test-debuginfo]
name=Remi's test RPM repository for Enterprise Linux 7 - $basearch - debuginfo
baseurl=http://rpms.remirepo.net/enterprise/7/debug-test/$basearch/
enabled=0
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-remi
EOF
yum clean all
yum makecache
echo -e "\033[46m [Notice] install service \033[0m"
yum install -y nginx mysql-community-server php php-opcache php-pecl-apcu php-devel php-mbstring php-mcrypt php-mysqlnd php-json php-phpunit-PHPUnit php-pecl-xdebug php-pecl-xhprof php-pdo php-pdo_dblib php-pear php-fpm php-cli php-xml php-bcmath php-process php-gd php-common php-pecl-zip php-recode php-snmp php-soap memcached libmemcached libmemcached-devel php-pecl-memcached redis php-pecl-redis ImageMagick ImageMagick-devel php-pecl-imagick
sed -i '4a return 500;' /etc/nginx/conf.d/default.conf
sed -i "/^return/ s/^/    / " /etc/nginx/conf.d/default.conf
sed -i '23a server_tokens off;' /etc/nginx/nginx.conf
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
systemctl disable httpd 
systemctl stop httpd
systemctl enable mysqld.service;
systemctl enable php-fpm.service;
systemctl enable nginx.service;
systemctl enable firewalld.service;
systemctl start firewalld.service
firewall-cmd --permanent --zone=public --add-service=http;
firewall-cmd --permanent --zone=public --add-service=https;
firewall-cmd --reload;
systemctl start mysqld.service;
systemctl start php-fpm.service;
systemctl start nginx.service;
mkdir -p /var/lib/php/session
chown -R nginx:nginx /var/lib/php/session/
chown -R nginx:nginx /var/run/php-fpm/
echo -e "\033[46m [Notice] lnmp successful \033[0m"
echo -e "\033[46m [Notice] install postfix opendkim \033[0m"
yum install -y postfix opendkim mailx
sed -i "s/#myhostname = virtual.domain.tld/myhostname = `hostname -f`/g" /etc/postfix/main.cf
sed -i "s/#mydomain = domain.tld/mydomain = `hostname -f`/g" /etc/postfix/main.cf
sed -i 's:inet_interfaces = localhost:inet_interfaces = all:g' /etc/postfix/main.cf
sed -i 's:inet_protocols = all:inet_protocols = ipv4:g' /etc/postfix/main.cf
sed -i 's:mydestination =:#mydestination =:g' /etc/postfix/main.cf
sed -i 's:#relay_domains = $mydestination:relay_domains = $mydomain:g' /etc/postfix/main.cf
sed -i 's:#myorigin = $mydomain:myorigin = $mydomain:g' /etc/postfix/main.cf
cat > /etc/opendkim.conf<<"EOF"
UserID                  opendkim:opendkim
UMask                   022
Mode                    sv
PidFile                 /var/run/opendkim/opendkim.pid
Canonicalization        relaxed/relaxed
TemporaryDirectory      /var/tmp
ExternalIgnoreList      refile:/etc/opendkim/TrustedHosts
InternalHosts           refile:/etc/opendkim/TrustedHosts
KeyTable                refile:/etc/opendkim/KeyTable
SigningTable            refile:/etc/opendkim/SigningTable
MinimumKeyBits          1024
Socket                  inet:8891@127.0.0.1
LogWhy                  Yes
Syslog                  Yes
SyslogSuccess           Yes
EOF
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
cat > /usr/sbin/panel<<"EOF"
#!/bin/bash
# Sanity check
[ $(id -g) != "0" ] && die "Script must be run as root.";
echo -e "\033[46m Nginx PHP Mail Manage \033[0m"
echo -e "\033[46m1.restart nginx&php-fpm\n2.check nginx&php-fpm status\n3.restart postfix&opendkim\n4.check postfix&opendkim \033[0m"
select selected in 'rnp' 'cnp' 'rpo' 'cpo'; do
break;
done;


if [ "$selected" == 'rnp' ]; then
  systemctl restart nginx
  systemctl restart php-fpm
  systemctl status nginx
  systemctl status php-fpm
  chown -R nginx:nginx /var/run/php-fpm/
  chown -R nginx:nginx /var/lib/php/session/
  exit;
elif [ "$selected" == 'cnp' ]; then
  systemctl status nginx
  systemctl status php-fpm
  exit;
elif [ "$selected" == 'rpo' ]; then
  systemctl restart postfix
  systemctl restart opendkim
  systemctl status postfix
  systemctl status opendkim
  exit;
elif [ "$selected" == 'cpo' ]; then
  systemctl status postfix
  systemctl status opendkim
  exit;
fi;

EOF
chmod +x /usr/sbin/panel
mkdir /root/backup
mkdir /root/tools
mkdir /root/tmp
cat > /root/tools/backup.sh<<EOF
#!/bin/bash
SCRIPT_DIR="/usr/sbin" #这个改成你存放刚刚下载下来的dropbox_uploader.sh的文件夹位置
DROPBOX_DIR="/root/backup" #这个改成你的备份文件想要放在Dropbox下面的文件夹名称，如果不存在，脚本会自动创建
BACKUP_SRC="/home /etc/nginx/conf.d" #这个是你想要备份的本地VPS上的文件，不同的目录用空格分开
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
echo '#!/bin/bash
# Sanity check
[ $(id -g) != "0" ] && die "Script must be run as root.";
echo -e "\033[46m Vhost Manage \033[0m"
echo -e "\033[46m1.add www domain\n2.add second domain\n3.delete website\n4.exit \033[0m"
select selected in 'addwww' 'addxxx' 'del' 'exit'; do
break;
done;
if [ "$selected" == 'addwww' ]; then
	unset domain
    echo "input domain";
	read domain
	useradd -m -s /sbin/nologin $domain;
	usermod -G nginx $domain
	mkdir -p /home/$domain/www;
	mkdir -p /home/$domain/log;
	mkdir -p /home/$domain/tmp/session;
	chown -R nginx:nginx /home/$domain
    cat > /etc/nginx/conf.d/$domain.conf <<EOF
server {
 listen 80;
 server_name www.$domain;
 access_log /home/$domain/log/access.log;
 error_log /home/$domain/log/error.log;
 root /home/$domain/www;
 index index.php index.html index.htm;
 location = /favicon.ico {
 log_not_found off;
 access_log off;
 }
 #include /home/$domain/rewrite.conf;
 location = /robots.txt {
 allow all;
 log_not_found off;
 access_log off;
 }

 #error_page 404 /404.html;

 # redirect server error pages to the static page /50x.html
 #
 error_page 500 502 503 504 /50x.html;
 location = /50x.html {
 root /usr/share/nginx/html;
 }

 # pass the PHP scripts to FastCGI server listening on sock
 #
 location ~ \.php\$ { 
 try_files \$uri =404;
 fastcgi_pass unix:/var/run/php-fpm/$domain.sock;
 fastcgi_index index.php;
 fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
 include fastcgi_params;
 }
 
 # Deny all attempts to access hidden files such as .htaccess
 # Deny access to any files with a .php extension in the uploads directory
 #
 location ~ /\. {
 deny all;
 }
 location ~* /(?:uploads|files|data|upload)/.*\.php\$ {
 deny all;
 }
 
 location ~* \.(gif|jpg|jpeg|png|bmp|txt|zip|jar|swf)\$ {
 expires 30d;
 access_log off; 
 valid_referers none blocked *.$domain  server_names ~\.google\. ~\.baidu\. ~\.bing\. ~\.yahoo\. ~\.soso\. ~\.sogou\. ~\.alexa\. ~\.haosou\. ~\.youdao\.;
 if (\$invalid_referer) {
 #return 403;
 rewrite ^/ http://www.$domain/403.png;
  }
 }
 rewrite ^/sitemap.xml\$ /sitemap.php last;
}

server {
	server_name $domain;
	rewrite ^/(.*)\$ http://www.\$host/$1 permanent;
	}
EOF
    cat > /etc/php-fpm.d/$domain.conf <<EOF
[$domain]
listen = /var/run/php-fpm/$domain.sock
listen.allowed_clients = 127.0.0.1
listen.owner = nginx
listen.group = nginx
listen.mode = 0660

user = nginx
group = nginx

pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35

chdir = /
slowlog = /var/log/php-fpm/www-slow.log
php_value[session.save_handler] = files
php_value[session.save_path] = /home/$domain/tmp/session
php_admin_value[open_basedir] = /home/$domain/www:/home/$domain/tmp:/usr/share/php:/tmp
php_admin_value[upload_tmp_dir] = /home/$domain/tmp
EOF
#    cat > /etc/logrotate.d/$domain <<EOF
#/data/$domain/log/*.log {
#daily
#missingok
#rotate 7
#compress
#delaycompress
#notifempty
#create 640 nginx adm
#sharedscripts
#postrotate
# [ -f /var/run/nginx.pid ] && kill -USR1 `cat /var/run/nginx.pid`
#endscript
#}
#EOF
	nginx -t
    systemctl restart nginx
    systemctl restart php-fpm
    systemctl status nginx
    systemctl status php-fpm
	echo "successful!";
    exit;
elif [ "$selected" == 'addxxx' ]; then
	unset domain
    echo "input domain";
	read domain
	unset sdomain
	echo "input second domain [need add . at end]";
	read sdomain
	useradd -m -s /sbin/nologin $sdomain$domain;
	usermod -G nginx $sdomain$domain
	mkdir -p /home/$sdomain$domain/www;
	mkdir -p /home/$sdomain$domain/log;
	mkdir -p /home/$sdomain$domain/tmp/session;
	chown -R nginx:nginx /home/$sdomain$domain
    cat > /etc/nginx/conf.d/$sdomain$domain.conf <<EOF
server {
 listen 80;
 server_name $sdomain$domain;
 access_log /home/$sdomain$domain/log/access.log;
 error_log /home/$sdomain$domain/log/error.log;
 root /home/$sdomain$domain/www;
 index index.php index.html index.htm;
 location = /favicon.ico {
 log_not_found off;
 access_log off;
 }
 #include /home/$sdomain$domain/rewrite.conf;
 location = /robots.txt {
 allow all;
 log_not_found off;
 access_log off;
 }

 #error_page 404 /404.html;

 # redirect server error pages to the static page /50x.html
 #
 error_page 500 502 503 504 /50x.html;
 location = /50x.html {
 root /usr/share/nginx/html;
 }

 # pass the PHP scripts to FastCGI server listening on sock
 #
 location ~ \.php\$ { 
 try_files \$uri =404;
 fastcgi_pass unix:/var/run/php-fpm/$sdomain$domain.sock;
 fastcgi_index index.php;
 fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
 include fastcgi_params;
 }
 
 # Deny all attempts to access hidden files such as .htaccess
 # Deny access to any files with a .php extension in the uploads directory
 #
 location ~ /\. {
 deny all;
 }
 location ~* /(?:uploads|files|data|upload)/.*\.php\$ {
 deny all;
 }
 
 location ~* \.(gif|jpg|jpeg|png|bmp|txt|zip|jar|swf)\$ {
 expires 30d;
 access_log off; 
 valid_referers none blocked *.$sdomain$domain  server_names ~\.google\. ~\.baidu\. ~\.bing\. ~\.yahoo\. ~\.soso\. ~\.sogou\. ~\.alexa\. ~\.haosou\. ~\.youdao\.;
 if (\$invalid_referer) {
 #return 403;
 rewrite ^/ http://www.$domain/403.png;
  }
 }
 rewrite ^/sitemap.xml\$ /sitemap.php last;
}
EOF
    cat > /etc/php-fpm.d/$sdomain$domain.conf <<EOF
[$sdomain$domain]
listen = /var/run/php-fpm/$sdomain$domain.sock
listen.allowed_clients = 127.0.0.1
listen.owner = nginx
listen.group = nginx
listen.mode = 0660

user = nginx
group = nginx

pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 35

chdir = /
slowlog = /var/log/php-fpm/www-slow.log
php_value[session.save_handler] = files
php_value[session.save_path] = /home/$sdomain$domain/tmp/session
php_admin_value[open_basedir] = /home/$sdomain$domain/www:/home/$sdomain$domain/tmp:/usr/share/php:/tmp
php_admin_value[upload_tmp_dir] = /home/$sdomain$domain/tmp
EOF
#    cat > /etc/logrotate.d/$sdomain$domain <<EOF
#/data/$sdomain$domain/log/*.log {
#daily
#missingok
#rotate 7
#compress
#delaycompress
#notifempty
#create 640 nginx adm
#sharedscripts
#postrotate
# [ -f /var/run/nginx.pid ] && kill -USR1 `cat /var/run/nginx.pid`
#endscript
#}
#EOF
    systemctl restart nginx
	systemctl restart php-fpm
	systemctl status nginx
	systemctl status php-fpm
	echo "successful!";
    exit;
elif [ "$selected" == 'del' ]; then
    echo "input domain";
	read domain
	echo "input second domain [need add . at end]";
	read sdomain
	rm /etc/nginx/conf.d/$sdomain$domain.conf
	tar zcvf /home/bakdel$sdomain$domain.tar.gz /home/www/$sdomain$domain
	rm /home/www/$sdomain$domain -rf
    exit;
elif [ "$selected" == 'exit' ]; then
    exit;
fi;

'>>/usr/sbin/vhost

chmod +x /usr/sbin/vhost
echo -e "\033[46mneed set mysql mysql_secure_installation\nset dropbox key! go /root/dropbox_uploader.sh info\ncrontab -e [0 5 * * * /bin/bash /root/tools/backup.sh]\npanel and vhost command can help you \033[0m"


