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

Once the image is built, run the following to build SharpHound:

```bash
docker run --rm \
    -v .:/source \
    -v ./BuildBinary:/BuildBinary \
    shc-offline-build \
    --common-dir /source/SharpHoundCommon \
    --sharp-dir /source/SharpHound \
    --output-dir /BuildBinary \
    --config Debug
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
