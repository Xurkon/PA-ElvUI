local E = unpack(ElvUI)
local WE = E.WarcraftEnhanced
local QH = WarcraftEnhanced or QuestHelper or WE

local LootRollEnhancement = CreateFrame("Frame")
LootRollEnhancement.isHooked = false

local function GetDB()
	if not WE or not WE.db then return end

	WE.db.lootRoll = WE.db.lootRoll or E:CopyTable({}, P.warcraftenhanced.lootRoll)
	return WE.db.lootRoll
end

function LootRollEnhancement:Initialize()
	self.db = GetDB()
	if not self.db then
		return
	end

	self:Enable()
end

function LootRollEnhancement:Enable()
	if self.isHooked then return end

	hooksecurefunc("StaticPopup_Show", function(which)
		if which == "CONFIRM_LOOT_ROLL" then
			local db = GetDB()
			if not db or not db.skipConfirmation then
				return
			end

			C_Timer.After(0.01, function()
				local dialog = StaticPopup_FindVisible("CONFIRM_LOOT_ROLL")
				if dialog and dialog.button1 and dialog.button1:IsEnabled() then
					dialog.button1:Click()
				end
			end)
		end
	end)

	self.isHooked = true
end

function LootRollEnhancement:SetSkipConfirmation(enabled)
	local db = GetDB()
	if not db then return end

	db.skipConfirmation = enabled
	if enabled then
		WE:Print("Loot roll confirmation skip enabled")
	else
		WE:Print("Loot roll confirmation skip disabled")
	end
end

QH:RegisterModule("LootRollEnhancement", LootRollEnhancement)
WE.LootRollEnhancement = LootRollEnhancement

