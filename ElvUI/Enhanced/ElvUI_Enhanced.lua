local E, L, V, P, G = unpack(ElvUI)
local addon = E:NewModule("ElvUI_Enhanced")
local EP = E.Libs.EP

local addonName = ...

local format = string.format
local CreateFrame = CreateFrame
local rawget = rawget
local rawset = rawset
local getmetatable = getmetatable
local setmetatable = setmetatable
local InCombatLockdown = InCombatLockdown

local function SanitizeCharacterSetupSavedVariables()
	local sv = rawget(_G, "NewCharacterSetupUtilData")
	if type(sv) ~= "table" then
		return
	end

	for realm, realmData in pairs(sv) do
		if type(realmData) == "table" then
			for character, characterData in pairs(realmData) do
				if type(characterData) == "table" and characterData.enableTransmog == nil then
					characterData.enableTransmog = false
				end
			end
		end
	end
end

local wrappedFunctions = setmetatable({}, { __mode = "k" })

if not addon._UnitReactionPatched then
	addon._UnitReactionPatched = true
	local originalUnitReaction = UnitReaction
	function UnitReaction(unit, otherUnit)
		if not unit or not otherUnit then
			return nil
		end
		return originalUnitReaction(unit, otherUnit)
	end
end

-- Combat-safe SetScale wrapper for nameplate frames
if not addon._NameplateScalePatched then
	addon._NameplateScalePatched = true
	
	-- Hook ElvUI's nameplate scale functions after module loads
	local function HookNameplateFunctions()
		local NP = E:GetModule("NamePlates")
		if not NP or NP._ScaleHooked then return end
		NP._ScaleHooked = true
		
		local originalScalePlate = NP.ScalePlate
		if originalScalePlate then
			NP.ScalePlate = function(self, nameplate, scale, targetPlate)
				if InCombatLockdown() then
					-- Defer scale updates until after combat
					return
				end
				return originalScalePlate(self, nameplate, scale, targetPlate)
			end
		end
		
		local originalStylePlate = NP.StylePlate
		if originalStylePlate then
			NP.StylePlate = function(self, nameplate)
				if InCombatLockdown() then
					-- Defer scale updates until after combat
					return
				end
				return originalStylePlate(self, nameplate)
			end
		end
		
		local originalStyleTargetPlate = NP.StyleTargetPlate
		if originalStyleTargetPlate then
			NP.StyleTargetPlate = function(self, nameplate)
				if InCombatLockdown() then
					-- Defer scale updates until after combat
					return
				end
				return originalStyleTargetPlate(self, nameplate)
			end
		end
	end
	
	-- Try to hook immediately, or wait for module to load
	local hookFrame = CreateFrame("Frame")
	hookFrame:RegisterEvent("PLAYER_LOGIN")
	hookFrame:SetScript("OnEvent", function()
		HookNameplateFunctions()
		hookFrame:UnregisterAllEvents()
	end)
	HookNameplateFunctions() -- Try immediately in case module is already loaded
end

local function SanitizeCharacterSetupData()
	local util = rawget(_G, "NewCharacterSetupUtil")
	if type(util) ~= "table" then
		return
	end

	local visited = setmetatable({}, { __mode = "k" })

	local function sanitize(tbl)
		if type(tbl) ~= "table" or visited[tbl] then
			return
		end

		visited[tbl] = true

		if rawget(tbl, "enableTransmog") == nil then
			tbl.enableTransmog = false
		end

		for _, child in pairs(tbl) do
			sanitize(child)
		end
	end

	sanitize(util)
end

SanitizeCharacterSetupSavedVariables()

local function WrapSetCharacterData(util, func)
	if type(func) ~= "function" then
		return false
	end

	if wrappedFunctions[func] then
		return true
	end

	local wrapped = function(self, characterName, key, value, ...)
		if value == nil then
			value = false
		end

		SanitizeCharacterSetupData()
		SanitizeCharacterSetupSavedVariables()

		return func(self, characterName, key, value, ...)
	end

	wrappedFunctions[func] = true
	wrappedFunctions[wrapped] = true
	util._ElvUIEnhancedWrapped = true

	rawset(util, "SetCharacterData", wrapped)

	return true
end

local function TryWrapNewCharacterSetupUtil()
	local util = rawget(_G, "NewCharacterSetupUtil")
	if type(util) ~= "table" or util._ElvUIEnhancedWrapped then
		return util and util._ElvUIEnhancedWrapped
	end

	SanitizeCharacterSetupData()
	SanitizeCharacterSetupSavedVariables()

	local original = util.SetCharacterData
	if type(original) == "function" then
		return WrapSetCharacterData(util, original)
	end

	return false
end

local wrapWatcher

local function EnsureProxyTable()
	local util = rawget(_G, "NewCharacterSetupUtil")
	if util == nil then
		util = {}
		rawset(_G, "NewCharacterSetupUtil", util)
	end

	if type(util) ~= "table" then
		return
	end

	SanitizeCharacterSetupData()
	SanitizeCharacterSetupSavedVariables()

	local mt = getmetatable(util) or {}
	if mt.__ElvUIEnhancedProxy then
		return
	end

	local originalNewIndex = mt.__newindex

	mt.__newindex = function(t, key, value)
		if key == "SetCharacterData" and type(value) == "function" then
			if not WrapSetCharacterData(t, value) and originalNewIndex then
				return originalNewIndex(t, key, value)
			end
		else
			if originalNewIndex then
				return originalNewIndex(t, key, value)
			end
			rawset(t, key, value)
		end

		SanitizeCharacterSetupData()
		SanitizeCharacterSetupSavedVariables()
	end

	mt.__ElvUIEnhancedProxy = true
	setmetatable(util, mt)
end

local function EnsureNewCharacterSetupUtilWrapped()
	EnsureProxyTable()
	SanitizeCharacterSetupData()
	SanitizeCharacterSetupSavedVariables()

	if TryWrapNewCharacterSetupUtil() then
		return true
	end

	if not wrapWatcher then
		local watcher = CreateFrame("Frame")
		watcher:RegisterEvent("ADDON_LOADED")
		watcher:RegisterEvent("PLAYER_LOGIN")
		watcher:RegisterEvent("PLAYER_ENTERING_WORLD")
		watcher:SetScript("OnEvent", function(self)
			EnsureProxyTable()
			SanitizeCharacterSetupData()
			SanitizeCharacterSetupSavedVariables()
			if TryWrapNewCharacterSetupUtil() then
				self:UnregisterAllEvents()
				self:SetScript("OnEvent", nil)
				wrapWatcher = nil
			end
		end)
		watcher:SetScript("OnUpdate", function(self)
			EnsureProxyTable()
			SanitizeCharacterSetupData()
			SanitizeCharacterSetupSavedVariables()
			if TryWrapNewCharacterSetupUtil() then
				self:SetScript("OnUpdate", nil)
				self:Hide()
				self:UnregisterAllEvents()
				wrapWatcher = nil
			end
		end)

		wrapWatcher = watcher
	end

	return false
end

EnsureNewCharacterSetupUtilWrapped()
SanitizeCharacterSetupData()
SanitizeCharacterSetupSavedVariables()

local function gsPopupShow()
	local url = "https://www.wowinterface.com/downloads/getfile.php?id=12245&aid=47105"

	E.PopupDialogs["GS_VERSION_INVALID"] = {
		text = L["GearScore '3.1.20b - Release' is not for WotLK. Download 3.1.7. Disable this version?"],
		button1 = DISABLE,
		hideOnEscape = 1,
		showAlert = 1,
		OnShow = function(self)
			self.editBox:SetAutoFocus(false)
			self.editBox.width = self.editBox:GetWidth()
			self.editBox:SetWidth(220)
			self.editBox:SetText(url)
			self.editBox:HighlightText()
			ChatEdit_FocusActiveWindow()
		end,
		OnAccept = function()
			DisableAddOn("GearScore")
			DisableAddOn("BonusScanner")
			ReloadUI()
		end,
		OnHide = function(self)
			self.editBox:SetWidth(self.editBox.width or 50)
			self.editBox.width = nil
		end,
		EditBoxOnEnterPressed = function(self)
			ChatEdit_FocusActiveWindow()
			self:GetParent():Hide()
		end,
		EditBoxOnEscapePressed = function(self)
			ChatEdit_FocusActiveWindow()
			self:GetParent():Hide()
		end,
		EditBoxOnTextChanged = function(self)
			if self:GetText() ~= url then
				self:SetText(url)
			end
			self:HighlightText()
			self:ClearFocus()
			ChatEdit_FocusActiveWindow()
		end,
		OnEditFocusGained = function(self)
			self:HighlightText()
		end
	}

	E:StaticPopup_Show("GS_VERSION_INVALID")
end

function addon:ColorizeSettingName(name)
	name = name or ""
	return format("|cffff8000%s|r", tostring(name))
end

function addon:DBConversions()
	if E.db.enhanced.general.trainAllButton ~= nil then
		E.db.enhanced.general.trainAllSkills = E.db.enhanced.general.trainAllButton
		E.db.enhanced.general.trainAllButton = nil
	end

	if E.private.skins.animations ~= nil then
		E.private.enhanced.animatedAchievementBars = E.private.skins.animations
		E.private.skins.animations = nil
	end

	if E.private.enhanced.blizzard and E.private.enhanced.blizzard.deathRecap ~= nil then
		E.private.enhanced.deathRecap = E.private.enhanced.blizzard.deathRecap
		E.private.enhanced.blizzard.deathRecap = nil
	end

	if E.private.enhanced.character.model and E.private.enhanced.character.model.enable ~= nil then
		E.private.enhanced.character.modelFrames = E.private.enhanced.character.model.enable
		E.private.enhanced.character.model.enable = nil
	end

	if P.unitframe.units.player.portrait.detachFromFrame ~= nil then
		E.db.enhanced.unitframe.detachPortrait.player.enable = P.unitframe.units.player.portrait.detachFromFrame
		E.db.enhanced.unitframe.detachPortrait.player.width = P.unitframe.units.player.portrait.detachedWidth
		E.db.enhanced.unitframe.detachPortrait.player.height = P.unitframe.units.player.portrait.detachedHeight
		E.db.enhanced.unitframe.detachPortrait.target.enable = P.unitframe.units.target.portrait.detachFromFrame
		E.db.enhanced.unitframe.detachPortrait.target.width = P.unitframe.units.target.portrait.detachedWidth
		E.db.enhanced.unitframe.detachPortrait.target.height = P.unitframe.units.target.portrait.detachedHeight

		P.unitframe.units.player.portrait.detachFromFrame = nil
		P.unitframe.units.player.portrait.detachedWidth = nil
		P.unitframe.units.player.portrait.detachedHeight = nil
		P.unitframe.units.target.portrait.detachFromFrame = nil
		P.unitframe.units.target.portrait.detachedWidth = nil
		P.unitframe.units.target.portrait.detachedHeight = nil
	end

	if E.db.enhanced.nameplates.cacheUnitClass ~= nil then
		E.db.enhanced.nameplates.classCache = true
	end
	if EnhancedDB and EnhancedDB.UnitClass and next(EnhancedDB.UnitClass) then
		local classMap = {}
		for i, class in ipairs(CLASS_SORT_ORDER) do
			classMap[class] = i
		end
		for name, class in pairs(EnhancedDB.UnitClass) do
			if type(class) == "string" then
				EnhancedDB.UnitClass[name] = classMap[class]
			end
		end

		EnhancedDB.UnitClass[UNKNOWN] = nil
	end

	local tooltipDB = E.db.enhanced.tooltip and E.db.enhanced.tooltip.progressInfo
	if tooltipDB then
		tooltipDB.tiers = tooltipDB.tiers or {}
		local tiers = tooltipDB.tiers
		local migrated
		for _, key in ipairs({"DS", "FL", "BH", "TOTFW", "BT", "BWD"}) do
			if tiers[key] ~= nil then
				tiers[key] = nil
				migrated = true
			end
		end

		for key, defaultValue in pairs({ RS = true, ICC = true, ToC = true, Ulduar = true }) do
			if tiers[key] == nil then
				tiers[key] = defaultValue
			end
		end
	end

	if E.db.general.minimap.buttons then
		E.private.enhanced.minimapButtonGrabber = true

		E.db.enhanced.minimap.buttonGrabber.buttonSize = E.db.general.minimap.buttons.buttonsize
		E.db.enhanced.minimap.buttonGrabber.buttonSpacing = E.db.general.minimap.buttons.buttonspacing
		E.db.enhanced.minimap.buttonGrabber.backdrop = E.db.general.minimap.buttons.backdrop
		E.db.enhanced.minimap.buttonGrabber.backdropSpacing = E.db.general.minimap.buttons.backdropSpacing
		E.db.enhanced.minimap.buttonGrabber.buttonsPerRow = E.db.general.minimap.buttons.buttonsPerRow
		E.db.enhanced.minimap.buttonGrabber.alpha = E.db.general.minimap.buttons.alpha
		E.db.enhanced.minimap.buttonGrabber.mouseover = E.db.general.minimap.buttons.mouseover
		E.db.enhanced.minimap.buttonGrabber.growFrom = E.db.general.minimap.buttons.point

		if E.db.general.minimap.buttons.insideMinimap then
			E.db.enhanced.minimap.buttonGrabber.insideMinimap.enable = E.db.general.minimap.buttons.insideMinimap.enable
			E.db.enhanced.minimap.buttonGrabber.insideMinimap.position = E.db.general.minimap.buttons.insideMinimap.position
			E.db.enhanced.minimap.buttonGrabber.insideMinimap.xOffset = E.db.general.minimap.buttons.insideMinimap.xOffset
			E.db.enhanced.minimap.buttonGrabber.insideMinimap.yOffset = E.db.general.minimap.buttons.insideMinimap.yOffset
		end

		E.db.general.minimap.buttons = nil
	end

	if E.db.fogofwar then
		E.db.enhanced.map.fogClear.enable = E.db.fogofwar.enable

		if E.db.fogofwar.color then
			E.db.enhanced.map.fogClear.color.r = E.db.fogofwar.color.r
			E.db.enhanced.map.fogClear.color.g = E.db.fogofwar.color.g
			E.db.enhanced.map.fogClear.color.b = E.db.fogofwar.color.b
			E.db.enhanced.map.fogClear.color.a = E.db.fogofwar.color.a
		end

		E.db.fogofwar = nil
	end
end

function addon:PrintAddonMerged(mergedAddonName)
	local _, _, _, enabled, _, reason = GetAddOnInfo(mergedAddonName)
	if reason == "MISSING" then return end

	local text = format(L["Addon |cffFFD100%s|r was merged into |cffFFD100ElvUI_Enhanced|r.\nPlease remove it to avoid conflicts."], mergedAddonName)
	E:Print(text)

	if enabled then
		if not E.PopupDialogs.ENHANCED_MERGED_ADDON then
			E.PopupDialogs.ENHANCED_MERGED_ADDON = {
				button2 = CANCEL,
				OnAccept = function()
					DisableAddOn(E.PopupDialogs.ENHANCED_MERGED_ADDON.mergedAddonName)
					ReloadUI()
				end,
				whileDead = 1,
				hideOnEscape = false
			}
		end

		local popup = E.PopupDialogs.ENHANCED_MERGED_ADDON
		popup.text = text
		popup.button1 = format("Disable %s", string.gsub(mergedAddonName, "^ElvUI_", ""))

		E:StaticPopup_Show("ENHANCED_MERGED_ADDON")
	end
end

function addon:Initialize()
	EnhancedDB = EnhancedDB or {}

	self.version = "1.05 (Integrated)"

	self:DBConversions()

	-- Apply ghost effect setting on load
	if E.db.enhanced.general.ghostEffect ~= nil then
		SetCVar("ffxDeath", E.db.enhanced.general.ghostEffect and "1" or "0")
	else
		-- Initialize from current CVar if not set
		local currentValue = GetCVar("ffxDeath")
		E.db.enhanced.general.ghostEffect = (currentValue == "1")
	end

	EP:RegisterPlugin(addonName, self.GetOptions)

	if E.db.general.loginmessage then
		print(format(L["ENH_LOGIN_MSG"], E.media.hexvaluecolor, addon.version))
	end

	if IsAddOnLoaded("GearScore") and IsAddOnLoaded("BonusScanner") then
		if GetAddOnMetadata("GearScore", "Version") == "3.1.20b - Release" then
			gsPopupShow()
		end
	end

	self:PrintAddonMerged("ElvUI_MinimapButtons")
	self:PrintAddonMerged("ElvUI_FogofWar")
end

local function InitializeCallback()
	addon:Initialize()
end

E:RegisterModule(addon:GetName(), InitializeCallback)