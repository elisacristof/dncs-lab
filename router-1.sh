export DEBIAN_FRONTEND=noninteractive

# Startup commands go here

sudo sysctl -w net.ipv4.ip_forward=1

sudo ip addr add 10.1.0.1/30 dev enp0s9
sudo ip link set dev enp0s9 up

sudo ip link add link enp0s8 name enp0s8.20 type vlan id 20
sudo ip link add link enp0s8 name enp0s8.30 type vlan id 30

sudo ip addr add 192.168.0.1/23 dev enp0s8.20
sudo ip addr add 192.168.8.1/23 dev enp0s8.30
sudo ip link set dev enp0s8 up
sudo ip link set dev enp0s8.20 up
sudo ip link set dev enp0s8.30 up

sudo ip route add 192.168.3.0/24 via 10.1.0.2

