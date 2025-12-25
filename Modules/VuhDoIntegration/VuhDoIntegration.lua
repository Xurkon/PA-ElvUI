local E, L, V, P, G = unpack(ElvUI)
local VDI = E:NewModule("VuhDoIntegration")

local _G = _G

-- Disable VuhDo's original slash commands and redirect to ElvUI
function VDI:DisableVuhDoCommands()
	-- Override VuhDo's slash command function
	if VUHDO_slashCmd then
		local originalSlashCmd = VUHDO_slashCmd
		
		VUHDO_slashCmd = function(aCommand)
			-- Redirect all commands to ElvUI config
			E:Print("|cff1784d1VuhDo|r options are now integrated into ElvUI.")
			E:Print("Use |cff00ff00/ec|r and navigate to the |cff1784d1VuhDo|r section.")
			
			-- Still allow the command to work for showing the options frame
			if aCommand and (string.find(aCommand:lower(), "opt") or aCommand == "" or aCommand == nil) then
				-- Open ElvUI config to VuhDo section
				E:ToggleOptions("vuhdo")
			else
				-- For other commands, inform user
				E:Print("VuhDo command |cffFFFF00/"..aCommand.."|r has been disabled.")
				E:Print("All VuhDo features are accessible through |cff00ff00/ec|r → VuhDo")
			end
		end
	end
	
	-- Override slash commands
	SLASH_VUHDO1 = "/vuhdo"
	SLASH_VUHDO2 = "/vd"
	SlashCmdList["VUHDO"] = function(msg)
		VUHDO_slashCmd(msg)
	end
end


function VDI:Initialize()
	-- Wait for VuhDo to fully load
	if not IsAddOnLoaded("VuhDo") then
		local frame = CreateFrame("Frame")
		frame:RegisterEvent("ADDON_LOADED")
		frame:SetScript("OnEvent", function(self, event, addon)
			if addon == "VuhDo" then
				VDI:DisableVuhDoCommands()
				self:UnregisterEvent("ADDON_LOADED")
			end
		end)
	else
		self:DisableVuhDoCommands()
	end
	
	E:Print("|cff1784d1VuhDo|r is now integrated with ElvUI. Use |cff00ff00/ec|r to access options.")
end

E:RegisterModule(VDI:GetName())

