# $1 is name space1, $2 ip veth1 and $3 is IP1 and $4 $5 $6 is for 2

ip link add $2 type veth peer name $5
ip link set $2 netns $1
ip link set $5 netns $4

ip netns exec $1 ip addr add $3 dev $2
ip netns exec $1 ip link set dev $2 up
ip netns exec $4 ip addr add $6 dev $5
ip netns exec $4 ip link set dev $5 up