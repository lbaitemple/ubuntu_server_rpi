#!/bin/bash
###############
# Please modify your cloud mqtt credential here
##############
m_i2c="3c"
m_server="m16.cloudmqtt.com"
m_port=12247
m_user="pspniyjc1111"
m_pass="sBm4EpaDgRe51111"
m_topic="raspberry/ipaddress"

################
# nothing needs to be changed below
##############
echo "Starting script sayIPbs "
private=`hostname -I | sed -E -e 's/[[:blank:]]+/_/g' `
res=`mosquitto_pub -h $m_server -p $m_port -u $m_user -P $m_pass -t $m_topic -m $private  > /dev/null 2>&1`

mapfile -t data < <(i2cdetect -y 1)

for i in $(seq 1 ${#data[@]}); do
    line=(${data[$i]})
    echo ${line[@]:1} | grep -qw "$m_i2c"
    if [ $? -eq 0 ]; then
        test=` python /home/ubuntu/stats.py`
        exit 0
    fi
done
