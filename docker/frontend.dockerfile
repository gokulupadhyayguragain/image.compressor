FROM nginx:alpine
COPY frontend/default.conf /tmp/my-default.conf
COPY frontend/docker-entrypoint.d/ /docker-entrypoint.d/
RUN chmod +x /docker-entrypoint.d/99-copy-config.sh
COPY frontend/ /usr/share/nginx/html/
EXPOSE 80
