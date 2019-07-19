#!/bin/bash
docker build -t premhashmap/django-demo . 
docker build -t premhashmap/django-demo-dbsetup -f Dockerfile-database-setup .
docker-compose up
