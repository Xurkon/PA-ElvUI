local E, L, V, P, G = unpack(ElvUI)
local M = E:NewModule("Enhanced_Misc", "AceHook-3.0", "AceEvent-3.0")

function M:Initialize()
	self:ToggleQuestReward()
	self:WatchedFaction()
	self:QuestLevelToggle()
end

local function InitializeCallback()
	M:Initialize()
end

E:RegisterModule(M:GetName(), InitializeCallback)