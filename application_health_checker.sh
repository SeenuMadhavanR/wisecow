#!/bin/bash

URL=$1

if [[ -z "$URL" ]]; then
    echo "Usage example: application_health_checker google.com"
    exit
fi

val=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$URL")

if [[ "$val" =~ ^[2][0-9]{2}$ ]]; then
    echo "Application is UP and has $val as status code."
elif [[ "$val" =~ ^[3][0-9]{2}$ ]]; then
    echo "Application is UP but has $val as status code."
elif [[ "$val" =~ ^[45][0-9]{2}$ ]]; then
    echo "Application is DOWN and has $val as status code."
else
    echo "Application is DOWN and Domain not found."
fi