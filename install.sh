#!/bin/bash
set -e

SILLYTAVERN_PATH="$1"

echo -e "\033[36mJanitorAI Native Bypass Installer\033[0m"
echo -e "\033[36m=================================\033[0m"
echo ""

if [ -z "$SILLYTAVERN_PATH" ]; then
    echo -e "\033[31mError: Please provide SillyTavern path\033[0m"
    echo "Usage: ./install.sh /path/to/SillyTavern"
    exit 1
fi

if [ ! -d "$SILLYTAVERN_PATH" ] || [ ! -f "$SILLYTAVERN_PATH/server.js" ]; then
    echo -e "\033[31mError: Not a valid SillyTavern directory (server.js not found)\033[0m"
    exit 1
fi

echo -e "\033[33mApplying native patch to SillyTavern core...\033[0m"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_PATCH="$SCRIPT_DIR/janitor-native-bypass.patch"

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
    echo -e "\033[31m  ⚠ Patch file not found! Please ensure 'janitor-native-bypass.patch' is in the repository root.\033[0m"
fi

echo ""
echo -e "\033[32mInstallation complete! Please restart your SillyTavern server.\033[0m"
echo ""