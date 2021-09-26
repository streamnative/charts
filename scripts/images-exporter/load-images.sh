#!/bin/bash

DOCKER=docker

for f in *.tar;
do
	"$DOCKER" load -i "$f"
done
