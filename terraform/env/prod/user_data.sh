#!/bin/bash
dnf -y update
dnf -y install nginx postgresql16

# Health check endpoint
echo "ok" > /usr/share/nginx/html/up
cat >/etc/nginx/conf.d/app.conf <<NGX
server {
  listen 80 default_server;
  location /up { return 200 "ok"; }
  location / { return 200 "hello from EC2"; }
}
NGX
systemctl enable nginx
systemctl restart nginx
