#!/bin/bash
go get github.com/sfproductlabs/floater
go build
sudo docker build -t floater .
