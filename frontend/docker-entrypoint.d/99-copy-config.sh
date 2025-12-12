#!/bin/sh
# Add proxy locations to nginx config after entrypoint modifications
echo "Adding proxy locations to nginx config..."
cat >> /etc/nginx/conf.d/default.conf << 'EOF'

    # Proxy compress endpoint to backend
    location /compress {
        proxy_pass http://gocools-backend:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
EOF
echo "Proxy locations added successfully"
