--[[
Copyright (c) 2009, Hendrik "Nevcairiel" Leppkes < h.leppkes@gmail.com >
All rights reserved.

Integrated into ElvUI by Project Ascension
]]

local E, L, V, P, G = unpack(select(2, ...))
local Mapster = E:GetModule("Mapster")
-- Locale reference will be set during initialization

local function GetWorldMapProfile()
	if Mapster and Mapster.EnsureProfileDefaults then
		return Mapster:EnsureProfileDefaults()
	end

	E.db.maps = E.db.maps or {}
	E.db.maps.worldMap = E.db.maps.worldMap or {}
	return E.db.maps.worldMap
end

local optGetter, optSetter
do
	function optGetter(info)
		local profileDB = GetWorldMapProfile()
		local key = info[#info]
		if key:sub(1,5) == "mini_" then
			local mini = profileDB.mini
			return mini and mini[key:sub(6)]
		else
			return profileDB[key]
		end
	end

	function optSetter(info, value)
		local profileDB = GetWorldMapProfile()
		local key = info[#info]
		if key:sub(1,5) == "mini_" then
			profileDB.mini = profileDB.mini or {}
			profileDB.mini[key:sub(6)] = value
		else
			profileDB[key] = value
		end
		Mapster:Refresh()
	end
end

local options, moduleOptions = nil, {}
local function getOptions()
	if not options then
		options = {
			type = "group",
			name = "Mapster",
			args = {
				general = {
					order = 1,
					type = "group",
					name = "General Settings",
					get = optGetter,
					set = optSetter,
					args = {
						intro = {
							order = 1,
							type = "description",
							name = L["Mapster allows you to control various aspects of your World Map. You can change the style of the map, control the plugins that extend the map with new functionality, and configure different profiles for every of your characters."],
						},
						nl = {
							order = 10,
							type = "description",
							name = "",
						},
						arrowScale = {
							order = 11,
							name = L["PlayerArrow Scale"],
							desc = L["Adjust the size of the Player Arrow on the Map for better visibility."],
							type = "range",
							min = 0.5, max = 2, bigStep = 0.01,
							isPercent = true,
						},
						poiScale = {
							order = 12,
							type = "range",
							name = L["POI Scale"],
							desc = L["Scale of the POI Icons on the Map."],
							min = 0.1, max = 2, bigStep = 0.01,
							isPercent = true,
						},
						nl2 = {
							order = 20,
							type = "description",
							name = "",
						},
						hideMapButton = {
							order = 21,
							type = "toggle",
							name = L["Hide Map Button"],
						},
						nl3 = {
							order = 30,
							type = "description",
							name = "",
						},
						hideBorder = {
							order = 31,
							type = "toggle",
							name = L["Hide Border"],
							desc = L["Hide the borders of the big map."],
							disabled = true,
						},
						mini_hideBorder = {
							order = 32,
							type = "toggle",
							name = L["(Mini) Hide Border"],
							desc = L["Hide the borders of the minimized map."],
						},
						disableMouse = {
							order = 33,
							type = "toggle",
							name = L["Disable Mouse"],
							desc = L["Disable the mouse interactivity of the main map, eg. to change zones."],
						},
						mini_disableMouse = {
							order = 34,
							type = "toggle",
							name = L["(Mini) Disable Mouse"],
							desc = L["Disable the mouse interactivity of the main map when in minimized mode, eg. to change zones."],
						},
					},
				},
			},
		}
		-- Add module options in order
		local moduleOrder = {
			["Coords"] = 2,
			["Magnify"] = 3,
			["FogClear"] = 4,
			["GroupIcons"] = 5,
			["BattleMap"] = 6,
			["InstanceMaps"] = 7,
		}
		
		for k,v in pairs(moduleOptions) do
			local modOpt = (type(v) == "function") and v() or v
			if modOpt then
				-- Set order if not already set
				if not modOpt.order and moduleOrder[k] then
					modOpt.order = moduleOrder[k]
				end
				options.args[k] = modOpt
			end
		end
	end
	
	return options
end

function Mapster:SetupOptions()
	-- Options are integrated into ElvUI's options panel
	-- See ElvUI_OptionsUI/Maps.lua
end

function Mapster:RegisterModuleOptions(name, optionTbl, displayName)
	moduleOptions[name] = optionTbl
end

-- Export the options getter for ElvUI's options panel
Mapster.GetOptions = getOptions
Mapster.RegisterModuleOptions = Mapster.RegisterModuleOptions

function Mapster:SetupMapButton()
	-- create button on the worldmap to toggle the options
	self.optionsButton = CreateFrame("Button", "MapsterOptionsButton", WorldMapFrame, "UIPanelButtonTemplate")
	self.optionsButton:SetWidth(95)
	self.optionsButton:SetHeight(18)
	self.optionsButton:SetText("Mapster")
	self.optionsButton:ClearAllPoints()
	self.optionsButton:SetPoint("TOPRIGHT", WorldMapPositioningGuide, "TOPRIGHT", -43, -2)

	local profileDB = GetWorldMapProfile()
	if profileDB.hideMapButton then
		self.optionsButton:Hide()
	else
		self.optionsButton:Show()
	end

	self.optionsButton:SetScript("OnClick", function()
		E:ToggleOptionsUI()
		-- Navigate to Mapster settings
		E.Libs.AceConfigDialog:SelectGroup("ElvUI", "maps", "worldMap")
	end)
end
