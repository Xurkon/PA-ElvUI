-- WarcraftEnhanced Macro Button
-- Creates a clickable button in spellbook that can be dragged to action bars

local QH = QH or WarcraftEnhanced

local MacroButton = {}
QH.MacroButton = MacroButton

-- Configuration
local MACRO_NAME = "WarcraftEnhanced_Options"
local MACRO_ICON = 1  -- Question mark icon (icon index)
local PORTALBOX_MACRO_NAME = "PortalBox_Options"
local PORTALBOX_MACRO_ICON = 1  -- Teleport icon (icon index)

-- Create or update the main WarcraftEnhanced macro
local function CreateMacroButton()
	if InCombatLockdown() then
		-- Queue for after combat
		C_Timer.After(1, CreateMacroButton)
		return
	end
	
	-- Check if macro already exists
	local macroIndex = GetMacroIndexByName(MACRO_NAME)
	
	-- Macro text - opens WarcraftEnhanced options
	local macroText = "/script if WarcraftEnhanced then local ACE = LibStub('AceConfigDialog-3.0', true); if ACE then ACE:Open('WarcraftEnhanced') else QH = QH or WarcraftEnhanced; if QH and QH.OpenOptions then QH.OpenOptions() end end end"
	
	if macroIndex == 0 then
		-- Macro doesn't exist, create it
		local numGlobal, numAccount = GetNumMacros()
		local numLocal = numGlobal - numAccount
		
		if numGlobal >= 18 then
			QH:Print("Warning: Too many macros exist. Cannot create WarcraftEnhanced macro button.")
			return
		end
		
		local accountWide = false  -- Per character macro
		CreateMacro(MACRO_NAME, MACRO_ICON, macroText, accountWide)
		QH:Print("Created WarcraftEnhanced spellbook button!")
	else
		-- Macro exists, update it
		EditMacro(macroIndex, MACRO_NAME, MACRO_ICON, macroText)
	end
end

-- Create or update the PortalBox macro
local function CreatePortalBoxMacro()
	if InCombatLockdown() then
		-- Queue for after combat
		C_Timer.After(1, CreatePortalBoxMacro)
		return
	end
	
	-- Check if macro already exists
	local macroIndex = GetMacroIndexByName(PORTALBOX_MACRO_NAME)
	
	-- Macro text - opens WarcraftEnhanced options to PortalBox tab
	local macroText = "/script if WarcraftEnhanced then local ACE = LibStub('AceConfigDialog-3.0', true); if ACE then ACE:Open('WarcraftEnhanced'); ACE:SelectGroup('WarcraftEnhanced', 'portalbox') end end"
	
	if macroIndex == 0 then
		-- Macro doesn't exist, create it
		local numGlobal, numAccount = GetNumMacros()
		local numLocal = numGlobal - numAccount
		
		if numGlobal >= 18 then
			QH:Print("Warning: Too many macros exist. Cannot create PortalBox macro button.")
			return
		end
		
		local accountWide = false  -- Per character macro
		CreateMacro(PORTALBOX_MACRO_NAME, PORTALBOX_MACRO_ICON, macroText, accountWide)
		QH:Print("Created PortalBox spellbook button!")
	else
		-- Macro exists, update it
		EditMacro(macroIndex, PORTALBOX_MACRO_NAME, PORTALBOX_MACRO_ICON, macroText)
	end
end

-- Initialize macro button on login
function MacroButton:Initialize()
	-- Schedule macro creation after a short delay to ensure everything is loaded
	C_Timer.After(3, function()
		CreateMacroButton()
		CreatePortalBoxMacro()  -- Also create PortalBox macro for mages
	end)
	
	-- Silent load
end

-- Clean up on addon unload
function MacroButton:Shutdown()
	-- Don't delete the macro, user might want to keep it
end

-- Register module
QH:RegisterModule("MacroButton", MacroButton)

