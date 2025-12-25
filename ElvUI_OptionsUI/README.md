# ElvUI_OptionsUI

Configuration interface for ElvUI - A comprehensive UI replacement for World of Warcraft 3.3.5 (WotLK).

## Version

- **Version:** 1.0.0
- **Interface:** 30300 (WotLK)
- **Authors:** Elv, Bunny

## Description

ElvUI_OptionsUI provides the configuration interface for ElvUI. This addon is loaded on demand when you access ElvUI settings, keeping memory usage minimal until needed.

## Features

- Comprehensive configuration panels for all ElvUI modules
- Profile management (create, copy, delete profiles)
- Import/Export functionality for sharing configurations
- Module-specific options:
  - Action Bars configuration
  - Auras settings
  - Bag customization
  - Chat options
  - DataBar settings
  - DataText configuration
  - Map customization
  - Nameplate styling and filters
  - Tooltip settings
  - Unit Frame configuration
  - Skin options

## Access

Open the configuration panel:
- Type `/ec` or `/elvui` in-game
- Click the ElvUI button in the minimap menu
- Use the ElvUI installation wizard

## Dependencies

- **Required:** ElvUI (main addon must be installed)
- **Load:** On Demand (only loads when accessing settings)

## Structure

### Configuration Modules
- `ActionBars.lua` - Action bar settings
- `Auras.lua` - Buff/debuff display options
- `Bags.lua` - Inventory configuration
- `Chat.lua` - Chat frame settings
- `DataBars.lua` - Experience/reputation bar options
- `DataTexts.lua` - Information display configuration
- `Filters.lua` - Filter management
- `General.lua` - General ElvUI settings
- `Maps.lua` - Minimap and world map options
- `Nameplates.lua` - Nameplate configuration
- `Skins.lua` - UI skinning options
- `Tooltip.lua` - Tooltip settings
- `UnitFrames.lua` - Unit frame configuration

### Libraries
- AceConfig-3.0 - Configuration framework
- AceGUI-3.0 - GUI widget library
- SharedMedia - Font and texture library

## Usage

1. Install ElvUI first (required dependency)
2. Place ElvUI_OptionsUI in your AddOns folder
3. Launch WoW and use `/ec` to open settings
4. Configure ElvUI to your preferences
5. Save and apply changes

## Profile System

ElvUI_OptionsUI includes a powerful profile system:
- **Create** new profiles for different characters or playstyles
- **Copy** settings from one profile to another
- **Delete** unused profiles
- **Reset** to default settings
- **Import/Export** profiles as text strings

## Credits

- **Elv** - Lead Developer
- **Bunny** - Co-Developer
- Ace3 Library Authors
- Community Contributors

## License

ElvUI_OptionsUI is free software distributed with ElvUI.

## Notes

This addon will only load when you access ElvUI configuration, saving memory during normal gameplay.

