#!/bin/sh
###############
# Please modify your cloud mqtt credential here
##############
m_server="m16.cloudmqtt.com"
m_port=12247
m_user="pspniyjc111"
m_pass="sBm4EpaDgRe5111"
m_topic="raspberry/ipaddress"

################
# nothing needs to be changed below
##############
echo "Starting script sayIPbs "
private=`hostname -I | sed -E -e 's/[[:blank:]]+/_/g' `
res=`mosquitto_pub -h $m_server -p $m_port -u $m_user -P $m_pass -t $m_topic -m $private  > /dev/null 2>&1`
test=` python /home/ubuntu/stats.py`
