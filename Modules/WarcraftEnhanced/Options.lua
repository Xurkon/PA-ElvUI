-- ElvUI WarcraftEnhanced Options Integration
-- Adds WarcraftEnhanced to ElvUI config menu

local E, L, V, P, G = unpack(ElvUI)
local WE = E.WarcraftEnhanced

local ACH = E.Libs.ACH

-- Helper function for options
local function GetOptions()
	local options = ACH:Group("WarcraftEnhanced", nil, nil, "tab", function(info) 
		if E.db and E.db.warcraftenhanced then 
			return E.db.warcraftenhanced[info[#info]] 
		end 
	end, function(info, value) 
		if E.db and E.db.warcraftenhanced then 
			E.db.warcraftenhanced[info[#info]] = value 
		end 
	end)
	
	options.args.header = ACH:Header("WarcraftEnhanced - Fully Integrated", 0)
	options.args.description = ACH:Description(
		"|cff1784d1All WarcraftEnhanced features have been fully integrated into ElvUI!|r\n\n" ..
		"This addon provided Quest Automation (AutoQuest), Omen Threat Meter, PortalBox, and various UI enhancements. " ..
		"All of these features are now accessible directly through ElvUI's native options menu for a more seamless experience.\n\n" ..
		"|cffffcc00Where to find each feature:|r\n\n" ..
		"|cff00ff00Quest Automation (AutoQuest):|r\n" ..
		"  ElvUI → General → Automation → Quest Automation\n" ..
		"  Commands: /aq, /autoquest\n\n" ..
		"|cff00ff00Omen Threat Meter:|r\n" ..
		"  ElvUI → Omen (complete configuration)\n" ..
		"  Commands: /omen, /omen toggle\n\n" ..
		"|cff00ff00PortalBox:|r\n" ..
		"  ElvUI → General → Miscellaneous → PortalBox\n" ..
		"  Commands: /port, /portalbox\n\n" ..
		"|cff00ff00TomTom Navigation:|r\n" ..
		"  ElvUI → TomTom\n" ..
		"  Commands: /way, /way list\n\n" ..
		"|cff00ff00All Commands Reference:|r\n" ..
		"  ElvUI → Commands (comprehensive list)\n\n" ..
		"|cff00ff00UI Enhancements:|r\n" ..
		"  ElvUI → General → BlizzUI Improvements\n\n" ..
		"|cffff9900Note:|r You can safely ignore this menu - everything is now in ElvUI's main options!", 1)
	
	return options
end

-- WarcraftEnhanced options have been fully integrated into ElvUI
-- This options table is no longer registered with ElvUI to avoid clutter
-- All features are accessible through ElvUI's native menus

--[[
-- Insert options into ElvUI (DISABLED - features are now fully integrated)
function WE:InsertOptions()
	E.Options.args.warcraftenhanced = GetOptions()
end

-- Insert options when ElvUI_OptionsUI loads
local function InsertOptions()
	WE:InsertOptions()
end

-- Use the proper ElvUI initialization hook
if IsAddOnLoaded("ElvUI_OptionsUI") then
	InsertOptions()
else
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("ADDON_LOADED")
	frame:SetScript("OnEvent", function(self, event, addon)
		if addon == "ElvUI_OptionsUI" then
			InsertOptions()
			self:UnregisterEvent("ADDON_LOADED")
		end
	end)
end
--]]

