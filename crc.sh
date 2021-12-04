#creating a network topology consisting 2 clients and a router
 
# |client1| <----> |router| <----> |client2|

# Creating namespaces
sudo ip netns add client1
sudo ip netns add router
sudo ip netns add client2

#create veth pairs and assign interfaces to network namespaces
sudo ip link add veth0 type veth peer name veth1
sudo ip link set veth0 netns client1
sudo ip link set veth1 netns router

sudo ip link add veth2 type veth peer name veth3
sudo ip link set veth2 netns client2
sudo ip link set veth3 netns router

#configuring the interfaces in network namespaces by assigning ip addresses
sudo ip netns exec client1 ip addr add 10.0.0.2/24 dev veth0
sudo ip netns exec router  ip addr add 10.0.0.1/24 dev veth1

sudo ip netns exec client2 ip addr add 10.0.1.2/24 dev veth2
sudo ip netns exec router ip addr add 10.0.1.1/24 dev veth3

#setting the interfaces up
sudo ip netns exec client1 ip link set dev veth0 up
sudo ip netns exec router ip link set dev veth1 up
sudo ip netns exec client2 ip link set dev veth2 up
sudo ip netns exec router ip link set dev veth3 up

#enabling ip forwarding
sudo ip netns exec router sysctl -w net.ipv4.conf.all.forwarding=1

#add ip route
sudo ip netns exec client1 ip route add default via 10.0.0.1
sudo ip netns exec client2 ip route add default via 10.0.1.1

#ping 10.0.1.2 from client1
echo "Ping 10.0.1.2 from client1...."
sudo ip netns exec client1 ping 10.0.1.2 -c 5

#ping 10.0.0.2 from client2
echo "Ping 10.0.0.2 from client2...."
sudo ip netns exec client2 ping 10.0.0.2 -c 5

#deleting namespaces
sudo ip netns delete client1
sudo ip netns delete router
sudo ip netns delete client2
   
