-- ElvUI Commands Reference
-- Comprehensive list of all available commands for ElvUI and integrated addons

local E, L, V, P, G = unpack(ElvUI)

-- Only create after ElvUI is loaded
if not E then return end

local ACH = E.Libs.ACH

-- Function to get all commands
local function GetCommandsOptions()
	return {
		order = 50, -- Alphabetical: C (Commands)
		type = "group",
		name = "Commands",
		childGroups = "tab",
		args = {
			header = {
				order = 1,
				type = "header",
				name = "ElvUI Commands Reference",
			},
			description = {
				order = 2,
				type = "description",
				name = "Complete list of available slash commands for ElvUI and all integrated addons.\n",
			},
			
			-- ElvUI Core Commands
			elvuiCore = {
				order = 10,
				type = "group",
				name = "ElvUI Core",
				args = {
					header = {
						order = 1,
						type = "header",
						name = "ElvUI Core Commands",
					},
					commands = {
						order = 2,
						type = "description",
						name = 
							"|cff1784d1Main Commands:|r\n" ..
							"  |cffffcc00/elvui|r - Open ElvUI configuration\n" ..
							"  |cffffcc00/ec|r - Shortcut for /elvui\n" ..
							"  |cffffcc00/elvui install|r - Run installation wizard\n" ..
							"  |cffffcc00/elvui reset|r - Reset ElvUI settings\n" ..
							"  |cffffcc00/elvui resetui|r - Reset UI layout\n" ..
							"  |cffffcc00/elvui version|r - Show ElvUI version\n" ..
							"  |cffffcc00/elvui status|r - Show addon status\n" ..
							"  |cffffcc00/elvui kb|r - Toggle keybind mode\n" ..
							"  |cffffcc00/elvui moveui|r - Toggle move frames mode\n" ..
							"  |cffffcc00/elvui resetmovers|r - Reset all frame positions\n" ..
							"  |cffffcc00/elvui bgstats|r - Toggle battleground stats\n" ..
							"  |cffffcc00/elvui emote|r - Do an emote animation\n" ..
							"  |cffffcc00/farmmode|r - Toggle farm mode (larger frames)\n\n" ..
							"|cff1784d1Profile Commands:|r\n" ..
							"  |cffffcc00/elvui profile|r - Profile management\n" ..
							"  |cffffcc00/elvui export|r - Export profile\n" ..
							"  |cffffcc00/elvui import|r - Import profile\n",
					},
				},
			},
			
			-- ActionBar Commands
			actionBars = {
				order = 20,
				type = "group",
				name = "ActionBars",
				args = {
					header = {
						order = 1,
						type = "header",
						name = "ActionBar Commands",
					},
					commands = {
						order = 2,
						type = "description",
						name = 
							"|cff1784d1ActionBar Visibility:|r\n" ..
							"  |cffffcc00/ab|r - Toggle ActionBar visibility\n" ..
							"  |cffffcc00/ab 1|r - Toggle Bar 1\n" ..
							"  |cffffcc00/ab 2|r - Toggle Bar 2\n" ..
							"  |cffffcc00/ab 3|r - Toggle Bar 3\n" ..
							"  |cffffcc00/ab 4|r - Toggle Bar 4\n" ..
							"  |cffffcc00/ab 5|r - Toggle Bar 5\n" ..
							"  |cffffcc00/ab 6|r - Toggle Bar 6\n" ..
							"  |cffffcc00/ab pet|r - Toggle Pet Bar\n" ..
							"  |cffffcc00/ab stance|r - Toggle Stance Bar\n\n" ..
							"|cffffcc00Note:|r ActionBar settings are in ElvUI → ActionBars\n",
					},
				},
			},
			
			-- Quest Automation Commands
			autoQuest = {
				order = 30,
				type = "group",
				name = "Quest Automation",
				args = {
					header = {
						order = 1,
						type = "header",
						name = "Quest Automation (AutoQuest) Commands",
					},
					commands = {
						order = 2,
						type = "description",
						name = 
							"|cff1784d1AutoQuest Commands:|r\n" ..
							"  |cffffcc00/aq|r or |cffffcc00/autoquest|r - Show help and status\n" ..
							"  |cffffcc00/aq accept <on|off>|r - Toggle auto-accept all quests\n" ..
							"  |cffffcc00/aq daily <on|off>|r - Toggle auto-accept daily quests\n" ..
							"  |cffffcc00/aq fate <on|off>|r - Toggle auto-accept Fate quests\n" ..
							"  |cffffcc00/aq repeat <on|off>|r - Toggle auto-accept repeatable quests\n" ..
							"  |cffffcc00/aq complete <on|off>|r - Toggle auto-complete quests\n" ..
							"  |cffffcc00/aq highrisk <on|off>|r - Toggle auto-accept high-risk quests\n" ..
							"  |cffffcc00/aq toggle <quest name>|r - Enable/disable specific quest\n" ..
							"  |cffffcc00/aq remove <quest name>|r - Remove custom quest setting\n\n" ..
							"|cffFFFF00Tip:|r Hold Shift/Ctrl/Alt when talking to NPCs to temporarily disable AutoQuest\n\n" ..
							"|cffffcc00Settings:|r ElvUI → General → Automation → Quest Automation\n",
					},
				},
			},
			
			-- Omen Commands
			omen = {
				order = 40,
				type = "group",
				name = "Omen Threat Meter",
				args = {
					header = {
						order = 1,
						type = "header",
						name = "Omen Threat Meter Commands",
					},
					commands = {
						order = 2,
						type = "description",
						name = 
							"|cff1784d1Omen Commands:|r\n" ..
							"  |cffffcc00/omen|r - Toggle Omen window\n" ..
							"  |cffffcc00/omen toggle|r - Toggle Omen window\n" ..
							"  |cffffcc00/omen show|r - Show Omen window\n" ..
							"  |cffffcc00/omen hide|r - Hide Omen window\n" ..
							"  |cffffcc00/omen config|r - Open configuration (now in ElvUI)\n" ..
							"  |cffffcc00/omen test|r - Toggle test mode\n" ..
							"  |cffffcc00/omen lock|r - Lock window position\n" ..
							"  |cffffcc00/omen unlock|r - Unlock window position\n" ..
							"  |cffffcc00/omen reset|r - Reset window position\n\n" ..
							"|cffffcc00Settings:|r ElvUI → Omen (full configuration)\n",
					},
				},
			},
			
			-- TomTom Commands
			tomtom = {
				order = 50,
				type = "group",
				name = "TomTom Navigation",
				args = {
					header = {
						order = 1,
						type = "header",
						name = "TomTom Navigation Commands",
					},
					commands = {
						order = 2,
						type = "description",
						name = 
							"|cff1784d1TomTom Waypoint Commands:|r\n" ..
							"  |cffffcc00/way|r - Add waypoint (current zone)\n" ..
							"  |cffffcc00/way <x> <y>|r - Add waypoint at coordinates\n" ..
							"  |cffffcc00/way <zone> <x> <y>|r - Add waypoint in specific zone\n" ..
							"  |cffffcc00/way <x> <y> <description>|r - Add waypoint with note\n" ..
							"  |cffffcc00/way list|r - List all active waypoints\n" ..
							"  |cffffcc00/way clear|r - Clear nearest waypoint\n" ..
							"  |cffffcc00/way clearall|r - Clear all waypoints\n" ..
							"  |cffffcc00/way reset|r - Reset arrow position\n\n" ..
							"|cff1784d1Examples:|r\n" ..
							"  |cffffcc00/way 42 67|r - Waypoint at 42,67 in current zone\n" ..
							"  |cffffcc00/way Elwynn Forest 32 50|r - Waypoint in Elwynn Forest\n" ..
							"  |cffffcc00/way 50 50 Quest NPC|r - Waypoint with description\n\n" ..
							"|cffffcc00Settings:|r ElvUI → TomTom\n",
					},
				},
			},
			
			-- PortalBox Commands
			portalbox = {
				order = 60,
				type = "group",
				name = "PortalBox",
				args = {
					header = {
						order = 1,
						type = "header",
						name = "PortalBox Commands",
					},
					commands = {
						order = 2,
						type = "description",
						name = 
							"|cff1784d1PortalBox Commands:|r\n" ..
							"  |cffffcc00/port|r - Toggle PortalBox window\n" ..
							"  |cffffcc00/portalbox|r - Toggle PortalBox window\n\n" ..
							"|cffffcc00Settings:|r ElvUI → WarcraftEnhanced → PortalBox\n",
					},
				},
			},
			
			-- Bags Commands
			bags = {
				order = 70,
				type = "group",
				name = "Bags",
				args = {
					header = {
						order = 1,
						type = "header",
						name = "Bag Commands",
					},
					commands = {
						order = 2,
						type = "description",
						name = 
							"|cff1784d1Bag Commands:|r\n" ..
							"  |cffffcc00/bags|r - Toggle bags\n" ..
							"  |cffffcc00/bag|r - Toggle bags\n" ..
							"  |cffffcc00/rb|r - Toggle reagent bank\n\n" ..
							"|cffffcc00Settings:|r ElvUI → Bags\n",
					},
				},
			},
			
			-- DataTexts Commands  
			datatexts = {
				order = 80,
				type = "group",
				name = "DataTexts",
				args = {
					header = {
						order = 1,
						type = "header",
						name = "DataText Commands",
					},
					commands = {
						order = 2,
						type = "description",
						name = 
							"|cff1784d1DataText Commands:|r\n" ..
							"  |cffffcc00/dt|r - Toggle DataText configuration mode\n" ..
							"  |cffffcc00Right-click any DataText|r - Quick change menu\n\n" ..
							"|cffffcc00Settings:|r ElvUI → DataTexts\n",
					},
				},
			},
			
			-- Additional Integrated Addons
			integratedAddons = {
				order = 90,
				type = "group",
				name = "Other Addons",
				args = {
					header = {
						order = 1,
						type = "header",
						name = "Other Integrated Addon Commands",
					},
					dbm = {
						order = 10,
						type = "description",
						name = 
							"|cff1784d1Deadly Boss Mods (DBM):|r\n" ..
							"  |cffffcc00/dbm|r - Open DBM options\n" ..
							"  |cffffcc00/dbm unlock|r - Unlock DBM bars\n" ..
							"  |cffffcc00/dbm lock|r - Lock DBM bars\n" ..
							"  |cffffcc00/dbm test|r - Test DBM bars\n",
					},
					weakauras = {
						order = 20,
						type = "description",
						name = 
							"\n|cff1784d1WeakAuras:|r\n" ..
							"  |cffffcc00/wa|r - Open WeakAuras configuration\n" ..
							"  |cffffcc00/weakauras|r - Open WeakAuras configuration\n" ..
							"  |cffffcc00/wa minimap|r - Toggle minimap button\n",
					},
					details = {
						order = 30,
						type = "description",
						name = 
							"\n|cff1784d1Details! Damage Meter:|r\n" ..
							"  |cffffcc00/details|r - Open Details options\n" ..
							"  |cffffcc00/details toggle|r - Toggle Details windows\n" ..
							"  |cffffcc00/details reset|r - Reset Details windows\n",
					},
					atlasloot = {
						order = 40,
						type = "description",
						name = 
							"\n|cff1784d1AtlasLoot:|r\n" ..
							"  |cffffcc00/al|r - Open AtlasLoot\n" ..
							"  |cffffcc00/atlasloot|r - Open AtlasLoot\n",
					},
					handynotes = {
						order = 50,
						type = "description",
						name = 
							"\n|cff1784d1HandyNotes:|r\n" ..
							"  |cffffcc00/handynotes|r - Open HandyNotes options\n" ..
							"  |cffffcc00/hn|r - Shortcut for HandyNotes\n",
					},
				},
			},
			
			-- Help and Tips
			helpTips = {
				order = 100,
				type = "group",
				name = "Help & Tips",
				args = {
					header = {
						order = 1,
						type = "header",
						name = "Help & Tips",
					},
					tips = {
						order = 2,
						type = "description",
						name = 
							"|cff1784d1Quick Tips:|r\n\n" ..
							"|cffFFFF00Moving UI Elements:|r\n" ..
							"  • Type |cffffcc00/elvui moveui|r to unlock frames\n" ..
							"  • Drag frames to desired position\n" ..
							"  • Click 'Lock' or type |cffffcc00/elvui moveui|r again to lock\n\n" ..
							"|cffFFFF00Installation & Setup:|r\n" ..
							"  • Type |cffffcc00/elvui install|r to run the setup wizard\n" ..
							"  • Follow on-screen instructions for optimal setup\n\n" ..
							"|cffFFFF00Profiles:|r\n" ..
							"  • ElvUI → Profiles to manage different setups\n" ..
							"  • Great for different characters or roles\n\n" ..
							"|cffFFFF00Getting More Help:|r\n" ..
							"  • Join Ascension Discord for support\n" ..
							"  • ElvUI documentation available online\n" ..
							"  • Type |cffffcc00/elvui|r and explore the options!\n",
					},
				},
			},
		},
	}
end

-- Insert commands into ElvUI options
function E:SetupCommandsOptions()
	E.Options.args.commands = GetCommandsOptions()
end

-- Initialize when ElvUI_OptionsUI loads
local function InitializeCommandsOptions()
	if E.Options then
		E:SetupCommandsOptions()
	end
end

if IsAddOnLoaded("ElvUI_OptionsUI") then
	InitializeCommandsOptions()
else
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("ADDON_LOADED")
	frame:SetScript("OnEvent", function(self, event, addon)
		if addon == "ElvUI_OptionsUI" then
			InitializeCommandsOptions()
			self:UnregisterEvent("ADDON_LOADED")
		end
	end)
end

