# JanitorAI Character Importer

A SillyTavern plugin/extension that enables importing characters from JanitorAI with Cloudflare bypass support.

## Features

- **Direct API Import**: Tries to import characters directly from JanitorAI's API
- **Cloudflare Bypass**: When Cloudflare blocks the API, provides a user-friendly browser-based workaround
- **Automatic Avatar Handling**: Downloads and embeds character avatars in the import
- **Drag & Drop Support**: Import downloaded character JSON files via drag & drop
- **Seamless Integration**: Works with SillyTavern's existing character import system

## Why This Plugin?

The SillyTavern maintainers don't want to maintain Cloudflare bypass/reverse engineering methods in the core application. This plugin provides that functionality as a standalone, optional extension that users can install if they need it.

## Installation

### Prerequisites

1. SillyTavern must have **server plugins enabled** in your `config.yaml`:
   ```yaml
   enableServerPlugins: true
   ```

2. **Optional but Recommended**: Apply the avatar support patch to enable automatic avatar import from the bookmarklet. Without this patch, you'll need to manually set character avatars after import.

   ```bash
   # From your SillyTavern root directory
   git apply plugins/janitor-importer/avatar-base64-support.patch
   ```

   This patch adds support for importing character avatars that are embedded as base64 data in the character JSON file.

### Installation Steps

1. **Install the Server Plugin:**
   
   Copy the `plugins/janitor-importer` folder to your SillyTavern `plugins` directory:
   ```
   SillyTavern/
   └── plugins/
       └── janitor-importer/
           ├── index.js
           └── package.json
   ```

2. **Install the Client Extension:**
   
   Copy the `public/scripts/extensions/janitor-importer` folder to your SillyTavern extensions directory:
   ```
   SillyTavern/
   └── public/
       └── scripts/
           └── extensions/
               └── janitor-importer/
                   ├── index.js
                   ├── manifest.json
                   ├── style.css
                   └── janitorCloudflareBypass.html
   ```

3. **Restart SillyTavern**

4. The extension will be automatically loaded and integrated into the character import system.

## Usage

### Method 1: Direct URL Import (Preferred)

1. Go to **Character Management** in SillyTavern
2. Click **Import from URL**
3. Paste a JanitorAI character URL:
   ```
   https://janitorai.com/characters/[uuid]
   ```
4. The plugin will attempt to import the character directly

### Method 2: Cloudflare Bypass (Fallback)

If Cloudflare blocks the direct import, the plugin will automatically show a modal with instructions:

1. **Open the Character Page**: Click the button to open the JanitorAI character page
2. **Run the Extraction Code**: 
   - Press `F12` to open Developer Tools
   - Click the Console tab
   - Copy and paste the provided code
   - Press Enter
3. **Import the Downloaded File**: 
   - Drag and drop the downloaded JSON file into the modal, OR
   - Use the standard character import to load the file

## How It Works

### Server Plugin (`plugins/janitor-importer`)

The server plugin provides API endpoints:

- `POST /api/plugins/janitor-importer/import`: Attempts to download a character from JanitorAI's API
- `GET /api/plugins/janitor-importer/bookmarklet`: Returns the extraction bookmarklet code

When Cloudflare blocks a request (HTTP 403), the plugin returns a special error response with:
- The character's UUID
- The character page URL
- A browser-executable bookmarklet for manual extraction

### Client Extension (`public/scripts/extensions/janitor-importer`)

The client extension:

1. Intercepts JanitorAI character import requests
2. Routes them through the plugin API
3. Handles Cloudflare block errors by displaying a user-friendly modal
4. Provides drag-and-drop support for manually extracted character files
5. Integrates with SillyTavern's existing import pipeline

### The Bookmarklet

The bookmarklet is a JavaScript snippet that:
1. Extracts character data from the JanitorAI page DOM
2. Downloads the character avatar image
3. Converts everything to a Tavern V2 character card format
4. Includes the avatar as a base64-encoded image in the JSON
5. Triggers a download of the complete character file

## Character Format

Characters are exported in **Tavern V2** format with additional metadata:

```json
{
  "spec": "chara_card_v2",
  "spec_version": "2.0",
  "data": {
    "name": "Character Name",
    "description": "...",
    "personality": "...",
    "scenario": "...",
    "first_mes": "...",
    "mes_example": "...",
    "extensions": {
      "janitor_uuid": "original-uuid",
      "janitor_display_name": "Display Name",
      "avatar_url": "https://...",
      "avatar_base64": "data:image/png;base64,..."
    }
  }
}
```

The `avatar_base64` field is automatically processed during import and the avatar is extracted and saved separately.

## Troubleshooting

### Server Plugin Not Loading

- Check that `enableServerPlugins: true` is set in `config.yaml`
- Check the server console for plugin loading errors
- Verify the plugin files are in the correct directory

### Extension Not Working

- Check browser console for JavaScript errors
- Verify the extension files are in the correct directory
- Make sure the server plugin is loaded first

### Bookmarklet Fails

- Make sure you're on the character page (not the chat page)
- Try refreshing the page before running the bookmarklet
- Check browser console for errors
- JanitorAI may have changed their website structure - the bookmarklet may need updating

### Import Fails with 403 Error

This is expected when Cloudflare blocks the request. Follow the Cloudflare bypass instructions shown in the modal.

## Development

### Testing the Server Plugin

```bash
# From SillyTavern root
node server.js
# Check console for: [JanitorImporter] Plugin initialized
```

### Testing the Bookmarklet

Navigate to a JanitorAI character page and run the bookmarklet code in the browser console. It should download a JSON file.

### Updating the Bookmarklet

If JanitorAI changes their website structure, you'll need to update the bookmarklet in [`plugins/janitor-importer/index.js`](plugins/janitor-importer/index.js) in the `getJanitorBookmarkletCode()` function.

## Contributing

Contributions are welcome! If JanitorAI changes their API or website structure, please submit a PR with the necessary updates.

## License

MIT

## Credits

- Original implementation by [@ZeOs360](https://github.com/ZeOs360)
- Converted to plugin format for independent distribution
