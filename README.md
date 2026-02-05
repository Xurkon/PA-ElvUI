# ElvUI for Project Ascension

[![Documentation](https://img.shields.io/badge/📖_Docs-GitHub_Pages-2ea44f?style=for-the-badge)](https://xurkon.github.io/PA-ElvUI/)
![Downloads](https://img.shields.io/github/downloads/Xurkon/PA-ElvUI/total?style=for-the-badge&label=DOWNLOADS&color=e67e22)
[![Patreon](https://img.shields.io/badge/Patreon-Support-orange?style=for-the-badge&logo=patreon)](https://patreon.com/Xurkon)
[![PayPal](https://img.shields.io/badge/PayPal-Donate-blue?style=for-the-badge&logo=paypal)](https://www.paypal.com/cgi-bin/webscr?cmd=_donations&business=kancerous@gmail.com)

**A comprehensive user interface replacement for World of Warcraft 3.3.5 (WotLK)**

[![Version](https://img.shields.io/badge/version-1.3.8-blue.svg)](https://github.com/Xurkon/PA-ElvUI)
[![WoW](https://img.shields.io/badge/WoW-3.3.5a-orange.svg)](https://project-ascension.com)

## About

ElvUI is a complete UI replacement featuring action bars, unit frames, nameplates, bags, chat, maps, tooltips, and more - all highly customizable.

**Updated for Project Ascension compatibility by Xurkon**
 
 ## ⚡ At a Glance
 - **Full UI Replacement**: Replaces all standard Blizzard interface elements.
 - **Highly Customizable**: Configure every aspect of your UI via `/ec`.
 - **Ascension Ready**: Tweaked specifically for Project Ascension 3.3.5a.
 - **Performance Focused**: Optimized for smooth gameplay.

## Version 1.3.8

### Recent Changes

- **OmniBar Compatibility** - Fixed `ElvUI_Enhanced` integration with updated OmniBar
- **Fixed Minimap Button Options** - Calendar, Mail, LFG, PvP, etc. buttons properly enable/disable
- **Improved MBF Integration** - Options correctly grey out when MBF controls buttons
- **Persistent Tree Divider** - Options panel divider remembers its position across sessions
- **ButtonFacade Support** - 30+ button skins for action bars

## Features

| Feature | Description |
|---------|-------------|
| **Action Bars** | Fully customizable with ButtonFacade skin support |
| **Unit Frames** | Player, target, party, raid with extensive options |
| **Nameplates** | Enhanced with styling and filtering |
| **Bags** | Unified interface with sorting and searching |
| **Chat** | URL detection and customization |
| **Maps** | Customizable minimap and world map |
| **Data Texts** | Informative game statistics displays |
| **Tooltips** | Enhanced with additional information |
| **Skins** | Consistent styling for all Blizzard frames |

## Installation

1. Extract both `ElvUI` and `ElvUI_OptionsUI` folders to `Interface\AddOns`
2. Launch World of Warcraft
3. Complete the installation wizard on first load
4. Configure with `/ec` or `/elvui`

## Components

This is a **monorepo** containing:

- **ElvUI** - Core functionality and framework
- **ElvUI_OptionsUI** - Configuration panel (loads on demand)

## Configuration

| Command | Description |
|---------|-------------|
| `/ec` | Open configuration |
| `/elvui` | Open configuration |
| `/elvui install` | Run installation wizard |
| `/elvui reset` | Reset all settings |

## Credits

- **Project Ascension Updates:** Xurkon
- **Modernized Overhaul:** [XiusTV](https://github.com/XiusTV/)
- **Original ElvUI:** Elv, Bunny, and team
- oUF Framework, Ace3 Library, Community Contributors

---

**For issues, please open an issue on this repository.**

[Documentation](docs/index.html)
