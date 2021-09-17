export DEBIAN-FRONTEND=noninteractive

# Startup commands go here

sudo ip addr add 192.168.3.2/24 dev enp0s8
sudo ip link set dev enp0s8 up

sudo apt-get update
sudo pat-get -y install docker.io
sudo systemctl start docker
sudo systemctl enable docker

sudo docker pull dustnic82/nginx-test
sudo docker run --name nginx -p 80:80 -d dustnic82/nginx-test

sudo ip route add 10.1.0.0/30 via 192.168.3.1
sudo ip route add 192.168.0.0/20 via 192.168.3.1

