### Configuring of Docker Desktop 
Install Docker 
get mongos base docker image from the docker hub (https://hub.docker.com/_/mongo) 
>  `docker pull mongo`

 Confirm you user is in the docker-users group created on install, if it is there and still cant open docker desktop restart your machine.  
> `net localgroup docker-users "DATACOM-NZ/UserN" /ADD`

## Deployments 
### Docker-Compose (perfered method)
This will build an image for the mongo-setup machine (a machine thats wait for the nodes to start then configures MongoDB between them and sets node 1 to be the primary) 
Then Starts all 6 nodes, after the nodes are up itll start the mongo-setup machine and configure the clusture  
> `docker-compose -f .\docker-compose.yml up`

NB if you update the scripts for the the setup machine you will need to reimage it 

> ` docker build .\mongo-setup -t mango-setup:latest ' 

Or remove image through docker desktop and rerun docker compose


### Docker (nonCompose method)
> `docker network create MongoNet
docker network list
docker run -d -p 30001:27017 --net MongoNet --name localMongo1 mongo --replSet MongoSet
docker run -d -p 30002:27017 --net MongoNet --name localMongo2 mongo --replSet MongoSet
docker run -d -p 30003:27017 --net MongoNet --name localMongo3 mongo --replSet MongoSet`


> `docker exec -it localMongo1 mongo`

> `config = { "_id":"MongoSet","members":[{_id:0,host:"localmongo1:27017"},{_id:1,host:"localmongo2:27017"},{_id:2,host:"localmongo3:27017"}] }
> MongoSet> `rs.initiate(config)`



### Health Check
> `docker exec -it [ContainterName of a Node] mongo`  

> MongoSet:PRIMARY> `rs.status()`


## Post Creation Sanity Checks
### Health Check
> `docker stop [Primary Node]`

> `docker exec -it [Other Node] mongo` 

> MongoSet:PRIMARY> `rs.status()`


### Replication Check
Juump on primary node 
> ` db.inventory.insertMany( [
    { item: "journal", instock: [ { warehouse: "A", qty: 5 }, { warehouse: "C", qty: 15 } ] }, 
    { item: "paper", instock: [ { warehouse: "A", qty: 60 }, { warehouse: "B", qty: 15 } ] }, 
    { item: "planner", instock: [ { warehouse: "A", qty: 40 }, { warehouse: "B", qty: 5 } ] }, 
    { item: "postcard", instock: [ { warehouse: "B", qty: 15 }, { warehouse: "C", qty: 35 } ] } ]); ` 

response should say
> "acknowledged" : true, 

Jump off, stop primary node 
docker stop [Primary Node]

jump on other node to see what it now Primary 
docker exec -it [Other Node] mongo 
> `rs.status()`

Jump on new primary node 
> ` db.inventory.find( {} )`  

response should conatin our mock data 
> `{ "_id" : ObjectId("62426170282f26d2d1a617fb"), "item" : "postcard", "instock" : [ { "warehouse" : "B", "qty" : 15 }, { "warehouse" : "C", "qty" : 35 } ] }
{ "_id" : ObjectId("62426170282f26d2d1a617f9"), "item" : "paper", "instock" : [ { "warehouse" : "A", "qty" : 60 }, { "warehouse" : "B", "qty" : 15 } ] }
{ "_id" : ObjectId("62426170282f26d2d1a617fa"), "item" : "planner", "instock" : [ { "warehouse" : "A", "qty" : 40 }, { "warehouse" : "B", "qty" : 5 } ] }
{ "_id" : ObjectId("62426170282f26d2d1a617f8"), "item" : "journal", "instock" : [ { "warehouse" : "A", "qty" : 5 }, { "warehouse" : "C", "qty" : 15 } ] }`