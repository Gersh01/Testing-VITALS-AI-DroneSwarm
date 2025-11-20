#!/bin/bash

# To check if a Docker container exists, you can use
# the docker ps command. However, it only shows the running containers.

# If you want to check if a container with a specific name exists,
# regardless of whether it is running or not, you can use
# the docker inspect command. It will return information about the container,
# and if it does not exist, it will return an error.

# In this script, replace your_image_name with the actual name of the Docker
# image you want to run. The script checks if the container exists and is running.
# If it exists but is not running, it starts the container. If it does not exist,
# it creates and starts the container.

# Here is an example script in Bash:

container_name="vitals-container"

# Check if the container exists
if docker inspect "$container_name" > /dev/null 2>&1; then
    echo "The container $container_name exists."
    
    # Check if the container is running
    if $(docker inspect -f '{{.State.Status}}' "$container_name" | grep -q "running"); then
        echo "The container $container_name is running."
    else
        echo "The container $container_name is not running."
        
        # Start the container if it is not running
        docker start "$container_name"
    fi
else
    echo "The container $container_name does not exist."
    
    # Create and start the container if it does not exist
    docker run -d --name "$container_name" your_image_name
fi

