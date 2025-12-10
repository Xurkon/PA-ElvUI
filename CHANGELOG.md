# ElvUI Changelog

All notable changes to ElvUI will be documented in this file.

**Updated for Project Ascension compatibility by Xurkon**

## [1.3.3] - 2025-12-10

### Added - Options Panel Improvements

- **Persistent Tree Divider Width**
  - Options panel tree divider (white bar between menu and settings) now remembers its position
  - Saved to global settings, persists across reloads and sessions
  - Drag the divider once and it stays where you put it

### Technical Details

- Added `treeWidth` setting to `G.general.AceGUI` in Global.lua
- Modified `AceConfigDialog-3.0.lua` to save/load treeWidth from ElvUI global settings
- Added `OnTreeResize` callback to save position on drag
- Automatically restores saved width when options panel opens

## [1.3.2] - 2025-12-09

### Added - MinimapButtonFrame Integration

- **MBF Integration Option**
  - New "MinimapButtonFrame" section in Maps → Minimap → Buttons (only shown when MBF addon is loaded)
  - "Let MBF Control Buttons" toggle to hand button control to MBF addon instead of ElvUI
  - When enabled, all ElvUI button options (Calendar, Mail, LFG, PvP, etc.) grey out with notice
  - ElvUI's Minimap Button Grabber automatically releases buttons back to MBF
  
- **Auto-Relinquish Behavior**
  - When MBF addon is disabled/not loaded, ElvUI automatically regains button control
  - Prevents orphaned buttons when switching between addons
  
### Changed

- Added `mbfControlEnabled` setting to minimap profile defaults
- MinimapButtonGrabber now checks for MBF control state before grabbing buttons
- Added `ReleaseButtonsToMBF()` function to properly release grabbed buttons
- Added reload UI popup when toggling MBF control

### Technical Details

- Modified `Profile.lua` to add `mbfControlEnabled = false` default
- Modified `Maps.lua` to add MBF integration group with toggle and notice
- Modified `MinimapButtonGrabber.lua` with `ReleaseButtonsToMBF()` and updated `HandleEnableState()`
- All button groups (Calendar, Mail, LFG, PvP, Difficulty, VehicleLeave, ButtonGrabber) now respect MBF control flag

## [1.3.1] - 2025-11-05

### Added - AuraTracker Enhancements

- **Black Color Preset**
  - Added black color option to all color preset dropdowns (Default, Warning, Urgent)
  - Allows users to choose black for countdown text colors
  
- **White Outline Toggle**
  - New "White Outline" option in AuraTracker settings
  - Inverts outline color from black to white for better visibility on dark backgrounds
  - Automatically disabled when Font Outline is set to "None"
  - Uses MONOCHROME flag to achieve white outline effect

### Changed - AuraTracker Improvements

- **Menu Reorganization**
  - Renamed "Aura Duration Tracker" to "Aura Tracker" throughout options menu
  - Moved AuraTracker from nested section under General Options to standalone tab
  - Now accessible via: ElvUI → ActionBars → Aura Tracker
  - Removed duplicate AuraTracker section from General Options
  
- **Menu Name Updates**
  - Renamed "Raid Markers Bar" to "Raid Markers" for consistency
  
- **Permanent Buff Display**
  - Changed behavior: permanent buffs (shapeshifts, stances) now show no text instead of "UP"
  - Only displays countdown timers for temporary buffs/debuffs with actual durations
  - Prevents clutter on action bars for permanent abilities

### Fixed - AuraTracker Bugs

- **Debug Command Improvements**
  - Fixed `/cleartest` command to clear ALL registered buttons instead of just Button1
  - Now properly clears test mode flags and resets text/colors on all buttons
  - Improved error handling and user feedback
  
- **Menu Structure**
  - Fixed missing closing braces in ActionBars options menu
  - Resolved syntax errors preventing ActionBar settings from loading
  - Corrected indentation and structure throughout options menu

### Technical Details

- Updated `FormatTime()` to return empty string for permanent auras (>= 999999 seconds)
- Enhanced `/cleartest` command to iterate through all registered AuraTracker buttons
- Added `invertOutline` setting to Profile.lua defaults
- Modified `FontTemplate` calls to append ", MONOCHROME" when white outline is enabled
- Updated all color preset tables to include black color option
- Fixed order values in options menu after adding new settings

## [1.3.0] - 2024-11-04

### Added - Major Features

- **ButtonFacade/LibButtonFacade (LBF) Integration**
  - Full LibButtonFacade support for action bar button skinning
  - 30+ button skins available (29 custom + Blizzard default)
  - LBF settings now profile-based for cross-character saving
  - Options integrated into ElvUI → ActionBars → General Options → LBF Support
  - ButtonFacade panel with full skin customization (gloss, backdrop, colors)
  
- **Omen Threat Meter Full Integration**
  - Complete Omen configuration embedded in ElvUI options menu
  - Accessible via ElvUI → Omen (all sub-menus: General, Show When, Show Classes, Title Bar, Bar Settings, Warning Settings, Slash Command, Profiles)
  - `/omen config` now opens ElvUI → Omen instead of Blizzard Interface Options
  - Removed warrior-specific Help File from embedded options
  - Omen skinning defaults properly load and apply
  
- **Quest Automation (AutoQuest) Integration**
  - Moved from WarcraftEnhanced to ElvUI → General → Automation → Quest Automation
  - Full quest automation with 700+ repeatable/daily quest database
  - Options: Auto-accept all quests, dailies, Fate quests, repeatables, high-risk quests
  - Auto-complete quests with no reward choices
  - Hold Shift/Ctrl/Alt when talking to NPCs to temporarily disable
  - Slash commands: `/aq`, `/autoquest` with full configuration
  
- **PortalBox Integration**
  - Moved from WarcraftEnhanced to ElvUI → General → Miscellaneous
  - Quick access to all teleport and portal spells
  - Minimap button hide/show toggle
  - Direct open button in ElvUI options
  
- **Comprehensive Commands Reference**
  - New ElvUI → Commands menu with complete command documentation
  - Organized by category: ElvUI Core, ActionBars, Quest Automation, Omen, TomTom, PortalBox, Bags, DataTexts, Other Addons, Help & Tips
  - Searchable command list with examples and usage
  
- **Options Menu Reorganization**
  - All main menu items now in alphabetical order
  - Search moved to top for quick access
  - Credits moved to bottom
  - Cleaner, more intuitive navigation

### Added - Minor Features

- **AuraTracker Module** (In Development)
  - Displays buff/debuff duration remaining directly on action bar buttons
  - Shows time left for your abilities on current target (e.g., Gift of the Wild buff duration, Moonfire DoT remaining)
  - Color-coded by urgency: Green (>10s), Yellow (5-10s), Red (<5s)
  - Configurable font, size, and outline
  - Options in ElvUI → ActionBars → General Options → Aura Duration Tracker
  - **Note:** Feature is functional but still being refined
  
- **Taint Fix Module**
  - Prevents common taint issues with action bars and raid frames
  - Configurable fixes for different frame types
  - Options in ElvUI → General → Taint Fix

### Changed

- **WarcraftEnhanced Integration**
  - Removed WarcraftEnhanced from ElvUI sidebar menu (features now native)
  - `/we` command now shows helpful redirect to feature locations
  - AutoQuest, Omen, and PortalBox fully integrated into ElvUI native menus
  
- **ActionBars Module**
  - Added AuraTracker button registration in StyleButton
  - Improved icon texture coordinate handling with LBF compatibility
  - Enhanced button styling logic for ButtonFacade integration
  
- **General Options Improvements**
  - Automation section reorganized with better spacing
  - Quest Automation, Vendor Automation, and Combat Automation clearly separated
  - PortalBox settings added to Miscellaneous
  - Fixed duplicate tooltip text in "Accept Invites" option
  - Added nil checks for taintFix settings (backward compatibility with older profiles)

### Fixed

- **Core Stability**
  - Fixed "attempt to index field 'db' (a nil value)" error in Core.lua line 226
  - Added comprehensive nil checks for `self.db`, `self.db.general`, `self.db.unitframe`, and `self.db.chat` in UpdateMedia()
  - Prevents race condition errors during early initialization
  
- **Omen Skinning**
  - Fixed Omen skinning not loading correctly after removal/re-add
  - Added missing `V.addOnSkins` table to Private.lua (includes Omen, Recount, Skada)
  - Omen default profile and skinning now load properly
  
- **ButtonFacade Issues**
  - Fixed blank action bars when ButtonFacade was enabled
  - Removed duplicate ButtonFacade registration from ActionBars.lua
  - Corrected ButtonData structure for proper element references
  - Fixed icon SetTexCoord conflicts with ButtonFacade
  - Enhanced BF:UpdateSkins() to properly remove and restore ElvUI styling
  - Fixed gloss and backdrop settings not applying correctly
  - Removed duplicate requirement text from ButtonFacade options
  
- **Options UI Errors**
  - Fixed "ElvUI.GetActionBarButtonFacadeOptions: unknown parameter" error
  - Removed invalid options table export
  - Fixed syntax error in General.lua causing TomTom options to be unclickable
  - Fixed taintFix nil value error with backward-compatible defaults

### Technical Details

- LBF settings moved from `V.actionbar.lbf` (private) to `P.actionbar.lbf` (profile) for cross-character saving
- All code references updated from `E.private.actionbar.lbf` to `E.db.actionbar.lbf`
- Enhanced `BF:RegisterAndSkinBar()` with correct ButtonData mapping (Icon, Flash, Cooldown, HotKey, Count, Name, Border, NormalTexture)
- `BF:RemoveActionBarsFromLBF()` updated to use `group:DeleteButton()` and `LBF:DeleteGroup()` for clean reset
- Added proper nil checks throughout options UI for backward compatibility
- ElvUI_OptionsUI files organized: Omen.lua, Commands.lua added to load order
- WarcraftEnhanced options registration disabled (all features now native)

### Removed

- ElvUI_WarcraftEnhanced_Integration_Files folder (obsolete, features now built-in)
- Integrate-WarcraftEnhanced-Into-ElvUI.ps1 (integration complete)
- 25 development documentation files (.md and .txt files created during development)
- WarcraftEnhanced options menu from ElvUI sidebar
- Omen "Help File" tab from embedded configuration

## [1.2.0] - 2024-11-02

### Added

- Reintegrated Party frames module
  - Re-enabled Party.lua in Groups loader
  - Restored party frame configuration options in ElvUI_OptionsUI
  - Re-enabled BuffIndicator updates for party frames
  - Re-enabled Blizzard party interface hiding
- Reintegrated Raid frames module
  - Re-enabled Raid.lua in Groups loader
  - Restored raid frame configuration options in ElvUI_OptionsUI
  - Re-enabled BuffIndicator updates for raid frames
- Reintegrated Raid-40 frames module
  - Re-enabled Raid40.lua in Groups loader
  - Restored raid40 frame configuration options in ElvUI_OptionsUI
  - Re-enabled BuffIndicator updates for raid40 frames
- Reintegrated Raid Pet frames module
  - Re-enabled RaidPets.lua in Groups loader
  - Restored raidpet frame configuration options in ElvUI_OptionsUI

### Changed

- Updated Load_Groups.xml to include all group frame modules
- Updated UnitFrames.lua to re-enable aura watch updates for group frames
- Updated UnitFrames.lua to re-enable Blizzard interface hiding for party frames

### Technical Details

- Removed `if false then` wrappers from party, raid, raid40, and raidpet configuration sections
- Re-enabled conditional logic for party/raid/raid40 BuffIndicator updates
- Restored full functionality that was previously disabled

## [1.1.0] - 2024-11-02

### Changed

- Updated author list to include Xius

### Removed

- Removed Harlem Shake easter egg feature
  - Deleted `/harlemshake` command
  - Removed `Core/AprilFools.lua` file
  - Removed associated popup dialogs
  - Deleted HarlemShake.ogg sound file
- Removed Hello Kitty easter egg feature
  - Deleted `/hellokitty` and `/hellokittyfix` commands
  - Removed Hello Kitty initialization code
  - Removed associated popup dialogs
  - Deleted HelloKitty.ogg, HelloKitty.tga, HelloKittyChat.tga, and HelloKitty chat logo
  - Removed localization strings from all language files

### Technical Details

- Cleaned up media references in SharedMedia.lua
- Removed initialization hooks from Core.lua
- Updated static popup definitions
- Removed command registrations from Commands.lua

## [1.0.0] - 2024-11-02

### Initial Release

Complete UI replacement addon for World of Warcraft 3.3.5 (WotLK)

### Added

- **Action Bars Module**
  - Fully customizable action bars (1-10)
  - Pet bar with customization
  - Stance bar support
  - Totem bar for shamans
  - Micro bar (character, spellbook, talents, etc.)
  - Keybind mode
  - Mouseover functionality

- **Unit Frames Module**
  - Player, Target, Target of Target frames
  - Focus and Focus Target frames
  - Pet and Pet Target frames
  - Party frames (1-5 members)
  - Raid frames (1-40 members)
  - Boss frames
  - Arena frames
  - Assist and Tank frames
  - oUF framework integration
  - Extensive customization options

- **Nameplates Module**
  - Complete nameplate overhaul
  - Style filters for conditional formatting
  - Threat detection
  - Class colors
  - Aura tracking
  - Target highlighting
  - Customizable fonts and textures

- **Bags Module**
  - Unified bag interface
  - Bank integration
  - Item sorting and filtering
  - Search functionality
  - Reverse slot order option
  - Bag bar for quick access

- **Chat Module**
  - Enhanced chat frames
  - URL detection and copying
  - Chat emoji support
  - Tab customization
  - Chat panel datatexts
  - Separate whisper windows option
  - Combat log enhancements

- **Maps Module**
  - Customizable minimap
  - World map enhancements
  - Coordinates display
  - Mapster integration
  - Instance difficulty indicator
  - Combat fade
  - Mouseover/hover options

- **DataBars Module**
  - Experience bar
  - Reputation bar
  - Pet experience bar
  - Customizable positioning
  - Mouseover text display

- **DataTexts Module**
  - 25+ data text options
  - Customizable panels
  - Left-click, right-click actions
  - Tooltip information
  - Auto-hide in combat option

- **Auras Module**
  - Buff display
  - Debuff display
  - Consolidated buffs option
  - Custom filtering
  - Wrap after X auras
  - Mouseover functionality

- **Tooltip Module**
  - Enhanced tooltips
  - Item level display
  - Spell ID display
  - Guild ranks
  - Player titles
  - Health bar
  - Cursor anchor option

- **Skins Module**
  - Consistent UI skinning
  - 150+ Blizzard frames skinned
  - Addon skins support
  - WeakAuras integration
  - Details integration
  - DBM integration

- **Blizzard Module**
  - Alert frame customization
  - Capture bar enhancements
  - Durability frame
  - GM frame
  - Kill/Honor frame
  - Vehicle seat indicator
  - Watch frame (objectives)

- **Misc Module**
  - Experience/reputation notifications
  - Loot roll enhancements
  - Automation features
  - Threat meter
  - Error frame filtering
  - And more...

- **Core Features**
  - Installation wizard
  - Profile system
  - Layout customization
  - Mover system for positioning
  - Developer tools
  - Plugin support
  - Extensive customization options

### Libraries

- Ace3 (AceAddon, AceConfig, AceDB, AceEvent, etc.)
- oUF (Unit Frame framework)
- LibSharedMedia-3.0
- LibActionButton-1.0
- LibAuraInfo-1.0
- LibDataBroker-1.1
- LibDualSpec-1.0
- LibElvUIPlugin-1.0
- LibItemSearch-1.2
- LibSpellRange-1.0
- And more...

### Notes

- Compatible with WotLK 3.3.5
- Interface version: 30300
- Includes VuhDo integration support

---

## Future Plans

- Bug fixes and optimizations
- Additional features based on user feedback
- Enhanced plugin support
- More customization options
