#! /bin/bash

read -p "enter your fmz id: " fmz_id
read -p "enter your fmz password: " fmz_pass 

# 更新
apt update

# 同步时区
timedatectl set-timezone 'Asia/Shanghai' && sudo apt-get install ntpdate && ntpdate cn.pool.ntp.org

# 安装托管者 
wget https://node.fmz.com/dist/robot_linux_amd64.tar.gz -O robot_linux_amd64.tar.gz && tar zxvf robot_linux_amd64.tar.gz && chmod +x robot

# 新建systemd运行托管者，开机自启
cat >/etc/systemd/system/fmz.service<<EOF 
[Unit]
Description=fmz
After=syslog.target network.target

[Service]
Type=simple
User=root
ExecStart=/root/robot -s node.fmz.com/$fmz_id -n my_fmz_robot -p $fmz_pass
UMask=0002

RestartSec=1
Restart=on-failure

StandardOutput=file:/root/log1.log
StandardError=file:/root/log2.log

SyslogIdentifier=fmz

[Install]
WantedBy=multi-user.target
EOF
systemctl reenable /etc/systemd/system/fmz.service
systemctl restart fmz


sleep 4
# 打印登录日志
cat /root/log1.log