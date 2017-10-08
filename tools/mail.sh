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
