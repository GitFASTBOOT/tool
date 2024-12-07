#!/bin/bash

# Check if a directory path is provided as an argument
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 path/to/rom/dump"
    exit 1
fi

# Assign the provided argument to a variable
ROM_DUMP_DIR="$1"

# Define destination directories
DEST_SYSTEM_LIB64="./system/lib64"
DEST_SYSTEM_LIB64_HW="./system/lib64/hw"
DEST_SYSTEM_EXT_LIB64="./system_ext/lib64"
DEST_SYSTEM_EXT_LIB64_HW="./system_ext/lib64/hw"
DEST_VENDOR_LIB64="./vendor/lib64"
DEST_VENDOR_LIB64_HW="./vendor/lib64/hw"
DEST_VENDOR_BIN_HW="./vendor/bin/hw"
DEST_VENDOR_APP_MCRegistry="./vendor/app/mcRegistry"
DEST_VENDOR_THH_TA="./vendor/thh/ta"

# Create destination directories if they don't exist
mkdir -p "$DEST_SYSTEM_LIB64"
mkdir -p "$DEST_SYSTEM_LIB64_HW"
mkdir -p "$DEST_SYSTEM_EXT_LIB64"
mkdir -p "$DEST_SYSTEM_EXT_LIB64_HW"
mkdir -p "$DEST_VENDOR_LIB64"
mkdir -p "$DEST_VENDOR_LIB64_HW"
mkdir -p "$DEST_VENDOR_BIN_HW"
mkdir -p "$DEST_VENDOR_APP_MCRegistry"
mkdir -p "$DEST_VENDOR_THH_TA"

# Debugging - log the ROM dump directory
echo "Using ROM dump directory: $ROM_DUMP_DIR"
echo "Searching for libraries, binaries, mcRegistry, and thh/ta files in this path..."

# Search for "keymaster", "gatekeeper", or "keymint" related .so files
find "$ROM_DUMP_DIR" -type f \( -name "*keymaster*.so" -o -name "*gatekeeper*.so" -o -name "*keymint*.so" \) | while read -r file; do
    echo "Found: $file"
    
    # Copy logic for system, system_ext, vendor directories
    if [[ "$file" == *"/system_ext/lib64/hw/"* ]]; then
        echo "Copying to system_ext/lib64/hw/"
        cp -v "$file" "$DEST_SYSTEM_EXT_LIB64_HW/"
    elif [[ "$file" == *"/system_ext/lib64/"* ]]; then
        echo "Copying to system_ext/lib64/"
        cp -v "$file" "$DEST_SYSTEM_EXT_LIB64/"
    elif [[ "$file" == *"/system/lib64/hw/"* ]]; then
        echo "Copying to system/lib64/hw/"
        cp -v "$file" "$DEST_SYSTEM_LIB64_HW/"
    elif [[ "$file" == *"/system/lib64/"* ]]; then
        echo "Copying to system/lib64/"
        cp -v "$file" "$DEST_SYSTEM_LIB64/"
    elif [[ "$file" == *"/vendor/lib64/hw/"* ]]; then
        echo "Copying to vendor/lib64/hw/"
        cp -v "$file" "$DEST_VENDOR_LIB64_HW/"
    elif [[ "$file" == *"/vendor/lib64/"* ]]; then
        echo "Copying to vendor/lib64/"
        cp -v "$file" "$DEST_VENDOR_LIB64/"
    else
        echo "Unknown or unhandled path for: $file - skipping."
    fi
done

# Search for binaries in vendor/bin/hw/ related to keymaster, gatekeeper, or keymint
find "$ROM_DUMP_DIR/vendor/bin/hw" -type f \( -name "*keymaster*" -o -name "*gatekeeper*" -o -name "*keymint*" \) | while read -r bin_file; do
    echo "Found binary: $bin_file"
    
    # Copy logic for vendor/bin/hw
    if [[ "$bin_file" == *"/vendor/bin/hw/"* ]]; then
        echo "Copying to vendor/bin/hw/"
        cp -v "$bin_file" "$DEST_VENDOR_BIN_HW/"
    else
        echo "Unknown or unhandled binary path for: $bin_file - skipping."
    fi
done

# Extract all files in vendor/app/mcRegistry if it exists
if [ -d "$ROM_DUMP_DIR/vendor/app/mcRegistry" ]; then
    echo "Found vendor/app/mcRegistry directory. Extracting files..."
    cp -r -v "$ROM_DUMP_DIR/vendor/app/mcRegistry/." "$DEST_VENDOR_APP_MCRegistry/"
else
    echo "No vendor/app/mcRegistry directory found. Skipping."
fi

# Extract all files in vendor/thh/ta if it exists
if [ -d "$ROM_DUMP_DIR/vendor/thh/ta" ]; then
    echo "Found vendor/thh/ta directory. Extracting files..."
    cp -r -v "$ROM_DUMP_DIR/vendor/thh/ta/." "$DEST_VENDOR_THH_TA/"
else
    echo "No vendor/thh/ta directory found. Skipping."
fi

# Function to delete empty directories
delete_empty_dirs() {
    local dir="$1"
    find "$dir" -type d -empty -delete
}

# Cleanup: Remove any empty directories
echo "Cleaning up empty directories..."
delete_empty_dirs "$DEST_SYSTEM_LIB64"
delete_empty_dirs "$DEST_SYSTEM_LIB64_HW"
delete_empty_dirs "$DEST_SYSTEM_EXT_LIB64"
delete_empty_dirs "$DEST_SYSTEM_EXT_LIB64_HW"
delete_empty_dirs "$DEST_VENDOR_LIB64"
delete_empty_dirs "$DEST_VENDOR_LIB64_HW"
delete_empty_dirs "$DEST_VENDOR_BIN_HW"
delete_empty_dirs "$DEST_VENDOR_APP_MCRegistry"
delete_empty_dirs "$DEST_VENDOR_THH_TA"

# Special cleanup for system_ext if it's empty
if [ -d "./system_ext" ]; then
    echo "Checking if system_ext is empty..."
    if [ -z "$(ls -A ./system_ext)" ]; then
        echo "system_ext is empty. Deleting it..."
        rm -rf "./system_ext"
        echo "Deleted empty system_ext directory."
    else
        echo "system_ext is not empty. Skipping deletion."
    fi
fi

# Final Debugging Log
echo "Extraction and cleanup completed."
