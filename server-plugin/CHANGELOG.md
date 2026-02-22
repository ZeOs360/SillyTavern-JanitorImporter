# Changelog

All notable changes to the JanitorAI Importer plugin will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-02-22

### Added
- Initial release of JanitorAI Character Importer plugin
- Server plugin for handling JanitorAI API imports (`/api/plugins/janitor-importer/import`)
- Client extension with UI for Cloudflare bypass instructions
- Browser bookmarklet for extracting character data when Cloudflare blocks API access
- Automatic avatar download and embedding in character JSON
- Drag & drop support for importing downloaded character files
- Full Tavern V2 character card format support
- Installation scripts for Windows (PowerShell) and Linux/Mac (Bash)
- Avatar base64 support patch for core SillyTavern
- Comprehensive documentation and troubleshooting guide

### Features
- **Direct API Import**: Attempts to import characters directly from JanitorAI API
- **Cloudflare Bypass**: When blocked, provides step-by-step browser-based workaround
- **Avatar Handling**: Downloads avatars and embeds them as base64 in character JSON
- **Seamless Integration**: Hooks into existing SillyTavern import system
- **User-Friendly**: Clear instructions and error messages for non-technical users

### Technical Details
- Server plugin: Node.js/Express with proper error handling
- Client extension: Vanilla JS with jQuery for DOM manipulation
- Template system: Handlebars for rendering UI components
- Character format: Tavern V2 with extended metadata

## [Unreleased]

### Planned Features
- Auto-update capability for the bookmarklet if JanitorAI changes their site
- Support for bulk character imports
- Optional proxy configuration for users behind corporate firewalls
- Character search and browse functionality
- Local caching of downloaded characters

### Known Issues
- Cloudflare detection may have false positives on some network configurations
- Bookmarklet needs manual update if JanitorAI changes their website structure

## Migration from Core Feature

This plugin was originally implemented as a core feature in SillyTavern but was rejected by maintainers who don't want to maintain Cloudflare bypass methods. It has been converted to a standalone plugin to provide the functionality independently.

**Original PR**: https://github.com/SillyTavern/SillyTavern/pull/[number]
**Original Branch**: https://github.com/ZeOs360/SillyTavern/tree/feature/janitorai-cloudflare-bypass
