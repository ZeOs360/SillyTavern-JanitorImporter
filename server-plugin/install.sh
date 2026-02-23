#!/bin/bash
# Installation script for JanitorAI Importer Plugin
# Usage: ./install.sh /path/to/SillyTavern

set -e

SILLYTAVERN_PATH="$1"

echo -e "\033[36mJanitorAI Importer Plugin Installer\033[0m"
echo -e "\033[36m===================================\033[0m"
echo ""

# Validate arguments
if [ -z "$SILLYTAVERN_PATH" ]; then
    echo -e "\033[31mError: Please provide SillyTavern path\033[0m"
    echo "Usage: ./install.sh /path/to/SillyTavern"
    exit 1
fi

# Validate SillyTavern path
if [ ! -d "$SILLYTAVERN_PATH" ]; then
    echo -e "\033[31mError: SillyTavern directory not found: $SILLYTAVERN_PATH\033[0m"
    exit 1
fi

if [ ! -f "$SILLYTAVERN_PATH/server.js" ]; then
    echo -e "\033[31mError: Not a valid SillyTavern directory (server.js not found)\033[0m"
    exit 1
fi

echo -e "\033[32mInstalling to: $SILLYTAVERN_PATH\033[0m"
echo ""

# Create directories if they don't exist
PLUGIN_DIR="$SILLYTAVERN_PATH/plugins"
EXTENSION_DIR="$SILLYTAVERN_PATH/public/scripts/extensions"

mkdir -p "$PLUGIN_DIR"
mkdir -p "$EXTENSION_DIR"

# Set base script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Copy server plugin
echo -e "\033[33m[1/4] Installing server plugin...\033[0m"
DEST_PLUGIN="$PLUGIN_DIR/janitor-importer"

if [ -d "$DEST_PLUGIN" ]; then
    echo "  Removing existing plugin..."
    rm -rf "$DEST_PLUGIN"
fi

mkdir -p "$DEST_PLUGIN"

# Find server-plugin directory
SOURCE_PLUGIN="$SCRIPT_DIR/server-plugin"
if [ ! -d "$SOURCE_PLUGIN" ]; then
    SOURCE_PLUGIN="$SCRIPT_DIR"
fi

# Copy contents safely
cp -r "$SOURCE_PLUGIN"/*.js "$SOURCE_PLUGIN"/*.json "$DEST_PLUGIN/" 2>/dev/null || true
echo -e "\033[32m  ✓ Server plugin installed\033[0m"

# Copy client extension
echo -e "\033[33m[2/4] Installing client extension...\033[0m"
SOURCE_EXTENSION="$SCRIPT_DIR/../client-extension"

if [ ! -d "$SOURCE_EXTENSION" ]; then
    SOURCE_EXTENSION="$SCRIPT_DIR/client-extension"
fi

DEST_EXTENSION="$EXTENSION_DIR/janitor-importer"

if [ -d "$SOURCE_EXTENSION" ]; then
    if [ -d "$DEST_EXTENSION" ]; then
        echo "  Removing existing extension..."
        rm -rf "$DEST_EXTENSION"
    fi
    cp -r "$SOURCE_EXTENSION" "$DEST_EXTENSION"
    echo -e "\033[32m  ✓ Client extension installed\033[0m"
else
    echo -e "\033[33m  ⚠ Client extension files not found - you may need to install manually\033[0m"
fi

# Check config.yaml
echo -e "\033[33m[3/4] Checking configuration...\033[0m"
CONFIG_PATH="$SILLYTAVERN_PATH/config.yaml"

if [ -f "$CONFIG_PATH" ]; then
    if grep -q "enableServerPlugins:\s*true" "$CONFIG_PATH"; then
        echo -e "\033[32m  ✓ Server plugins already enabled\033[0m"
    else
        echo -e "\033[33m  ⚠ WARNING: You need to enable server plugins in config.yaml\033[0m"
        echo -e "\033[33m    Add or change: enableServerPlugins: true\033[0m"
    fi
else
    echo -e "\033[33m  ⚠ config.yaml not found - will be created on first run\033[0m"
fi

# Apply native Cloudflare bypass patch
echo -e "\033[33m[4/4] Applying native Cloudflare bypass patch to SillyTavern core...\033[0m"

SOURCE_PATCH="$SCRIPT_DIR/../janitor-native-bypass.patch"
if [ ! -f "$SOURCE_PATCH" ]; then
    SOURCE_PATCH="$SCRIPT_DIR/janitor-native-bypass.patch"
fi

if [ -f "$SOURCE_PATCH" ]; then
    TEMP_PATCH="$SILLYTAVERN_PATH/janitor-native-bypass.patch"
    cp "$SOURCE_PATCH" "$TEMP_PATCH"
    
    pushd "$SILLYTAVERN_PATH" > /dev/null
    
    if git apply "janitor-native-bypass.patch" > /dev/null 2>&1; then
        echo -e "\033[32m  ✓ Core code successfully patched!\033[0m"
    else
        echo -e "\033[33m  ⚠ Patch could not be applied automatically. It might already be applied or there is a conflict.\033[0m"
    fi
    
    rm -f "janitor-native-bypass.patch"
    popd > /dev/null
else
    echo -e "\033[33m  ⚠ Patch file not found! Please ensure 'janitor-native-bypass.patch' is in the repository root.\033[0m"
fi

echo ""
echo -e "\033[32mInstallation complete!\033[0m"
echo ""
echo -e "\033[36mNext steps:\033[0m"
echo "1. Make sure 'enableServerPlugins: true' is set in config.yaml"
echo "2. Restart SillyTavern"
echo "3. Try importing a JanitorAI character URL"
echo ""