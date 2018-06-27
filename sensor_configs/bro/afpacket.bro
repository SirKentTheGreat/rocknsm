# Put this in /usr/share/bro/site/scripts
# And add a @load statement to the /usr/share/bro/site/local.bro script

redef AF_Packet::fanout_id = strcmp(getenv("fanout_id"),"") == 0 ? 0 : to_count(getenv("fanout_id"));

