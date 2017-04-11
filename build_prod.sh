#!/bin/bash
docker build --no-cache --compress --label production -t dinux/ctdock:latest .
