#!/bin/bash
apt-get update && apt-get install -y nginx
echo "hello from terraform" > /var/www/html/index.html