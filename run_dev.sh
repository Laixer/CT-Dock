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
	-e URL=http://172.17.0.3 \
	-d dinux/ctdock
