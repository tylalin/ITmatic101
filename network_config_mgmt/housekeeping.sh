#!/bin/bash

# Cisco IOS XE
# archive all cisco daily config backup into /configs/cisco/ 
mv /home/gnu-ftp01/[a-z]*[0-9] /configs/cisco/ 2> /dev/null

# HPE ProCurve
# archive all hpe daily config backup into /configs/hpe/ 
mv /tftproot/*.cfg /configs/hpe/ 2> /dev/null
# rename the file with current date
cd /configs/hpe/ 2> /dev/null
mv gnu-ce01.cfg gnu-ce01-$(date +'%Y%m%d').cfg 2> /dev/null

# Huawei VRP
# archive all huawei daily config backup into /configs/huawei/ 
mv /home/gnu-ftp01/[0-9]*.zip /configs/huawei/ 2> /dev/null

# MikroTik RouterOS
# archive all mikrotik daily config backup into /configs/mikrotik/ 
mv /home/gnu-ftp01/*.rsc /configs/mikrotik/ 2> /dev/null

# FortiGate
# archive all fortigate daily config backup into /configs/fortigate/ 
mv /home/gnu-ftp01/fw01.conf /configs/fortigate/ 2> /dev/null
# rename the file with current date
cd /configs/fortigate/ 2> /dev/null
mv fw01.conf fw01-$(date +'%Y%m%d').conf 2> /dev/null