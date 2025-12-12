FROM nginx:alpine
COPY frontend/default.conf /tmp/my-default.conf
COPY frontend/docker-entrypoint.d/ /docker-entrypoint.d/
COPY frontend/ /usr/share/nginx/html/
EXPOSE 80
