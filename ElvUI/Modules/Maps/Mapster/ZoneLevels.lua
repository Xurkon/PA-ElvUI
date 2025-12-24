--[[
Integrated Cromulent-style zone info for Mapster within ElvUI.
Displays zone level ranges, instance information, and fishing requirements on the world map.
]]

local E, L, V, P, G = unpack(select(2, ...))
local Mapster = E:GetModule("Mapster")
if not Mapster then return end

local MODNAME = "ZoneLevels"
local ZoneLevels = Mapster:NewModule(MODNAME, "AceHook-3.0")

local Tourist = E.Libs.Tourist
local LibStub = LibStub
local pairs = pairs
local string_format = string.format
local string_gsub = string.gsub
local table_concat = table.concat
local table_insert = table.insert
local table_wipe = table.wipe

local GetMapContinents = GetMapContinents
local GetCurrentMapContinent = GetCurrentMapContinent
local GetNumSkillLines = GetNumSkillLines
local GetPlayerMapPosition = GetPlayerMapPosition
local GetSkillLineInfo = GetSkillLineInfo
local GetSpellInfo = GetSpellInfo
local WorldMapFrameAreaLabel = WorldMapFrameAreaLabel
local WorldMapFrameAreaDescription = WorldMapFrameAreaDescription

local defaults = {
	profile = {
		showZoneLevels = true,
		showInstances = true,
		showFishing = true,
		colorizeByFaction = true,
	},
}

local db
local lastZone -- so we don't rebuild display every frame
local lastFishingText
local displayLines = {}
local fishingSpell
local updateElapsed = 0
local updateInterval = 0.15

local function GetAreaTextElements()
	local areaFrame = _G.WorldMapFrameAreaFrame
	local label = _G.WorldMapFrameAreaLabel or (areaFrame and (areaFrame.Label or areaFrame.AreaLabel))
	local description = _G.WorldMapFrameAreaDescription or (areaFrame and (areaFrame.Description or areaFrame.SubLabel or areaFrame.AreaDescription))

	return label, description
end

-- remove previously appended level suffix from a font string
local function StripSuffix(fontString, suffix)
	if suffix then
		local current = fontString:GetText()
		if current and current:sub(-#suffix) == suffix then
			fontString:SetText(current:sub(1, -#suffix - 1))
		end
	end
end

local optGetter, optSetter
do
	local mod = ZoneLevels
	function optGetter(info)
		return db[info[#info]]
	end

	function optSetter(info, value)
		db[info[#info]] = value
		mod:Refresh()
	end
end

local options
local function getOptions()
	if not options then
		options = {
			type = "group",
			name = L["Zone Info"],
			arg = MODNAME,
			get = optGetter,
			set = optSetter,
			args = {
				intro = {
					order = 1,
					type = "description",
					name = L["Display Cromulent-style zone information on the world map."],
				},
				enabled = {
					order = 2,
					type = "toggle",
					name = L["Enable Zone Info"],
					get = function() return Mapster:GetModuleEnabled(MODNAME) end,
					set = function(_, value) Mapster:SetModuleEnabled(MODNAME, value) end,
				},
				showZoneLevels = {
					order = 3,
					type = "toggle",
					name = L["Show Zone Levels"],
				},
				showInstances = {
					order = 4,
					type = "toggle",
					name = L["Show Instances"],
				},
				showFishing = {
					order = 5,
					type = "toggle",
					name = L["Show Fishing Skill"],
				},
				colorizeByFaction = {
					order = 6,
					type = "toggle",
					name = L["Colorize Zone Names"],
				},
			},
		}
	end

	return options
end

function ZoneLevels:OnInitialize()
	self.db = Mapster.db:RegisterNamespace(MODNAME, defaults)
	db = self.db.profile

	if Mapster:GetModuleEnabled(MODNAME) == nil then
		Mapster:SetModuleEnabled(MODNAME, true)
	end

	self:SetEnabledState(Mapster:GetModuleEnabled(MODNAME) ~= false)
	Mapster:RegisterModuleOptions(MODNAME, getOptions, L["Zone Info"])

	if self:IsEnabled() then
		self:Enable()
	end
end

function ZoneLevels:OnEnable()
	Tourist = E.Libs.Tourist or LibStub("LibTourist-3.0", true)
	if not Tourist then
		E:Print("LibTourist-3.0 was not found; Zone Info module disabled.")
		self:SetEnabledState(false)
		Mapster:SetModuleEnabled(MODNAME, false)
		return
	end

	if not self.frame then
		local areaLabel, areaDescription = GetAreaTextElements()
		self.frame = CreateFrame("Frame", "MapsterZoneInfoFrame", WorldMapFrame or UIParent)

		local parent = (areaLabel and areaLabel:GetParent()) or (areaDescription and areaDescription:GetParent()) or WorldMapFrame or UIParent
		self.frame.text = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
		local text = self.frame.text
		local font, size = GameFontHighlightLarge:GetFont()
		text:SetFont(font, size, "OUTLINE")

		local anchor = areaDescription or areaLabel or WorldMapFrame or parent
		text:ClearAllPoints()
		text:SetPoint("TOP", anchor, "BOTTOM", 0, -5)
		text:SetWidth(1024)
	end

	fishingSpell = GetSpellInfo(7620)
	self.frame:Show()

	updateElapsed = updateInterval

	self.frame:SetScript("OnUpdate", function(_, elapsed)
		updateElapsed = updateElapsed + elapsed
		if updateElapsed >= updateInterval then
			updateElapsed = 0
			ZoneLevels:WorldMapButton_OnUpdate()
		end
	end)

	self:Refresh()
	self:WorldMapButton_OnUpdate()
end

function ZoneLevels:OnDisable()
	if self.frame then
		self.frame:SetScript("OnUpdate", nil)
	end
	updateElapsed = 0

	if self.frame then
		self.frame:Hide()
		self.frame.text:SetText("")
	end

	local areaLabel, areaDescription = GetAreaTextElements()
	if areaLabel then
		areaLabel:SetTextColor(1, 1, 1)
	end
	if areaDescription then
		areaDescription:SetTextColor(1, 1, 1)
	end

	self.labelSuffix = nil
	self.descSuffix = nil
	lastZone = nil
	lastFishingText = nil
end

function ZoneLevels:Refresh()
	db = self.db.profile
	lastZone = nil
	lastFishingText = nil

	if self.frame and not self:IsEnabled() then
		self.frame:Hide()
	elseif self.frame then
		self.frame:Show()
	end
end

local function GetFishingSkillText(minFish)
	if not db.showFishing or not minFish or not fishingSpell then
		return
	end

	for i = 1, GetNumSkillLines() do
		local skillName, _, _, skillRank = GetSkillLineInfo(i)
		if skillName == fishingSpell then
			local r, g, b = 1, 1, 0
			local r1, g1, b1 = 1, 0, 0
			if minFish <= skillRank then
				r1, g1, b1 = 0, 1, 0
			end
			return string_format("|cff%02x%02x%02x%s|r |cff%02x%02x%02x[%d]|r", r * 255, g * 255, b * 255, fishingSpell, r1 * 255, g1 * 255, b1 * 255, minFish)
		end
	end
end

local function ShouldColorizeZone()
	return db.colorizeByFaction
end

function ZoneLevels:WorldMapButton_OnUpdate()
	if not self.frame or not self:IsEnabled() or not Tourist then
		return
	end

	local areaLabel, areaDescription = GetAreaTextElements()
	if not areaLabel or not areaLabel:IsShown() then
		self.frame.text:SetText("")
		lastZone = nil
		self.labelSuffix = nil
		self.descSuffix = nil
		return
	end

	local zoneSource = areaLabel
	local zone = areaLabel:GetText()
	local underAttack = false

	if zone then
		zone = string_gsub(zone, " |cff.+$", "")
		if areaDescription and areaDescription:IsShown() and areaDescription:GetText() and areaDescription:GetText() ~= "" then
			underAttack = true
			zoneSource = areaDescription
			zone = string_gsub(areaDescription:GetText(), " |cff.+$", "")
		end
	end

	if GetCurrentMapContinent and GetCurrentMapContinent() == 0 then
		local continents = { GetMapContinents() }
		for index = 2, #continents, 2 do
			if zone == continents[index] then
				if areaLabel then areaLabel:SetTextColor(1, 1, 1) end
				if areaDescription then areaDescription:SetTextColor(1, 1, 1) end
				self.frame.text:SetText("")
				self.labelSuffix = nil
				self.descSuffix = nil
				return
			end
		end
	end

	if not zone or not Tourist:IsZoneOrInstance(zone) then
		zone = WorldMapFrame and WorldMapFrame.areaName
	end

	if not zone then
		lastZone = nil
		self.frame.text:SetText("")
		return
	end

	local factionR, factionG, factionB = Tourist:GetFactionColor(zone)
	if ShouldColorizeZone() and factionR and factionG and factionB then
		if not underAttack then
			if areaLabel then areaLabel:SetTextColor(factionR, factionG, factionB) end
			if areaDescription then areaDescription:SetTextColor(1, 1, 1) end
		else
			if areaLabel then areaLabel:SetTextColor(1, 1, 1) end
			if areaDescription then areaDescription:SetTextColor(factionR, factionG, factionB) end
		end
	else
		if areaLabel then areaLabel:SetTextColor(1, 1, 1) end
		if areaDescription then areaDescription:SetTextColor(1, 1, 1) end
	end

	local low, high = Tourist:GetLevel(zone)
	local minFish = Tourist:GetFishingLevel(zone)
	local zoneTarget = zoneSource
	local previousSuffix = underAttack and self.descSuffix or self.labelSuffix

	if previousSuffix and zoneTarget then
		StripSuffix(zoneTarget, previousSuffix)
		if underAttack then
			self.descSuffix = nil
		else
			self.labelSuffix = nil
		end
	end

	local levelText
	if zoneTarget and db.showZoneLevels and low and high and low > 0 and high > 0 then
		local r, g, b = Tourist:GetLevelColor(zone)
		if low == high then
			levelText = string_format(" |cff%02x%02x%02x[%d]|r", r * 255, g * 255, b * 255, high)
		else
			levelText = string_format(" |cff%02x%02x%02x[%d-%d]|r", r * 255, g * 255, b * 255, low, high)
		end
		local groupSize = Tourist:GetInstanceGroupSize(zone)
		if groupSize and groupSize > 0 then
			levelText = levelText .. " " .. string_format(L["%d-man"], groupSize)
		end

		if zoneTarget:GetText() then
			zoneTarget:SetText(zoneTarget:GetText() .. levelText)
		end

		if underAttack then
			self.descSuffix = levelText
		else
			self.labelSuffix = levelText
		end
	end

	local fishingText = GetFishingSkillText(minFish)
	local hasInstances = db.showInstances and Tourist:DoesZoneHaveInstances(zone)

	local needsUpdate = (lastZone ~= zone) or (lastFishingText ~= fishingText) or (self.lastHasInstances ~= hasInstances) or (self.lastLevelText ~= levelText)
	if needsUpdate then
		lastZone = zone
		lastFishingText = fishingText
		self.lastHasInstances = hasInstances
		self.lastLevelText = levelText

		table_wipe(displayLines)

		if levelText then
			table_insert(displayLines, string_format("|cffffff00%s|r%s", zone, levelText))
		end

		if hasInstances then
			table_insert(displayLines, string_format("|cffffff00%s:|r", L["Instances"]))
			for instance in Tourist:IterateZoneInstances(zone) do
				local complex = Tourist:GetComplex(instance)
				local instLow, instHigh = Tourist:GetLevel(instance)
				local r1, g1, b1 = Tourist:GetFactionColor(instance)
				local r2, g2, b2 = Tourist:GetLevelColor(instance)
				local groupSize = Tourist:GetInstanceGroupSize(instance)
				local name = complex and (complex .. " - " .. instance) or instance

				if instLow == instHigh then
					if groupSize and groupSize > 0 then
						table_insert(displayLines, string_format("|cff%02x%02x%02x%s|r |cff%02x%02x%02x[%d]|r " .. L["%d-man"], r1 * 255, g1 * 255, b1 * 255, name, r2 * 255, g2 * 255, b2 * 255, instHigh, groupSize))
					else
						table_insert(displayLines, string_format("|cff%02x%02x%02x%s|r |cff%02x%02x%02x[%d]|r", r1 * 255, g1 * 255, b1 * 255, name, r2 * 255, g2 * 255, b2 * 255, instHigh))
					end
				else
					if groupSize and groupSize > 0 then
						table_insert(displayLines, string_format("|cff%02x%02x%02x%s|r |cff%02x%02x%02x[%d-%d]|r " .. L["%d-man"], r1 * 255, g1 * 255, b1 * 255, name, r2 * 255, g2 * 255, b2 * 255, instLow, instHigh, groupSize))
					else
						table_insert(displayLines, string_format("|cff%02x%02x%02x%s|r |cff%02x%02x%02x[%d-%d]|r", r1 * 255, g1 * 255, b1 * 255, name, r2 * 255, g2 * 255, b2 * 255, instLow, instHigh))
					end
				end
			end
		end

		if fishingText then
			table_insert(displayLines, fishingText)
		end

		if #displayLines > 0 then
			self.frame.text:SetText(table_concat(displayLines, "\n"))
		else
			self.frame.text:SetText("")
		end
	end
end

