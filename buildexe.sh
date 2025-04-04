#!/bin/bash

# ================================
# SharpHound Offline Build Script
# ================================

# Define build parameters
IMAGE_NAME="shc-offline-build"
DOCKERFILE="OfflineImageDockerfile"
OUTPUT_DIR="./BuildBinary"
CONFIGURATION="Debug"

# Build the Docker image (restores NuGet packages)
echo "[*] Building Docker image: $IMAGE_NAME"
docker build -t "$IMAGE_NAME" \
    --no-cache \
    --network=host \
    --file "$DOCKERFILE" .

# Run the container to build the binaries
echo "[*] Running container to build SharpHound..."
docker run --rm \
    -v "$(pwd)":/source \
    -v "$OUTPUT_DIR":/BuildBinary \
    "$IMAGE_NAME" \
    --common-dir /source/SharpHoundCommon \
    --sharp-dir /source/SharpHound \
    --output-dir /BuildBinary \
    --config "$CONFIGURATION"

echo "[+] Build complete. Output located in: $OUTPUT_DIR"
