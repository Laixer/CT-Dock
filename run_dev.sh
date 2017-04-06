#!/bin/bash
docker run --rm --name ctdev -h ctdemo \
	-e SESSION_NAME=ctlocal \
	-e MOLLIE_API= \
	-e POSTCODE_API= \
	-e MAILCHIMP_APIKEY= \
	-e MAILGUN_SECRET=key- \
	-e MAILGUN_PUBLIC=pubkey- \
	-e APP_ENV=demo \
	-e APP_DEBUG=true \
	-e EP_REDIS=1 \
	-e EP_HTTPD=1 \
	-e EP_CRON=1 \
	-e EP_PGSQL=1 \
	-v "$PWD/"calctool-v2/app:/var/www/ct/app \
	-v "$PWD/"calctool-v2/config:/var/www/ct/config \
	-v "$PWD/"calctool-v2/resources:/var/www/ct/resources \
	-d dinux/ctdock
