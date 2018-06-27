# Bro Configuration

*NOTE*
=====================================================
Anytime you restart bro
```
sudo broctl stop
sudo broctl cleanup all
sudo broctl deploy
```
=====================================================


On the Sensor - `ssh admin@172.16.10.100`

`sudo yum install -y bro broctl bro-plugin-kafka bro-plugin-af_packet`

*The broctl portion is going to wrap around the bro binary and will allow us to spin up multiple instances for scaling out sensors or cores or multiple machines running bro(working together).*

## Change some Bro files

`cd /etc/bro` (there are a couple of files we need to change)

### 1. Bro Control directory paths
`sudo vi broctl.cfg`

```
All we care about is what's at the bottom,

LogDir = /data/bro/logs

NOTE: DO NOT CHANGE THE SPOOL DIRECTORY

under CfgDir = /etc/bro  add-->

lb_custom.InterfacePrefix=af_packet::

```
### 2. Scale Bro networks
`sudo vi networks.cfg`

```
10.0.10.0/24    Private IP space
172.16.10.0/24  Private IP space
192.168.2.0/24  Private IP space
```
### 3. How you would set Bro based off your hardware
`sudo vi node.cfg`

```
comment lines 8, 9 , 10 , 11 by default set bro into standalone - which is single core - we do not want that so we're going to comment them out and change the core settings

8   #[bro]
9   #type=standalone
10  #host=localhost
11  #interface=eth0

UNCOMMENT: line 20 - 31 = These lines are you workers - you can scale them to your hardware - we are scaling to 4 cores.
20  [manager]
    type=manager
    host-localhost
    pin_cpus=1

    [proxy-1]
    type=proxy
    host=localhost

    [worker-1]      {each worker represents an interface you're  collecting on}
    type=worker
    host=localhost    {you would use this to cluster - only one box needs this file}
    interface=enp2s0
    lb_method=custom
    lb_procs=2      {this is the number of cpus to be listed below}
    pin_cpus=2,3    {the the cpus to be used}
    env_vars=fanout_id=73   {id is arbitrary = pick one}
    :wq
```

## Add some scripts

`cd /usr/share/bro/site/`

`sudo mkdir scripts`

`cd scripts/`

### kafka.bro

`sudo vi kafka.bro`

```
@load Apache/Kafka/logs-to-kafka

redef Kafka::topic_name = "bro-raw";
redef Kafka::json_timestamps = JSON::TS_ISO8601;
redef Kafka::tag_json = T;
redef Kafka::kafka_conf = table (
  ["metadata.broker.list"] = "172.16.10.100:9092"
  );

  # Enable bro logging to kafka for all logs
  event bro_init() &priority=-5
  {
      for (stream_id in Log::active_streams)
      {
          if (|Kafka::logs_to_send| == 0 || stream_id in Kafka::logs_to_send)
          {
              local filter: Log::Filter = [
                  $name = fmt("kafka-%s", stream_id),
                  $writer = Log::WRITER_KAFKAWRITER,
                  $config = table(["stream_id"] = fmt("%s", stream_id))
              ];

              Log::add_filter(stream_id, filter);
          }
      }
  }
  :wq
```
### afpacket.bro

`sudo vi afpacket.bro`

```
# Put this in /usr/share/bro/site/scripts
# And add a @load statement to the /usr/share/bro/site/local.bro script

redef AF_Packet::fanout_id = strcmp(getenv("fanout_id"),"") == 0 ? 0 : to_count(getenv("fanout_id"));

```
###Rock scripts

`sudo curl -L -O http://perched-repo/sensor_configs/bro/rock-scripts.tar.gz`

`sudo tar -zxf rock-scripts.tar.gz`

`sudo vi /usr/share/bro/site/scripts/rock-scripts/plugins/afpacket.bro `

```
comment out lines 17 & 18 so they are like the below 2 lines
#@load scripts/rock/plugins/afpacket
#redef AF_Packet::fanout_id = strcmp(getenv("fanout_id"),"") == 0 ? 0 : to_count(getenv("fanout_id"));
```

### change local.bro

`sudo vi /usr/share/bro/site/local.bro`
```
Shift G - to navigate to bottom of file

add ##### My Custom scripts ####### below here:
@load ./scripts/afpacket.bro
@load ./scripts/kafka.bro
@load ./scripts/rock-scripts/rock.bro
:wq
```

`sudo mkdir -p /data/bro/logs`

`sudo broctl deploy`


### change rock.bro

`sudo vi /usr/share/bro/site/scripts/rock-scripts/rock.bro`

and comment out last line:

`#@load ./plugins/afpacket`

=================================================================
## Bro Logs Extracted Files:

you can view bro logs at.

`cd /data/bro/logs/current`
`ll`
`cd`
Download VIMRC - every time you vi - it will read VIMRC config file. which adds line numbers and colors

`sudo curl -L -O perched-repo/vimrc`
Notice: the File.log is now present under /data/bro/logs/current

looking inside of the file - you can see files that have been captured by bro.

`less -S /data/bro/logs/current/files.log`

after downloading a pdf:

`sudo curl -L -O http://perched-repo/markdown-cheatsheet-online.pdf`

you can see the log at `less -S /data/bro/logs/current/files.log` :
But bro also makes a copy of the pdf.

VERY IMPORTANT: you can find the copy of this copied file at :
`cd /data/bro/logs/extract_files/`

You could scp these files and open them, although that is not a recomended practice.

Stop Bro so it doesn't interfere with installing fsf -
`sudo broctl stop`

you have to stop bro - or you just want to stop bro because, bro is attempting to send things fsf which hasn't even been stood up yet. Stoping bro will make installing fsf much easier as far as resources.

## INSTALL FSF

`sudo yum install fsf`

edit fsf configs to configure peraminters like directories paths and timout.

`sudo vi /opt/fsf/fsf-server/conf/config.py`

```
import socket

SCANNER_CONFIG =  { 'LOG_PATH' : '/data/fsf/logs',
                    'YARA_PATH' : '/var/lib/yara-rules/rules.yara',
                    'PID_PATH' : '/run/fsf/fsf.pid',
                    'EXPORT_PATH' : '/data/fsf/archive',
                    'TIMEOUT' : 60,
                    'MAX_DEPTH' : 10,
                    'ACTIVE_LOGGING_MODULES' : ['rockout'],
                  }
SERVER_CONFIG = { 'IP_ADDRESS' : "172.16.10.100",
                  'PORT' : 5800 }
```
*NOTE: under SERVER_CONFIG IP_ADDRESS you could set the IP ADDRESS to 0.0.0.0 which will bind fsf to all physical interfaces on that host/machine.*

* Next we're going to make the directories for our fsf products to go (/logs and /archive)

`sudo mkdir -p /data/fsf/{logs,archive}`
`sudo chown -R fsf:fsf /data/fsf`
`sudo systemctl start fsf`
`sudo systemctl status fsf`
`sudo systemctl enable fsf`
`ss -lnt`

### Set up CLient to listen to SERVER

*Note - the client doesn't have to be on the server - it could be any distant machine.*

* Open Firewall to listen on port 5800

`sudo firewall-cmd --add-port=5800/tcp --permanent`
`sudo firewall-cmd --reload`
`sudo firewall-cmd --list-ports`

* finish configuring CLient

`sudo vi /opt/fsf/fsf-client/conf/config.py`
you only have to change the IP address in the config.py
```
SERVER_CONFIG = {'IP_ADDRESS' : ['172.16.10.100'], 'PORT' : 5800 }
```
you could used multip addresses here like so
SERVER_CONFIG = {'IP_ADDRESS' : ['172.16.10.100','172.16.10.101','172.16.10.102']}

* to test this out - there is a binary that gets executed
*execute the binary against a pdf extracted by bro - you might have to curl a file from you repo for it to show up in bro's extractdfiles*

`/opt/fsf/fsf-client/fsf_client.py --full /data/bro/logs/extract_files/HTTP-XXXXXXXXXXX.pdf`
*note: if there is a bunch of "stuff" before you get an error it actually worked you can now start bro back up*
What we're seeing is a json report. JSON is disecting what we're seeing in the pdf. You can also see the Yara rules executed against this file. To view were the yara rules reside navigate to
`cd /var/lib/yara-rules`

you can also find more yara rules by googling yara rules on github.

* where is bro making the magic happen?
we're not changing anything but it's important to know whats going on.

`cd /usr/share/bro/site/scripts/`

`sudo vi rock-scripts/frameworks/files/extract2fsf.bro`

all you really care about in this file the part that says "local scan_cmd = fmt(....)"

Notice the `--archive none portion` - this means that rock will not keep a malicious file by default. you can change this to alert.

=====================================================
Anytime you restart bro
```
sudo broctl stop
sudo broctl cleanup all
sudo broctl deploy
```
=====================================================
