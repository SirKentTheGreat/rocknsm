Repo Stuff

# Yellowdog Update Manager, Delete and Add local Repository

`cd /etc/yum.repos.d/`

`ls`

`sudo rm -f *`

`sudo vi perched.repo`

name=perched local repo

enabled=1

baseurl=http://perched-repo/repos/epel

gpgcheck=0

:wq

*ping perched-repo* to test repos


## Mirror list

*mirror list an online list of mirrors*

this is simply a list of URL's which that also host the files in the repo

## gpgcheck

are public keys that you can download. you simply go online and find the specific gpgcheck. specific to the repo. so epel, or pip, or elasticsearch.



# sync and download repository to local machine.

in a production network you would install `reposync` ... so we're going to use `rsync` instead

`sudo reposync --repoid=<copr-rocknsm-2.1> --download_path=/data/share/repos/`



This is a onetime deal - but we are going to download a repository to our partners machine.


`df -h` to check free space and ensure our /data drive has enough memory >100Gib

`cd /data`

`sudo rsync -r admin@192.168.2.11:/data/share/repos .`

Local Password:`xxxxxxxxxx`

destination password:`perched1234!@#$`


## Check repo after download

`cd /data/repos/`
`ll`
* perform a create repo on each folder listed in /data/repos/

`createrepo base/`

`createrepo epel/`

`createrepo updates/`

`createrepo etc/`

*createrepo makes the repo downloaded usable*



# create Repository from ONline repository

reposync --help
we care about -r repoid
and -p download path

vi elasticsearch.repo

notice the repo ID in [xxx]
 copy id and type
 reposync --repoid=xxxx --download_path=/data/share/repos -l


# delete old /etc/repos.d and configure new repos.d

*note that this has to be done so that the machine knows where to go.*

rm -f /etc/repos.d/*

ls /data/repos/
list all repos downloaded.

`sudo vi perched.repo`

**[base-local]**

**name=<any thing you want>**

**enabled=1**

**gpgcheck=0**

**baseurl=file:///data/repos**

*notice the triple /// - the first two are the protocol and the third one is for the root directory*

copy those lines and paste it to create the proper syntax for each individual repository we made note of above.

**[copr-rocknsm-2.1-local]**

**name=<any thing you want>**

**enabled=1**

**gpgcheck=0**

**baseurl=file:///data/repos/copr-rocknsm-2.1**

* do this for each individual repo! so in our case you'll create an entry for each repo so that the machine knows how to find the proper files to download. The machine will look in /etc/repos by default for this information

`cd /etc/repos.d`

`sudo yum makecache fast`

{this is going to make a cached database of the yum repositories. this will allow the machine to know where to find everything}

now you should be able to do `yum install` and `yum search`

# NGINX open source webserver

`sudo yum install -y nginx`

`cd /etc/nginx/conf.d/`

`sudo vi repo.conf`

`server {
    listen 8008;
    location / {
    root /data/repos;
    autoindex on;
    index index.html index.htm }  }`

*"this is a server that listens on port 8008. As the root user access /data/repos. autoindex is on and will create an index file for your browswer. that is why there is no css or coding added to the page"*

`sudo vi /etc/nginx/nginx.conf`

*we are commenting out lines 39-41. THis is that we do not land on the NGINX splash page by default*

`server {
  #listen 80 default_server;
  #[::]:80 default_server;
  #server_name _;
  #Load configuration files for  the default server block
}`

### check status, start, enable NGINX systemctl
`sudo systemctl start nginx`

`ss -lnt`

`systemctl status nginx`

`systemctl enable nginx`

### configure firewall to allow 8008 trafic

punch a hole in firewall

`sudo firewall-cmd --add-port=8008/tcp --permanent`

restart firewalld

`sudo systemctl restart firewalld`

list ports open on firewall

`sudo firewall-cmd --list-ports`

`cd /data/repos/`

**view flag reserved for SELinux**

`ll -Z`

notice the etc_runtime_t context and possible User not root. you have to change the context to allow yum installs from distant devices.

`sudo chcon -R -u system_u -t httpd_sys_content_t repos/`

`sudo chown -R nginx:nginx repos/`


### last step

ensure that you can curl 8008 without error

`curl localhost:8008`

* make note of the computers ip address that is hosting the NGINX server
