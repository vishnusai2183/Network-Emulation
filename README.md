
# Network-Emulation

- Here we created a network topology consisting 2 clients and a router.

- The topology looks like :
```bash
 |client1| <----> |router| <----> |client2|
```

- The topology is created using linux namespace and iproute2.

## Script

```bash
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
   
```


## Installation of iproute2

- IP route tools are necessary for the managment of network namespaces. so we install iproute2, if not present using the following command

```bash
  sudo apt-get install -y iproute2
```
    
## Description of Script
- After installing iproute2 create namespaces for both Clients and Router
```bash
sudo ip netns add client1
sudo ip netns add router
sudo ip netns add client2
```
- Creating veth pairs inorder to assign interface
```bash
sudo ip link add veth0 type veth peer name veth1
sudo ip link add veth2 type veth peer name veth3
```
- Assigning interface to namespaces
 Here ```veth0``` and ```veth2``` are assigned for ```client1``` and ```client2``` respectively, and ```veth1``` and ```veth3``` are assigned for ```router```. 
 ```bash
 sudo ip link set veth0 netns client1
sudo ip link set veth1 netns router

sudo ip link set veth2 netns client2
sudo ip link set veth3 netns router
 ```

- Configuring the interfaces
In this step we are configuring the namespaces by assigning IP addresses
```
sudo ip netns exec client1 ip addr add 10.0.0.2/24 dev veth0
sudo ip netns exec router  ip addr add 10.0.0.1/24 dev veth1

sudo ip netns exec client2 ip addr add 10.0.1.2/24 dev veth2
sudo ip netns exec router ip addr add 10.0.1.1/24 dev veth3

```
- Setting up the interfaces
Now everything is set but our interface is ```DOWN```.  So in this step we bring it ```UP``` 
```bash
sudo ip netns exec client1 ip link set dev veth0 up
sudo ip netns exec router ip link set dev veth1 up
sudo ip netns exec client2 ip link set dev veth2 up
sudo ip netns exec router ip link set dev veth3 up
```
- Enabling IP forwarding
It is necessary to turn on ip forwarding , because in the case of router, it should be capable of forwarding packets to other destination (other than itself).
```bash
sudo ip netns exec router sysctl -w net.ipv4.conf.all.forwarding=1
```
- Adding IP route 
IP routing basically describes the path for data to follow in order to navigate from one location to another.
```bash
sudo ip netns exec client1 ip route add default via 10.0.0.1
sudo ip netns exec client2 ip route add default via 10.0.1.1

```
- Pinging from client1 and client2
```bash
sudo ip netns exec client1 ping 10.0.1.2 -c 5
sudo ip netns exec client2 ping 10.0.0.2 -c 5

```
