#Build Kafka

* We are going to go over two ways to build kafka



CentOS and RHEL are built at the kernel level with python. So it isn't wise to download pip products directly to the machine.Below is an example for properly download pip products in a virutual envrionment.

`sudo pip install virutal_env`

##Build from RPM

`sudo yum install zookeeper kafka`

Configure Kafka server pentameters.

`cd /etc/kafka`

`ls`

`sudo vi server.properties`


```
broker.id=0 (this is for each individual client in regards to clustering we dont have to chang it now, but you would for multiple clients)

(uncomment)
31: listeners=PLAINTEXT://172.16.10.100:9092


(uncomment)
36: advertise.listeners=PLAINTEXT://172.16.10.100:9092

60: log.dirs=/data/kafka/logs

!!NOCHANGE
65: num.partitions=1
(this is a partition for kafka: this is basically how much we can scale the number of people consuming from KAFKA - IF you want to scale up your operation, you have to increase your partitions and matching workers. For the exam you need to change this number to 2!)

103: log.retention.hours=12
123: zookeeper.connect=172.16.10.100:2181
```
make /data/kafka/logs directory
`sudo mkdir -p /data/kafka/logs`
change ownership
`sudo chown -R kafka:kafka /data/kafka/`
Open Firewall for kafka
`sudo firewall-cmd --add-port=9092/tcp --permanent`

### zookeeper
*Kafka will not start without zookeeper! zookeeper's job is to manage Kafka*

`sudo systemctl start zookeeper`

`sudo systemctl start kafka`

`sudo systemctl status zookeeper`

`sudo systemctl status kafka`

`sudo systemctl enable zookeeper`

`sudo systemctl enable kafka`

`sudo firewall-cmd --add-port=2181/tcp --permanent`

`sudo firewall-cmd --reload`

In old versions of zookeeper. you would have to change an ip inside of the zoo.cfg

To easily test zookeeper
`cd /data/kafka/logs/`

*insure that you have started kafka*

you should be able to see files.

you can also `ss -lnt`


`cd /etc/zookeeper`

`ls`
`sudo vi zoo.cfg`

```
zookeeper.ipaddress:xxxxx
```

In older versions of zookeeper you would have to change the zookeeper ip to the sensor - you no longer have to do that.


## Manually create topic in Kafka

`cd /opt/kafka/bin`

`./kafka-topics.sh --create --topic bro-raw --partitions 2 --replication-factor 1 --zookeeper 172.16.10.100:2181`

`./kafka-topics.sh --create --topic fsf-raw --partitions 2 --replication-factor 1 --zookeeper 172.16.10.100:2181`

`./kafka-topics.sh --create --topic suricata-raw --partitions 2 --replication-factor 1 --zookeeper 172.16.10.100:2181`

The next step is to Start Bro:
## Test Bro to ensure bro logs are being sent into kafka

`sudo broctl start`

`/opt/kafka/bin/kafka-console-consumer.sh --bootstrap-server 172.16.10.100:9092 --topic bro-raw --from-beginning`

- if the command doesn't output - check the kafka.bro under /usr/share/bro/site/scripts. Ensure you have the right IP.

### You have to Alter a Topic in order to increase partitions

*do for exam*

`./kafka-topics.sh --alter --topic bro-raw --partitions 2 --zookeeper 172.16.10.100:2181`

`./kafka-topics.sh --alter --topic fsf-raw --partitions 2 --zookeeper 172.16.10.100:2181`

`./kafka-topics.sh --alter --topic suricata-raw --partitions 2 --zookeeper 172.16.10.100:2181`

=======================================================
# Configure Filebeat

the two files we care about are the only two files bro is missing

/data/suricata/logs
eve.json
/data/fsf/logs
rockout.log

### Install and configure Filebeat
`sudo yum install filebeat`

`sudo vi /etc/filebeat/filebeat.yml`

```
remove lines starting from
17: # Each is a prospector
65: #
66: #================================File beat Modules==============================
```
add to `sudo vi /etc/filebeat/filebeat.yml`
```
16:
- input_type:  logs
  paths:
    - /data/suricata/logs/eve.json
  json.keys_under_root: true
  fields:
    kafka_topic: suricata-raw
  fields_under_root: true

- input_type: logs
  paths:
    - /data/fsf/logs/rockout.log
  json.keys_under_root: true
  fields:
    kafka_topic: fsf-raw
  fields_under_root: true

  processors:
   - decode_json_fields:
       fields: ["message","Scan Time", "Filename", "objects", "Source", "meta", "Alert" ,"Summary"]
       process_array: true
       max_depth: 10

    .....
  116:#----- - - --- ---- - -----Elasticsearch output - - - -- - - - - - - - --
  117: output.kafka:
    hosts: ["172.16.10.100:9092"]
    topic: '%{[kafka_topic]}'
    required_acks: 1
    compression: gzip
    max_message_bytes: 1000000
    #- - - - - - - - - -  - - - - -Logstash output - - - - - - - - - - - - --  - - -

    :wq

```

`sudo systemctl start filebeat`
`sudo systemctl status filebeat`
`sudo systemctl enable filebeat`

`cd /data/kafka/logs`

Notice suricata-raw-0... we only have one partition set up - but would ensure we have two for the exam.
