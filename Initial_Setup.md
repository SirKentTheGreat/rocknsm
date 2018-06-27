# Initial Setup
## RSA Key Atom Gitea/Gitlab setup
Provides Privacy, Integrity, and Authentication:

* Generate RSA Key

 `ssh-keygen -t rsa -b 4096 -C "Comment for Key"`

 note - adding a passphrase will add a password, remember the
 objective is to not have a passphrase.

* install Atom

   `sudo yum install -y libcurl`

   `sudo curl -L -O https://atom.io/download/rpm`

   `sudo yum localinstall atom.rpm`

* Install git

    `sudo yum install -y git`

    `git --version`

* copy ssh key and paste in gitea under SSH

 `cd /home/kennithwingard/.ssh`

 `ls`

 `pwd`

 `cat id_rsa.pub`

* SSH and clone gitea project repo

 `git clone ssh://gitea@192.168.2.11:4001/SirKentTheGreat/SG01.git`

* link directory to ATOM - file Add Project Folder

1. save files as .md
2. make changes to file and save files
3. Ctrl shift 9 ^(
4. right click stage changes
5. add commit message and commit to master
   You may have to add proper credentials

`git config --global user.email "email@email.com"`

`git config --global user.name "SirKentTheGreat" `

 pull before push and push file to update gitea live
