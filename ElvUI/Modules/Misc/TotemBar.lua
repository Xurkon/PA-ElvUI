local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local TOTEMS = E:GetModule("Totems")

--Lua functions
local unpack = unpack
local pairs, ipairs = pairs, ipairs
local strlower = string.lower
local gsub = string.gsub
local match = string.match

--WoW API / Variables
local CooldownFrame_SetTimer = CooldownFrame_SetTimer
local CreateFrame = CreateFrame
local DestroyTotem = DestroyTotem
local GetTotemInfo = GetTotemInfo
local UnitAura = UnitAura

local BLANK_TEX = E.media.blankTex
local IsSpellInRange = IsSpellInRange
local GetSpellInfo = GetSpellInfo

local function GetAlertBorderSize()
	local mult = E.mult
	if mult and mult > 0 then
		return mult * 3
	end

	return 3
end

local MAX_TOTEMS = MAX_TOTEMS
local TOTEM_PRIORITIES = TOTEM_PRIORITIES

local SLOT_BORDER_COLORS = {
	[EARTH_TOTEM_SLOT]	= {r = 0.23, g = 0.45, b = 0.13},	-- [2]
	[FIRE_TOTEM_SLOT]	= {r = 0.58, g = 0.23, b = 0.10},	-- [1]
	[WATER_TOTEM_SLOT]	= {r = 0.19, g = 0.48, b = 0.60},	-- [3]
	[AIR_TOTEM_SLOT]	= {r = 0.42, g = 0.18, b = 0.74}	-- [4]
}

local function NormalizeName(name)
	if not name or name == "" then return nil end

	local normalized = name
	normalized = gsub(normalized, "%s*%b()", "")      -- remove text within parentheses (ranks)
	normalized = gsub(normalized, "%s+[IVXivx]+$", "") -- strip trailing roman numerals
	normalized = gsub(normalized, "%s+%d+$", "")      -- strip trailing digits
	normalized = match(normalized, "^%s*(.-)%s*$")    -- trim whitespace

	if normalized and normalized ~= "" then
		return strlower(normalized)
	end
end

local function BuildLookup(names)
	local lookup

	if type(names) == "table" then
		for _, value in ipairs(names) do
			local normalized = NormalizeName(value)
			if normalized then
				lookup = lookup or {}
				lookup[normalized] = true
			end
		end
	elseif names then
		local normalized = NormalizeName(names)
		if normalized then
			lookup = lookup or {}
			lookup[normalized] = true
		end
	end

	return lookup
end

local RAW_TOTEM_BUFFS = {
	["Strength of Earth Totem"] = {"Strength of Earth Totem", "Strength of Earth"},
	["Stoneskin Totem"] = {"Stoneskin Totem", "Stoneskin"},
	["Windfury Totem"] = {"Windfury Totem", "Windfury"},
	["Wrath of Air Totem"] = {"Wrath of Air Totem", "Wrath of Air"},
	["Flametongue Totem"] = {"Flametongue Totem", "Flametongue"},
	["Totem of Wrath"] = {"Totem of Wrath"},
	["Mana Spring Totem"] = {"Mana Spring Totem", "Mana Spring"},
	["Mana Tide Totem"] = {"Mana Tide Totem", "Mana Tide"},
	["Fire Resistance Totem"] = {"Fire Resistance Totem", "Fire Resistance"},
	["Frost Resistance Totem"] = {"Frost Resistance Totem", "Frost Resistance"},
	["Nature Resistance Totem"] = {"Nature Resistance Totem", "Nature Resistance"},
	["Shadow Resistance Totem"] = {"Shadow Resistance Totem", "Shadow Resistance"},
	["Tranquil Air Totem"] = {"Tranquil Air Totem", "Tranquil Air"},
	["Grounding Totem"] = {"Grounding Totem", "Grounding Totem Effect"},
	["Poison Cleansing Totem"] = {"Poison Cleansing Totem"},
	["Disease Cleansing Totem"] = {"Disease Cleansing Totem"},
	["Elemental Resistance Totem"] = {"Elemental Resistance Totem", "Elemental Resistance"},
}

local TOTEM_BUFF_LOOKUP = {}

for totemName, buffs in pairs(RAW_TOTEM_BUFFS) do
	local normalizedTotem = NormalizeName(totemName)
	if normalizedTotem then
		local lookup = TOTEM_BUFF_LOOKUP[normalizedTotem]
		if not lookup then
			lookup = {}
			TOTEM_BUFF_LOOKUP[normalizedTotem] = lookup
		end

		local buffLookup = BuildLookup(buffs)
		if buffLookup then
			for buffName in pairs(buffLookup) do
				lookup[buffName] = true
			end
		end
	end
end

local function PlayerHasTotemBuff(buffLookup)
	if not buffLookup then
		return false
	end

	for i = 1, 40 do
		local name = UnitAura("player", i, "HELPFUL")
		if not name then break end

		local normalized = NormalizeName(name)
		if normalized and buffLookup[normalized] then
			return true
		end
	end

	return false
end

function TOTEMS:UpdateAllTotems()
	for i = 1, MAX_TOTEMS do
		self:UpdateTotem(nil, i)
	end

	self:UpdateTotemRange()
end

function TOTEMS:UpdateTotem(event, slot)
	local slotID = TOTEM_PRIORITIES[slot]
	local _, name, startTime, duration, icon = GetTotemInfo(slot)
	local button = self.bar[slotID]

	if icon ~= "" then
		local color = SLOT_BORDER_COLORS[slot]
		button.iconTexture:SetTexture(icon)
		button:SetBackdropBorderColor(color.r, color.g, color.b)
		button.baseBorderColor = color

		CooldownFrame_SetTimer(button.cooldown, startTime, duration, 1)

		button:Show()

		local lookup = name and TOTEM_BUFF_LOOKUP[NormalizeName(name)] or nil
		button.buffLookup = lookup
		button.spellName = name or button.spellName

		if button.alertBorder then
			local borderSize = GetAlertBorderSize()
			button.alertBorder:SetOutside(button, borderSize, borderSize)
			button.alertBorder:SetBackdrop({edgeFile = BLANK_TEX, edgeSize = borderSize})
		end
	else
		button:Hide()
		button.baseBorderColor = nil
		button.buffLookup = nil
		button.spellName = nil
		if button.alertBorder then
			button.alertBorder:Hide()
		end
	end

	self:UpdateTotemRange()
end

function TOTEMS:UpdateTotemRange()
	if not self.bar then return end

	for i = 1, MAX_TOTEMS do
		local button = self.bar[i]
		if button:IsShown() and button.baseBorderColor then
			local needsAlert = false

			if button.buffLookup and not PlayerHasTotemBuff(button.buffLookup) then
				needsAlert = true
			elseif button.spellName then
				local inRange = IsSpellInRange(button.spellName, "player")
				if inRange == 0 then
					needsAlert = true
				end
			end

			if needsAlert then
				button:SetBackdropBorderColor(1, 0, 0)
				if button.alertBorder then
					button.alertBorder:SetBackdropBorderColor(1, 0, 0, 1)
					button.alertBorder:Show()
				else
					button:SetBackdropBorderColor(1, 0, 0)
				end
			else
				local color = button.baseBorderColor
				if color then
					button:SetBackdropBorderColor(color.r, color.g, color.b)
				end
				if button.alertBorder then
					button.alertBorder:Hide()
				end
			end
		end
	end
end

function TOTEMS:ToggleEnable()
	if E.db.general.totems.enable then
		if self.Initialized then
			self.bar:Show()
			self:RegisterEvent("PLAYER_TOTEM_UPDATE", "UpdateTotem")
			self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateAllTotems")
			self:UpdateAllTotems()
			E:EnableMover("TotemBarMover")
		else
			self:Initialize()
			self:UpdateAllTotems()
		end
	elseif self.Initialized then
		self.bar:Hide()
		self:UnregisterEvent("PLAYER_TOTEM_UPDATE")
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		E:DisableMover("TotemBarMover")
	end
end

function TOTEMS:PositionAndSize()
	if not self.Initialized then return end

	for i = 1, MAX_TOTEMS do
		local button = self.bar[i]
		local prevButton = self.bar[i - 1]

		button:Size(self.db.size)
		button:ClearAllPoints()

		if self.db.growthDirection == "HORIZONTAL" and self.db.sortDirection == "ASCENDING" then
			if i == 1 then
				button:Point("LEFT", self.bar, "LEFT", self.db.spacing, 0)
			elseif prevButton then
				button:Point("LEFT", prevButton, "RIGHT", self.db.spacing, 0)
			end
		elseif self.db.growthDirection == "VERTICAL" and self.db.sortDirection == "ASCENDING" then
			if i == 1 then
				button:Point("TOP", self.bar, "TOP", 0, -self.db.spacing)
			elseif prevButton then
				button:Point("TOP", prevButton, "BOTTOM", 0, -self.db.spacing)
			end
		elseif self.db.growthDirection == "HORIZONTAL" and self.db.sortDirection == "DESCENDING" then
			if i == 1 then
				button:Point("RIGHT", self.bar, "RIGHT", -self.db.spacing, 0)
			elseif prevButton then
				button:Point("RIGHT", prevButton, "LEFT", -self.db.spacing, 0)
			end
		else
			if i == 1 then
				button:Point("BOTTOM", self.bar, "BOTTOM", 0, self.db.spacing)
			elseif prevButton then
				button:Point("BOTTOM", prevButton, "TOP", 0, self.db.spacing)
			end
		end
	end

	if self.db.growthDirection == "HORIZONTAL" then
		self.bar:Width(self.db.size*(MAX_TOTEMS) + self.db.spacing*(MAX_TOTEMS) + self.db.spacing)
		self.bar:Height(self.db.size + self.db.spacing * 2)
	else
		self.bar:Height(self.db.size*(MAX_TOTEMS) + self.db.spacing*(MAX_TOTEMS) + self.db.spacing)
		self.bar:Width(self.db.size + self.db.spacing * 2)
	end
end

local function Button_OnClick(self)
	DestroyTotem(self.slot)
end
local function Button_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
	self:UpdateTooltip()
end
local function Button_OnLeave(self)
	GameTooltip:Hide()
end
local function UpdateTooltip(self)
	if GameTooltip:IsOwned(self) then
		GameTooltip:SetTotem(self.slot)
	end
end

function TOTEMS:Initialize()
	if not E.db.general.totems.enable then return end

	self.db = E.db.general.totems

	local bar = CreateFrame("Frame", "ElvUI_TotemBar", E.UIParent)
	bar:Point("TOPLEFT", LeftChatPanel, "TOPRIGHT", 14, 0)
	self.bar = bar

	for i = 1, MAX_TOTEMS do
		local frame = CreateFrame("Button", "$parentTotem"..i, bar)
		frame.slot = TOTEM_PRIORITIES[i]
		frame:SetTemplate("Default")
		frame:StyleButton()
		frame.ignoreBorderColors = true
		frame:Hide()
		frame.buffLookup = nil

		frame.UpdateTooltip = UpdateTooltip

		frame:RegisterForClicks("RightButtonUp")
		frame:SetScript("OnClick", Button_OnClick)
		frame:SetScript("OnEnter", Button_OnEnter)
		frame:SetScript("OnLeave", Button_OnLeave)

		frame.holder = CreateFrame("Frame", nil, frame)
		frame.holder:SetAlpha(0)
		frame.holder:SetAllPoints()

		frame.iconTexture = frame:CreateTexture(nil, "ARTWORK")
		frame.iconTexture:SetTexCoord(unpack(E.TexCoords))
		frame.iconTexture:SetInside()

		frame.cooldown = CreateFrame("Cooldown", "$parentCooldown", frame, "CooldownFrameTemplate")
		frame.cooldown:SetReverse(true)
		frame.cooldown:SetInside()
		E:RegisterCooldown(frame.cooldown)

		local alertBorder = CreateFrame("Frame", nil, frame)
		local borderSize = GetAlertBorderSize()
		alertBorder:SetFrameLevel(frame:GetFrameLevel() + 3)
		alertBorder:SetOutside(frame, borderSize, borderSize)
		alertBorder:SetBackdrop({edgeFile = BLANK_TEX, edgeSize = borderSize})
		alertBorder:SetBackdropColor(0, 0, 0, 0)
		alertBorder:SetBackdropBorderColor(1, 0, 0, 1)
		alertBorder:Hide()
		frame.alertBorder = alertBorder

		self.bar[i] = frame
	end

	self.Initialized = true

	self:PositionAndSize()

	E:CreateMover(bar, "TotemBarMover", TUTORIAL_TITLE47, nil, nil, nil, nil, nil, "general,totems")

	self:RegisterEvent("PLAYER_TOTEM_UPDATE", "UpdateTotem")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateAllTotems")
	self:RegisterEvent("PLAYER_TARGET_CHANGED", "UpdateTotemRange")
	self:RegisterEvent("PLAYER_UPDATE_RESTING", "UpdateTotemRange")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "UpdateTotemRange")
	self:RegisterEvent("UNIT_AURA", "UpdateTotemRange")
	self:RegisterEvent("PLAYER_MOVING_UPDATE", "UpdateTotemRange")
end

local function InitializeCallback()
	TOTEMS:Initialize()
end

E:RegisterModule(TOTEMS:GetName(), InitializeCallback)