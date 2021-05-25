#!/bin/bash
# $1 docker container name
# $2 veth name in container
# $3 IP1
# $4 netns
# $5 veth name in ns2
# $6 IP2


ip link add $2 type veth peer name $5
ip link set $5 netns $4

 docker run --privileged --network="none" -d --rm --name $1 leodotcloud/swiss-army-knife sleep 3600
 container_id=$(sudo docker ps | grep $1 | head -n 1 | awk '{print $1}')
 pid=$(sudo docker inspect -f '{{.State.Pid}}' ${container_id})
 mkdir -p /var/run/netns/
 ln -sfT /proc/$pid/ns/net /var/run/netns/$container_id
 ip link set $2 down
 ip link set $2 netns ${container_id}

ip netns exec ${container_id} ip addr add $3 dev $2
 ip netns exec ${container_id} ip link set $2 up
ip netns exec $4 ip addr add $6 dev $5
ip netns exec $4 ip link set dev $5 up
echo ${container_id}