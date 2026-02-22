# SillyTavern JanitorAI Importer Plugin

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/ZeOs360/SillyTavern-JanitorImporter/releases)

A SillyTavern plugin that enables importing characters from JanitorAI with automatic Cloudflare bypass support.

## 🌟 Features

- **Direct API Import**: Automatically attempts to import characters from JanitorAI's API
- **Cloudflare Bypass**: When API is blocked, provides a user-friendly browser-based workaround
- **Automatic Avatar Import**: Downloads and embeds character avatars automatically
- **Drag & Drop Support**: Easy import of downloaded character JSON files
- **Seamless Integration**: Works naturally with SillyTavern's character import system

## 📋 Why This Plugin Exists

The SillyTavern core maintainers don't want to maintain Cloudflare bypass/reverse engineering methods in the main application. This plugin provides that functionality as a standalone, optional extension that users can choose to install.

## 🚀 Quick Installation

### Automated Installation (Recommended)

**Windows (PowerShell):**
```powershell
# Download and extract this repository first, then:
cd path\to\SillyTavern-JanitorImporter
.\server-plugin\install.ps1 "C:\path\to\your\SillyTavern"
```

**Linux/Mac:**
```bash
# Download and extract this repository first, then:
cd path/to/SillyTavern-JanitorImporter
chmod +x server-plugin/install.sh
./server-plugin/install.sh /path/to/your/SillyTavern
```

### Manual Installation

See [INSTALL.md](server-plugin/INSTALL.md) for detailed manual installation instructions.

## 📖 Usage

1. **Enable Server Plugins** in your SillyTavern `config.yaml`:
   ```yaml
   enableServerPlugins: true
   ```

2. **Restart SillyTavern**

3. **Import a JanitorAI Character**:
   - Go to Character Management
   - Click "Import from URL"
   - Paste a JanitorAI character URL: `https://janitorai.com/characters/[uuid]`

4. **If Cloudflare Blocks the Import**:
   - A modal will appear with step-by-step instructions
   - Run the provided code in your browser console
   - Import the downloaded JSON file

## 🎯 How It Works

### Direct Import Flow

```
User pastes URL → Plugin tries API → Success → Character imported! 🎉
```

### Cloudflare Bypass Flow

```
User pastes URL → Plugin tries API → 403 (Cloudflare blocks)
    → Plugin shows modal with instructions
    → User opens character page in browser
    → User runs bookmarklet in console
    → Character data downloads as JSON (with avatar)
    → User imports JSON file
    → Character imported! 🎉
```

The bookmarklet extracts character data directly from the webpage's JavaScript, bypassing Cloudflare's bot protection.

## 📁 Repository Structure

```
SillyTavern-JanitorImporter/
├── server-plugin/          # Backend plugin (goes in SillyTavern/plugins/)
│   ├── index.js           # Main plugin logic and API endpoints
│   ├── package.json       # NPM package metadata
│   ├── install.ps1        # Windows installer
│   ├── install.sh         # Linux/Mac installer
│   ├── README.md          # Detailed documentation
│   ├── INSTALL.md         # Installation guide
│   ├── CHANGELOG.md       # Version history
│   └── avatar-base64-support.patch  # Optional core patch
│
├── client-extension/      # Frontend extension (goes in SillyTavern/public/scripts/extensions/)
│   ├── index.js           # Frontend logic and UI
│   ├── manifest.json      # Extension metadata
│   ├── style.css          # Modal styling
│   └── janitorCloudflareBypass.html  # Bypass instructions template
│
└── README.md              # This file
```

## 🔧 Technical Details

### Server Plugin

- **Language**: JavaScript (ES Module)
- **Framework**: Express.js
- **API Endpoints**:
  - `POST /api/plugins/janitor-importer/import` - Import character by UUID
  - `GET /api/plugins/janitor-importer/bookmarklet` - Get bookmarklet code

### Client Extension

- **Language**: JavaScript (ES Module)
- **Dependencies**: SillyTavern extensions API
- **Features**: URL interception, modal display, drag-drop support

## 🛠️ Development

### Testing Locally

```bash
# In your SillyTavern directory
node server.js

# Check console for:
# [JanitorImporter] Plugin initialized with API routes
# [JanitorImporter] Extension initialized
```

### Updating the Bookmarklet

If JanitorAI changes their website structure, update the bookmarklet in [`server-plugin/index.js`](server-plugin/index.js) in the `getJanitorBookmarkletCode()` function.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Areas for Contribution

- Bug fixes for website structure changes
- UI/UX improvements for the bypass modal
- Additional import sources
- Documentation improvements
- Translations

## 📝 Changelog

See [CHANGELOG.md](server-plugin/CHANGELOG.md) for version history.

## 🐛 Troubleshooting

### Plugin Not Loading
- Ensure `enableServerPlugins: true` in `config.yaml`
- Check server console for error messages
- Verify files are in correct directories

### Import Fails with 403
- This is expected when Cloudflare blocks the request
- Follow the bypass instructions in the modal
- Make sure you're on the character page, not the chat page

### Bookmarklet Doesn't Work
- Ensure you're on `https://janitorai.com/characters/[uuid]`
- Try refreshing the page and running again
- Check browser console for error messages
- JanitorAI may have updated their website - please open an issue

## 📄 License

MIT License - see [LICENSE](server-plugin/LICENSE) file for details

## 🙏 Credits

- **Author**: [@ZeOs360](https://github.com/ZeOs360)
- **SillyTavern**: [SillyTavern/SillyTavern](https://github.com/SillyTavern/SillyTavern)

## ⚠️ Disclaimer

This plugin is not affiliated with or endorsed by JanitorAI or SillyTavern. It is a community-created tool to help users import their characters. Use responsibly and respect the terms of service of all platforms involved.

## 🔗 Links

- [SillyTavern Official Repository](https://github.com/SillyTavern/SillyTavern)
- [Report Issues](https://github.com/ZeOs360/SillyTavern-JanitorImporter/issues)
- [Releases](https://github.com/ZeOs360/SillyTavern-JanitorImporter/releases)
