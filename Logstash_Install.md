# Logstash_Install

.yml files reside in:

`cd /etc/logstash `

these .yml files tell logstash specifi data like cpu utilizations, partitions, and workers:

Pipeline configuration files pertain to the actual movement of data:
Those files are located in: /etc/logstash/conf.d

We have to create this config file:
`cd /etc/logstash/conf.d`

`sudo vi logstash-100-input-kafka-bro.conf`

```

input {
  kafka {
    topics => ["bro-raw"]
    add_field => { "[@metadata][stage]" => "broraw_kafka" }
    # Set this to one per kafka partition to scale up
    #consumer_threads => 4
    group_id => "bro_logstash"
    bootstrap_servers => "172.16.10.100:9092"
    codec => json
    auto_offset_reset => "earliest"
  }
}

```

Do the same thing for fsf and suricata. You can easily find these into the repository: BUT.... if you're name is SFC Bledsoe - and you just have to have it written down 100 times.... you can just follow the info below.

FSF:


`sudo vi logstash-100-input-kafka-fsf.conf`

```

input {
  kafka {
    topics => ["fsf-raw"]
    add_field => { "[@metadata][stage]" => "fsfraw_kafka" }
    # Set this to one per kafka partition to scale up
    #consumer_threads => 4
    group_id => "fsf_logstash"
    bootstrap_servers => "172.16.10.100:9092"
    codec => json
    auto_offset_reset => "earliest"
  }
}

```

Suricata:

`sudo vi logstash-100-input-kafka-suricata.conf`

```
input {
  kafka {
    topics => ["suricata-raw"]
    add_field => { "[@metadata][stage]" => "suricataraw_kafka" }
    # Set this to one per kafka partition to scale up
    #consumer_threads => 4
    group_id => "suricata_logstash"
    bootstrap_servers => "172.16.10.100:9092"
    codec => json
    auto_offset_reset => "earliest"
  }
}

```

Next: we're going to create the 500 - FILTERS - most important of all logstash configuration:

Create Bro 500 Filter configuration file:

`sudo vi logstash-500-filter-bro.conf`

```
filter {
  if [@metadata][stage] == "broraw_kafka" {
      # Set the timestamp
      date { match => [ "ts", "ISO8601" ] }

      # move metadata to new field
      mutate {
        rename => {
          "@stream" => "[@meta][stream]"
          "@system" => "[@meta][system]"
          "@proc"   => "[@meta][proc]"
        }
      }

      # Rename ID field from file analyzer logs
      if [@meta][stream] in ["pe", "x509", "files"] {
        mutate { rename => { "id" => "fuid" } }
        mutate {
          add_field => { "[@meta][event_type]" => "file" }
          add_field => { "[@meta][id]" => "%{fuid}" }
        }
      } else if [@meta][stream] in ["intel", "notice", "notice_alarm", "signatures", "traceroute"] {
          mutate { add_field => { "[@meta][event_type]" => "detection" } }

          if [id_orig_h] {
            mutate {
              convert => {
                "id_orig_p" => "integer"
                "id_resp_p" => "integer"
              }
              add_field => {
                "[@meta][id]" => "%{uid}"
                "[@meta][orig_host]" => "%{id_orig_h}"
                "[@meta][orig_port]" => "%{id_orig_p}"
                "[@meta][resp_host]" => "%{id_resp_h}"
                "[@meta][resp_port]" => "%{id_resp_p}"
              }
            }
            geoip {
              source => "id_orig_h"
              target => "[@meta][geoip_orig]"
            }
            geoip {
              source => "id_resp_h"
              target => "[@meta][geoip_resp]"
            }
          }
      } else if [@meta][stream] in [ "capture_loss", "cluster", "communication", "loaded_scripts", "packet_filter", "prof", "reporter", "stats", "stderr", "stdout" ] {
        mutate { add_field => { "[@meta][event_type]" => "diagnostic" } }
      } else if [@meta][stream] in ["netcontrol", "netcontrol_drop", "netcontrol_shunt", "netcontrol_catch_release", "openflow"] {
        mutate { add_field => { "[@meta][event_type]" => "netcontrol" } }
      } else if [@meta][stream] in ["known_certs", "known_devices", "known_hosts", "known_modbus", "known_services", "software"] {
        mutate { add_field => { "[@meta][event_type]" => "observations" } }
      } else if [@meta][stream] in ["barnyard2", "dpd", "unified2", "weird"] {
        mutate { add_field => { "[@meta][event_type]" => "miscellaneous" } }
      } else {

        # Network type
        mutate {
          convert => {
          "id_orig_p" => "integer"
          "id_resp_p" => "integer"
          }
          add_field => {
            "[@meta][event_type]" => "network"
            "[@meta][id]" => "%{uid}"
            "[@meta][orig_host]" => "%{id_orig_h}"
            "[@meta][orig_port]" => "%{id_orig_p}"
            "[@meta][resp_host]" => "%{id_resp_h}"
            "[@meta][resp_port]" => "%{id_resp_p}"
          }
        }
        geoip {
          source => "id_orig_h"
          target => "[@meta][geoip_orig]"
        }
        geoip {
          source => "id_resp_h"
          target => "[@meta][geoip_resp]"
        }
      }

      # Tie related records
      mutate { add_field => { "[@meta][related_ids]" => [] }}
      if [uid] {
        mutate { merge => {"[@meta][related_ids]" => "uid" }}
      }
      if [fuid] {
        mutate { merge => {"[@meta][related_ids]" => "fuid" }}
      }
      if [related_fuids] {
        mutate { merge => { "[@meta][related_ids]" => "related_fuids" }}
      }
      if [orig_fuids] {
        mutate { merge => { "[@meta][related_ids]" => "orig_fuids" }}
      }
      if [resp_fuids] {
        mutate { merge => { "[@meta][related_ids]" => "resp_fuids" }}
      }
      if [conn_uids] {
        mutate { merge => { "[@meta][related_ids]" => "conn_uids" }}
      }
      if [cert_chain_fuids] {
        mutate { merge => { "[@meta][related_ids]" => "cert_chain_fuids" }}
      }

      # Nest the entire document
      ruby {
        code => "
          require 'logstash/event'

          logtype = event.get('[@meta][stream]')
          ev_hash = event.to_hash
          meta_hash = ev_hash['@meta']
          timestamp = ev_hash['@timestamp']

          # Cleanup duplicate info
          #meta_hash.delete('stream')
          ev_hash.delete('@meta')
          ev_hash.delete('@timestamp')
          ev_hash.delete('tags')

          result = {
          logtype => ev_hash,
          '@meta' => meta_hash,
          '@timestamp' => timestamp
          }
          event.initialize( result )
        "
      }
      mutate { add_field => {"[@metadata][stage]" => "broraw_kafka" } }
  }
}

```

Create the fsf 500 filter configuration file:

`sudo vi logstash-500-filter-fsf.conf`

```
filter {
  if [@metadata][stage] == "fsfraw_kafka" {
    if ![tags] {
      # Remove kafka_topic field
      mutate { remove_field => [ "kafka_topic" ] }

      # Set the timestamp
      date { match => [ "Scan Time", "ISO8601" ] }
    }
    else {
      mutate { add_field => { "[@metadata][stage]" => "_parsefailure" } }
    }
  }

  if [@metadata][stage] == "fsf" {
    if ![tags] {
        mutate { remove_field => ["path"] }
    }
    else {
      mutate { add_field => { "[@metadata][stage]" => "_parsefailure" } }
    }
  }
}

```

Create the suricata 500 filter configuration file:

`sudo vi logstash-500-filter-suricata.conf`

```

filter {

  if [@metadata][stage] == "suricataraw_kafka" {

    if ![tags] {

      # Remove kafka_topic field
      mutate {
        remove_field => [ "kafka_topic" ]
      }

      # Set the timestamp
      date { match => [ "timestamp", "ISO8601" ] }
    } else {
      mutate { add_field => { "[@metadata][stage]" => "_parsefailure" } }
    }
  }

  if [@metadata][stage] == "suricata_eve" {
    # Tags will determine if there is some sort of parse failure
    if ![tags] {
      mutate { remove_field => ["path"] }
    }
    else {
      mutate { add_field => { "[@metadata][stage]" => "_parsefailure" } }
    }
  }
}

```

Next we are going to configure the 999 OUTPUT configuration:

First configure bro -999 output configuration
`sudo vi logstash-999-output-es-bro.conf`

```
output {
    if [@metadata][stage] == "broraw_kafka" {
        kafka {
          codec => json
          topic_id => "bro-%{[@meta][event_type]}"
          bootstrap_servers => "172.16.10.100:9092"
        }

        elasticsearch {
            hosts => ["172.16.10.100"]
            index => "bro-%{[@meta][event_type]}-%{+YYYY.MM.dd}"
            template => "/etc/elasticsearch/es-bro-mappings.json"
            document_type => "_doc"
        }
    }
}

```

configure fsf 999 configuration file:
`sudo vi logstash-999-output-es-fsf.conf`

```
output {
  if [@metadata][stage] == "fsfraw_kafka" {
    kafka {
     codec => json
     topic_id => "fsf-clean"
     bootstrap_servers => "172.16.10.100:9092"
    }

    elasticsearch {
      hosts => ["172.16.10.100"]
      index => "fsf-%{+YYYY.MM.dd}"
      manage_template => false
      document_type => "_doc"
    }
  }
}

```

configure suricata 999 configuration file:

`sudo vi logstash-999-output-es-suricata.conf`

```
output {
  if [@metadata][stage] == "suricataraw_kafka" {
    kafka {
     codec => json
     topic_id => "suricata-clean"
     bootstrap_servers => "172.16.10.100:9092"
    }

    elasticsearch {
      hosts => ["172.16.10.100"]
      index => "suricata-%{+YYYY.MM.dd}"
      manage_template => false
      document_type => "_doc"
    }
  }
}

```


Start Logstash

`sudo systemctl start logstash`

`sudo systemctl stop logstash`

BY starting this - logstash will write all files with the ROOT as owner:

Test logstash config files: Test for all 9 files:

Prior to testing these files:

You can find this in the kibana repo:
```
sudo -s
cd /etc/elasticsearch/
curl -L -O http://perched-repo/sensor_configs/kibana/bro-mapping.json
mv bro-mapping.json es-bro-mappings.json
```

Ensure es-bro-mappings.json is in /etc/elasticsearch

`sudo /usr/share/logstash/bin/logstash --path.settings /etc/logstash/ -f /etc/logstash/conf.d/logstash-100-input-kafka-bro.conf -t`

expected output: 'configuration OKAY'

`sudo /usr/share/logstash/bin/logstash --path.settings /etc/logstash/ -f /etc/logstash/conf.d/logstash-100-input-kafka-fsf.conf -t`

`sudo /usr/share/logstash/bin/logstash --path.settings /etc/logstash/ -f /etc/logstash/conf.d/logstash-100-input-kafka-suricata.conf -t`

`sudo /usr/share/logstash/bin/logstash --path.settings /etc/logstash/ -f /etc/logstash/conf.d/logstash-500-filter-bro.conf -t`

`sudo /usr/share/logstash/bin/logstash --path.settings /etc/logstash/ -f /etc/logstash/conf.d/logstash-500-filter-fsf.conf -t`

`sudo /usr/share/logstash/bin/logstash --path.settings /etc/logstash/ -f /etc/logstash/conf.d/logstash-500-filter-suricata.conf -t`

`sudo /usr/share/logstash/bin/logstash --path.settings /etc/logstash/ -f /etc/logstash/conf.d/logstash-999-output-es-bro.conf -t`

`sudo /usr/share/logstash/bin/logstash --path.settings /etc/logstash/ -f /etc/logstash/conf.d/logstash-999-output-es-fsf.conf -t`

`sudo /usr/share/logstash/bin/logstash --path.settings /etc/logstash/ -f /etc/logstash/conf.d/logstash-999-output-es-suricata.conf -t`

You can test all 9 with the following script: I DONT PERSONALLY LIKE IT

`for i in /etc/logstash/conf.d/*; do sudo /usr/share/logstash/bin/logstash --path.settings /etc/logstash -f $1 -t; done`

testing logstash is working!

`sudo systemctl start logstash`

`sudo systemctl status logstash`

The line youre looking for it 'Sending Logstash's logs to .....'


Keep in mind we still have to change the owner:



`sudo chomd 755 /etc/elasticsearch/`


`curl 172.16.10.100:9200/ _cat/nodes`

`curl 172.16.10.100:9200/ _cat/indices`

=================================================================================
Trouble shooting issues - you may not have to do this - or you might. This is
stemmed from not having any data in network data in elastic.

`cd /etc/logstash/conf.d`

 `rm -f logstash-500-filter-bro.conf`

 `sudo vi logstash-999-output-es-bro.conf`

 ```
just ensure your index looks like this:
index => "bro-%{+YYYY.MM.dd}"
 ```
 `sudo systemctl stop elasticsearch`

 This is how to start elasticsearch as if it were brandnew

 `sudo rm -rf /data/elasticsearch/data/nodes/0/indices/`

`sudo systemctl start elasticsearch`

`sudo systemctl start logstash`

`curl 172.16.10.100:9200/ _cat/indices`



=================================================================================
