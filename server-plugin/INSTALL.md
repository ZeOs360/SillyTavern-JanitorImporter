# Quick Installation Guide

## Automatic Installation (Recommended)

### For Windows Users:

1. Download this repository
2. Open PowerShell in the plugin directory
3. Run:
   ```powershell
   .\install.ps1 "C:\path\to\your\SillyTavern"
   ```

### For Linux/Mac Users:

1. Download this repository
2. Open terminal in the plugin directory
3. Run:
   ```bash
   chmod +x install.sh
   ./install.sh /path/to/your/SillyTavern
   ```

## Manual Installation

### Step 1: Enable Server Plugins

Edit your SillyTavern `config.yaml` and set:
```yaml
enableServerPlugins: true
```

### Step 2: Copy Plugin Files

Copy these directories:

**Server Plugin:**
```
janitor-importer/plugins/janitor-importer
  → YOUR_SILLYTAVERN/plugins/janitor-importer
```

**Client Extension:**
```
janitor-importer/public/scripts/extensions/janitor-importer
  → YOUR_SILLYTAVERN/public/scripts/extensions/janitor-importer
```

### Step 3: Apply Avatar Support Patch (Optional)

From your SillyTavern root directory:
```bash
git apply plugins/janitor-importer/avatar-base64-support.patch
```

Or manually apply the changes shown in `avatar-base64-support.patch`.

### Step 4: Restart SillyTavern

## Verifying Installation

1. Check the server console for:
   ```
   [JanitorImporter] Plugin initialized with API routes:
     POST /api/plugins/janitor-importer/import
     GET  /api/plugins/janitor-importer/bookmarklet
   ```

2. Check the browser console (F12) for:
   ```
   [JanitorImporter] Extension initialized
   [JanitorImporter] Import interceptor installed
   ```

## Usage

Try importing a JanitorAI character URL:
```
https://janitorai.com/characters/[uuid]
```

If Cloudflare blocks the import, follow the instructions in the modal that appears.

## Troubleshooting

- **Plugin not loading?** Make sure `enableServerPlugins: true` is set in config.yaml
- **Extension not loading?** Check browser console for errors
- **403 errors?** This is normal - use the Cloudflare bypass instructions
