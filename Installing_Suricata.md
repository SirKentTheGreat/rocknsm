Installing Suricata
`sudo yum install suricata`

Suricata has some different permissions - so you cannot cd into them without being escalated
`sudo -s`

`cd /etc/suricata/`
`ls`
`ls rules/`

`curl -L -O http://perched-repo/sensor_configs/suricata/emerging.rules.tar.gz`

*refer to the add_rules.sh.md for the actual script.*

* inside of the file download - there is a rules folder we will merge them by unzipping it, Notice: the owner will change from suricata to root, change it back.

`tar -zxf emerging.rules.tar.gz`

`ls rules/`

`chown -R suricata:root rules/`


* now we have to edit the Suricata.yaml

Start with creating an the executable script - with the add-rules.sh.

you have to add executable rights to the file.

`chmod +x add-rules.sh`

Execute script

`./add-rules.sh`


`vi suricata.yaml`


```
:set nu

Vars:

  HOME_NET: "[192.168.2.0/24,10.0.10.0/24,172.16.10.0/24]"

Port-groups: (these will have to change to your productions
  environment)

  We did nothing to this

rule-files:

  -botxx.rules

  -ciamry.rules

  etc
  etc

*The script already edited this portion*

*you still have to edit the following:

122 default-log-dir: /data/suricata/logs

126 enabled: no

135 enabled: no (fast)

142 enabled yes (Extensible Event Format)

256 enabled: no

298 enabled: no

308 enabled: no

362 enabled: no

400 enabled: no

899 enabled: no

547     - interface: enp2s0

1373    set-cpu-affinity: no (note never cpu 0)
```

* how to check cpu information


`sudo cat /proc/cpuinfo | egrep -e 'processor|physical id|core id' | xargs -l3`


in our case you could "pin" 123, and 567 because the core-id's have affinity - we know this because the id = 0.

* make our directories

`sudo mkdir -p /data/suricata/logs`
`sudo chown -R suricata:suricata /data/suricata`


* Option Files

`sudo vi /etc/sysconfig/suricata`

`OPTIONS="--af-packet=enp2s0" ` you could add other interfaces.
`:wq`

(should still be in /etc/suricata)

*download script to easily load up rules into the suricata.yaml file*
`curl -L -O http://perched-repo/sensor_configs/suricata/add-rules.sh`

`chmod +x add-rules.sh`

`./add-rules.sh`

`cat suricata.yaml | grep .rules`

* create a configuration file for logrotate.d which will rotate the eve.json. rotate means to zip it up and start writing new contnet

`sudo vi /etc/logrotate.d/suricata.conf`


```/data/suricata/*.log /data/suricata/*.json
{
    rotate 3
    missingok
    nonompress
    create
    sharedscripts
    postrotate
          /bin/kill -HUP $(cat /var/run/suricata.pid)
    endscript
}
:wq
```
* start Suricata

`sudo systemctl start suricata`

`sudo systemctl status suricata`

`sudo systemctl enable suricata`
