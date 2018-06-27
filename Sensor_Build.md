# Initial CentOS Sensor Build

* Plug in Flash drive and reboot machine - Press F11

* Select USB - and Press Enter

* Select Install CentOS

### select English

### Network and Hostname
* highlight `enp0s31f6` (use the top one for management) and click configure
* change DHCP to Manual and change configuration
` Address = 172.16.10.100 Netmask = 24 Gateway = 172.16.10.1 `
`DNS Servers: = 192.168.2.1` save configuration
* IPv6 - Ignore
* set `hostname: sg01.local.lan` (located at bottom left of the screen)
### Select UTC time
**select REGION ETC and then CITY: Corrdinated Universal Time**
### Software Selection Minimum or GNOME Install
### Security Policy - NONE
### Installation Destination
* select both drives
* Check I would like to make additional space available
* Click Done
* Delete all partition tables
* select installation Destination
* select I will configure partitioning
* Click Done
* Stay on LVM
* click here to configure automatically
* delete swap - select and click minus
* select /home and / and change desired capacity to 1 Gib and click update settings
* Modify centos volume group
- change the name and the disk it is associated with
1. NAME = `sensor-OS` - and select `ATADEMSR` - 32 G only and click save - this will be the operating system partition
2. click `Volume group` and Create `sensor-data` volume group and click save
3. Hit Plus Sign create mount point of `/data` with `1G`. Modify `/data` with volume group of `sensor-data` - ensuring you're clicking update settings
4. Modify `/home` volume group to `sensor-OS` and click update settings
* change sizes of all partitions
1. `/ = 10G` `update settings`
2. `/home = 'blank'` `update settings`
3. `/data = 'blank'` `update settings`
* accept changes
### disable KDUMP
## BEGIN INSTALLATION!!!!
### create user
* check make this user administrator
* user name admin
* set password admin


#WAIT! BEFORE YOU GO
ensure to change the ONBOOT=yes in network-scripts
 vi /etc/sysconfig/network-scripts/ifcfg-enp0s31fg
 and change ONBOOT=no to ONBOOT=yes.
