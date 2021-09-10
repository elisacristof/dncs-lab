export DEBIAN-FRONTEND=noninteractive

# Startup commands go here

sudo ip addr add 192.168.3.2/24 dev enp0s8
sudo ip link set enp0s8 up

# docker commands
