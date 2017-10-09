#!/bin/bash
# Sanity check
[ $(id -g) != "0" ] && die "Script must be run as root.";
echo -e "\033[46m Firewall端口转发配置 \033[0m"
echo -e "\033[46m1.开启IP转发与伪装IP\n2.查看现有规则\n3.配置新的端口转发规则\n4.删除端口转发规则\n5.检查是否允许伪装IP\n6.开启伪装IP\n7.关闭伪装IP\033[0m"
select selected in 'Prepare' 'ListForward' 'AddForward' 'RemoveForward' 'QueryMasquerade' 'AddMasquerade' 'RemoveMasquerade'; do
break;
done;

if [ "$selected" == 'Prepare' ]; then
  sed -i 's@net.ipv4.ip_forward = 0@net.ipv4.ip_forward = 1@g' /etc/sysctl.conf
  sysctl -p
  firewall-cmd --permanent --zone=public --add-masquerade
  firewall-cmd --reload
  firewall-cmd --list-all --zone=public
  exit;
elif [ "$selected" == 'ListForward' ]; then
  firewall-cmd --list-all --zone=public
  exit;
elif [ "$selected" == 'AddForward' ]; then
  echo -e "\033[46m 目前的转发规则如下 \033[0m"
  firewall-cmd --list-all --zone=public  
  echo -e "\033[46m 设定转发的端口 （支持端口段 如2000-3000） \033[0m"
  read ForwardPort
  echo -e "\033[46m 设定转发的目标IP \033[0m"
  read ForwardIP
  firewall-cmd --permanent --add-forward-port=port=$ForwardPort:proto=tcp:toaddr=$ForwardIP
  firewall-cmd --permanent --add-forward-port=port=$ForwardPort:proto=udp:toaddr=$ForwardIP
  firewall-cmd --reload
  firewall-cmd --list-all --zone=public  
  exit;
elif [ "$selected" == 'RemoveForward' ]; then
  echo -e "\033[46m 目前的转发规则如下 \033[0m"
  firewall-cmd --list-all --zone=public  
  echo -e "\033[46m 设定取消转发的端口 （支持端口段 如2000-3000） \033[0m"
  read ForwardPort
  echo -e "\033[46m 设定取消转发的目标IP \033[0m"
  read ForwardIP
  firewall-cmd --permanent --remove-forward-port=port=$ForwardPort:proto=tcp:toaddr=$ForwardIP
  firewall-cmd --permanent --remove-forward-port=port=$ForwardPort:proto=udp:toaddr=$ForwardIP
  firewall-cmd --reload
  firewall-cmd --list-all --zone=public  
  exit;
elif [ "$selected" == 'QueryMasquerade' ]; then
  firewall-cmd --query-masquerade
  exit;
elif [ "$selected" == 'AddMasquerade' ]; then
  firewall-cmd --permanent --zone=public --add-masquerade
  firewall-cmd --reload
  exit;
elif [ "$selected" == 'RemoveMasquerade' ]; then
  firewall-cmd --permanent --zone=public --remove-masquerade
  firewall-cmd --reload
  exit;
fi;
