Install_Elasticsearch

*Pay the penalty (CPU and Ram) upfront - once and done-
compared to splunk which you pay on the backend, and paying
again and again*

*you should never give elasticsearch more than 31 gigs of ram - becuase it uses a java background*

`sudo yum install elasticsearch`

`sudo vi /etc/elasticsearch/elasticsearch.yml`

```
under:
---- --- -- - -  - -Cluster - - - - - - - - - -
add:
17: cluster.name: perched

23: node.name: sg01

27: is an additional attribute you could add on for node name.

33: path.data: /data/elasticsearch/data

uncomment:
43: bootstrap.memory_lock: true

#Sensor IP
55: network.host: 172.16.10.100
uncomment:
59: http.port: 9200

68: used for clustoring

wq:
```
make the directories

`sudo mkdir -p /data/elasticsearch`

`sudo chown -R elasticsearch:elasticsearch /data/elasticsearch`

`sudo mkdir /etc/systemd/system/elasticsearch.service.d`
(systemd is a global override)

### This allows elasticserearch to manage itsown memory instead of the OS.

`sudo vi /etc/systemd/system/elasticsearch.service.d/override.conf`

```
[Service]
LimitMEMLOCK=infinity

:wq
```

### Tell it how much ram it can use

`sudo vi /etc/elasticsearch/jvm.options`

```
always set the min and max to the same 'heap size'

:22: -Xms16g
:23: -Xmx16g

:wq
```
Configure firewall

`sudo firewall-cmd --add-port=9200/tcp --permanent`

`sudo systemctl start elasticsearch`

`sudo systemctl enable elasticsearch`

`sudo systemctl status elasticsearch`

to check that elasticsearch is working

```
sudo -s

cat /var/log/elasticsearch/perched.log

curl 172.16.10.100:9200/

curl 172.16.10.100:9200/_cat
(lists all cat-api's - a way for some other client to interact with your software)
```

=================================================
not on test -

###CLUSTER elasticsearch

`vi /etc/elasticsearch/elasticsearch.yml `

```
uncomment:

:68 add all sensor IP's in quotes, separated by a comma and a space - the ideal number i 5 ip's

72: minimum_number_nodes: 3

:wq
```

`sudo systemctl restart elasticsearch`

clustering requires port 9300 to work

```
sudo firewall-cmd --add-port=9300/tcp --permanent

sudo firewall-cmd --reload

```
test results:

`sudo systemctl status elasticsearch`

` curl 172.16.10.100:9200/_cat/nodes`
