# PFSense Install Documentation

## Loading the OS:

```Power on Machine and press F11 to enter bootmenu and select UEFI USB```
* enter pfsense Installer bootmenu press `Enter`
to `<Accept>`
1. Select `I` and press `Enter` Install
2. press `Enter` for default Key Map
3. Partitioning - Auto - `Enter`
4. Press Enter - select `< NO >` for shell prompt
5. Complete `<Complete>` pressing `Enter` for `Reboot` **ensure to remove USB after reboot is initiated**

## 1. Assign Interface

Note LAN and Interface name:

LAN1 = em0 = WAN

LAN2 = em1 = LAN

LAN3 = em2 = OPT1

LAN4 = em3 = OPT2

First select Option: 1 for `Assign Interface`
Although VLANs are setup on the student group switch - they are not setup on the PFsense - so select `NO` for VLANs

Type `em0` for WAN Interface name

type `em1` for LAN Interface name

type `em2` for Optional 1 interface name

type `em3` for Optional 2 interface name

## 2. Set Interface (4 total) IP address
select option 2
Available Interface
### 1. WAN (em0)

select `'y'` for Configure IPv4 via DHCP

Configure IPv4 - select `'n'`

Press `Enter` to void IPv6 manual entry

Revert to HTTP as the webConfigurator protocol   `'y'`

Finished

Press `Enter` to continue

### 2.  LAN (em1)

Enter `2` for lan configuration

Enter IPv4 for LAN IP
`172.16.10.1`

Enter `24` for bit count (1 to 31)

For a LAN press `ENTER` for none:

For IPv6 press `ENTER` for none:

Enable DHCP server for LAN: type `'y'`

Enter the range for DHCP server

START address = `<172.16.10.101>`

END address = `<172.16.10.254>`

press `ENTER` and `ENTER` again to continue

## PFsense WEB Interface Configuration

*You are now ready to plug your laptop into the LAN port of the switch via CAT5...
Navigate to  PFsense ip `<172.16.10.1>` in webbrowser for http configuration.*

*The default username and password is:*

username: = `'admin'`
password: = ``'pfsense'`

Enter pfsense setup configuration

select next and next again until you get to hostname setup under general information

Make hostname `'sg01-pfsense'` and press next

set Primary DNS Server to EDGE Router IP `<192.168.2.1>`

`Next`

leave NTP to default and press next

next scroll down to:

RFC and **uncheck** `Block Private Networks`
and `Block non-Internet routed networks` and click `NEXT`

Now your going to configure `LAN settings`
No changes to IP - click next and change default `Admin Password` - you have to change THIS

next click: _Reload_

Under Status/Dashboard select the `'+'SIGN`
and add `Traffic Graphs` as well as `service status` widgets

## Firewall/Rules/

### Under WAN Interface
* Select `<ADD>` a Rule
* Action = `Pass`
* Interface `WAN`
* protocol `ANY`
* source `ANY`
* destination `ANY`
* click SAVE

Now you have to click `<Apply Changes>` for rule to take affect

### Under LAN interface
NOTE: you should see three entries

**Delete IPv6 Rule**

**Edit Default allow LAN to any Rules**
* Action = `Pass`
* Interface `LAN`
* protocol `ANY`
* source `ANY`
* destination `ANY`
* click SAVE
* `<Apply Changes>`

### Change NAT Configurations
Navigate to: Navigate Firewall - NAT - OUTBOUND

Turn off OUTBOUND Nat-ing

### Diagonostic Tools / Backup and Restore

Under Dashboard and the Diagnostics tab you can see a lot of tools like Ping and reboot as well as Halt System. Most importantly - Backup and Restore

Keep defaults and select Download configuration as XML.


``` NOTE: the Firewall WAN and LAN rules are really important. If you cannot access the PFSense - start with looking at these rules.
```
*perform a halt on PFsense for soft shutdown*
