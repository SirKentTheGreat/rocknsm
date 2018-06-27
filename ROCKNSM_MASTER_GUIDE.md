# ROCKNSM MASTER GUIDE
## 1.
First Start with Building your Sensor [Sensor_Build](http://gitea/SirKentTheGreat/SG01/src/branch/master/Sensor_Build.md)

## 2.
Next build the sensor using the [PFSense_Install](http://gitea/SirKentTheGreat/SG01/src/branch/master/PFSense_Install.md) guide.

*Note - you can simply load an .xml backup file if you've already created one.*
```
Diagnostics - Backup & Restore
Scroll to bottom - Restore Backup
and select file - Restore Configuration

```
## 3.
Perform the [TAP_CONFIGURATION](http://gitea/SirKentTheGreat/SG01/src/branch/master/Tap_Configuration.md) steps. This will allow you to setup your inline tap infrastructure setup.

* INSTALL EQUIPMENT

## 4. Prepare Sensor and configure yum
Refer to [Sensor_prep](http://gitea/SirKentTheGreat/SG01/src/branch/master/Sensor_prep.md).

## 5.Install Stenographer

Follow instructions listed on [Installing_Stenographer](http://gitea/SirKentTheGreat/SG01/src/branch/master/Installing_Stenographer.md) How to guide.

## 6. Install Suricata

Follow instrcution listed on [Installing_Suricata](http://gitea/SirKentTheGreat/SG01/src/branch/master/Installing_Suricata.md) How to guide.

## 7. Install Bro
Follow instrcution listed on [Bro_Setup](http://gitea/SirKentTheGreat/SG01/src/branch/master/Bro_Setup.md) How to guide.

## 8. Instll Kafka
Follow instrcution listed on [Kafka_Build](http://gitea/SirKentTheGreat/SG01/src/branch/master/Kafka_Build.md) How to guide.

## 9. Cluster Kafka (optional)
Follow instrcution listed on [Cluster_Kafka](http://gitea/SirKentTheGreat/SG01/src/branch/master/cluster%20kafka) How to guide.

### Ensure that you've enabled ALL SERVICES

`sudo systemctl enable stenographer suricata fsf kafka filebeat zookeeper logstash elasticsearch kibana`


## 10. Install elasticsearch
[elasticsearch_install](http://gitea/SirKentTheGreat/SG01/src/branch/master/Elasticsearch_Install.md)

## 11. Install kibana
[Kibana_Install](http://gitea/SirKentTheGreat/SG01/src/branch/master/Kibana_install.md)

## 12. logstash
[Logstash_Install](http://gitea/SirKentTheGreat/SG01/src/branch/master/Logstash_Install.md)

## 13. Test TAP_CONFIGURATION
[ROC_FUNCTIONS_CHECK](http://gitea/SirKentTheGreat/SG01/src/branch/master/ROCK_FUNCTIONS_CHECK.md)
