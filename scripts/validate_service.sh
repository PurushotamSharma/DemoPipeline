#!/bin/bash
# Log file for debugging
exec 1>/var/log/aws/codedeploy-agent/validate-service.log 2>&1

echo "Starting service validation..."

# Wait for the service to be up
max_retries=30
counter=0
while [ $counter -lt $max_retries ]; do
    if curl -s http://localhost:80 > /dev/null; then
        echo "Service is up and running!"
        exit 0
    fi
    echo "Service not ready yet... waiting"
    sleep 10
    counter=$((counter + 1))
done

echo "Service failed to start properly"
exit 1