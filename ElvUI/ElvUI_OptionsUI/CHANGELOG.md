# ElvUI_OptionsUI Changelog

All notable changes to ElvUI_OptionsUI will be documented in this file.

**Updated for Project Ascension compatibility by Xurkon**

## [1.0.3] - 2025-12-10

### Added - Options Panel Improvements

- **Persistent Tree Divider Width**
  - The white divider bar between the menu tree and settings panel now remembers its position
  - Saved to ElvUI global settings, persists across reloads and game sessions
  - Modified `AceConfigDialog-3.0.lua` to hook `OnTreeResize` callback for saving

## [1.0.2] - 2025-12-09

### Added - Bidirectional MBF Integration

- **MBF Disable Popup**: When enabling the Minimap Button Grabber while MinimapButtonFrame is installed, a popup now offers to disable MBF addon to avoid conflicts
  - Options: "Disable & Reload", "Just Reload", "Cancel"

## [1.0.1] - 2025-12-09

### Added - MinimapButtonFrame Integration

- **MBF Integration Section**
  - New "MinimapButtonFrame" group in Maps → Minimap → Buttons
  - "Let MBF Control Buttons" toggle option
  - Informational notice when MBF control is enabled
  - Section only visible when MinimapButtonFrame addon is loaded

### Changed

- All minimap button options (Calendar, Mail, LFG Queue, PvP Queue, Instance Difficulty, Leave Vehicle, Button Grabber) now disabled when MBF controls buttons
- Entire "Minimap Button Grabber" group disabled at group level (not just individual options) when MBF controls
- Improved spacing in MBF notice text (added line breaks between each message)
- Added reload UI popup when toggling MBF control
- Updated disabled functions to check `mbfControlEnabled` flag

## [1.0.0] - 2024-11-02

### Initial Release

Configuration interface for ElvUI - Complete options panel system

### Added

- **Core Configuration System**
  - AceConfig-3.0 framework integration
  - AceGUI-3.0 widget system
  - Load on demand functionality
  - Memory efficient loading

- **Profile Management**
  - Create new profiles
  - Copy existing profiles
  - Delete profiles
  - Reset to defaults
  - Import/Export system
  - Profile sharing via text strings

- **Module Configuration Panels**
  - **General Settings**
    - UI scale
    - UI theme
    - Font settings
    - Media selection
    - Auto-repair
    - Auto-sell junk
    - Vendor grays

  - **Action Bars**
    - Bar 1-10 configuration
    - Pet bar options
    - Stance bar settings
    - Totem bar customization
    - Micro bar positioning
    - Keybind mode
    - Visibility conditions

  - **Auras**
    - Buff display settings
    - Debuff configuration
    - Consolidated buffs
    - Filter management
    - Size and spacing

  - **Bags**
    - Bag layout options
    - Item sorting
    - Bank settings
    - Vendor grays
    - Bag bar configuration

  - **Chat**
    - Frame positioning
    - Channel colors
    - Font settings
    - URL detection
    - Emoji support
    - Combat log options

  - **DataBars**
    - Experience bar settings
    - Reputation bar options
    - Pet experience configuration
    - Mouseover text
    - Colors and textures

  - **DataTexts**
    - Panel configuration
    - Text selection
    - Click actions
    - Tooltip settings
    - Auto-hide options

  - **Maps**
    - Minimap customization
    - World map settings
    - Coordinates display
    - Mapster integration
    - Combat fade
    - Icon settings

  - **Nameplates**
    - Nameplate styling
    - Style filters
    - Threat coloring
    - Aura tracking
    - Font configuration
    - Texture selection

  - **Skins**
    - Blizzard frame skins
    - Addon skins
    - ACE3 skins
    - WeakAuras integration
    - Details integration

  - **Tooltip**
    - Tooltip styling
    - Information display
    - Item level
    - Spell IDs
    - Health bars
    - Cursor anchor

  - **Unit Frames**
    - Player frame settings
    - Target frame configuration
    - Party frame options
    - Raid frame settings
    - Arena frame customization
    - Boss frame options
    - All frame types configurable

- **Filter Management**
  - Buff indicator filters
  - Aura filters
  - Nameplate filters
  - Custom filter creation
  - Import/Export filters

- **Advanced Options**
  - Developer mode
  - Debug tools
  - Cache clearing
  - Reset functions
  - Module toggles

### Libraries

- AceConfig-3.0 (Configuration framework)
- AceConfigDialog-3.0 (Dialog system)
- AceConfigRegistry-3.0 (Settings registry)
- AceGUI-3.0 (Widget library)
- AceDBOptions-3.0 (Database options)
- LibSharedMedia-3.0 (Media library)

### Features

- Load on demand (saves memory until needed)
- Intuitive tree-based navigation
- Real-time preview of changes
- Comprehensive tooltips
- Search functionality
- Quick access to common settings

### Commands

- `/ec` - Open ElvUI configuration
- `/elvui` - Open ElvUI configuration
- `/elvui install` - Run installation wizard
- `/elvui reset` - Reset all settings
- `/elvui toggle` - Toggle ElvUI on/off

### Notes

- Requires ElvUI main addon
- Compatible with WotLK 3.3.5
- Interface version: 30300
- Automatically loaded when accessing settings

---

## Future Plans

- Additional configuration options
- Enhanced filter management
- Quick setup profiles
- More customization presets
- Improved import/export system
