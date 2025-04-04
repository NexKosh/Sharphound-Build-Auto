# SharpHound Offline Build Environment

This project provides a **Docker-based offline build environment** for the [SharpHound](https://github.com/BloodHoundAD/SharpHound) project and its shared library `SharpHoundCommon`. It is designed for **air-gapped or restricted environments** where internet access is not available during build time.

---

## 📁 Directory Structure

```
.
├── BuildBinary/           # Output folder for built binaries
├── entrypoint.sh          # Script that runs inside the Docker container to perform the build
├── OfflineImageDockerfile # Dockerfile to create the offline-capable build image
├── SharpHound/            # Main SharpHound project
└── SharpHoundCommon/      # Shared library used by SharpHound
```

---

## 🐳 Docker Image Build

Before running builds offline, you'll need to build the Docker image and restore dependencies.

```bash
docker build -t shc-offline-build --no-cache --network=host --file OfflineImageDockerfile .
```

> The `--network=host` option allows NuGet packages to be downloaded during image creation. After building the image, it can be used offline.

---

## ⚙️ Build Usage

You can build the project using the `buildexe.sh` script:

```bash
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
```

### Arguments (passed to `entrypoint.sh`):

- `--common-dir`: Path to `SharpHoundCommon` project (inside container)
- `--sharp-dir`: Path to `SharpHound` project (inside container)
- `--output-dir`: Where to copy the built binaries
- `--config`: Build configuration (e.g., `Debug` or `Release`)

---

## 📦 Output

After the build completes, the compiled binaries will be available in the `BuildBinary/` directory on the host machine.

---

## 📝 Notes

- Make sure `entrypoint.sh` is executable and contains your custom build logic using `dotnet build`.
- NuGet packages are pre-restored into `/nuget-packages` during the Docker image build, allowing offline builds later.
