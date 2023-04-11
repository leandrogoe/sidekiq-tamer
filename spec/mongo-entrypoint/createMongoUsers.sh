#!/usr/bin/env bash
echo "Creating mongo users..."
mongosh admin --host localhost -u $MONGO_INITDB_ROOT_USERNAME -p $MONGO_INITDB_ROOT_PASSWORD --eval \
    "db.enableFreeMonitoring();
     db.createUser({user: 'USER', pwd: 'PASS', roles: [{role: 'readWrite', db: 'mydb'}]});
     db.createUser({user: 'clusterMonitor', pwd: 'PASS', roles: [{role: 'clusterMonitor', db: 'admin'}]});
     db.createUser({user: 'admin', pwd: 'PASS', roles: [{role: 'userAdminAnyDatabase', db: 'admin'}]});"
echo "Mongo users created."