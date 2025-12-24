local _, _, _, enhancedEnabled = GetAddOnInfo and GetAddOnInfo("ElvUI_Enhanced")
if enhancedEnabled then return end

local E, _, _, P = unpack(ElvUI)
local WE = E.WarcraftEnhanced
local IBC = E:NewModule("Enhanced_ItemBorderColor", "AceHook-3.0")
local TT = E:GetModule("Tooltip")

local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor

local function EnsureUIEnhancementDB()
	if not WE then return end

	local defaults = (P and P.warcraftenhanced and P.warcraftenhanced.uiEnhancements) or {}

	WE.db = WE.db or {}
	if not WE.db.uiEnhancements then
		WE.db.uiEnhancements = E:CopyTable({}, defaults)
	end

	local uiEnhancements = WE.db.uiEnhancements
	uiEnhancements.errorFilters = uiEnhancements.errorFilters or {}

	if uiEnhancements.tooltipIcon == nil then
		local tooltipDefaults = defaults.tooltipIcon or {
			enable = false,
			tooltipIconItems = true,
			tooltipIconSpells = true,
			tooltipIconAchievements = true
		}
		uiEnhancements.tooltipIcon = E:CopyTable({}, tooltipDefaults)
	end

	if uiEnhancements.itemBorderColor == nil then
		uiEnhancements.itemBorderColor = defaults.itemBorderColor or false
	end

	return uiEnhancements
end

local function MigrateLegacySetting()
	if not E.db.enhanced or not E.db.enhanced.tooltip then return end

	local legacyValue = E.db.enhanced.tooltip.itemQualityBorderColor
	if legacyValue == nil then return end

	local uiEnhancements = EnsureUIEnhancementDB()
	if uiEnhancements then
		uiEnhancements.itemBorderColor = legacyValue and true or false
	end

	E.db.enhanced.tooltip.itemQualityBorderColor = nil
end

function IBC:SetBorderColor(_, tt)
	if not tt.GetItem then return end

	local _, link = tt:GetItem()
	if link then
		local _, _, quality = GetItemInfo(link)
		if quality then
			tt:SetBackdropBorderColor(GetItemQualityColor(quality))
		end
	end
end

function IBC:ToggleState()
	local uiEnhancements = EnsureUIEnhancementDB()
	if not uiEnhancements then return end

	if uiEnhancements.itemBorderColor then
		if not self:IsHooked(TT, "SetStyle", "SetBorderColor") then
			self:SecureHook(TT, "SetStyle", "SetBorderColor")
		end
	else
		self:UnhookAll()
	end
end

function IBC:Initialize()
	MigrateLegacySetting()

	local uiEnhancements = EnsureUIEnhancementDB()
	if not uiEnhancements then return end
	if not uiEnhancements.itemBorderColor then return end

	self:ToggleState()

	self.initialized = true
end

local function InitializeCallback()
	IBC:Initialize()
end

E:RegisterModule(IBC:GetName(), InitializeCallback)

