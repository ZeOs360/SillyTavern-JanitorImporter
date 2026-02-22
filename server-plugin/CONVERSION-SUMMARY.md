# Conversion Summary: JanitorAI Cloudflare Bypass → SillyTavern Extension

## Overview

Your JanitorAI Cloudflare bypass feature has been successfully converted from a core SillyTavern modification into a **standalone plugin/extension**. This allows users to install it independently without requiring maintainer approval.

## What Was Created

### 📁 File Structure

```
plugins/janitor-importer/                      ← Server Plugin
├── index.js                                   - Main server plugin code
├── package.json                               - npm package metadata
├── README.md                                  - Full documentation
├── INSTALL.md                                 - Quick installation guide
├── CHANGELOG.md                               - Version history
├── LICENSE                                    - MIT license
├── .gitignore                                 - Git ignore rules
├── avatar-base64-support.patch               - Optional core patch
├── install.ps1                                - Windows installer
└── install.sh                                 - Linux/Mac installer

public/scripts/extensions/janitor-importer/   ← Client Extension
├── index.js                                   - Client-side logic
├── manifest.json                              - Extension metadata
├── style.css                                  - UI styling
└── janitorCloudflareBypass.html              - Modal template
```

### 🔧 Components

#### Server Plugin (`plugins/janitor-importer/`)

**Purpose**: Handles backend API requests and Cloudflare bypass logic

**API Endpoints**:
- `POST /api/plugins/janitor-importer/import` - Import character by UUID
- `GET /api/plugins/janitor-importer/bookmarklet` - Get bookmarklet code

**Key Features**:
- Downloads characters from JanitorAI API
- Detects Cloudflare 403 blocks
- Returns bookmarklet code when blocked
- Full error handling and logging

#### Client Extension (`public/scripts/extensions/janitor-importer/`)

**Purpose**: Provides UI and integrates with SillyTavern's import system

**Key Features**:
- Intercepts JanitorAI character imports
- Shows Cloudflare bypass modal when blocked
- Provides copy-to-clipboard for bookmarklet
- Drag & drop support for downloaded files
- Seamless integration with existing UI

#### Bookmarklet

**Purpose**: Extracts character data directly from JanitorAI web pages

**Process**:
1. Parses character data from page DOM
2. Downloads avatar image
3. Converts to Tavern V2 format
4. Embeds avatar as base64
5. Downloads complete JSON file

### 🔄 Changes from Original Implementation

| Original (Core Feature) | New (Plugin/Extension) |
|------------------------|------------------------|
| Modified `src/endpoints/content-manager.js` | Standalone plugin with own API routes |
| Modified `public/scripts/utils.js` | Extension intercepts imports |
| Required core approval | Independent distribution |
| Hard to maintain/update | Easy to update independently |
| Template in core templates | Extension has own template |

## Installation Methods

### Method 1: Automated Installer (Easiest)

**Windows**:
```powershell
.\install.ps1 "C:\path\to\SillyTavern"
```

**Linux/Mac**:
```bash
chmod +x install.sh
./install.sh /path/to/SillyTavern
```

### Method 2: Manual Installation

1. Copy `plugins/janitor-importer` to `SillyTavern/plugins/`
2. Copy `public/scripts/extensions/janitor-importer` to `SillyTavern/public/scripts/extensions/`
3. Enable server plugins in `config.yaml`: `enableServerPlugins: true`
4. Optionally apply avatar patch: `git apply plugins/janitor-importer/avatar-base64-support.patch`
5. Restart SillyTavern

## Publishing Options

### Option 1: Separate GitHub Repository (Recommended)

Create a new repo: `sillytavern-janitor-importer`

**Structure**:
```
sillytavern-janitor-importer/
├── README.md                  ← Main documentation
├── LICENSE
├── CHANGELOG.md
├── server-plugin/             ← Server plugin files
│   ├── index.js
│   └── package.json
├── client-extension/          ← Client extension files
│   ├── index.js
│   ├── manifest.json
│   ├── style.css
│   └── janitorCloudflareBypass.html
├── patches/
│   └── avatar-base64-support.patch
└── scripts/
    ├── install.ps1
    └── install.sh
```

**Advantages**:
- Users can clone/download directly
- Easy to track issues and PRs
- Can use GitHub releases for versioning
- Clean separation from SillyTavern fork

### Option 2: Distribute as ZIP

Create a release ZIP with the exact folder structure needed:

```
janitor-importer-v1.0.0.zip
├── plugins/
│   └── janitor-importer/
└── public/
    └── scripts/
        └── extensions/
            └── janitor-importer/
```

Users extract directly into their SillyTavern folder.

### Option 3: Distribution via Package Manager (Future)

If SillyTavern adds a plugin marketplace, you can publish there.

## How to Use (End User Perspective)

### Installation
1. Download/clone the plugin
2. Run installer or manually copy files
3. Enable server plugins in config
4. Restart SillyTavern

### Usage
1. Go to Character Management
2. Click "Import from URL"
3. Paste JanitorAI character URL
4. If Cloudflare blocks:
   - Follow modal instructions
   - Run bookmarklet in browser
   - Import downloaded JSON

## Next Steps for Distribution

### 1. Create GitHub Repository

```bash
cd /path/to/new/repo
git init
# Copy plugin files
# Structure as shown in Option 1
git add .
git commit -m "Initial release v1.0.0"
git remote add origin https://github.com/YourUsername/sillytavern-janitor-importer.git
git push -u origin main
```

### 2. Create Release

1. Go to GitHub → Releases → Create new release
2. Tag: `v1.0.0`
3. Title: `JanitorAI Importer v1.0.0 - Initial Release`
4. Description: Copy from CHANGELOG.md
5. Attach ZIP file with installation-ready structure
6. Publish release

### 3. Announce

- Post on SillyTavern Discord (if allowed)
- Reddit: r/SillyTavern
- Create a wiki/documentation site
- Submit to community extension lists

### 4. Maintenance

**When JanitorAI changes their site**:
1. Update bookmarklet in `server-plugin/index.js`
2. Test thoroughly
3. Increment version in `package.json` and `manifest.json`
4. Update CHANGELOG.md
5. Create new release

## Benefits of This Approach

✅ **Independence**: No need for maintainer approval  
✅ **Flexibility**: Update whenever needed  
✅ **Community**: Users who need it can install it  
✅ **Maintenance**: You control the update cycle  
✅ **Safety**: Isolated from core SillyTavern changes  
✅ **Legal**: Clear that it's a third-party extension  

## Support & Troubleshooting

Users should:
1. Check README.md for common issues
2. Check server console for plugin errors
3. Check browser console for extension errors
4. Report issues on your GitHub repo

## Legal Considerations

⚠️ **Important**: The maintainer rejected this because they don't want to maintain Cloudflare bypass methods. Make sure your distribution:

- Clearly states it's a **third-party extension**
- Not officially supported by SillyTavern team
- Users install at their own risk
- Complies with JanitorAI's Terms of Service
- Doesn't violate Cloudflare's policies

## Credits

- Original implementation: @ZeOs360
- Converted to standalone plugin: 2025-02-22
- License: MIT

---

**You're all set!** The plugin is complete and ready to be distributed. Choose your publishing method and share it with the community. 🚀
