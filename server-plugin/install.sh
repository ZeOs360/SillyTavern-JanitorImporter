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

# Copy server plugin
echo -e "\033[33m[1/3] Installing server plugin...\033[0m"
DEST_PLUGIN="$PLUGIN_DIR/janitor-importer"

if [ -d "$DEST_PLUGIN" ]; then
    echo "  Removing existing plugin..."
    rm -rf "$DEST_PLUGIN"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$DEST_PLUGIN"
cp -r "$SCRIPT_DIR"/*.js "$SCRIPT_DIR"/*.json "$SCRIPT_DIR"/*.md "$SCRIPT_DIR"/*.patch "$DEST_PLUGIN/" 2>/dev/null || true
echo -e "\033[32m  ✓ Server plugin installed\033[0m"

# Copy client extension
echo -e "\033[33m[2/3] Installing client extension...\033[0m"
SOURCE_EXTENSION="$SCRIPT_DIR/../public/scripts/extensions/janitor-importer"

if [ ! -d "$SOURCE_EXTENSION" ]; then
    SOURCE_EXTENSION="$SCRIPT_DIR/public/scripts/extensions/janitor-importer"
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
echo -e "\033[33m[3/3] Checking configuration...\033[0m"
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

echo ""
echo -e "\033[32mInstallation complete!\033[0m"
echo ""
echo -e "\033[36mNext steps:\033[0m"
echo "1. Make sure 'enableServerPlugins: true' is set in config.yaml"
echo "2. (Optional) Apply the avatar patch: git apply plugins/janitor-importer/avatar-base64-support.patch"
echo "3. Restart SillyTavern"
echo "4. Try importing a JanitorAI character URL"
echo ""
