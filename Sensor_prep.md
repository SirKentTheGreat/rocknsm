# Sensor Prep

## configure sensor to disable IPv6

# 1. Disable IPv6
`sudo vi etc/sysctl.conf ``

net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1

`sudo vi /etc/hosts`

Delete
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6

`sudo systemctl restart network`

*ss -lnt has replaced netstat*

*ip has replaced ifconfig*

*sudo nmtui - just something nice to remember*

*sudo firewall-cmd --list-ports*

*sudo firewall-cmd --list-all-zones*

*getenforce*

*sudo setenforce 0* -- do not do this on the exam

*getenforce* -- do not do this

*sudo touch /.autorelable* - do not do this


# 2. Enable ssh

## Enable SSH on to your sensor from your workstation

`ssh-copy-id admin@172.16.10.100`

## Create an Alias for SSH

`vi config`

  Host <NAME>

  HostName 172.16.1.100

  User admin

  IdentityFile ~/.ssh/id_rsa

## SCP

### Pull file via SCP

  `scp admin@172.16.10.100:/home/admin/test.txt .`

### Push file via scp

  `scp ./test.txt admin@172.16.10.100:/home/admin/`

# 3. configure sensor repository

From machine

`cd /etc/yum.repos.d`

`scp perched.repo admin@172.16.10.100:.`

SSH to Sensor:

`ssh admin@172.16.10.100`


Notice home directory has perched.repo

take ownership of files

`sudo chown root:root perched.repo`

move file to sensor yum.repos.d

`sudo mv perched.repo /etc/yum.repos.d`

`cd /etc/yum.repos.d/`

`sudo rm -f C*``

edit repo to point to machine nginx server
you only have to edit baseurl for every entry

`sudo vi perched.repo`

`esc`

`shift colon`  :

global search and replace command

`%s/file/http/g`

`%s/\/data\/repos/<machineIP>:8008/g`

`baseurl=http://<machine IP>:8008/<reponame>

:wq

*note that you can simply copy and paste from the Repository_Configuration_File.md located within the project*

[Repository_Configuration_File](http://gitea/SirKentTheGreat/SG01/src/branch/master/Repository_Configuration_file.md)



ensure you can reach IP to ensure yum will work.

`curl 192.168.2.197:8008`

contact and cache repository on machine

`sudo yum makecache fast`

Complete all yum installs in one-step

`sudo yum install -y stenographer suricata bro broctl bro-plugin-kafka bro-plugin-af_packet fsf filebeat kafka logstash elasticsearch kibana zookeeper`

if you encounter an error - please refer to YellowdogUpdateMangager.md. you'll have to ll -Z and possibly chcon and chown.

# 4. Enable off loading prep interface

*while on the sensor*

make note of interface name enp2s0

`ip a`

* Use ethtool to disable rx and tx (transmit receive) features that strip data from packets. Anything that ends with "o" is offloading data. We are reverting ethernet port to be as "raw as possible"

`sudo ethtool -K enp2s0 tso off gro off lro off gso off rx off tx off sg off rxvlan off txvlan off`

*you may get some errors back but that is okay*

`sudo ethtool -N enp2s0 rx-flow-hash upd4 sdfn`

`sudo ethtool -N enp2s0 rx-flow-hash upd6 sdfn`

`sudo ethtool -C enp2s0 adaptive-rx off`

`sudo ethtool -C enp2s0 rx-usecs 1000`

`sudo ethtool -G enp2s0 rx 4096`

*-G is editing ring buffer*

## set interface to promiscuous

`sudo ip link set enp2s0 promisc on`

# 5. configure sensor tap

Connect SWITCH port (1 (for SG01)) to TAP port (1)
Connect TAP port (2) to pfsense port emo (LAN1)
Connect pfsense port em1 (LAN2) to sensor port Mgmt (near edge)
Connect sensor Tap port to TAP port Mon (far right)

## 5.1 SPAN PORT
`Sudo yum install tcpdump`

`sudo tcpdump -i enp2s0`

*you can never do more than two spans on a switch*

 Open web browser and go to pfsense 172.16.10.1

**Navigate the Following:**
ENABLE OPT 2 on pfsense
 ```
 Interfaces
 OPT2
 Check Enable
 Save
 Apply Changes```

ENABLE SPAN PORT CONFIGS

 ```
 Interfaces
 Bridges
 SELECT: WAN & loading
 Description: SPAN
 Advanced Options
 SELECT: SPAN PORT OPT2
 SAVE
 ```


**you now have to go power cycle the device after 1 minute**

SSH back to the Sensor: and rerun the tcpdump command: This is testing that traffic is being captured. You're basically only seeing your SSH traffic.

`sudo tcpdump -i enp2s0`

## 5.2 In-Line tap

* You are going to install the inlinetap in between the Core switch (it doesnt have to be the Core Switch - but in our classroom environment it is).

1.1 You have your CoreSwitch Cat5 running to the inlinetap(port 1).

1.2 You then run the second interface (port 2) from the inlinetap to the pfsense Wan Interface.

1.3 you also run the Mirror port off of the inlinetap (port 5) to the tap port on the Sensor.

2.1 you ensure your Lan interface on the pfsense is still plugged into the Management port on the sensor.
