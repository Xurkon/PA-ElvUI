local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

--Lua functions
local _G = _G
local pcall = pcall
local ipairs = ipairs
--WoW API / Variables
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown

-- Create stub CompactRaidFrameManager IMMEDIATELY at file load time
-- This must happen before VARIABLES_LOADED event fires
if not CompactRaidFrameManager then
	local dummy = CreateFrame("Frame", "CompactRaidFrameManager")
	dummy:Hide()
	
	-- Add expected methods that return safe values
	dummy.SetSetting = function() end
	dummy.UpdateShown = function() end
	dummy.GetSetting = function() return "0" end
	
	-- Add container property
	dummy.container = CreateFrame("Frame", nil, dummy)
	dummy.container.UpdateDisplayedUnits = function() end
	dummy.container.TryUpdate = function() end
	
	-- Add displayFrame with a proper dropdown
	dummy.displayFrame = CreateFrame("Frame", nil, dummy)
	
	-- Create the profile selector dropdown
	dummy.displayFrame.profileSelector = CreateFrame("Frame", "CompactUnitFrameProfilesRaidStylePartyFrames", dummy.displayFrame)
	dummy.displayFrame.profileSelector.type = 1
	dummy.displayFrame.profileSelector.cvar = "useCompactPartyFrames"
	dummy.displayFrame.profileSelector.setFunc = function() end
	
	-- Create a stub dropdown to prevent UIDropDownMenu errors
	local dropdown = CreateFrame("Frame", "CompactUnitFrameProfilesProfileSelector", dummy.displayFrame, "UIDropDownMenuTemplate")
	dropdown:Hide()
	dummy.displayFrame.profileSelector.dropdown = dropdown
	
	_G["CompactRaidFrameManager"] = dummy
end

-- Now create the module
local TF = E:NewModule("TaintFix", "AceEvent-3.0")

-- Module initialized flag
TF.Initialized = false

-- Function to ensure CompactRaidFrameManager exists (for manual calls)
local function EnsureCompactRaidFrameManager()
	-- This is now mostly a no-op since we create it at file load,
	-- but kept for backwards compatibility with the rest of the code
	if not CompactRaidFrameManager then
		-- Shouldn't happen, but just in case
		local dummy = CreateFrame("Frame", "CompactRaidFrameManager")
		dummy:Hide()
		dummy.SetSetting = function() end
		dummy.UpdateShown = function() end
		dummy.GetSetting = function() return "0" end
		dummy.container = CreateFrame("Frame", nil, dummy)
		dummy.container.UpdateDisplayedUnits = function() end
		dummy.container.TryUpdate = function() end
		dummy.displayFrame = CreateFrame("Frame", nil, dummy)
		dummy.displayFrame.profileSelector = CreateFrame("Frame", "CompactUnitFrameProfilesRaidStylePartyFrames", dummy.displayFrame)
		dummy.displayFrame.profileSelector.type = 1
		dummy.displayFrame.profileSelector.cvar = "useCompactPartyFrames"
		dummy.displayFrame.profileSelector.setFunc = function() end
		_G["CompactRaidFrameManager"] = dummy
	end
	
	if TF.Initialized and E.db and E.db.general and E.db.general.taintFix and E.db.general.taintFix.debug then
		E:Print("|cff00ff00TaintFix:|r Verified CompactRaidFrameManager stub exists")
	end
end

-- Protect action bar buttons from taint
function TF:ProtectActionBarButtons()
	if InCombatLockdown() then
		return
	end
	
	-- Check if settings exist and are enabled
	if not E.db or not E.db.general or not E.db.general.taintFix or not E.db.general.taintFix.enableActionBarFix then
		return
	end
	
	-- Protect MultiBar buttons from taint
	local barNames = {
		"MultiBarBottomLeft",
		"MultiBarBottomRight",
		"MultiBarRight",
		"MultiBarLeft",
	}
	
	for _, barName in ipairs(barNames) do
		for i = 1, 12 do
			local buttonName = barName .. "Button" .. i
			local button = _G[buttonName]
			if button then
				-- Ensure the button has secure attributes set
				if button.SetAttribute then
					pcall(function()
						button:SetAttribute("allowSecureActions", true)
					end)
				end
			end
		end
	end
	
	-- Also protect main action bar
	for i = 1, 12 do
		local button = _G["ActionButton" .. i]
		if button and button.SetAttribute then
			pcall(function()
				button:SetAttribute("allowSecureActions", true)
			end)
		end
	end
end

-- Protect CompactRaidFrames from taint
function TF:ProtectCompactRaidFrames()
	if InCombatLockdown() then
		return
	end
	
	-- Check if settings exist and are enabled
	if not E.db or not E.db.general or not E.db.general.taintFix or not E.db.general.taintFix.enableCompactRaidFrameFix then
		return
	end
	
	-- Ensure CompactRaidFrameManager exists
	EnsureCompactRaidFrameManager()
	
	-- Protect CompactRaidFrame elements
	for i = 1, 40 do
		local frame = _G["CompactRaidFrame" .. i]
		if frame and frame.SetAttribute then
			pcall(function()
				frame:SetAttribute("allowSecureModifications", true)
			end)
		end
	end
	
	-- Protect CompactPartyFrame elements
	for i = 1, 4 do
		local frame = _G["CompactPartyFrameMember" .. i]
		if frame and frame.SetAttribute then
			pcall(function()
				frame:SetAttribute("allowSecureModifications", true)
			end)
		end
	end
end

-- Fix for RaidProfiles trying to access nil CompactRaidFrameManager
function TF:FixRaidProfiles()
	-- Stub out the problematic RaidProfiles functions to prevent errors
	if CompactUnitFrameProfiles_ActivateRaidProfile then
		local original = CompactUnitFrameProfiles_ActivateRaidProfile
		CompactUnitFrameProfiles_ActivateRaidProfile = function(profile)
			if not CompactRaidFrameManager or not CompactRaidFrameManager.displayFrame then
				-- Silently return if the frame doesn't exist
				if E.db and E.db.general and E.db.general.taintFix and E.db.general.taintFix.debug then
					E:Print("|cff00ff00TaintFix:|r Blocked RaidProfiles call - CompactRaidFrameManager missing")
				end
				return
			end
			return original(profile)
		end
	end
	
	if CompactUnitFrameProfiles_ValidateProfilesLoaded then
		local original = CompactUnitFrameProfiles_ValidateProfilesLoaded
		CompactUnitFrameProfiles_ValidateProfilesLoaded = function()
			if not CompactRaidFrameManager then
				-- Silently return if the frame doesn't exist
				return
			end
			return original()
		end
	end
end

-- Apply all taint fixes
function TF:ApplyFixes()
	-- Check if database and settings exist
	if not E.db or not E.db.general or not E.db.general.taintFix then
		return
	end
	
	if not E.db.general.taintFix.enable then
		return
	end
	
	if E.db.general.taintFix.enableActionBarFix then
		self:ProtectActionBarButtons()
	end
	
	if E.db.general.taintFix.enableCompactRaidFrameFix then
		self:ProtectCompactRaidFrames()
		self:FixRaidProfiles()
	end
	
	if E.db.general.taintFix.debug then
		E:Print("|cff00ff00TaintFix:|r Applied taint protection fixes")
	end
end

-- Event handler for reapplying fixes
function TF:PLAYER_ENTERING_WORLD()
	self:ApplyFixes()
end

function TF:PLAYER_REGEN_ENABLED()
	-- When leaving combat, reapply fixes in case they were queued
	self:ApplyFixes()
end

function TF:UPDATE_BINDINGS()
	if not InCombatLockdown() then
		self:ApplyFixes()
	end
end

-- Toggle the module
function TF:Toggle()
	-- Check if settings exist
	if not E.db or not E.db.general or not E.db.general.taintFix then
		return
	end
	
	if E.db.general.taintFix.enable then
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		self:RegisterEvent("UPDATE_BINDINGS")
		self:ApplyFixes()
	else
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		self:UnregisterEvent("UPDATE_BINDINGS")
	end
end

-- Initialize the module
function TF:Initialize()
	-- Check if database exists before accessing settings
	if E.db and E.db.general and E.db.general.taintFix then
		-- Apply fixes immediately on load if enabled
		if E.db.general.taintFix.enable then
			self:ApplyFixes()
			self:RegisterEvent("PLAYER_ENTERING_WORLD")
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
			self:RegisterEvent("UPDATE_BINDINGS")
		end
	else
		-- If settings don't exist yet, just register events to try again later
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
	end
	
	self.Initialized = true
end

local function InitializeCallback()
	TF:Initialize()
end

E:RegisterModule(TF:GetName(), InitializeCallback)

