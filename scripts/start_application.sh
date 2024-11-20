#!/bin/bash
cd /var/www/html
sudo pm2 serve . 80 --name "react-app" --spa
pm2 save
pm2 startup