#!/bin/bash
docker build -f Dockerfile.prod --no-cache --compress --label production -t dinux/ctdock:latest .
