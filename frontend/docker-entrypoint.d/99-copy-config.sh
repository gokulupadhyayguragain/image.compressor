#!/bin/sh
# Copy custom nginx config after entrypoint modifications
cp /tmp/my-default.conf /etc/nginx/conf.d/default.conf
