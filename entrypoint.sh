#!/bin/bash

# Default parameters
COMMON_DIR="/build/SharpHoundCommon"
SHARP_DIR="/build/SharpHound"
OUTPUT_DIR="/BuildBinary"
CONFIG="Debug"

# Parse command-line arguments
while [ "$#" -gt 0 ]; do
    case "$1" in
        --common-dir) COMMON_DIR="$2"; shift 2 ;;
        --sharp-dir) SHARP_DIR="$2"; shift 2 ;;
        --output-dir) OUTPUT_DIR="$2"; shift 2 ;;
        --config) CONFIG="$2"; shift 2 ;;
        *) echo "Unknown argument: $1"; exit 1 ;;
    esac
done

# Build SharpHoundCommonLib.dll
if [ -d "$COMMON_DIR" ]; then
    cd "$COMMON_DIR" || { echo "Failed to change to $COMMON_DIR"; exit 1; }
    echo "Current directory: $(/bin/pwd)"
    echo "Starting build: SharpHoundCommonLib.dll"
    dotnet build --source /nuget-packages --configuration "$CONFIG" || {
        echo "Build failed: SharpHoundCommonLib.dll"
        exit 1
    }
else
    echo "Directory not found: $COMMON_DIR"
    exit 1
fi

# Check generated files
cd / || { echo "Failed to return to root directory"; exit 1; }
CommonLibDll="$COMMON_DIR/src/CommonLib/bin/$CONFIG/net472/SharpHoundCommonLib.dll"
RpcDll="$COMMON_DIR/src/CommonLib/bin/$CONFIG/net472/SharpHoundRPC.dll"
if [ -f "$CommonLibDll" ] && [ -f "$RpcDll" ]; then
    echo "Found: $CommonLibDll and $RpcDll"
else
    [ ! -f "$CommonLibDll" ] && echo "Missing: $CommonLibDll"
    [ ! -f "$RpcDll" ] && echo "Missing: $RpcDll"
    exit 1
fi

# Build SharpHound.exe
if [ -d "$SHARP_DIR" ]; then
    cd "$SHARP_DIR" || { echo "Failed to change to $SHARP_DIR"; exit 1; }
    echo "Current directory: $(/bin/pwd)"
    echo "Starting build: SharpHound.exe"
    mkdir -p "$OUTPUT_DIR" || { echo "Failed to create output directory: $OUTPUT_DIR"; exit 1; }
    dotnet build "Sharphound.csproj" --source /nuget-packages --configuration "$CONFIG" --output "$OUTPUT_DIR" || {
        echo "Build failed: SharpHound.exe"
        exit 1
    }
else
    echo "Directory not found: $SHARP_DIR"
    exit 1
fi

# Check and (optional) run SharpHound.exe
SharpHoundExe="$OUTPUT_DIR/SharpHound.exe"
if [ -f "$SharpHoundExe" ]; then
    echo "Found SharpHound.exe: $SharpHoundExe"
else
    echo "Missing: $SharpHoundExe"
    exit 1
fi

echo "Build completed. Binaries output to: $OUTPUT_DIR"
