#!/bin/sh

set -e

# Get the target OS from the first argument, default to current OS
TARGET_OS=${1:-$(uname -s | tr '[:upper:]' '[:lower:]')}

# Automatically get the current environment's GOARCH; if not defined, use the detected system architecture
GOARCH=${GOARCH:-$(go env GOARCH)}
DOCS="true"

# Safely remove the old release directory and create a new one
echo "Preparing release directory..."
rm -rf release
mkdir -p release

# Generate Swagger documentation if DOCS is not empty
#if [ -n "${DOCS}" ]; then
#    # Check if swag is installed
#    if ! command -v swag &> /dev/null; then
#        echo "swag command not found. Please install it using:"
#        echo "go install github.com/swaggo/swag/cmd/swag@latest"
#        echo "Skipping Swagger documentation generation due to missing swag tool."
#    else
#        echo "Generating Swagger documentation..."
#        swag init -g cmd/apimain.go --output docs/api --instanceName api --exclude http/controller/admin
#        swag init -g cmd/apimain.go --output docs/admin --instanceName admin --exclude http/controller/api
#    fi
#else
#    echo "Skipping Swagger documentation generation due to DOCS is empty."
#fi

# Build based on target OS
case "$TARGET_OS" in
  "mac" | "darwin")
    echo "Building for macOS (darwin) using local Go compiler..."
    export GOOS=darwin
    export CGO_ENABLED=1
    export GOARCH=${GOARCH}
    go build -o -buildvsc=false -o release/apimain cmd/apimain.go
    ;;
  "linux")
    echo "Building for Linux using Docker..."
    # Check if Docker is running
    if ! docker info > /dev/null 2>&1; then
      echo "Docker does not seem to be running, please start it and try again."
      exit 1
    fi
    
    # Build the docker image
    echo "Step 1: Building Docker image..."
    docker-compose build
    
    # Create a temporary container
    echo "Step 2: Creating a temporary container..."
    CONTAINER_ID=$(docker create rustdesk-api-server-image)
    
    # Copy the binary from the container
    echo "Step 3: Copying binary from container..."
    docker cp $CONTAINER_ID:/app/apimain ./release/apimain
    
    # Remove the temporary container
    echo "Step 4: Cleaning up temporary container..."
    docker rm $CONTAINER_ID
    
    echo "Successfully extracted Linux binary to ./release/apimain"
    ;;
  *)
    echo "Unsupported OS: $TARGET_OS"
    exit 1
    ;;
esac

# Copy resource files to the release directory
echo "Copying assets..."
cp -ar resources release/
cp -ar docs release/
cp -ar conf release/

# Create necessary directory structures
mkdir -p release/data
mkdir -p release/runtime

echo "Build and setup completed successfully for $TARGET_OS."
