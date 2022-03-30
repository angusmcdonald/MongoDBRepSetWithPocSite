#!/bin/bash
echo "sleeping for 10 seconds"
sleep 10

MONGO1IP=$(getent hosts localmongo1 | awk '{ print $1 }')
MONGO2IP=$(getent hosts localmongo2 | awk '{ print $1 }')
MONGO3IP=$(getent hosts localmongo3 | awk '{ print $1 }')
MONGO4IP=$(getent hosts localmongo4 | awk '{ print $1 }')
MONGO5IP=$(getent hosts localmongo5 | awk '{ print $1 }')
MONGO6IP=$(getent hosts localmongo6 | awk '{ print $1 }')

if [ ! -f /data/mongo-init.flag ]; then

  echo mongo_setup.sh time now: `date +"%T" `
  mongo --host localmongo1:30001 <<EOF
    var cfg = {
      "_id": "MongoSet",
      "version": 1,
      "members": [
        {
          "_id": 0,
          "host": "localmongo1:30001",
          "priority": 1
        },
        {
          "_id": 1,
          "host": "localmongo2:30002",
          "priority": 1
        },
        {
          "_id": 2,
          "host": "localmongo3:30003",
          "priority": 1
        },
        {
          "_id": 3,
          "host": "localmongo4:30004",
          "priority": 1
        },
        {
          "_id": 4,
          "host": "localmongo5:30005",
          "priority": 1
        },
        {
          "_id": 5,
          "host": "localmongo6:30006",
          "priority": 1
        }
      ]
    };
    show dbs
    rs.initiate(cfg);
EOF
    touch /data/mongo-init.flag
else
    echo "Replicaset already initialized"
fi