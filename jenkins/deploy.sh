#!/bin/bash

if [ -z "${1}" ]; then
   version="latest"
else
   version="${1}"
fi

curl -X DELETE -H "Content-Type: application/json" http://localhost:8000/v2/apps/helloworld-nodejs-app
sleep 1

cp -f app_marathon.json app_marathon.json.tmp
sed -i "s/latest/${version}/g" app_marathon.json.tmp


curl -X POST -H "Content-Type: application/json" http://localhost:8000/v2/apps -d@app_marathon.json.tmp
