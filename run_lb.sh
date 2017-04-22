#!/bin/bash
docker run --rm --name lb1 --link ctdev -h lb1 \
	-v "$PWD/"nginx_lb/nginx.conf:/etc/nginx/nginx.conf \
	-v "$PWD/"nginx_lb/dhparam.pem:/etc/nginx/dhparam.pem \
	-v "$PWD/"nginx_lb/ssl:/etc/nginx/ssl \
	-v "$PWD/"nginx_lb/conf.d:/etc/nginx/conf.d \
	-d nginx
