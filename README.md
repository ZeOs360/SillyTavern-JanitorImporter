# SillyTavern JanitorAI Importer Plugin

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/ZeOs360/SillyTavern-JanitorImporter/releases)

A powerful SillyTavern plugin that enables importing characters directly from JanitorAI.  
It includes a native core patch to seamlessly bypass JanitorAI's **Cloudflare Bot Fight Mode**.

---

## 🌟 Features

- **Direct API Import**: Automatically imports characters from JanitorAI's API.
- **Native Cloudflare Bypass**: Integrates directly into SillyTavern’s core.  
  When blocked (403/502), it provides a user-friendly browser-based workaround.
- **Automatic Avatar Import**: Downloads and embeds character avatars automatically.
- **1-Click Bookmarklet**: Push character data securely back to SillyTavern via browser console.
- **Automated Installation**: Scripts handle copying files and patching the core automatically.

---

## 📋 Why This Plugin Exists

SillyTavern maintainers generally avoid maintaining Cloudflare bypasses in the main app.  
This plugin provides that functionality as a **standalone extension**, safely patching the core importer so you never lose access to JanitorAI characters.

---

## 🚀 Quick Installation

### 🪟 Windows (PowerShell)

1. Download and extract this repository (or clone it).
2. Open PowerShell (Administrator if SillyTavern is in a protected folder).
3. Run the installer:

```powershell
cd path\to\SillyTavern-JanitorImporter
.\install.ps1 "C:\path\to\your\SillyTavern"
```

### ⚠️ If you get an Execution Policy error, run:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
```

## 🐧 Linux & Mac
```bash
cd path/to/SillyTavern-JanitorImporter
chmod +x install.sh
./install.sh /path/to/your/SillyTavern
```

## ⚙️ Post-Installation Steps
1. Enable server plugins in config.yaml:
```yaml
enableServerPlugins: true
```
2. Restart SillyTavern completely (close terminal and relaunch).
3. In SillyTavern UI, click Import Character (URL) and paste:
```
https://janitorai.com/characters/[uuid]
```

## 🎯 How It Works

### Direct Import Flow
```
User pastes URL → Core tries API → Success → Character imported! 🎉
```

### Cloudflare Bypass Flow (Native Patch)
```
User pastes URL → Core tries API → 403/502 (blocked)
    → Native patch intercepts failure
    → UI shows modal with instructions
    → User opens character page in browser
    → User runs bookmarklet in console
    → Character data downloads as JSON (with avatar)
    → User drops JSON into SillyTavern
    → Character imported! 🎉
```

## 📁 Repository Structure

```
SillyTavern-JanitorImporter/
├── install.ps1                    # Windows automated installer
├── install.sh                     # Linux/Mac automated installer
├── janitor-native-bypass.patch    # Core Git patch for SillyTavern
├── push-to-github.ps1             # Helper script for publishing
├── README.md                      # Project documentation
│
├── server-plugin/                 # Backend plugin (goes in plugins/janitor-importer/)
│   ├── index.js                   # Main plugin logic & API endpoints
│   ├── package.json               # NPM package metadata
│   ├── CHANGELOG.md               # Version history
│   ├── LICENSE                    # License file
│   ├── install.ps1                # Windows installer (plugin only)
│   ├── install.sh                 # Linux/Mac installer (plugin only)
│   └── .gitignore                 # Git ignore rules
│
└── client-extension/              # Frontend extension (goes in public/scripts/extensions/)
├── index.js                   # Frontend logic and UI triggers
├── manifest.json              # Extension metadata
├── style.css                  # Custom styling for bypass modal
└── janitorCloudflareBypass.html # Modal UI template
```

## 🐛 Troubleshooting

Patch could not be applied automatically  
→ Your SillyTavern core files may be modified or outdated.
Run:
```bash
git restore .
```
(⚠️ Warning: resets local changes) and reinstall.

Plugin Not Loading  
→ Ensure enableServerPlugins: true in config.yaml.
Restart the server console (not just browser refresh).

Bookmarklet Doesn’t Work  
→ Make sure you are on:
```
https://janitorai.com/characters/[uuid]
```
→ Check browser console (F12) for errors.
→ JanitorAI may have updated their DOM structure.

## 🤝 Contributing
Bug fixes for DOM/website changes

UI/UX improvements for bypass modal

Additional import sources

Documentation & translations

Pull Requests are welcome!

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