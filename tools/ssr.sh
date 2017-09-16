#!/bin/bash
yum install libsodium git fail2ban vnstat -y
vnstat -u -i eth0
systemctl enable vnstat
systemctl start vnstat
git clone -b manyuser https://github.com/ToyoDAdoubi/shadowsocksr.git
cd shadowsocksr
bash setup_cymysql.sh
bash initcfg.sh
firewall-cmd --zone=public --permanent --add-service=mysql
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
wget --no-check-certificate https://github.com/teddysun/across/raw/master/bbr.sh
chmod +x bbr.sh
./bbr.sh
