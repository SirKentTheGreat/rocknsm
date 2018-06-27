#!/bin/bash
file="/etc/suricata/suricata.yaml.orig"

if [ -e "$file" ];
then
   echo -e "\033[1mFile $file exist.\nTask skipped\033[0m"
else
   sudo echo "\033[1mFile $file does not exist\033[0m" && sudo cat /etc/suricata/suricata.yaml > suricata.yaml.orig
fi


sudo rm -f /etc/suricata/temp.rules
sudo touch /etc/suricata/temp.rules
for item in /etc/suricata/rules/*.rules; do sudo echo " - $(basename $item)" >> /etc/suricata/temp.rules; done
sudo cat /etc/suricata/suricata.yaml > /etc/suricata/.suricata.yaml
echo -e "\033[1mCreated a hidden backup of /etc/suricata/suricata.yaml.\nFile is /etc/suricata/.suricata.yaml\033[0m"
sudo cat /etc/suricata/suricata.yaml | grep '\.rules' -v | sed '/rule-files:$/ r /etc/suricata/temp.rules' > /etc/suricata/temp.yaml
sudo cat /etc/suricata/temp.yaml > /etc/suricata/suricata.yaml
sudo rm -f /etc/suricata/temp.rules
sudo rm -f /etc/suricata/temp.yaml
