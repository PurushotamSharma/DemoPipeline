#!/bin/bash
if pm2 list | grep -q "react-app"; then
    pm2 stop react-app
    pm2 delete react-app
fi