#deleting names spaces
ip link del VethDefaultA
ip netns exec nsA ip link del VethAB
ip netns exec nsC ip link del VethCB
ip netns exec nsA ip link del VethADefault
ip netns exec nsB ip link del VethBA
ip netns exec nsA ip link del VethBC
ip netns del nsA
ip netns del nsB
ip netns del nsC
ip netns del nsD
docker stop testA 


ip netns add nsA
ip netns add nsB
ip netns add nsC
ip netns add nsD

ip link add VethDefaultA type veth peer name VethADefault netns nsA 
ip addr add 10.200.0.1/30 dev VethDefaultA
ip link set dev VethDefaultA up
ip netns exec nsA ip addr add 10.200.0.2/30 dev VethADefault
ip netns exec nsA ip link set dev VethADefault up
ip netns exec nsA ip route add default via 10.200.0.1
ip route add 10.200.0.0/16 via 10.200.0.2

./inNameSpace.sh nsA VethAB 10.200.0.5/30 nsB VethBA 10.200.0.6/30
ip netns exec nsB ip route add default via 10.200.0.5
./inNameSpace.sh nsB VethBC 10.200.0.9/30 nsC VethCB 10.200.0.10/30
ip netns exec nsC ip route add default via 10.200.0.9
ip netns exec nsA ip route add 10.200.0.8/30 via 10.200.0.6 metric 4

./inNameSpace.sh nsA VethAD 10.200.1.5/30 nsD VethDA 10.200.1.6/30
ip netns exec nsD ip route add default via 10.200.1.5
./inNameSpace.sh nsD VethDC 10.200.1.9/30 nsC VethCD 10.200.1.10/30
ip netns exec nsC ip route add 0.0.0.0 via 10.200.1.9
ip netns exec nsA ip route add 10.200.1.8/30 via 10.200.1.6
ip netns exec nsA ip route add 10.200.0.8/30 via 10.200.1.6 metric 5

testAid=$(./docker.sh testA VnodeTestAD 10.200.2.2/30 nsA VnodeDTest 10.200.2.1/30)
echo "testA "${testAid:0:12}
ip netns exec ${testAid:0:12} ip route add default via 10.200.2.1