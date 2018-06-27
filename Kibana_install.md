Kibana is super easy to stand up -

`sudo yum install kibana`


Make a couple of edits in the .yml file

`sudo vi kibana.yml`

```
7: server.host: "172.16.10.100"

21:....url: "http://172.16.10.100:9200"
```

OPEN FIREWALL

`sudo firewall-cmd --add-port=5601/tcp --permanent`
`sudo firewall-cmd --reload`
`sudo firewall-cmd --list-ports`

Start and Enable Kibana

`sudo systemctl start kibana`
`sudo systemctl enable kibana`

The best way to test is to browse to your sensor ip at :5601
[172.16.10.100:5601](http://172.16.10.100:5601)


Good trouble shooting technique is under dev tools:

GET _cat/nodes
GET _cat/indices
