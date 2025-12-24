-- ElvUI Omen Options Integration
-- Embeds Omen's existing configuration directly into ElvUI's options menu

local E, L, V, P, G = unpack(ElvUI)

-- Only load if Omen is available
if not Omen then return end

local ACH = E.Libs.ACH
local ACD = E.Libs.AceConfigDialog

-- Function to create the Omen options in ElvUI
local function GetOmenOptions()
	-- Generate Omen's options if they haven't been generated yet
	if Omen.GenerateOptions and not Omen.Options then
		Omen.GenerateOptions()
	end
	
	-- Return Omen's native options table
	return Omen.Options or {
		type = "group",
		name = "Omen",
		args = {
			disabled = {
				type = "description",
				name = "|cffff0000Omen options are not available.|r\n\nMake sure Omen is loaded and initialized.",
			}
		}
	}
end

-- Insert Omen options into ElvUI's options table
function E:SetupOmenOptions()
	if not Omen then return end
	
	-- Add Omen to ElvUI's main options menu
	E.Options.args.omen = {
		order = 110, -- Alphabetical: O
		type = "group",
		name = "Omen",
		childGroups = "tab",
		get = function(info)
			-- Delegate to Omen's options system
			local options = GetOmenOptions()
			if options.get then
				return options.get(info)
			end
		end,
		set = function(info, value)
			-- Delegate to Omen's options system
			local options = GetOmenOptions()
			if options.set then
				options.set(info, value)
			end
		end,
		args = {}, -- Will be populated dynamically
	}
	
	-- Get Omen's options and merge them in
	local omenOptions = GetOmenOptions()
	if omenOptions and omenOptions.args then
		-- Copy all of Omen's option groups into ElvUI's structure
		-- Exclude the Help file (warrior-specific, not needed)
		for key, value in pairs(omenOptions.args) do
			if key ~= "Help" then -- Exclude Help File
				E.Options.args.omen.args[key] = value
			end
		end
	end
end

-- Hook into ElvUI's options initialization
local function InitializeOmenOptions()
	if E.private and E.private.general and Omen then
		E:SetupOmenOptions()
		
		-- Override Omen's ShowConfig function to open ElvUI options instead
		-- This needs to happen after Omen is fully loaded
		local function HookShowConfig()
			if Omen and Omen.ShowConfig then
				local originalShowConfig = Omen.ShowConfig
				Omen.ShowConfig = function(self)
					-- Open ElvUI options to Omen section instead of Blizzard Interface Options
					if E.Libs.AceConfigDialog then
						E:ToggleOptionsUI("omen")
					else
						-- Fallback to original if ElvUI options aren't available
						originalShowConfig(self)
					end
				end
			end
		end
		
		-- Hook immediately if Omen is ready, otherwise wait for PLAYER_LOGIN
		if Omen.ShowConfig then
			HookShowConfig()
		else
			local hookFrame = CreateFrame("Frame")
			hookFrame:RegisterEvent("PLAYER_LOGIN")
			hookFrame:SetScript("OnEvent", function(self)
				HookShowConfig()
				self:UnregisterEvent("PLAYER_LOGIN")
			end)
		end
	end
end

-- Initialize when ElvUI_OptionsUI loads
if IsAddOnLoaded("ElvUI_OptionsUI") then
	InitializeOmenOptions()
else
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("ADDON_LOADED")
	frame:SetScript("OnEvent", function(self, event, addon)
		if addon == "ElvUI_OptionsUI" then
			InitializeOmenOptions()
			self:UnregisterEvent("ADDON_LOADED")
		end
	end)
end

