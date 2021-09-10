export DEBIAN_FRONTEND=noninteractive

# Startup commands go here

sudo ip addr add 192.168.8.2/23 dev enp0s8
sudo ip link set enp0s8 up

