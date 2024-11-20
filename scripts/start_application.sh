#!/bin/bash
cd /var/www/html
pm2 serve . 3000 --name "react-app" --spa