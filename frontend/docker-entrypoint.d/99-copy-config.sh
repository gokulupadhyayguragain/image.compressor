#!/bin/sh
# Copy custom nginx config after entrypoint modifications
echo "Copying custom nginx config..."
cp /tmp/my-default.conf /etc/nginx/conf.d/default.conf
echo "Config copied successfully"
