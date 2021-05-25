#/bin/bash


# initialise two chains that will put the mark on the packet and keep it in memory
iptables -t mangle -N CONNMARK1
iptables -t mangle -A CONNMARK1 -j MARK --set-mark 1
iptables -t mangle -A CONNMARK1 -j CONNMARK --save-mark

iptables -t mangle -N CONNMARK2
iptables -t mangle -A CONNMARK2 -j MARK --set-mark 2
iptables -t mangle -A CONNMARK2 -j CONNMARK --save-mark

# if the mark is zero if means the packet does not belong to any existing connection
iptables -t mangle -A PREROUTING -d $3 -m state --state NEW \
         -m statistic --mode nth --every 2 --packet 0 -j CONNMARK1
iptables -t mangle -A PREROUTING -d $3 -m state --state NEW \
         -m statistic --mode nth --every 2 --packet 1 -j CONNMARK2

if ! cat /etc/iproute2/rt_tables | grep -q '^251'
then
        echo '251     LINK1' >> /etc/iproute2/rt_tables
fi
if ! cat /etc/iproute2/rt_tables | grep -q '^252'
then
        echo '252     LINK2' >> /etc/iproute2/rt_tables
fi
cat /etc/iproute2/rt_tables

ip route add table LINK1 default dev $1
ip route add table LINK2 default dev $2

ip rule del from all fwmark 2 2>/dev/null
ip rule del from all fwmark 1 2>/dev/null
ip rule add fwmark 1 table LINK1
ip rule add fwmark 2 table LINK2
ip route flush cache