#!/bin/bash

set -e

# Change this to your actual tar.gz bundle URL
# Example: Use a GitHub release URL for a tar.gz file
BOOT_URL="https://github.com/statikfintechllc/WorkFlowRepo-Mirror/archive/refs/heads/master.tar.gz"

echo "[📦] Downloading WorkFlowRepo-Mirror Package..."
mkdir -p /tmp/workflowrepo
cd /tmp/workflowrepo

# 🔧 Dependency Check
echo "[🔍] Checking for required packages..."
if command -v apt &>/dev/null; then
    sudo apt update
    sudo apt install -y plymouth plymouth-themes grub2-common
elif command -v pacman &>/dev/null; then
    sudo pacman -Sy --noconfirm plymouth grub
elif command -v dnf &>/dev/null; then
    sudo dnf install -y plymouth grub2
else
    echo "❌ Unsupported package manager. Install dependencies manually."
    exit 1
fi

# Download and extract with fallback from wget to curl
echo "[🌐] Downloading from: $BOOT_URL"
if command -v wget &>/dev/null; then
    echo "[⬇️] Using wget to download..."
    if ! wget -q --show-progress "$BOOT_URL" -O workflowrepo.tar.gz; then
        echo "[❌] wget failed, trying curl as fallback..."
        if command -v curl &>/dev/null; then
            curl -L -o workflowrepo.tar.gz "$BOOT_URL" || {
                echo "[❌] Both wget and curl failed to download the file"
                echo "[💡] Please check the URL: $BOOT_URL"
                exit 1
            }
        else
            echo "[❌] curl not available as fallback"
            exit 1
        fi
    fi
elif command -v curl &>/dev/null; then
    echo "[⬇️] Using curl to download..."
    curl -L -o workflowrepo.tar.gz "$BOOT_URL" || {
        echo "[❌] curl failed to download the file"
        echo "[💡] Please check the URL: $BOOT_URL"
        exit 1
    }
else
    echo "[❌] Neither wget nor curl is available"
    echo "[💡] Please install wget or curl to continue"
    exit 1
fi
echo "[📦] Extracting workflowrepo.tar.gz..."
if [ ! -f workflowrepo.tar.gz ]; then
    echo "[❌] Downloaded file not found: workflowrepo.tar.gz"
    exit 1
fi

if ! tar -tzf workflowrepo.tar.gz >/dev/null 2>&1; then
    echo "[❌] Downloaded file is not a valid tar.gz archive"
    echo "[💡] The URL might not point to a valid tar.gz file or the file is corrupted"
    exit 1
fi

tar -xzf workflowrepo.tar.gz

# Find the extracted directory (robustly handle files at root level and multiple top-level dirs)
TOP_LEVELS=$(tar -tf workflowrepo.tar.gz | awk -F/ '{print $1}' | sort -u)
NUM_TOP_LEVELS=$(echo "$TOP_LEVELS" | wc -l)
if [ "$NUM_TOP_LEVELS" -eq 1 ]; then
    EXTRACTED_DIR="$TOP_LEVELS"
    if [ ! -d "$EXTRACTED_DIR" ]; then
        echo "[❌] Extracted directory not found: $EXTRACTED_DIR"
        exit 1
    fi
elif [ "$NUM_TOP_LEVELS" -gt 1 ]; then
    echo "[❌] Archive contains multiple top-level files or directories:"
    echo "$TOP_LEVELS"
    echo "[💡] Cannot determine a single extracted directory. Please check the archive structure."
    exit 1
else
    echo "[❌] Could not determine extracted directory from archive."
    exit 1
fi

echo "[📁] Found extracted directory: $EXTRACTED_DIR"
cd "$EXTRACTED_DIR"

echo "[🔧] Installing WorkFlowRepo-Mirror..."

# Navigate through the repository structure to verify it's complete
echo "[📋] Exploring downloaded repository structure..."
# We're already in the extracted directory, just check if we have the expected structure
if [ -d ".github" ]; then
    echo "[📁] Found repository root with .github directory"
else
    echo "[❌] Repository structure not found as expected"
    echo "[📁] Available directories:"
    ls -la
    exit 1
fi

echo "[📁] Repository contents:"
ls -la

if [ -d ".github/workflows" ]; then
    echo "[📁] Workflows directory:"
    ls -la .github/workflows
fi

if [ -d "docs" ]; then
    echo "[📁] Documentation directory:"
    ls -la docs
    
    if [ -d "docs/ticker-bot" ]; then
        echo "[📁] Ticker-bot directory:"
        ls -la docs/ticker-bot
    fi
    
    if [ -d "docs/graph" ]; then
        echo "[📁] Graph directory:"
        ls -la docs/graph
    fi
fi

echo "[✅] WorkFlowRepo-Mirror package structure verified successfully!"
