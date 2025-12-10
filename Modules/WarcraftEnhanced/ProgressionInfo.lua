local enhancedEnabled
if GetAddOnInfo then
	local _, _, _, enabled = GetAddOnInfo("ElvUI_Enhanced")
	enhancedEnabled = enabled
end
if enhancedEnabled then return end

local E, L = unpack(ElvUI)
local WE = E.WarcraftEnhanced
local PI = E:NewModule("Enhanced_ProgressionInfo", "AceHook-3.0", "AceEvent-3.0")
local TT = E:GetModule("Tooltip")

local pairs = pairs
local ipairs = ipairs
local select = select
local tonumber = tonumber
local format = string.format
local twipe = table.wipe

local CanInspect = CanInspect
local ClearAchievementComparisonUnit = ClearAchievementComparisonUnit
local GetAchievementComparisonInfo = GetAchievementComparisonInfo
local GetAchievementCriteriaInfo = GetAchievementCriteriaInfo
local GetAchievementInfo = GetAchievementInfo
local GetAchievementNumCriteria = GetAchievementNumCriteria
local GetComparisonStatistic = GetComparisonStatistic
local GetStatistic = GetStatistic
local GetTime = GetTime
local InCombatLockdown = InCombatLockdown
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown
local IsShiftKeyDown = IsShiftKeyDown
local SetAchievementComparisonUnit = SetAchievementComparisonUnit
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitIsPlayer = UnitIsPlayer
local UnitLevel = UnitLevel

local MAX_PLAYER_LEVEL = MAX_PLAYER_LEVEL

local difficulties = {"H25", "H10", "N25", "N10"}

local statisticTiers = {
	["RS"] = {
		{4823},
		{4822},
		{4820},
		{4821}
	},
	["ICC"] = {
		{4642, 4656, 4661, 4664, 4667, 4670, 4673, 4676, 4679, 4682, 4685, 4688},
		{4640, 4654, 4659, 4662, 4665, 4668, 4671, 4674, 4677, 4680, 4684, 4686},
		{4641, 4655, 4660, 4663, 4666, 4669, 4672, 4675, 4678, 4681, 4683, 4687},
		{4639, 4643, 4644, 4645, 4646, 4647, 4648, 4649, 4650, 4651, 4652, 4653}
	},
	["ToC"] = {
		{4029, 4035, 4039, 4043, 4047},
		{4030, 4033, 4037, 4041, 4045},
		{4031, 4034, 4038, 4042, 4046},
		{4028, 4032, 4036, 4040, 4044}
	},
	["Ulduar"] = {
		{},
		{},
		{2872, 2873, 2874, 2884, 2885, 2875, 2882, 3256, 3257, 3258, 2879, 2880, 2883, 2881},
		{2856, 2857, 2858, 2859, 2860, 2861, 2868, 2862, 2863, 2864, 2865, 2866, 2869, 2867}
	}
}

local achievementTiers = {
	["RS"] = {
		{4816},
		{4818},
		{4815},
		{4817}
	},
	["ICC"] = {
		{4632, 4633, 4634, 4635, 4584},
		{4628, 4629, 4630, 4631, 4583},
		{4604, 4605, 4606, 4607, 4597},
		{4531, 4528, 4529, 4527, 4530}
	},
	["ToC"] = {
		{3812},
		{3918},
		{3916},
		{3917}
	},
	["Ulduar"] = {
		{},
		{},
		{2887, 2889, 2891, 2893, 3037},
		{2886, 2888, 2890, 2892, 3036}
	}
}

local progressCache = {}

local function EnsureProgressDB()
	if not WE or not WE.db then return end

	WE.db.progression = WE.db.progression or E:CopyTable({}, P.warcraftenhanced.progression)

	local db = WE.db.progression
	db.tiers = db.tiers or {}
	local tiers = db.tiers
	if tiers.RS == nil then tiers.RS = true end
	if tiers.ICC == nil then tiers.ICC = true end
	if tiers.ToC == nil then tiers.ToC = true end
	if tiers.ToGC == nil then tiers.ToGC = true end
	if tiers.Ulduar == nil then tiers.Ulduar = true end

	return db
end

local function isAchievementComplete(achievementID)
	return (select(4, GetAchievementInfo(achievementID))) and 1 or 0
end

local function isAchievementComparisonComplete(achievementID)
	return (GetAchievementComparisonInfo(achievementID)) and 1 or 0
end

local function GetProgression(guid)
	local total, kills, killed, tierName
	local statFunc, tiers

	if progressCache[guid].useAchievements then
		statFunc = guid == E.myguid and isAchievementComplete or isAchievementComparisonComplete
		tiers = achievementTiers
	else
		statFunc = guid == E.myguid and GetStatistic or GetComparisonStatistic
		tiers = statisticTiers
	end

	local header = progressCache[guid].header
	local info = progressCache[guid].info

	for tier in pairs(tiers) do
		header[tier] = header[tier] and twipe(header[tier]) or {}
		info[tier] = info[tier] and twipe(info[tier]) or {}

		for i, difficulty in ipairs(difficulties) do
			if #tiers[tier][i] > 0 then
				total = #tiers[tier][i]
				killed = 0

				for _, statsID in ipairs(tiers[tier][i]) do
					kills = tonumber(statFunc(statsID))

					if kills and kills > 0 then
						killed = killed + 1
					end
				end

				if killed > 0 then
					tierName = tier
					if i <= 2 and tier == "ToC" then
						tierName = "ToGC"
					end

					header[tier][i] = format("%s [%s]:", L[tierName], difficulty)
					info[tier][i] = format("%d/%d", killed, total)

					if killed == total then
						break
					end
				end
			end
		end
	end
end

local function UpdateProgression(guid)
	if not progressCache[guid] then
		progressCache[guid] = {
			header = {},
			info = {},
			useAchievements = false,
		}
	end

	local db = EnsureProgressDB()
	if not db then return end

	progressCache[guid].useAchievements = db.checkAchievements

	progressCache[guid].timer = GetTime()

	GetProgression(guid)
end

local function SetProgressionInfo(guid, tt)
	if not progressCache[guid] then return end

	local db = EnsureProgressDB()
	local tiers = db.checkAchievements and achievementTiers or statisticTiers

	for tier in pairs(tiers) do
	if db.tiers[tier] then
			for i = 1, #difficulties do
				if #tiers[tier][i] > 0 then
					tt:AddDoubleLine(progressCache[guid].header[tier][i], progressCache[guid].info[tier][i], nil, nil, nil, 1, 1, 1)
				end
			end
		end
	end
end

local function ShowInspectInfo(tt)
	if InCombatLockdown() then return end

	local db = EnsureProgressDB()
	if not db then return "SHIFT" end

	local modifier = db.modifier
	if modifier ~= "ALL" and not ((modifier == "SHIFT" and IsShiftKeyDown()) or (modifier == "CTRL" and IsControlKeyDown()) or (modifier == "ALT" and IsAltKeyDown())) then return end

	local unit = select(2, tt:GetUnit())
	if unit == "player" then
		if not db.checkPlayer then return end

		UpdateProgression(E.myguid)
		SetProgressionInfo(E.myguid, tt)
		return
	end

	if not unit or not UnitIsPlayer(unit) then return end

	local level = UnitLevel(unit)
	if not level or level < MAX_PLAYER_LEVEL then return end

	if not CanInspect(unit) then return end

	local guid = UnitGUID(unit)
	local frameShowen = AchievementFrame and AchievementFrame:IsShown()

	if progressCache[guid] and (frameShowen or (GetTime() - progressCache[guid].timer) < 600) then
		SetProgressionInfo(guid, tt)
	elseif not frameShowen then
		PI.compareGUID = guid

		PI:RegisterEvent("INSPECT_ACHIEVEMENT_READY")

		if AchievementFrameComparison then
			AchievementFrameComparison:UnregisterEvent("INSPECT_ACHIEVEMENT_READY")
		end

		ClearAchievementComparisonUnit()
		SetAchievementComparisonUnit(unit)
	end
end

function PI:INSPECT_ACHIEVEMENT_READY()
	UpdateProgression(self.compareGUID)
	ClearAchievementComparisonUnit()

	if UnitExists("mouseover") and UnitGUID("mouseover") == self.compareGUID then
		GameTooltip:SetUnit("mouseover")
	end

	self:UnregisterEvent("INSPECT_ACHIEVEMENT_READY")

	if AchievementFrameComparison then
		AchievementFrameComparison:RegisterEvent("INSPECT_ACHIEVEMENT_READY")
	end

	self.compareGUID = nil
end

function PI:MODIFIER_STATE_CHANGED(_, key)
	if (key == format("L%s", self.modifier) or key == format("R%s", self.modifier)) and UnitExists("mouseover") then
		GameTooltip:SetUnit("mouseover")
	end
end

function PI:UpdateSettings()
	local enabled

	for _, state in pairs(db.tiers) do
		if state then
			enabled = state
			break
		end
	end

	if enabled then
		self:ToggleState()
	else
		self:UnregisterEvent("INSPECT_ACHIEVEMENT_READY")
		self:UnhookAll()
	end
end

function PI:UpdateModifier()
	local db = EnsureProgressDB()
	if not db then return end

	self.modifier = db.modifier

	if self.modifier == "ALL" then
		self:UnregisterEvent("MODIFIER_STATE_CHANGED")
	else
		self:RegisterEvent("MODIFIER_STATE_CHANGED")
	end
end

function PI:ToggleState()
	local progressInfo = EnsureProgressDB()
	if not progressInfo then return end

	if progressInfo.enable then
		if E.private.tooltip.enabled and TT then
			if not self:IsHooked(TT, "GameTooltip_OnTooltipSetUnit", ShowInspectInfo) then
				self:SecureHook(TT, "GameTooltip_OnTooltipSetUnit", ShowInspectInfo)
			end
		else
			if not self:IsHooked(GameTooltip, "OnTooltipSetUnit", ShowInspectInfo) then
				self:HookScript(GameTooltip, "OnTooltipSetUnit", ShowInspectInfo)
			end
		end

		self:UpdateModifier()
	else
		self:UnregisterAllEvents()
		self:UnhookAll()
	end
end

function PI:Initialize()
	local progressInfo = EnsureProgressDB()
	if not progressInfo or not progressInfo.enable then return end

	self.progressCache = progressCache
	self:ToggleState()

	self.initialized = true
end

local function InitializeCallback()
	PI:Initialize()
end

E:RegisterModule(PI:GetName(), InitializeCallback)

