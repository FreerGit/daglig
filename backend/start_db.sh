#!/bin/bash

docker build -t dev-pg . 
docker run -p 5432:5432 -d dev-pg
