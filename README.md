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

From *host-a* to all the others:
![host-a](https://user-images.githubusercontent.com/89995099/134345048-14718681-08d9-44eb-8f42-738454da21f6.png)

From *host-b* to all the others:
![host-b](https://user-images.githubusercontent.com/89995099/134346619-0d2547a1-8169-436a-9113-91c2cdfd0208.png)

From *host-c* to all the others:
![host-c](https://user-images.githubusercontent.com/89995099/134347842-4e66149a-3b97-47ef-a7f3-61a95a8fa272.png)


Furthermore, with `curl 192.168.3.2`, I was able to see the html page present in host-c docker webserver. The output below is referred to host-a, but the same result is obtained from host-b. 

```
<!DOCTYPE html>
<html>
<head>
<title>Hello World</title>
<link href="data:image/png;base64,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" rel="icon" type="image/png" />
<style>
body {
  margin: 0px;
  font: 20px 'RobotoRegular', Arial, sans-serif;
  font-weight: 100;
  height: 100%;
  color: #0f1419;
}
div.info {
  display: table;
  background: #e8eaec;
  padding: 20px 20px 20px 20px;
  border: 1px dashed black;
  border-radius: 10px;
  margin: 0px auto auto auto;
}
div.info p {
    display: table-row;
    margin: 5px auto auto auto;
}
div.info p span {
    display: table-cell;
    padding: 10px;
}
img {
    width: 176px;
    margin: 36px auto 36px auto;
    display:block;
}
div.smaller p span {
    color: #3D5266;
}
h1, h2 {
  font-weight: 100;
}
div.check {
    padding: 0px 0px 0px 0px;
    display: table;
    margin: 36px auto auto auto;
    font: 12px 'RobotoRegular', Arial, sans-serif;
}
#footer {
    position: fixed;
    bottom: 36px;
    width: 100%;
}
#center {
    width: 400px;
    margin: 0 auto;
    font: 12px Courier;
}

</style>
<script>
var ref;
function checkRefresh(){
    if (document.cookie == "refresh=1") {
        document.getElementById("check").checked = true;
        ref = setTimeout(function(){location.reload();}, 1000);
    } else {
    }
}
function changeCookie() {
    if (document.getElementById("check").checked) {
        document.cookie = "refresh=1";
        ref = setTimeout(function(){location.reload();}, 1000);
    } else {
        document.cookie = "refresh=0";
        clearTimeout(ref);
    }
}
</script>
</head>
<body onload="checkRefresh();">
<img alt="NGINX Logo" src="http://d37h62yn5lrxxl.cloudfront.net/assets/nginx.png"/>
<div class="info">
<p><span>Server&nbsp;address:</span> <span>172.17.0.2:80</span></p>
<p><span>Server&nbsp;name:</span> <span>8b11010e7d8a</span></p>
<p class="smaller"><span>Date:</span> <span>22/Sep/2021:12:30:42 +0000</span></p>
<p class="smaller"><span>URI:</span> <span>/</span></p>
</div>
<br>
<div class="info">
    <p class="smaller"><span>Host:</span> <span>192.168.3.2</span></p>
    <p class="smaller"><span>X-Forwarded-For:</span> <span></span></p>
</div>

<div class="check"><input type="checkbox" id="check" onchange="changeCookie()"> Auto Refresh</div>
    <div id="footer">
        <div id="center" align="center">
            Request ID: 8d411e80448e017571eb5d8acee59e3b<br/>
            &copy; NGINX, Inc. 2018
        </div>
    </div>
</body>
</html>
```

