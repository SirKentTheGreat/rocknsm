TAP_CONFIGURATION

#configure sensor tap

Connect SWITCH port (1 (for SG01)) to TAP port (1)
Connect TAP port (2) to pfsense port emo (LAN1)
Connect pfsense port em1 (LAN2) to sensor port Mgmt (near edge)
Connect sensor Tap port to TAP port Mon (far right)

## PFSense Prep work
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

```Interfaces
Assignments
Bridges
SELECT: WAN & Lan
loading Description: SPAN
Advanced Options
SELECT: SPAN PORT OPT2
SAVE
```


**you now have to go power cycle the device after 1 minute**


# Pick one Method

## 1. SPAN PORT
`Sudo yum install tcpdump`

`sudo tcpdump -i enp2s0`

*you can never do more than two spans on a switch*


SSH back to the Sensor: and rerun the tcpdump command: This is testing that traffic is being captured. You're basically only seeing your SSH traffic.

`sudo tcpdump -i enp2s0`

## 2. In-Line tap

* You are going to install the inlinetap in between the Core switch (it doesnt have to be the Core Switch - but in our classroom environment it is).

1.1 You have your CoreSwitch Cat5 running to the inlinetap(port 1).

1.2 You then run the second interface (port 2) from the inlinetap to the pfsense Wan Interface.

1.3 you also run the Mirror port off of the inlinetap (port 5) to the tap port on the Sensor.

2.1 you ensure your Lan interface on the pfsense is still plugged into the Management port on the sensor.
