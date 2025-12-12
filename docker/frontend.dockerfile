FROM nginx:alpine
# Copy nginx config directly
COPY frontend/default.conf /etc/nginx/conf.d/default.conf
# Copy static files
COPY frontend/index.html /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
