#!/bin/bash

####### VARIABLES ##########
REGISTRY=frimpongefrei/api:1.0.0
CONTAINER_NAME=api:1.0.0

####### EXECUTION ##########
echo "CREATION DU CONTAINER $REGISTRY\n"
docker build . -t $CONTAINER_NAME
docker tag $CONTAINER_NAME $REGISTRY
docker push $REGISTRY
echo "FIN DU PROCESSUS\n"
sleep 2
clear

