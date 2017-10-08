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
#rpm -Uvh http://repo.mysql.com/mysql-community-release-el7-5.noarch.rpm
rm /etc/yum.repos.d/remi.repo -f

wget -P /etc/yum.repos.d/ https://raw.githubusercontent.com/NBY/tools/master/tools/remi.repo 

yum clean all
yum makecache
echo -e "\033[46m [Notice] install service \033[0m"
yum install -y vnstat nginx php php-opcache php-pecl-apcu php-devel php-mbstring php-mcrypt php-mysqlnd php-json php-phpunit-PHPUnit php-pecl-xdebug php-pecl-xhprof php-pdo php-pdo_dblib php-pear php-fpm php-cli php-xml php-bcmath php-process php-gd php-common php-pecl-zip php-recode php-snmp php-soap memcached libmemcached libmemcached-devel php-pecl-memcached redis php-pecl-redis ImageMagick ImageMagick-devel php-pecl-imagick
#yum install -y mysql-community-server
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
vnstat -u -i eth0
systemctl enable vnstat
systemctl start vnstat
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
#echo -e "\033[46m [Notice] move mysql to /home \033[0m"
#systemctl stop mysqld.service;

#mv /var/lib/mysql /home/
#mkdir /home/log
#touch /home/log/mysqld.log
#chown -R mysql:mysql /home/mysql
#chown -R mysql:mysql /home/log
#chmod u+w,-x,o-w-r /home/log/mysqld.log
#chmod 777 /home/log/mysqld.log
#sed -i 's:datadir=/var/lib/mysql:datadir=/home/mysql:g' /etc/my.cnf
#sed -i 's:socket=/var/lib/mysql/mysql.sock:socket=/home/mysql/mysql.sock:g' /etc/my.cnf
#sed -i 's:log-error=/var/log/mysqld.log:log-error=/home/log/mysqld.log:g' /etc/my.cnf
#sed -i '$a [client]' /etc/my.cnf
#sed -i '$a socket=/user/mysql/mysql.sock' /etc/my.cnf
#sed -i 's:pdo_mysql.default_socket=:pdo_mysql.default_socket=/var/lib/mysql/mysql.sock:g' /etc/php.ini
#systemctl start mysqld.service;

#systemctl status mysqld.service;
systemctl start php-fpm.service;
systemctl start nginx.service;
mkdir -p /var/lib/php/session
chown -R nginx:nginx /var/lib/php/session/
chown -R nginx:nginx /var/run/php-fpm/
echo -e "\033[46m [Notice] lnmp successful \033[0m"

wget -P /usr/sbin/ https://raw.githubusercontent.com/NBY/tools/master/tools/panel 
chmod +x /usr/sbin/panel

mkdir /root/backup
mkdir /root/tools
mkdir /root/tmp
cat > /root/tools/backup.sh<<EOF
#!/bin/bash
SCRIPT_DIR="/usr/sbin" #这个改成你存放刚刚下载下来的dropbox_uploader.sh的文件夹位置
DROPBOX_DIR="/" #这个改成你的备份文件想要放在Dropbox下面的文件夹名称，如果不存在，脚本会自动创建
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
wget -P /usr/sbin/ https://raw.githubusercontent.com/NBY/tools/master/tools/vhost 
chmod +x /usr/sbin/vhost
echo -e "\033[46mneed set mysql mysql_secure_installation\nset dropbox key! go /root/dropbox_uploader.sh info\ncrontab -e [0 5 * * * /bin/bash /root/tools/backup.sh]\npanel and vhost command can help you \033[0m"


