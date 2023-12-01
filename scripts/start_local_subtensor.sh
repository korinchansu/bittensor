# Checks for local subtensor image "opentensor/subtensor"
# If not found, build it by downloading the repo and running the Dockerfile/docker-compose.yml
# If it's already built, run docker-compose down (if running) and then docker-compose up
# Do some error handling and make sure this is legit for production (you're in subtensor dir, etc)
# Potentially spawn a separate process to do this in a separate thread/shell so it's not affecting this one.
# Potentially add a flag to force a rebuild of the image and a flag for not restarting if running...

#!/bin/bash

set -e

IMAGE_NAME="opentensor/subtensor"
REPO_URL="https://github.com/opentensor/subtensor"
CLONE_DIR="$HOME/.subtensor"
CONTAINER_NAME="node-subtensor"

DOCKER_CMD="docker"
if ! docker ps &> /dev/null; then
    echo "sudo required for Docker commands"
    DOCKER_CMD="sudo docker"
fi

start_docker_compose() {
    # Check if the container is already running
    if $DOCKER_CMD ps | grep -q $CONTAINER_NAME; then
        echo "Container $CONTAINER_NAME is running. Stopping it..."
        $DOCKER_CMD-compose down
    fi

    # Start the container
    echo "Starting container $CONTAINER_NAME..."
    $DOCKER_CMD-compose up -d
}

change_or_clone_directory() {
    CURRENT_DIR=$(basename "$PWD")
    if [ "$CURRENT_DIR" != "subtensor" ]; then
        if [ -d "$CLONE_DIR" ]; then
            echo "Changing directory to $CLONE_DIR/subtensor..."
            cd "$CLONE_DIR/subtensor"
        else
            echo "Cloning repository to $CLONE_DIR..."
            git clone $REPO_URL $CLONE_DIR
            cd "$CLONE_DIR/subtensor"
        fi
    fi
}

if ! $DOCKER_CMD images -q $IMAGE_NAME &> /dev/null; then
    echo "Image $IMAGE_NAME not found. Cloning repository and building image..."
    change_or_clone_directory
    $DOCKER_CMD build . -t $IMAGE_NAME
else
    echo "Image $IMAGE_NAME already exists."
    change_or_clone_directory
fi

start_docker_compose
