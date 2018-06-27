Repository configuration

`vi /etc/yum.repos.d/sg01.repo`

```
[base-local]
name=this is just a description of base local
enabled=1
gpgcheck=0
baseurl=http://192.168.2.197:8008/base

[copr-rocknsm-2.1-local]
name=this is just a description of copr local
enabled=1
gpgcheck=0
baseurl=http://192.168.2.197:8008/copr-rocknsm-2.1

[elasticsearch-6.x-local]
name=this is just a description of elasticsearch local
enabled=1
gpgcheck=0
baseurl=http://192.168.2.197:8008/elasticsearch-6.x

[epel-local]
name=this is just a description of epel local
enabled=1
gpgcheck=0
baseurl=http://192.168.2.197:8008/epel

[extras-local]
name=this is just a description of extras local
enabled=1
gpgcheck=0
baseurl=http://192.168.2.197:8008/extras

[noarch-local]
name=this is just a description of noarch local
enabled=1
gpgcheck=0
baseurl=http://192.168.2.197:8008/noarch

[rocknsm_2_1-local]
name=this is just a description of rocknsm local
enabled=1
gpgcheck=0
baseurl=http://192.168.2.197:8008/rocknsm_2_1

[rpmforge-local]
name=this is just a description of rpmforge local
enabled=1
gpgcheck=0
baseurl=http://192.168.2.197:8008/rpmforge

[updates-local]
name=this is just a description of updates local
enabled=1
gpgcheck=0
baseurl=http://192.168.2.197:8008/updates
```
:wq
