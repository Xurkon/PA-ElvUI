-- ElvUI WarcraftEnhanced Module
-- Integrates WarcraftEnhanced features into ElvUI

local E, L, V, P, G = unpack(ElvUI)
local WE = E:NewModule("WarcraftEnhanced", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0")

-- Make module globally accessible
E.WarcraftEnhanced = WE
_G.WarcraftEnhanced = WE
_G.QuestHelper = WE -- Backwards compatibility

-- Version
WE.version = "2.0.0-ElvUI"
WE.modules = {}

local autoQuestKeys = {"autoAccept", "autoDaily", "autoFate", "autoRepeat", "autoComplete", "autoHighRisk"}
local uiEnhancementKeys = {"errorFiltering", "autoDelete"}
local socialKeys = {"blockDuels", "blockGuildInvites", "blockPartyInvites"}
local automationKeys = {"autoReleasePvP", "autoSpiritRes", "autoSellJunk", "autoSellJunkSummary", "autoRepair", "autoRepairGuildFunds", "autoRepairSummary"}
local systemKeys = {"maxCameraZoom"}

local function MergeDefaults(dest, src)
	if not dest or not src then return end

	for key, value in pairs(src) do
		if type(value) == "table" then
			dest[key] = dest[key] or {}
			MergeDefaults(dest[key], value)
		elseif dest[key] == nil then
			dest[key] = value
		end
	end
end

function WE:Initialize()
	-- Database shortcut
	if not E.db or not E.db.warcraftenhanced then
		self:ScheduleTimer("Initialize", 1)
		return
	end
	self.db = E.db.warcraftenhanced

	self.db.autoQuest = self.db.autoQuest or {}
	MergeDefaults(self.db.autoQuest, P.warcraftenhanced.autoQuest)
	self.db.autoQuest.overrideList = self.db.autoQuest.overrideList or {}

	for _, key in ipairs(autoQuestKeys) do
		if self.db[key] ~= nil then
			self.db.autoQuest[key] = self.db[key]
			self.db[key] = nil
		end
	end

	if type(_G.AutoQuestSave) == "table" then
		for _, key in ipairs(autoQuestKeys) do
			if _G.AutoQuestSave[key] ~= nil then
				self.db.autoQuest[key] = _G.AutoQuestSave[key]
			end
		end

		if type(_G.AutoQuestSave.overrideList) == "table" then
			for quest, value in pairs(_G.AutoQuestSave.overrideList) do
				self.db.autoQuest.overrideList[quest] = value
			end
		end
	end

	self.db.portalBox = self.db.portalBox or {}
	MergeDefaults(self.db.portalBox, P.warcraftenhanced.portalBox)

	self.db.buttonGrabber = self.db.buttonGrabber or {}
	MergeDefaults(self.db.buttonGrabber, P.warcraftenhanced.buttonGrabber)

	self.db.uiEnhancements = self.db.uiEnhancements or {}
	MergeDefaults(self.db.uiEnhancements, P.warcraftenhanced.uiEnhancements)
	if self.db.errorFilters then
		self.db.uiEnhancements.errorFilters = E:CopyTable({}, self.db.errorFilters)
		self.db.errorFilters = nil
	end
	self.db.uiEnhancements.errorFilters = self.db.uiEnhancements.errorFilters or {}
	for _, key in ipairs(uiEnhancementKeys) do
		if self.db[key] ~= nil then
			self.db.uiEnhancements[key] = self.db[key]
			self.db[key] = nil
		end
	end

	self.db.social = self.db.social or {}
	MergeDefaults(self.db.social, P.warcraftenhanced.social)
	for _, key in ipairs(socialKeys) do
		if self.db[key] ~= nil then
			self.db.social[key] = self.db[key]
			self.db[key] = nil
		end
	end

	self.db.automation = self.db.automation or {}
	MergeDefaults(self.db.automation, P.warcraftenhanced.automation)
	for _, key in ipairs(automationKeys) do
		if self.db[key] ~= nil then
			self.db.automation[key] = self.db[key]
			self.db[key] = nil
		end
	end

	self.db.system = self.db.system or {}
	MergeDefaults(self.db.system, P.warcraftenhanced.system)
	self.db.lootRoll = self.db.lootRoll or {}
	MergeDefaults(self.db.lootRoll, P.warcraftenhanced.lootRoll)

	self.db.progression = self.db.progression or {}
	MergeDefaults(self.db.progression, P.warcraftenhanced.progression)

	self.db.achievements = self.db.achievements or {}
	MergeDefaults(self.db.achievements, P.warcraftenhanced.achievements)

	self.db.omen = self.db.omen or {}
	MergeDefaults(self.db.omen, P.warcraftenhanced.omen)

	for _, key in ipairs(systemKeys) do
		if self.db[key] ~= nil then
			self.db.system[key] = self.db[key]
			self.db[key] = nil
		end
	end
	
	-- Initialize sub-modules
	self:InitializeUIEnhancements()
	self:InitializeAutoQuest()
	self:InitializeLeatrixFeatures()
	self:InitializeLootRoll()
	self:InitializeMacroButton()
	self:InitializePortalBox()
	self:InitializeMinimapButtonGrabber()

	self:RegisterEvent("PLAYER_LOGOUT")
	
	-- TomTom and Omen load separately (they're full addons)
	-- We just integrate their settings into our options
	
	-- Silent load - no chat spam
end

-- Print function
function WE:Print(msg)
	E:Print("|cff00ff00[WarcraftEnhanced]|r " .. msg)
end

-- Module registration (for sub-features)
function WE:RegisterModule(name, module)
	self.modules[name] = module
end

-- Placeholder init functions (actual implementations in their respective files)
function WE:InitializeUIEnhancements()
	if self.modules.UIEnhancements and self.modules.UIEnhancements.Initialize then
		self.modules.UIEnhancements:Initialize()
	end
end

function WE:InitializeAutoQuest()
	self.db.autoQuest = self.db.autoQuest or E:CopyTable({}, P.warcraftenhanced.autoQuest)
	self.db.autoQuest.overrideList = self.db.autoQuest.overrideList or {}

	AutoQuestSave = self.db.autoQuest
end

function WE:InitializeLeatrixFeatures()
	if self.modules.LeatrixFeatures and self.modules.LeatrixFeatures.Initialize then
		self.modules.LeatrixFeatures:Initialize()
	end
end

function WE:InitializeLootRoll()
	if self.modules.LootRollEnhancement and self.modules.LootRollEnhancement.Initialize then
		self.modules.LootRollEnhancement:Initialize()
	end
end

function WE:InitializeMacroButton()
	-- MacroButton auto-initializes
end

function WE:InitializePortalBox()
	if self.modules.PortalBox and self.modules.PortalBox.Initialize then
		self.modules.PortalBox:Initialize()
	end
end

function WE:InitializeMinimapButtonGrabber()
	if self.modules.MinimapButtonGrabber and self.modules.MinimapButtonGrabber.HandleEnableState then
		self.modules.MinimapButtonGrabber:HandleEnableState()
	end
end

function WE:PLAYER_LOGOUT()
	_G.AutoQuestSave = nil
end

-- Slash commands (WarcraftEnhanced is now fully integrated into ElvUI)
SLASH_WARCRAFTENHANCED1 = "/warcraftenhanced"
SLASH_WARCRAFTENHANCED2 = "/we"
SLASH_WARCRAFTENHANCED3 = "/wce"
SlashCmdList["WARCRAFTENHANCED"] = function(msg)
	msg = msg:lower():trim()
	
	WE:Print("|cff1784d1WarcraftEnhanced features are now fully integrated into ElvUI!|r")
	WE:Print(" ")
	WE:Print("|cffffcc00Feature locations:|r")
	WE:Print("  Quest Automation: |cff00ff00/elvui|r → General → Automation")
	WE:Print("  PortalBox: |cff00ff00/elvui|r → General → Miscellaneous")
	WE:Print("  Omen: |cff00ff00/elvui|r → Omen")
	WE:Print("  Commands: |cff00ff00/elvui|r → Commands")
	WE:Print(" ")
	WE:Print("|cffffcc00Quick commands:|r")
	WE:Print("  /aq - Quest automation")
	WE:Print("  /port - PortalBox window")
	WE:Print("  /omen - Omen threat meter")
	WE:Print("  /way - TomTom waypoints")
end

E:RegisterModule(WE:GetName())

