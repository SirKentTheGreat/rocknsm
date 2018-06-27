
# 1. Install Stenographer

`sudo yum install stenographer`
"this will not work real world unless you've linked to fedora's copr repository"

Real world you would link to stenographer (https://copr.fedorainfracloud.org/coprs/g/rocknsm/rocknsm-2.1/packages/)

*logged onto the sensor*

`cd /etc/stenographer/`
`ls`
`sudo vi config`

change
first line under "Threads":
```
{
  "Threads": [

    { "PacketsDirectory": "/data/stenographer/packets",

      "IndexDirectory": "/data/stenographer/index",

      "MaxDirectoryFiles": 30000,

      "DiskFreePercentage": 10

    }

  ],

    "StenotypePath": "/usr/bin/stenotype",

    "Interface": "enp2s0",

    "Port": 8083,

    "Host": "172.16.10.100",

    "Flags": [],
    
    "CertPath": "/etc/stenographer/certs"
}
```
`:wq`

`"Interface": "enp2s0"`
`"port": 8083` Can be any port you want above 4000
`"Host": "172.160.10.100"` although you can leave it at loopback address.


**Next your going to run a bash script to create keys for the user and group stenographer**

`sudo stenokeys.sh stenographer stenographer`

**create directory included parent directories if they don't exist as well packets and index**
`sudo mkdir -p /data/stenographer/{packets,index}`

**give stenographer the right to read and write to stenographer**
`sudo chown -R stenographer:stenographer /data/stenographer/`

`sudo systemctl start stenographer`

`sudo systemctl status stenographer`

`sudo systemctl enable stenographer`

`cd /data/stenographer/packets/`
`ll`
