#!/bin/sh
# Copy custom nginx config and add compress location
echo "Copying custom nginx config..."
cp /tmp/my-default.conf /etc/nginx/conf.d/default.conf
echo "Adding compress location..."
sed -i '/^}/i\
    # Proxy compress endpoint to backend\
    location /compress {\
        proxy_pass http://gocools-backend:3000;\
        proxy_set_header Host $host;\
        proxy_set_header X-Real-IP $remote_addr;\
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\
        proxy_set_header X-Forwarded-Proto $scheme;\
    }\
' /etc/nginx/conf.d/default.conf
echo "Config updated successfully"
