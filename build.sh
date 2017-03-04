#!/bin/bash
cd calctool-v2/
git pull
cd ..
docker build -t ctdock .
