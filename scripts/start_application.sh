#!/bin/bash
cd /var/www/html
pm2 serve build 3000 --name "react-app" --spa