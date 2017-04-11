#!/bin/bash
docker run --rm --name ctdev -h ctdemo \
	-e SESSION_NAME=ctlocal \
	-e MOLLIE_API=live_dUapTi8xt2DujzS6WkPyGt8T7UpqY3 \
	-e POSTCODE_API=rFgaZzNUrB502bjpimpsS3tAzq70dRqJ6QuVXf8F \
	-e MAILCHIMP_APIKEY=150cc06e3a848bbba776f0d031da6c94-us14 \
	-e MAILGUN_SECRET=key-939dcd2afaf30eb9dabf874c47c6de50 \
	-e MAILGUN_PUBLIC=pubkey-5ad82f40a86568d0b05fbd5e1cd21b70 \
	-e APP_ENV=demo \
	-e APP_DEBUG=true \
	-e EP_REDIS=1 \
	-e EP_HTTPD=1 \
	-e EP_CRON=1 \
	-e EP_PGSQL=1 \
	-e EP_WORKER=1 \
	-v "$PWD/"calctool-v2/app:/var/www/ct/app \
	-v "$PWD/"calctool-v2/config:/var/www/ct/config \
	-v "$PWD/"calctool-v2/resources:/var/www/ct/resources \
	-v "$PWD/"calctool-v2/routes:/var/www/ct/routes \
	-d dinux/ctdock
