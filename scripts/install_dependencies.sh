#!/bin/bash

if ! command -v pm2 &> /dev/null; then
    npm install -g pm2
fi