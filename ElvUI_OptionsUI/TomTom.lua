-- ElvUI TomTom Options Integration
-- Full TomTom configuration integrated into ElvUI options

local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(select(2, ...))
local ACH = E.Libs.ACH

-- Helper functions to access TomTom profile
local function getTomTomOption(ns, opt)
	if not TomTom or not TomTom.db or not TomTom.db.profile or not TomTom.db.profile[ns] then
		return nil
	end
	local val = TomTom.db.profile[ns][opt]
	if type(val) == "table" then
		return unpack(val)
	else
		return val
	end
end

local function setTomTomOption(ns, opt, value, value2, value3, value4)
	if not TomTom or not TomTom.db or not TomTom.db.profile or not TomTom.db.profile[ns] then
		return
	end
	
	if value2 then
		local entry = TomTom.db.profile[ns][opt]
		entry[1] = value
		entry[2] = value2
		entry[3] = value3
		entry[4] = value4
	else
		TomTom.db.profile[ns][opt] = value
	end
	
	-- Trigger updates
	if ns == "block" then
		if TomTom.ShowHideCoordBlock then TomTom:ShowHideCoordBlock() end
	elseif ns == "mapcoords" then
		if TomTom.ShowHideWorldCoords then TomTom:ShowHideWorldCoords() end
	elseif ns == "arrow" then
		if TomTom.ShowHideCrazyArrow then TomTom:ShowHideCrazyArrow() end
	elseif ns == "poi" then
		if TomTom.EnableDisablePOIIntegration then TomTom:EnableDisablePOIIntegration() end
	elseif opt == "otherzone" then
		if TomTom.ReloadWaypoints then TomTom:ReloadWaypoints() end
	elseif opt == "enable" and (ns == "minimap" or ns == "worldmap") then
		if TomTom.ReloadWaypoints then TomTom:ReloadWaypoints() end
	elseif opt == "coords_throttle" then
		if TomTom.UpdateCoordFeedThrottle then TomTom:UpdateCoordFeedThrottle() end
	elseif opt == "arrow_throttle" then
		if TomTom.UpdateArrowFeedThrottle then TomTom:UpdateArrowFeedThrottle() end
	end
end

E.Options.args.tomtom = {
	order = 160, -- Alphabetical: T (TomTom)
	type = "group",
	name = "TomTom",
	childGroups = "tab",
	args = {
		-- General Options
		general = {
			order = 1,
			type = "group",
			name = "General Options",
			args = {
				header = ACH:Header("General Options", 1),
				description = ACH:Description("General TomTom settings and behavior.", 2),
				announce = ACH:Toggle("Announce New Waypoints", "Announce new waypoints to the default chat frame when they are added", 3, nil, nil, nil, function() return getTomTomOption("general", "announce") end, function(info, value) setTomTomOption("general", "announce", value) end),
				confirmremoveall = ACH:Toggle("Confirm Remove All", "Ask for confirmation before removing all waypoints", 4, nil, nil, nil, function() return getTomTomOption("general", "confirmremoveall") end, function(info, value) setTomTomOption("general", "confirmremoveall", value) end),
				persistence = {
					order = 5,
					type = "group",
					name = "Waypoint Persistence",
					inline = true,
					args = {
						savewaypoints = ACH:Toggle("Save New Waypoints", "Save new waypoints until manually removed", 1, nil, nil, nil, function() return getTomTomOption("persistence", "savewaypoints") end, function(info, value) setTomTomOption("persistence", "savewaypoints", value) end),
						cleardistance = ACH:Range("Clear Waypoint Distance", "Distance in yards that signals arrival at waypoint (0 = disabled)", 2, {min = 0, max = 150, step = 1}, nil, function() return getTomTomOption("persistence", "cleardistance") end, function(info, value) setTomTomOption("persistence", "cleardistance", value) end),
					}
				},
				corpse_arrow = ACH:Toggle("Auto Waypoint on Death", "Automatically set a waypoint when you die", 6, nil, nil, nil, function() return getTomTomOption("general", "corpse_arrow") end, function(info, value) setTomTomOption("general", "corpse_arrow", value) end),
			}
		},
		
		-- Coordinate Block
		coordblock = {
			order = 2,
			type = "group",
			name = "Coordinate Block",
			args = {
				header = ACH:Header("Coordinate Block", 1),
				description = ACH:Description("TomTom provides you with a floating coordinate display that can be used to determine your current position.", 2),
				enable = ACH:Toggle("Enable Coordinate Block", "Enables a floating block that displays your current position in the current zone", 3, nil, nil, nil, function() return getTomTomOption("block", "enable") end, function(info, value) setTomTomOption("block", "enable", value) end),
				lock = ACH:Toggle("Lock Coordinate Block", "Locks the coordinate block so it can't be accidentally dragged", 4, nil, nil, nil, function() return getTomTomOption("block", "lock") end, function(info, value) setTomTomOption("block", "lock", value) end),
				accuracy = ACH:Range("Coordinate Accuracy", "Controls precision of coordinate display (0=XX,YY 1=XX.X,YY.Y 2=XX.XX,YY.YY)", 5, {min = 0, max = 2, step = 1}, nil, function() return getTomTomOption("block", "accuracy") end, function(info, value) setTomTomOption("block", "accuracy", value) end),
				display = {
					order = 6,
					type = "group",
					name = "Display Settings",
					inline = true,
					args = {
						description = ACH:Description("Customize the appearance of the coordinate block.", 1),
						bordercolor = ACH:Color("Border Color", "Border color", 2, true, nil, nil, nil, nil, nil, nil, function() return getTomTomOption("block", "bordercolor") end, function(info, r, g, b, a) setTomTomOption("block", "bordercolor", r, g, b, a) end),
						bgcolor = ACH:Color("Background Color", "Background color", 3, true, nil, nil, nil, nil, nil, nil, function() return getTomTomOption("block", "bgcolor") end, function(info, r, g, b, a) setTomTomOption("block", "bgcolor", r, g, b, a) end),
						height = ACH:Range("Block Height", "Height of the coordinate block", 4, {min = 5, max = 50, step = 1}, nil, function() return getTomTomOption("block", "height") end, function(info, value) setTomTomOption("block", "height", value) end),
						width = ACH:Range("Block Width", "Width of the coordinate block", 5, {min = 50, max = 250, step = 5}, nil, function() return getTomTomOption("block", "width") end, function(info, value) setTomTomOption("block", "width", value) end),
						fontsize = ACH:Range("Font Size", "Font size for coordinate text", 6, {min = 1, max = 24, step = 1}, nil, function() return getTomTomOption("block", "fontsize") end, function(info, value) setTomTomOption("block", "fontsize", value) end),
						reset_position = ACH:Execute("Reset Position", "Resets the position of the coordinate block", 7, function()
							if TomTomBlock then
								TomTomBlock:ClearAllPoints()
								TomTomBlock:SetPoint("TOP", Minimap, "BOTTOM", -20, -10)
							end
						end),
					}
				},
			}
		},
		
		-- Waypoint Arrow
		crazytaxi = {
			order = 3,
			type = "group",
			name = "Waypoint Arrow",
			args = {
				header = ACH:Header("Waypoint Arrow", 1),
				description = ACH:Description("TomTom provides an arrow that can be placed anywhere on the screen. Similar to the arrow in \"Crazy Taxi\" it will point you towards your next waypoint.", 2),
				enable = ACH:Toggle("Enable Floating Waypoint Arrow", "Show the waypoint arrow", 3, nil, nil, nil, function() return getTomTomOption("arrow", "enable") end, function(info, value) setTomTomOption("arrow", "enable", value) end),
				autoqueue = ACH:Toggle("Automatically Set Waypoint Arrow", "Automatically set new waypoints as the active arrow waypoint", 4, nil, nil, nil, function() return getTomTomOption("arrow", "autoqueue") end, function(info, value) setTomTomOption("arrow", "autoqueue", value) end),
				lock = ACH:Toggle("Lock Waypoint Arrow", "Locks the waypoint arrow so it can't be moved accidentally", 5, nil, nil, nil, function() return getTomTomOption("arrow", "lock") end, function(info, value) setTomTomOption("arrow", "lock", value) end),
				showtta = ACH:Toggle("Show Estimated Time to Arrival", "Shows an estimate of how long it will take you to reach the waypoint", 6, nil, nil, nil, function() return getTomTomOption("arrow", "showtta") end, function(info, value) setTomTomOption("arrow", "showtta", value) end),
				menu = ACH:Toggle("Enable Right-Click Menu", "Enables a menu when right-clicking on the waypoint arrow", 7, nil, nil, nil, function() return getTomTomOption("arrow", "menu") end, function(info, value) setTomTomOption("arrow", "menu", value) end),
				noclick = ACH:Toggle("Disable All Mouse Input", "Disables mouse input, allowing all clicks to pass through", 8, nil, nil, nil, function() return getTomTomOption("arrow", "noclick") end, function(info, value) setTomTomOption("arrow", "noclick", value) end),
				setclosest = ACH:Toggle("Auto Set Closest Waypoint", "Automatically set the closest waypoint as active when current is cleared", 9, nil, nil, nil, function() return getTomTomOption("arrow", "setclosest") end, function(info, value) setTomTomOption("arrow", "setclosest", value) end),
				arrival = ACH:Range("Arrival Distance", "Distance at which arrow switches to downwards arrow (yards)", 10, {min = 0, max = 150, step = 5}, nil, function() return getTomTomOption("arrow", "arrival") end, function(info, value) setTomTomOption("arrow", "arrival", value) end),
				enablePing = ACH:Toggle("Play Sound on Arrival", "Play a sound when arriving at a waypoint", 11, nil, nil, nil, function() return getTomTomOption("arrow", "enablePing") end, function(info, value) setTomTomOption("arrow", "enablePing", value) end),
				display = {
					order = 12,
					type = "group",
					name = "Arrow Display",
					inline = true,
					args = {
						description = ACH:Description("Customize the size and opacity of the waypoint arrow.", 1),
						scale = ACH:Range("Scale", "Scale of the waypoint arrow", 2, {min = 0, max = 3, step = 0.05}, nil, function() return getTomTomOption("arrow", "scale") end, function(info, value) setTomTomOption("arrow", "scale", value) end),
						alpha = ACH:Range("Alpha", "Opacity of the waypoint arrow", 3, {min = 0, max = 1, step = 0.05}, nil, function() return getTomTomOption("arrow", "alpha") end, function(info, value) setTomTomOption("arrow", "alpha", value) end),
						title_width = ACH:Range("Title Width", "Maximum width of the title text (pixels)", 4, {min = 0, max = 500, step = 1}, nil, function() return getTomTomOption("arrow", "title_width") end, function(info, value) setTomTomOption("arrow", "title_width", value) end),
						title_height = ACH:Range("Title Height", "Maximum height of the title text (pixels)", 5, {min = 0, max = 300, step = 1}, nil, function() return getTomTomOption("arrow", "title_height") end, function(info, value) setTomTomOption("arrow", "title_height", value) end),
						title_scale = ACH:Range("Title Scale", "Scale of the title text", 6, {min = 0, max = 3, step = 0.05}, nil, function() return getTomTomOption("arrow", "title_scale") end, function(info, value) setTomTomOption("arrow", "title_scale", value) end),
						title_alpha = ACH:Range("Title Alpha", "Opacity of the title text", 7, {min = 0, max = 1, step = 0.05}, nil, function() return getTomTomOption("arrow", "title_alpha") end, function(info, value) setTomTomOption("arrow", "title_alpha", value) end),
						reset_position = ACH:Execute("Reset Position", "Resets the position of the waypoint arrow", 8, function()
							if TomTomCrazyArrow then
								TomTomCrazyArrow:ClearAllPoints()
								TomTomCrazyArrow:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
							end
						end),
					}
				},
				color = {
					order = 13,
					type = "group",
					name = "Arrow Colors",
					inline = true,
					args = {
						description = ACH:Description("The arrow changes color based on whether you're facing your destination. Green = facing it, Red = facing away.", 1),
						goodcolor = ACH:Color("Good Color", "Color when moving in the direction of the waypoint", 2, false, nil, nil, nil, nil, nil, nil, function() return getTomTomOption("arrow", "goodcolor") end, function(info, r, g, b) setTomTomOption("arrow", "goodcolor", r, g, b) end),
						middlecolor = ACH:Color("Middle Color", "Color when halfway between correct and wrong direction", 3, false, nil, nil, nil, nil, nil, nil, function() return getTomTomOption("arrow", "middlecolor") end, function(info, r, g, b) setTomTomOption("arrow", "middlecolor", r, g, b) end),
						badcolor = ACH:Color("Bad Color", "Color when moving in the opposite direction of the waypoint", 4, false, nil, nil, nil, nil, nil, nil, function() return getTomTomOption("arrow", "badcolor") end, function(info, r, g, b) setTomTomOption("arrow", "badcolor", r, g, b) end),
					}
				},
			}
		},
		
		-- Minimap
		minimap = {
			order = 4,
			type = "group",
			name = "Minimap",
			args = {
				header = ACH:Header("Minimap Waypoints", 1),
				description = ACH:Description("TomTom can display multiple waypoint arrows on the minimap.", 2),
				enable = ACH:Toggle("Enable Minimap Waypoints", "Show waypoints on the minimap", 3, nil, nil, nil, function() return getTomTomOption("minimap", "enable") end, function(info, value) setTomTomOption("minimap", "enable", value) end),
				tooltip = ACH:Toggle("Enable Mouseover Tooltips", "Show tooltips when mousing over waypoints", 4, nil, nil, nil, function() return getTomTomOption("minimap", "tooltip") end, function(info, value) setTomTomOption("minimap", "tooltip", value) end),
				menu = ACH:Toggle("Enable Right-Click Menu", "Enables a menu when right-clicking on a waypoint", 5, nil, nil, nil, function() return getTomTomOption("minimap", "menu") end, function(info, value) setTomTomOption("minimap", "menu", value) end),
			}
		},
		
		-- World Map
		worldmap = {
			order = 5,
			type = "group",
			name = "World Map",
			args = {
				header = ACH:Header("World Map Waypoints", 1),
				description = ACH:Description("TomTom can display multiple waypoints on the world map.", 2),
				enable = ACH:Toggle("Enable World Map Waypoints", "Show waypoints on the world map", 3, nil, nil, nil, function() return getTomTomOption("worldmap", "enable") end, function(info, value) setTomTomOption("worldmap", "enable", value) end),
				tooltip = ACH:Toggle("Enable Mouseover Tooltips", "Show tooltips when mousing over waypoints", 4, nil, nil, nil, function() return getTomTomOption("worldmap", "tooltip") end, function(info, value) setTomTomOption("worldmap", "tooltip", value) end),
				clickcreate = ACH:Toggle("Control-Right Click to Create Waypoint", "Allow control-right clicking on map to create new waypoint", 5, nil, nil, nil, function() return getTomTomOption("worldmap", "clickcreate") end, function(info, value) setTomTomOption("worldmap", "clickcreate", value) end),
				menu = ACH:Toggle("Enable Right-Click Menu", "Enables a menu when right-clicking on a waypoint", 6, nil, nil, nil, function() return getTomTomOption("worldmap", "menu") end, function(info, value) setTomTomOption("worldmap", "menu", value) end),
				create_modifier = ACH:Select("Create Note Modifier", "Modifier key used when right-clicking on the world map to create a waypoint", 7, {
					["A"] = "Alt",
					["C"] = "Ctrl",
					["S"] = "Shift",
					["AC"] = "Alt-Ctrl",
					["AS"] = "Alt-Shift",
					["CS"] = "Ctrl-Shift",
					["ACS"] = "Alt-Ctrl-Shift",
				}, nil, nil, function() return getTomTomOption("worldmap", "create_modifier") end, function(info, value) setTomTomOption("worldmap", "create_modifier", value) end),
				player = {
					order = 8,
					type = "group",
					name = "Player Coordinates",
					inline = true,
					args = {
						playerenable = ACH:Toggle("Enable Player Coordinates", "Show player coordinates on the world map", 1, nil, nil, nil, function() return getTomTomOption("mapcoords", "playerenable") end, function(info, value) setTomTomOption("mapcoords", "playerenable", value) end),
						playeraccuracy = ACH:Range("Player Coordinate Accuracy", "Precision of player coordinates (0=XX,YY 1=XX.X,YY.Y 2=XX.XX,YY.YY)", 2, {min = 0, max = 2, step = 1}, nil, function() return getTomTomOption("mapcoords", "playeraccuracy") end, function(info, value) setTomTomOption("mapcoords", "playeraccuracy", value) end),
					}
				},
				cursor = {
					order = 9,
					type = "group",
					name = "Cursor Coordinates",
					inline = true,
					args = {
						cursorenable = ACH:Toggle("Enable Cursor Coordinates", "Show cursor coordinates on the world map", 1, nil, nil, nil, function() return getTomTomOption("mapcoords", "cursorenable") end, function(info, value) setTomTomOption("mapcoords", "cursorenable", value) end),
						cursoraccuracy = ACH:Range("Cursor Coordinate Accuracy", "Precision of cursor coordinates (0=XX,YY 1=XX.X,YY.Y 2=XX.XX,YY.YY)", 2, {min = 0, max = 2, step = 1}, nil, function() return getTomTomOption("mapcoords", "cursoraccuracy") end, function(info, value) setTomTomOption("mapcoords", "cursoraccuracy", value) end),
					}
				},
			}
		},
		
		-- Quest Objectives
		poi = {
			order = 6,
			type = "group",
			name = "Quest Objectives",
			args = {
				header = ACH:Header("Quest Objective Integration", 1),
				description = ACH:Description("TomTom can be configured to set waypoints for quest objectives shown in the watch frame and world map.", 2),
				enable = ACH:Toggle("Enable Quest Objective Click Integration", "Enable setting waypoints when modified-clicking on quest objectives", 3, nil, nil, nil, function() return getTomTomOption("poi", "enable") end, function(info, value) setTomTomOption("poi", "enable", value) end),
				modifier = ACH:Select("Set Waypoint Modifier", "Modifier key used when clicking on a quest objective POI to create a waypoint", 4, {
					["A"] = "Alt",
					["C"] = "Ctrl",
					["S"] = "Shift",
					["AC"] = "Alt-Ctrl",
					["AS"] = "Alt-Shift",
					["CS"] = "Ctrl-Shift",
					["ACS"] = "Alt-Ctrl-Shift",
				}, nil, nil, function() return getTomTomOption("poi", "modifier") end, function(info, value) setTomTomOption("poi", "modifier", value) end),
				setClosest = ACH:Toggle("Enable Automatic Quest Objective Waypoints", "Automatically set waypoints based on closest objective (overrides manual waypoints)", 5, nil, nil, nil, function() return getTomTomOption("poi", "setClosest") end, function(info, value) setTomTomOption("poi", "setClosest", value) end),
			}
		},
		
		-- Data Feeds
		feeds = {
			order = 8,
			type = "group",
			name = "Data Feed Options",
			args = {
				header = ACH:Header("LibDataBroker Feeds", 1),
				description = ACH:Description("TomTom is capable of providing data sources via LibDataBroker, which allows them to be displayed in any LDB compatible display.", 2),
				coords = ACH:Toggle("Provide LDB Data Source for Coordinates", "Enable coordinate feed for LDB displays", 3, nil, nil, nil, function() return getTomTomOption("feeds", "coords") end, function(info, value) setTomTomOption("feeds", "coords", value) end),
				coords_throttle = ACH:Range("Coordinate Feed Throttle", "Controls the frequency of updates for the coordinate LDB feed", 4, {min = 0, max = 2, step = 0.05}, nil, function() return getTomTomOption("feeds", "coords_throttle") end, function(info, value) setTomTomOption("feeds", "coords_throttle", value) end),
				coords_accuracy = ACH:Range("Coordinate Feed Accuracy", "Precision of coordinate feed (0=XX,YY 1=XX.X,YY.Y 2=XX.XX,YY.YY)", 5, {min = 0, max = 2, step = 1}, nil, function() return getTomTomOption("feeds", "coords_accuracy") end, function(info, value) setTomTomOption("feeds", "coords_accuracy", value) end),
				arrow = ACH:Toggle("Provide LDB Data Source for Arrow", "Enable arrow feed for LDB displays", 6, nil, nil, nil, function() return getTomTomOption("feeds", "arrow") end, function(info, value) setTomTomOption("feeds", "arrow", value) end),
				arrow_throttle = ACH:Range("Arrow Feed Throttle", "Controls the frequency of updates for the arrow LDB feed", 7, {min = 0, max = 2, step = 0.05}, nil, function() return getTomTomOption("feeds", "arrow_throttle") end, function(info, value) setTomTomOption("feeds", "arrow_throttle", value) end),
			}
		},
		
		-- Commands
		commands = {
			order = 99,
			type = "group",
			name = "Commands",
			args = {
				header = ACH:Header("TomTom Commands", 1),
				commandsList = ACH:Description(
					"|cff1784d1TomTom Commands:|r\n" ..
					"  |cffffcc00/way <x> <y> [desc]|r - Add waypoint at coordinates\n" ..
					"  |cffffcc00/way reset|r - Clear all waypoints\n" ..
					"  |cffffcc00/way <waypoint #>|r - Set active waypoint\n" ..
					"  |cffffcc00/way closest|r - Set closest waypoint as active\n\n" ..
					"|cff1784d1Note:|r All TomTom configuration is now available in this menu.\nNo need to use /tomtom command.", 2
				),
			}
		},
	}
}

