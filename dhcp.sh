# we are making client1 as dhcp server and we are assigning ip address using dnsmasq 

sudo ip netns add client1
sudo ip link add veth0 type veth peer name veth1

# we are assigning veth1 interface to client1
sudo ip link set veth1 netns client1

sudo ip netns exec client1 ip addr add 10.0.0.1/24 dev veth1
sudo ip netns exec client1 ip link set dev veth1 up
sudo ip netns exec client1 ip route add 10.0.0.0/24 dev veth1

sudo ip netns exec client1 dnsmasq --dhcp-range=10.0.0.2,10.0.0.255,255.255.255.0 --interface=veth1 --no-daemon

# here in the above command in dhcp-range first and second ip adress define the range whilst the third one defines the subnet mask

# after running we make our our client1 as dhcp server so to assign an IP address to an interface, open another terminal
# and type -->   dhclient -d client0(the interface we want to assign IP address)
# to assign ip address through dhcp server
# It assigns an IP address from the specified range of IP addresses provided