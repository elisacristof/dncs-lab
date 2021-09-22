# DNCS-LAB

This repository contains the Vagrant files required to run the virtual lab environment used in the DNCS course.
```


        +-----------------------------------------------------+
        |                                                     |
        |                                                     |eth0
        +--+--+                +------------+             +------------+
        |     |                |            |             |            |
        |     |            eth0|            |eth2     eth2|            |
        |     +----------------+  router-1  +-------------+  router-2  |
        |     |                |            |             |            |
        |     |                |            |             |            |
        |  M  |                +------------+             +------------+
        |  A  |                      |eth1                       |eth1
        |  N  |                      |                           |
        |  A  |                      |                           |
        |  G  |                      |                     +-----+----+
        |  E  |                      |eth1                 |          |
        |  M  |            +-------------------+           |          |
        |  E  |        eth0|                   |           |  host-c  |
        |  N  +------------+      SWITCH       |           |          |
        |  T  |            |                   |           |          |
        |     |            +-------------------+           +----------+
        |  V  |               |eth2         |eth3                |eth0
        |  A  |               |             |                    |
        |  G  |               |             |                    |
        |  R  |               |eth1         |eth1                |
        |  A  |        +----------+     +----------+             |
        |  N  |        |          |     |          |             |
        |  T  |    eth0|          |     |          |             |
        |     +--------+  host-a  |     |  host-b  |             |
        |     |        |          |     |          |             |
        |     |        |          |     |          |             |
        ++-+--+        +----------+     +----------+             |
        | |                              |eth0                   |
        | |                              |                       |
        | +------------------------------+                       |
        |                                                        |
        |                                                        |
        +--------------------------------------------------------+



```

# Requirements
 - Python 3
 - 10GB disk storage
 - 2GB free RAM
 - Virtualbox
 - Vagrant (https://www.vagrantup.com)
 - Internet

# How-to
 - Install Virtualbox and Vagrant
 - Clone this repository
`git clone https://github.com/fabrizio-granelli/dncs-lab`
 - You should be able to launch the lab from within the cloned repo folder.
```
cd dncs-lab
[~/dncs-lab] vagrant up
```
Once you launch the vagrant script, it may take a while for the entire topology to become available.
 - Verify the status of the 4 VMs
 ```
 [dncs-lab]$ vagrant status                                                                                                                                                                
Current machine states:

router                    running (virtualbox)
switch                    running (virtualbox)
host-a                    running (virtualbox)
host-b                    running (virtualbox)
```
- Once all the VMs are running verify you can log into all of them:
`vagrant ssh router`
`vagrant ssh switch`
`vagrant ssh host-a`
`vagrant ssh host-b`
`vagrant ssh host-c`

# Assignment
This section describes the assignment, its requirements and the tasks the student has to complete.
The assignment consists in a simple piece of design work that students have to carry out to satisfy the requirements described below.
The assignment deliverable consists of a Github repository containing:
- the code necessary for the infrastructure to be replicated and instantiated
- an updated README.md file where design decisions and experimental results are illustrated
- an updated answers.yml file containing the details of your project

## Design Requirements
- Hosts 1-a and 1-b are in two subnets (*Hosts-A* and *Hosts-B*) that must be able to scale up to respectively 258 and 262 usable addresses
- Host 2-c is in a subnet (*Hub*) that needs to accommodate up to 143 usable addresses
- Host 2-c must run a docker image (dustnic82/nginx-test) which implements a web-server that must be reachable from Host-1-a and Host-1-b
- No dynamic routing can be used
- Routes must be as generic as possible
- The lab setup must be portable and executed just by launching the `vagrant up` command

## Tasks
- Fork the Github repository: https://github.com/fabrizio-granelli/dncs-lab
- Clone the repository
- Run the initiator script (dncs-init). The script generates a custom `answers.yml` file and updates the Readme.md file with specific details automatically generated by the script itself.
  This can be done just once in case the work is being carried out by a group of (<=2) engineers, using the name of the 'squad lead'. 
- Implement the design by integrating the necessary commands into the VM startup scripts (create more if necessary)
- Modify the Vagrantfile (if necessary)
- Document the design by expanding this readme file
- Fill the `answers.yml` file where required (make sure that is committed and pushed to your repository)
- Commit the changes and push to your own repository
- Notify the examiner (fabrizio.granelli@unitn.it) that work is complete specifying the Github repository, First Name, Last Name and Matriculation number. This needs to happen at least 7 days prior an exam registration date.

# Notes and References
- https://rogerdudler.github.io/git-guide/
- http://therandomsecurityguy.com/openvswitch-cheat-sheet/
- https://www.cyberciti.biz/faq/howto-linux-configuring-default-route-with-ipcommand/
- https://www.vagrantup.com/intro/getting-started/


# DESIGN
### First step
I run the initiator script which assigned me three different values that represents the number of hosts that my subnets have to support:
- 258 for subnet *Hosts-A*;
- 262 for subnet *Hosts-B*;
- 143 for subnet *Hub*.
## CREATING SUBNETS
Then I created four different subnets.
- The first is between the two routers, *router-1* and *router-2*; for this I chose the subnet 10.1.0.0/30 because it covers only the two routers (2<sup>32-30</sup> - 2 = 2)
- The second is between *router-1* and *host-a*; in this case I had to cover 258 addresses so I needed /23 as netmask (2<sup>32-24</sup> - 2 = 254 is not enough, instead 2<sup>32-23</sup> - 2 = 510 is right). I used the subnet 192.168.0.0/23    
- The third is between *router-1* and *host-b*, for which I chose to use the subnet 192.168.8.0/23    
- The fourth is between *router-2* and *host-c*; in this case I used the subnet 192.168.3.0/24 because it has to cover 143 addresses (2<sup>32-24</sup> - 2 > 143) 
## IP-MAP
![DNCS Design](https://user-images.githubusercontent.com/89995099/132944388-a64cb8ee-d237-4c87-95af-f58df2cebb89.png)

| Device | Interface | IP | Subnet |
| :----: | :----: | :----: | :----: |
| Router-1 | enp0s9 | 10.1.0.1 | 1 |
| Router-2 | enp0s9 | 10.1.0.2 | 1 |
| Router-1 | enp0s8.20 | 192.168.0.1 | 2 |
| Host-a | enp0s8 | 192.168.0.2 | 2 |
| Router-1 | enp0s8.30 | 192.168.8.1 | 3 |
| Host-b | enp0s8 | 192.168.8.2 | 3 |
| Router-2 | enp0s8 | 192.168.3.1 | 4 |
| Host-c | enp0s8 | 192.168.3.2 | 4 |

It was important and necessary to build two VLANs in order to keep Host-a and Host-b in separate subnets, so I created the VLANs for subnets 2 and 3, respectively with tags 20 and 30. 

## IMPLEMENTATIONS
### Commands
Here there is a list of the commands I used (all preceded by `sudo` because every command has to be executed by the superuser):
- [**IP FORWARDING**] I enabled the IPv4 forwarding in the routers with `sysctl -w net.ipv4.ip_forward=1`;
- [**IP**] I assigned an IP address to each interface, with the command `ip addr add [ip_address/netmask] dev [interface]` and then I activated that interface with `ip link set dev [interface] up`;
- [**VLANs**] In order to create the VLANs mentioned earlier, I used `ip link add link enp0s8 name enp0s8.20 type vlan id 20` and `ip link add link enp0s8 name enp0s8.30 type vlan id 30` and then I added the IP addresses to the virtual interfaces with `ip addr add 192.168.0.1/23 dev enp0s8.20` and `ip addr add 192.168.8.1/23 dev enp0s8.30`;
- [**ROUTES**] The command `ip route add [ip_address/netmask] via [address]` helped me create a route that takes all the traffic to the addresses included in the network [ip_address/netmask] and direct it to the [address].

### Configuring switch
Regarding the switch, first I created a bridge named *switch* with the command `ovs-vsctl add-br switch`. Then I configured the ports, assigning the tags, with the following commands: 
```
sudo ovs-vsctl add-port switch enp0s8
sudo ovs-vsctl add-port switch enp0s9 tag="20"
sudo ovs-vsctl add-port switch enp0s10 tag="30"
```

### Configuring Host-c
Finally, since one of the requirements was for Host-c to run a docker image, I configured it in this way:
```
sudo apt-get update
sudo pat-get -y install docker.io
sudo systemctl start docker
sudo systemctl enable docker

sudo docker pull dustnic82/nginx-test
sudo docker run --name nginx -p 80:80 -d dustnic82/nginx-test
```

## CONFIGURING VAGRANT
I included all the commands needed for the configuration of the network in bash scripts, one for each device implemented. These scripts are included in the `Vagrantfile` and will configure the network during the creation of the Virtual Machines, after launching the `vagrant up` command. 
I also needed to increase the memory size of Host-c (by modifying the option `vb.memory`) in order to run the Docker image.

## TEST
I launched the `vagrant up` command and finally I tried to connect with `vagrant ssh` to all the machines. Then with the `ping` command I checked all the possible connections.
From *router-1* to all the others: 
![router-1](https://user-images.githubusercontent.com/89995099/134328756-9bf049e8-2ddd-4d66-937a-3b772b6609fc.png)
From *router-2* to all the others:
![router-2](https://user-images.githubusercontent.com/89995099/134328956-30e6c753-4650-46f4-b857-d42d5da088d9.png)

