-- WarcraftEnhanced Leatrix Features Module
-- Integrated features from Leatrix Plus

local E, L, V, P, G = unpack(ElvUI)
local WE = E.WarcraftEnhanced
local QH = WarcraftEnhanced or QuestHelper or WE
if not WE then return end

local LF = {}
WE.LeatrixFeatures = LF

local LFEvt = CreateFrame("Frame")
local cameraCVarSettings = {
	{
		name = "cameraDistanceMaxZoomFactor",
		enabled = 2.6,
		disabled = 1.9,
	},
	{
		name = "cameraDistanceMaxFactor",
		enabled = 4,
		disabled = 1,
	},
	{
		name = "cameraDistanceMax",
		enabled = 50,
		disabled = 15,
	},
}

local function GetSocialDB()
	if not WE or not WE.db then return end
	WE.db.social = WE.db.social or E:CopyTable({}, P.warcraftenhanced.social)
	return WE.db.social
end

local function GetAutomationDB()
	if not WE or not WE.db then return end
	WE.db.automation = WE.db.automation or E:CopyTable({}, P.warcraftenhanced.automation)
	return WE.db.automation
end

local function GetSystemDB()
	if not WE or not WE.db then return end
	WE.db.system = WE.db.system or E:CopyTable({}, P.warcraftenhanced.system)
	return WE.db.system
end

----------------------------------------------------------------------
-- Helper: Friend Check (including guild members if enabled)
----------------------------------------------------------------------

function LF:FriendCheck(name, guid)
	-- Do nothing if name is empty
	if not name then return false end
	
	-- Update friends list
	ShowFriends()
	
	-- Remove realm if it exists
	if name ~= nil then
		name = strsplit("-", name, 2)
	end
	
	-- Check character friends
	for i = 1, GetNumFriends() do
		local friendName, _, _, _, friendConnected = GetFriendInfo(i)
		if friendName ~= nil then
			friendName = strsplit("-", friendName, 2)
			if (name == friendName) and friendConnected then
				return true
			end
		end
	end
	
	-- Check guild members if enabled
	local social = GetSocialDB()
	if social and social.friendlyGuild then
		if IsInGuild() then
			local gCount = GetNumGuildMembers()
			for i = 1, gCount do
				local gName, _, _, _, _, _, _, _, gOnline = GetGuildRosterInfo(i)
				if gOnline then
					gName = strsplit("-", gName, 2)
					if (name == gName) then
						return true
					end
				end
			end
		end
	end
	
	return false
end

----------------------------------------------------------------------
-- SOCIAL FEATURES
----------------------------------------------------------------------

-- Block Duels
function LF:SetupBlockDuels()
	local social = GetSocialDB()
	if social and social.blockDuels then
		LFEvt:RegisterEvent("DUEL_REQUESTED")
	else
		LFEvt:UnregisterEvent("DUEL_REQUESTED")
	end
end

-- Block Guild Invites
function LF:SetupBlockGuildInvites()
	local social = GetSocialDB()
	if social and social.blockGuildInvites then
		LFEvt:RegisterEvent("GUILD_INVITE_REQUEST")
	else
		LFEvt:UnregisterEvent("GUILD_INVITE_REQUEST")
	end
end


----------------------------------------------------------------------
-- GROUP FEATURES
----------------------------------------------------------------------

-- Party from Friends
function LF:SetupPartyFromFriends()
	local social = GetSocialDB()
	if not social then
		LFEvt:UnregisterEvent("PARTY_INVITE_REQUEST")
		return
	end

	if social.acceptPartyFriends or social.blockPartyInvites then
		LFEvt:RegisterEvent("PARTY_INVITE_REQUEST")
	else
		LFEvt:UnregisterEvent("PARTY_INVITE_REQUEST")
	end
end

----------------------------------------------------------------------
-- AUTOMATION FEATURES
----------------------------------------------------------------------

-- Release in PvP
function LF:SetupAutoReleasePvP()
	local automation = GetAutomationDB()
	if automation and automation.autoReleasePvP then
		LFEvt:RegisterEvent("PLAYER_DEAD")
	else
		LFEvt:UnregisterEvent("PLAYER_DEAD")
	end
end

-- Auto Spirit Res
function LF:SetupAutoSpiritRes()
	local automation = GetAutomationDB()
	if automation and automation.autoSpiritRes then
		LFEvt:RegisterEvent("RESURRECT_REQUEST")
	else
		LFEvt:UnregisterEvent("RESURRECT_REQUEST")
	end
end

-- Auto Sell Junk
function LF:SetupAutoSellJunk()
	local automation = GetAutomationDB()
	if automation and automation.autoSellJunk then
		LFEvt:RegisterEvent("MERCHANT_SHOW")
		LFEvt:RegisterEvent("MERCHANT_CLOSED")
	else
		LFEvt:UnregisterEvent("MERCHANT_SHOW")
		LFEvt:UnregisterEvent("MERCHANT_CLOSED")
	end
end

-- Auto Repair
function LF:SetupAutoRepair()
	local automation = GetAutomationDB()
	if automation and automation.autoRepair then
		LFEvt:RegisterEvent("MERCHANT_SHOW")
	else
		LFEvt:UnregisterEvent("MERCHANT_SHOW")
	end
end

----------------------------------------------------------------------
-- SYSTEM FEATURES
----------------------------------------------------------------------

-- Max Camera Zoom
function LF:SetupMaxCameraZoom()
	local system = GetSystemDB()
	if not system then return end

	local applied = false
	for _, data in ipairs(cameraCVarSettings) do
		local name = data.name
		if GetCVar(name) ~= nil then
			local value = system.maxCameraZoom and data.enabled or data.disabled
			SetCVar(name, tostring(value))
			applied = true
		end
	end

	if not applied and system.maxCameraZoom then
		WE:Print("Max camera zoom not supported on this client version")
		system.maxCameraZoom = false
	end
end


----------------------------------------------------------------------
-- EVENT HANDLER
----------------------------------------------------------------------

LFEvt:SetScript("OnEvent", function(self, event, ...)
	local arg1, arg2, arg3, arg4, guid = ...
	local social = GetSocialDB()
	local automation = GetAutomationDB()
	
	----------------------------------------------------------------------
	-- Block Duels
	----------------------------------------------------------------------
	if event == "DUEL_REQUESTED" and social and social.blockDuels and not LF:FriendCheck(arg1) then
		CancelDuel()
		StaticPopup_Hide("DUEL_REQUESTED")
		return
	end
	
	----------------------------------------------------------------------
	-- Block Guild Invites
	----------------------------------------------------------------------
	if event == "GUILD_INVITE_REQUEST" and social and social.blockGuildInvites then
		if not LF:FriendCheck(arg1, guid) then
			DeclineGuild()
			StaticPopup_Hide("GUILD_INVITE")
		end
		return
	end
	
	----------------------------------------------------------------------
	-- Party Invites from Friends/Whispers
	----------------------------------------------------------------------
	if event == "PARTY_INVITE_REQUEST" then
		-- If a friend, accept if you're accepting friends
		if social and social.acceptPartyFriends and LF:FriendCheck(arg1, guid) then
			AcceptGroup()
			for i = 1, STATICPOPUP_NUMDIALOGS do
				if _G["StaticPopup" .. i].which == "PARTY_INVITE" then
					_G["StaticPopup" .. i].inviteAccepted = 1
					StaticPopup_Hide("PARTY_INVITE")
					break
				elseif _G["StaticPopup" .. i].which == "PARTY_INVITE_XREALM" then
					_G["StaticPopup" .. i].inviteAccepted = 1
					StaticPopup_Hide("PARTY_INVITE_XREALM")
					break
				end
			end
			return
		end
		
		-- If not a friend and you're blocking invites, decline
		if social and social.blockPartyInvites then
			if not LF:FriendCheck(arg1, guid) then
				DeclineGroup()
				StaticPopup_Hide("PARTY_INVITE")
				StaticPopup_Hide("PARTY_INVITE_XREALM")
			end
		end
		return
	end
	
	----------------------------------------------------------------------
	-- Auto Release in PvP
	----------------------------------------------------------------------
	if event == "PLAYER_DEAD" and automation and automation.autoReleasePvP then
		local sType = select(2, IsActiveBattlefieldArena())
		if sType and sType == "DEATH" then
			C_Timer.After(0.5, function()
				RepopMe()
			end)
		end
		return
	end
	
	----------------------------------------------------------------------
	-- Auto Spirit Res
	----------------------------------------------------------------------
	if event == "RESURRECT_REQUEST" and automation and automation.autoSpiritRes then
		AcceptResurrect()
		StaticPopup_Hide("RESURRECT")
		StaticPopup_Hide("RESURRECT_NO_SICKNESS")
		StaticPopup_Hide("RESURRECT_NO_TIMER")
		return
	end
	
	----------------------------------------------------------------------
	-- Auto Sell Junk
	----------------------------------------------------------------------
	if event == "MERCHANT_SHOW" then
		if automation and automation.autoSellJunk and not IsShiftKeyDown() then
			C_Timer.After(0.2, function()
				local totalPrice = 0
				local itemsSold = 0
				
				for bag = 0, 4 do
					for slot = 1, GetContainerNumSlots(bag) do
						local itemLink = GetContainerItemLink(bag, slot)
						if itemLink then
							local _, _, quality, _, _, _, _, _, _, _, vendorPrice = GetItemInfo(itemLink)
							if quality == 0 and vendorPrice and vendorPrice > 0 then
								local _, count = GetContainerItemInfo(bag, slot)
								totalPrice = totalPrice + (vendorPrice * count)
								itemsSold = itemsSold + count
								UseContainerItem(bag, slot)
							end
						end
					end
				end
				
				if itemsSold > 0 and automation.autoSellJunkSummary then
					local gold, silver, copper = floor(totalPrice / 10000), floor((totalPrice % 10000) / 100), totalPrice % 100
					WE:Print(string.format("Sold %d items for |cffffffff%dg %ds %dc|r", itemsSold, gold, silver, copper))
				end
			end)
		end
		
		-- Auto Repair
		if automation and automation.autoRepair and not IsShiftKeyDown() and CanMerchantRepair() then
			local repairCost, canRepair = GetRepairAllCost()
			if canRepair and repairCost > 0 then
				local useGuildFunds = automation.autoRepairGuildFunds and CanGuildBankRepair() and repairCost <= GetGuildBankWithdrawMoney()
				RepairAllItems(useGuildFunds)
				
				if automation.autoRepairSummary then
					local gold, silver, copper = floor(repairCost / 10000), floor((repairCost % 10000) / 100), repairCost % 100
					local source = useGuildFunds and " (Guild)" or ""
					WE:Print(string.format("Repaired for |cffffffff%dg %ds %dc|r%s", gold, silver, copper, source))
				end
			end
		end
		return
	end
	
	if event == "MERCHANT_CLOSED" then
		-- Cleanup if needed
		return
	end
end)

----------------------------------------------------------------------
-- Initialize Module
----------------------------------------------------------------------

function LF:Initialize()
	self.social = GetSocialDB()
	self.automation = GetAutomationDB()
	self.system = GetSystemDB()

	self:ApplySocial()
	self:ApplyAutomation()
	self:ApplySystem()
-- Silent load
end

function LF:ApplySocial()
	self:SetupBlockDuels()
	self:SetupBlockGuildInvites()
	self:SetupPartyFromFriends()
end

function LF:ApplyAutomation()
	self:SetupAutoReleasePvP()
	self:SetupAutoSpiritRes()
	self:SetupAutoSellJunk()
	self:SetupAutoRepair()
end

function LF:ApplySystem()
	self:SetupMaxCameraZoom()
end

-- Register this module
WE:RegisterModule("LeatrixFeatures", LF)

