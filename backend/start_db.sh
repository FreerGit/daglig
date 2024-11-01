#!/bin/bash

docker build -t dev-pg .
docker build -t test-pg .
docker run -e POSTGRES_DB=test -e POSTGRES_USER=test -e POSTGRES_PASSWORD=test -p 5555:5432 -d test-pg
docker run -e POSTGRES_DB=dev -e POSTGRES_USER=dev -e POSTGRES_PASSWORD=dev -p 5432:5432 -d dev-pg
