# Switch_Configuration
Note Switch Configs are not on the test

**Group 1 is port 1 on the switch**

You will connect PFsense WAN port to switch port 1 across the class.

* Begin with pinging through the Wireless interface down to the sensor.

Ping Edge Router `<192.168.2.1>`

ping Switch WAN Interface `<10.0.0.2>`

Ping Switch Lan Interface `<10.0.0.1>`

* Now you are ready to SSH into the Switch -

`ssh admin@10.0.0.1`

Password = `perched1234!@#$`

* Configuration
enable
config t
ip dhcp excluded-address 10.0.10.0 10.0.10.1
ip dhcp pool sg01
network 10.0.10.0 255.255.255.252
default-router 10.0.10.1
dns-server 192.168.2.1

vlan 10
name XXXX
state active
no shut

interface GigabitEthernet1/0/1
switchport access vlan 10
no shut

interface vlan 10
ip add 10.0.10.1 255.255.255.252
no shut

ip routing //enables routing on L3switch
ip route 172.16.10.0 255.255.255.0 10.0.10.2



Ping PFSense/Switch WAN Interface `<10.0.10.1>`

Ping PFSense/Switch LAN INterfac '<10.0.10.2>'
