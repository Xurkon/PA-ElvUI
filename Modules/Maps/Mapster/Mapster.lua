--[[
Copyright (c) 2009, Hendrik "Nevcairiel" Leppkes < h.leppkes@gmail.com >
All rights reserved.

Integrated into ElvUI by Project Ascension
]]

local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local Mapster = E:NewModule("Mapster", "AceEvent-3.0", "AceHook-3.0")

local LibWindow = E.Libs.LibWindow or LibStub("LibWindow-1.1", true)
local InCombatLockdown = InCombatLockdown
local C_Timer = C_Timer
-- Locale will be loaded separately

local defaults = {
	profile = {
		strata = "HIGH",
		hideMapButton = false,
		arrowScale = 0.88,
		questObjectives = 2,
		modules = {
			['*'] = true,
		},
		x = 0,
		y = 0,
		point = "CENTER",
		scale = 0.75,
		poiScale = 0.8,
		alpha = 1,
		hideBorder = false,
		disableMouse = false,
		miniMap = false,
		mini = {
			x = 0,
			y = 0,
			point = "CENTER",
			scale = 1,
			alpha = 0.9,
			hideBorder = true,
			disableMouse = true,
		}
	}
}

-- Variables that are changed on "mini" mode
local miniList = { x = true, y = true, point = true, scale = true, alpha = true, hideBorder = true, disableMouse = true }

local db_
local db = setmetatable({}, {
	__index = function(t, k)
		if Mapster.miniMap and miniList[k] then
			return db_.mini[k]
		else
			return db_[k]
		end
	end,
	__newindex = function(t, k, v)
		if Mapster.miniMap and miniList[k] then
			db_.mini[k] = v
		else
			db_[k] = v
		end
	end
})

local format = string.format
local abs = math.abs

local function FrameExists()
	return WorldMapFrame or _G.WorldMapFrame
end

local function MergeDefaults(target, source)
	if not target or not source then return end

	for k, v in pairs(source) do
		if type(v) == "table" then
			if type(target[k]) ~= "table" then
				target[k] = {}
			end
			MergeDefaults(target[k], v)
		elseif target[k] == nil then
			target[k] = v
		end
	end
end

function Mapster:EnsureProfileDefaults()
	E.db.maps = E.db.maps or {}
	E.db.maps.worldMap = E.db.maps.worldMap or {}

	MergeDefaults(E.db.maps.worldMap, defaults.profile)

	if E.db.maps.worldMap.points and not E.db.maps.worldMap.point then
		E.db.maps.worldMap.point = E.db.maps.worldMap.points
	end
	E.db.maps.worldMap.points = nil

	return E.db.maps.worldMap
end

-- Cache frequently accessed frames and APIs for performance
local WorldMapFrame, WorldMapDetailFrame, WorldMapBlobFrame
local WorldMapButton, WorldMapPositioningGuide
local GetCurrentMapZone, GetCurrentMapContinent, GetPlayerMapPosition
local WORLDMAP_SETTINGS

local wmfOnShow, wmfStartMoving, wmfStopMoving, dropdownScaleFix
local questObjDropDownInit, questObjDropDownUpdate

-- Cache function to update frame references (called when frames become available)
local function CacheFrames()
	WorldMapFrame = WorldMapFrame or _G.WorldMapFrame
	WorldMapDetailFrame = WorldMapDetailFrame or _G.WorldMapDetailFrame
	WorldMapBlobFrame = WorldMapBlobFrame or _G.WorldMapBlobFrame
	WorldMapButton = WorldMapButton or _G.WorldMapButton
	WorldMapPositioningGuide = WorldMapPositioningGuide or _G.WorldMapPositioningGuide
	WORLDMAP_SETTINGS = WORLDMAP_SETTINGS or _G.WORLDMAP_SETTINGS
	GetCurrentMapZone = GetCurrentMapZone or _G.GetCurrentMapZone
	GetCurrentMapContinent = GetCurrentMapContinent or _G.GetCurrentMapContinent
	GetPlayerMapPosition = GetPlayerMapPosition or _G.GetPlayerMapPosition
end

function Mapster:Initialize()
	-- Ensure global maps table exists and migrate any legacy data
	if not E.global.maps then
		E.global.maps = {}
	end
	if E.global.mapster then
		if not E.global.maps.worldMap or not next(E.global.maps.worldMap) then
			E.global.maps.worldMap = E.global.mapster
		else
			MergeDefaults(E.global.maps.worldMap, E.global.mapster)
		end
		E.global.mapster = nil
	end
	if not E.global.maps.worldMap then
		E.global.maps.worldMap = {}
	end

	-- Ensure profile maps table exists and migrate legacy profile data
	local legacyProfile = rawget(E.db, "mapster")
	if legacyProfile then
		E.db.maps = E.db.maps or {}
		E.db.maps.worldMap = legacyProfile
		E.db.mapster = nil
	end

	local profileDB = self:EnsureProfileDefaults()
	db_ = profileDB

	-- Ensure modules table exists with proper default
	if not db_.modules then
		db_.modules = {}
	end
	-- Set metatable for wildcard default (all modules enabled by default)
	setmetatable(db_.modules, {
		__index = function(t, k)
			if rawget(t, k) == nil then
				return true  -- Default to enabled
			end
			return rawget(t, k)
		end
	})

	-- Create a database wrapper for child modules to use
	-- This provides compatibility with ACE database namespaces
	self.db = {
		profile = db_,
		global = E.global.maps.worldMap,
		RegisterNamespace = function(db, name, defaults)
			local profileParent = Mapster:EnsureProfileDefaults()
			if not profileParent[name] then
				profileParent[name] = {}
			end
			if defaults and defaults.profile then
				for k, v in pairs(defaults.profile) do
					if profileParent[name][k] == nil then
						if type(v) == "table" then
							profileParent[name][k] = E:CopyTable({}, v)
						else
							profileParent[name][k] = v
						end
					end
				end
			end

			local globalParent = E.global.maps.worldMap
			if not globalParent[name] then
				globalParent[name] = {}
			end
			if defaults and defaults.global then
				for k, v in pairs(defaults.global) do
					if globalParent[name][k] == nil then
						if type(v) == "table" then
							globalParent[name][k] = E:CopyTable({}, v)
						else
							globalParent[name][k] = v
						end
					end
				end
			end

			return {
				profile = profileParent[name],
				global = globalParent[name]
			}
		end
	}

	self.elementsToHide = {}

	self:SetupOptions()
end

local realZone
function Mapster:Enable()
	-- Cache frames on enable
	CacheFrames()
	
	local advanced, mini = GetCVarBool("advancedWorldMap"), GetCVarBool("miniWorldMap")
	SetCVar("miniWorldMap", nil)
	SetCVar("advancedWorldMap", nil)
	InterfaceOptionsObjectivesPanelAdvancedWorldMap:Disable()
	InterfaceOptionsObjectivesPanelAdvancedWorldMapText:SetTextColor(0.5,0.5,0.5)
	-- restore map to its vanilla state
	if mini then
		WorldMap_ToggleSizeUp()
	end
	if advanced then
		WorldMapFrame_ToggleAdvanced()
	end

	self:SetupMapButton()

	LibWindow.RegisterConfig(WorldMapFrame, db)

	local vis = WorldMapFrame:IsVisible()
	if vis then
		HideUIPanel(WorldMapFrame)
	end

	UIPanelWindows["WorldMapFrame"] = nil
	WorldMapFrame:SetAttribute("UIPanelLayout-enabled", false)
	WorldMapFrame:HookScript("OnShow", wmfOnShow)
	WorldMapFrame:HookScript("OnHide", wmfOnHide)
	if not self.visualsHooked then
		self.visualsHooked = true
		WorldMapFrame:HookScript("OnUpdate", function()
			Mapster:ApplyVisualSettings()
		end)
	end
	BlackoutWorld:Hide()
	WorldMapTitleButton:Hide()

	WorldMapFrame:SetScript("OnKeyDown", nil)

	WorldMapFrame:SetMovable(true)
	WorldMapFrame:RegisterForDrag("LeftButton")
	WorldMapFrame:SetScript("OnDragStart", wmfStartMoving)
	WorldMapFrame:SetScript("OnDragStop", wmfStopMoving)

	WorldMapFrame:SetParent(UIParent)
	WorldMapFrame:SetToplevel(true)
	WorldMapFrame:SetWidth(1024)
	WorldMapFrame:SetHeight(768)
	WorldMapFrame:SetClampedToScreen(false)

	WorldMapContinentDropDownButton:SetScript("OnClick", dropdownScaleFix)
	WorldMapZoneDropDownButton:SetScript("OnClick", dropdownScaleFix)
	WorldMapZoneMinimapDropDownButton:SetScript("OnClick", dropdownScaleFix)

	WorldMapFrameSizeDownButton:SetScript("OnClick", function() Mapster:ToggleMapSize() end)
	WorldMapFrameSizeUpButton:SetScript("OnClick", function() Mapster:ToggleMapSize() end)
	
	-- Hide Quest Objectives CheckBox and replace it with a DropDown
	WorldMapQuestShowObjectives:Hide()
	WorldMapQuestShowObjectives:SetChecked(db.questObjectives ~= 0)
	WorldMapQuestShowObjectives_Toggle()
	local questObj = CreateFrame("Frame", "MapsterQuestObjectivesDropDown", WorldMapFrame, "UIDropDownMenuTemplate")
	questObj:SetPoint("BOTTOMRIGHT", "WorldMapPositioningGuide", "BOTTOMRIGHT", -5, -2)
	
	local text = questObj:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	text:SetText(L["Quest Objectives"])
	text:SetPoint("RIGHT", questObj, "LEFT", 5, 3)
	-- Init DropDown
	UIDropDownMenu_Initialize(questObj, questObjDropDownInit)
	UIDropDownMenu_SetWidth(questObj, 150)
	questObjDropDownUpdate()

	-- Pre-apply settings to avoid redundant work on first map open
	self:SetStrata()
	self:SetScale()
	mapShowInitialized = true -- Mark as initialized since we already set them
	
	wmfOnShow(WorldMapFrame)
	hooksecurefunc(WorldMapTooltip, "Show", function(self)
		self:SetFrameStrata("TOOLTIP")
	end)

	tinsert(UISpecialFrames, "WorldMapFrame")

	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")

	if db.miniMap then
		self:SizeDown()
	end
	self.miniMap = db.miniMap

	self:SetPosition()
	self:SetAlpha()
	self:SetArrow()
	self:SetPOIScale()
	self:UpdateBorderVisibility()
	self:UpdateMouseInteractivity()

	self:ScheduleWarmup()

	self:SecureHook("WorldMapFrame_DisplayQuestPOI")
	self:SecureHook("WorldMapFrame_DisplayQuests")
	self:SecureHook("WorldMapFrame_SetPOIMaxBounds")
	WorldMapFrame_SetPOIMaxBounds()

	if vis then
		ShowUIPanel(WorldMapFrame)
	end
end

local blobWasVisible, blobNewScale
local blobHideFunc = function() blobWasVisible = nil end
local blobShowFunc = function() blobWasVisible = true end
local blobScaleFunc = function(self, scale) blobNewScale = scale end

function Mapster:PLAYER_REGEN_DISABLED()
	if InCombatLockdown and InCombatLockdown() then
		return
	end

	-- Cache frame reference for performance
	local blobFrame = WorldMapBlobFrame or _G.WorldMapBlobFrame
	if not blobFrame then return end

	blobWasVisible = blobFrame:IsShown()
	blobNewScale = nil
	-- Use pcall to safely handle SetParent in case it's protected
	pcall(function() blobFrame:SetParent(nil) end)
	blobFrame:ClearAllPoints()
	-- dummy position, off screen, so calculations don't go boom
	blobFrame:SetPoint("TOP", UIParent, "BOTTOM")
	blobFrame:Hide()
	blobFrame.Hide = blobHideFunc
	blobFrame.Show = blobShowFunc
	blobFrame.SetScale = blobScaleFunc
end

local updateFrame = CreateFrame("Frame")
local function restoreBlobs()
	local blobFrame = WorldMapBlobFrame or _G.WorldMapBlobFrame
	if not blobFrame then return end
	
	WorldMapBlobFrame_CalculateHitTranslations()
	local selected = WorldMapQuestScrollChildFrame.selected
	if selected and not selected.completed then
		blobFrame:DrawQuestBlob(selected.questId, true)
	end
	updateFrame:SetScript("OnUpdate", nil)
end

function Mapster:PLAYER_REGEN_ENABLED()
	if InCombatLockdown and InCombatLockdown() then
		return
	end

	-- Cache frame references for performance
	local blobFrame = WorldMapBlobFrame or _G.WorldMapBlobFrame
	local mapFrame = WorldMapFrame or _G.WorldMapFrame
	local detailFrame = WorldMapDetailFrame or _G.WorldMapDetailFrame
	if not blobFrame or not mapFrame or not detailFrame then return end

	-- Use pcall to safely handle SetParent in case it's protected
	pcall(function() blobFrame:SetParent(mapFrame) end)
	blobFrame:ClearAllPoints()
	blobFrame:SetPoint("TOPLEFT", detailFrame)
	blobFrame.Hide = nil
	blobFrame.Show = nil
	blobFrame.SetScale = nil
	if blobWasVisible then
		blobFrame:Show()
		updateFrame:SetScript("OnUpdate", restoreBlobs)
	end
	if blobNewScale then
		blobFrame:SetScale(blobNewScale)
		blobFrame.xRatio = nil
		blobNewScale = nil
	end

	local selected = WorldMapQuestScrollChildFrame.selected
	if selected then
		blobFrame:DrawQuestBlob(selected.questId, false)
	end
end

local WORLDMAP_POI_MIN_X = 12
local WORLDMAP_POI_MIN_Y = -12
local WORLDMAP_POI_MAX_X     -- changes based on current scale, see WorldMapFrame_SetPOIMaxBounds
local WORLDMAP_POI_MAX_Y     -- changes based on current scale, see WorldMapFrame_SetPOIMaxBounds

function Mapster:WorldMapFrame_DisplayQuestPOI(questFrame, isComplete)
	-- Recalculate Position to adjust for Scale
	local _, posX, posY = QuestPOIGetIconInfo(questFrame.questId)
	if posX and posY then
		-- Cache frame reference and dimensions for performance
		local detailFrame = WorldMapDetailFrame or _G.WorldMapDetailFrame
		if not detailFrame then return end
		
		local POIscale = (WORLDMAP_SETTINGS or _G.WORLDMAP_SETTINGS).size
		local detailWidth = detailFrame:GetWidth()
		local detailHeight = detailFrame:GetHeight()
		posX = posX * detailWidth * POIscale
		posY = -posY * detailHeight * POIscale

		-- keep outlying POIs within map borders
		if ( posY > WORLDMAP_POI_MIN_Y ) then
			posY = WORLDMAP_POI_MIN_Y
		elseif ( posY < WORLDMAP_POI_MAX_Y ) then
			posY = WORLDMAP_POI_MAX_Y
		end
		if ( posX < WORLDMAP_POI_MIN_X ) then
			posX = WORLDMAP_POI_MIN_X
		elseif ( posX > WORLDMAP_POI_MAX_X ) then
			posX = WORLDMAP_POI_MAX_X
		end
		-- Avoid tainting secure POI frames (e.g., quick travel points that use CastSpellByID)
		-- Only apply scaling/positioning if the frame is not protected
		if questFrame.poiIcon and not questFrame.poiIcon:IsProtected() then
			questFrame.poiIcon:SetPoint("CENTER", "WorldMapPOIFrame", "TOPLEFT", posX / db.poiScale, posY / db.poiScale)
			questFrame.poiIcon:SetScale(db.poiScale)
		end
	end
end

function Mapster:WorldMapFrame_SetPOIMaxBounds()
	-- Cache frame reference for performance
	local detailFrame = WorldMapDetailFrame or _G.WorldMapDetailFrame
	local settings = WORLDMAP_SETTINGS or _G.WORLDMAP_SETTINGS
	if not detailFrame or not settings then return end
	
	WORLDMAP_POI_MAX_Y = detailFrame:GetHeight() * -settings.size + 12;
	WORLDMAP_POI_MAX_X = detailFrame:GetWidth() * settings.size + 12;
end

function Mapster:Refresh()
	db_ = self.db.profile
	
	-- Ensure modules table exists and has metatable set
	if not db_.modules then
		db_.modules = {}
	end
	-- Reapply metatable in case it was lost (shouldn't happen, but be safe)
	if not getmetatable(db_.modules) then
		setmetatable(db_.modules, {
			__index = function(t, k)
				if rawget(t, k) == nil then
					return true  -- Default to enabled
				end
				return rawget(t, k)
			end
		})
	end

	for k,v in self:IterateModules() do
		if self:GetModuleEnabled(k) and not v:IsEnabled() then
			self:EnableModule(k)
		elseif not self:GetModuleEnabled(k) and v:IsEnabled() then
			self:DisableModule(k)
		end
		if type(v.Refresh) == "function" then
			v:Refresh()
		end
	end

	if (db.miniMap and not self.miniMap) then
		self:SizeDown()
	elseif (not db.miniMap and self.miniMap) then
		self:SizeUp()
	end
	self.miniMap = db.miniMap

	-- Reset the initialization flag so settings are applied on next show
	mapShowInitialized = false
	
	self:SetStrata()
	self:SetAlpha()
	self:SetArrow()
	self:SetPOIScale()
	self:SetScale()
	self:SetPosition()

	if self.optionsButton then
		if db.hideMapButton then
			self.optionsButton:Hide()
		else
			self.optionsButton:Show()
		end
	end

	self:UpdateBorderVisibility()
	self:UpdateMouseInteractivity()
	self:UpdateModuleMapsizes()
	WorldMapFrame_UpdateQuests()
end

function Mapster:ToggleMapSize()
	self.miniMap = not self.miniMap
	db.miniMap = self.miniMap
	ToggleFrame(WorldMapFrame)
	if self.miniMap then
		self:SizeDown()
	else
		self:SizeUp()
	end
	self:SetAlpha()
	self:SetPosition()

	-- Notify the modules about the map size change,
	-- so they can re-anchor frames or stuff like that.
	self:UpdateModuleMapsizes()

	self:UpdateBorderVisibility()
	self:UpdateMouseInteractivity()

	ToggleFrame(WorldMapFrame)
	WorldMapFrame_UpdateQuests()
end

function Mapster:UpdateModuleMapsizes()
	for k,v in self:IterateModules() do
		if v:IsEnabled() and type(v.UpdateMapsize) == "function" then
			v:UpdateMapsize(self.miniMap)
		end
	end
end

function Mapster:SizeUp()
	WORLDMAP_SETTINGS.size = WORLDMAP_QUESTLIST_SIZE
	-- adjust main frame
	WorldMapFrame:SetWidth(1024)
	WorldMapFrame:SetHeight(768)
	-- adjust map frames
	WorldMapPositioningGuide:ClearAllPoints()
	WorldMapPositioningGuide:SetPoint("CENTER")
	WorldMapDetailFrame:SetScale(WORLDMAP_QUESTLIST_SIZE)
	WorldMapDetailFrame:SetPoint("TOPLEFT", WorldMapPositioningGuide, "TOP", -726, -99)
	WorldMapButton:SetScale(WORLDMAP_QUESTLIST_SIZE)
	WorldMapFrameAreaFrame:SetScale(WORLDMAP_QUESTLIST_SIZE)
	WorldMapBlobFrame:SetScale(WORLDMAP_QUESTLIST_SIZE)
	WorldMapBlobFrame.xRatio = nil		-- force hit recalculations
	-- show big window elements
	WorldMapZoneMinimapDropDown:Show()
	WorldMapZoomOutButton:Show()
	WorldMapZoneDropDown:Show()
	WorldMapContinentDropDown:Show()
	WorldMapQuestScrollFrame:Show()
	WorldMapQuestDetailScrollFrame:Show()
	WorldMapQuestRewardScrollFrame:Show()
	WorldMapFrameSizeDownButton:Show()
	-- hide small window elements
	WorldMapFrameMiniBorderLeft:Hide()
	WorldMapFrameMiniBorderRight:Hide()
	WorldMapFrameSizeUpButton:Hide()
	-- floor dropdown
	WorldMapLevelDropDown:SetPoint("TOPRIGHT", WorldMapPositioningGuide, "TOPRIGHT", -50, -35)
	WorldMapLevelDropDown.header:Show()
	-- tiny adjustments
	WorldMapFrameCloseButton:SetPoint("TOPRIGHT", WorldMapPositioningGuide, 4, 4)
	WorldMapFrameSizeDownButton:SetPoint("TOPRIGHT", WorldMapPositioningGuide, -16, 4)
	WorldMapTrackQuest:SetPoint("BOTTOMLEFT", WorldMapPositioningGuide, "BOTTOMLEFT", 16, 4)
	WorldMapFrameTitle:ClearAllPoints()
	WorldMapFrameTitle:SetPoint("CENTER", 0, 372)

	MapsterQuestObjectivesDropDown:Show()

	WorldMapFrame_SetPOIMaxBounds()
	--WorldMapQuestShowObjectives_AdjustPosition()
	self:WorldMapFrame_DisplayQuests()

	self.optionsButton:SetPoint("TOPRIGHT", WorldMapPositioningGuide, "TOPRIGHT", -43, -2)
end

function Mapster:SizeDown()
	WORLDMAP_SETTINGS.size = WORLDMAP_WINDOWED_SIZE
	-- adjust main frame
	WorldMapFrame:SetWidth(623)
	WorldMapFrame:SetHeight(437)
	-- adjust map frames
	WorldMapPositioningGuide:ClearAllPoints()
	WorldMapPositioningGuide:SetAllPoints()
	WorldMapDetailFrame:SetScale(WORLDMAP_WINDOWED_SIZE)
	WorldMapButton:SetScale(WORLDMAP_WINDOWED_SIZE)
	WorldMapFrameAreaFrame:SetScale(WORLDMAP_WINDOWED_SIZE)
	WorldMapBlobFrame:SetScale(WORLDMAP_WINDOWED_SIZE)
	WorldMapBlobFrame.xRatio = nil		-- force hit recalculations
	WorldMapFrameMiniBorderLeft:SetPoint("TOPLEFT", 10, -14)
	WorldMapDetailFrame:SetPoint("TOPLEFT", 37, -66)
	-- hide big window elements
	WorldMapZoneMinimapDropDown:Hide()
	WorldMapZoomOutButton:Hide()
	WorldMapZoneDropDown:Hide()
	WorldMapContinentDropDown:Hide()
	WorldMapLevelDropDown:Hide()
	WorldMapLevelUpButton:Hide()
	WorldMapLevelDownButton:Hide()
	WorldMapQuestScrollFrame:Hide()
	WorldMapQuestDetailScrollFrame:Hide()
	WorldMapQuestRewardScrollFrame:Hide()
	WorldMapFrameSizeDownButton:Hide()
	-- show small window elements
	WorldMapFrameMiniBorderLeft:Show()
	WorldMapFrameMiniBorderRight:Show()
	WorldMapFrameSizeUpButton:Show()
	-- floor dropdown
	WorldMapLevelDropDown:SetPoint("TOPRIGHT", WorldMapPositioningGuide, "TOPRIGHT", -441, -35)
	WorldMapLevelDropDown:SetFrameLevel(WORLDMAP_POI_FRAMELEVEL + 2)
	WorldMapLevelDropDown.header:Hide()
	-- tiny adjustments
	WorldMapFrameCloseButton:SetPoint("TOPRIGHT", WorldMapFrameMiniBorderRight, "TOPRIGHT", -44, 5)
	WorldMapFrameSizeDownButton:SetPoint("TOPRIGHT", WorldMapFrameMiniBorderRight, "TOPRIGHT", -66, 5)
	WorldMapTrackQuest:SetPoint("BOTTOMLEFT", WorldMapDetailFrame, "BOTTOMLeft", 2, -26)
	WorldMapFrameTitle:ClearAllPoints()
	WorldMapFrameTitle:SetPoint("TOP", WorldMapDetailFrame, 0, 20)

	MapsterQuestObjectivesDropDown:Hide()

	WorldMapFrame_SetPOIMaxBounds()
	--WorldMapQuestShowObjectives_AdjustPosition()

	self.optionsButton:SetPoint("TOPRIGHT", WorldMapFrameMiniBorderRight, "TOPRIGHT", -93, -2)
end

local function getZoneId()
	-- Use cached API functions if available
	local getZone = GetCurrentMapZone or _G.GetCurrentMapZone
	local getContinent = GetCurrentMapContinent or _G.GetCurrentMapContinent
	return (getZone() + getContinent() * 100)
end

function Mapster:ZONE_CHANGED_NEW_AREA()
	local curZone = getZoneId()
	local getPlayerPos = GetPlayerMapPosition or _G.GetPlayerMapPosition
	if realZone == curZone or ((curZone % 100) > 0 and getPlayerPos("player") ~= 0) then
		SetMapToCurrentZone()
		realZone = getZoneId()
	end
end

local oldBFMOnUpdate
local mapShowInitialized = false
function wmfOnShow(frame)
	-- Only set strata/scale if they've changed or on first show
	if not mapShowInitialized then
		mapShowInitialized = true
		Mapster:SetStrata()
		Mapster:SetScale()
	end
	
	-- Always apply arrow and POI scale when map is shown
	Mapster:SetArrow()
	Mapster:SetPOIScale()
	
	realZone = getZoneId()
	if BattlefieldMinimap then
		oldBFMOnUpdate = BattlefieldMinimap:GetScript("OnUpdate")
		BattlefieldMinimap:SetScript("OnUpdate", nil)
	end

	local settings = WORLDMAP_SETTINGS or _G.WORLDMAP_SETTINGS
	if settings and settings.selectedQuest then
		WorldMapFrame_SelectQuestFrame(settings.selectedQuest)
	end
end

function wmfOnHide(frame)
	SetMapToCurrentZone()
	if BattlefieldMinimap then
		BattlefieldMinimap:SetScript("OnUpdate", oldBFMOnUpdate or BattlefieldMinimap_OnUpdate)
	end
end

function wmfStartMoving(frame)
	Mapster:HideBlobs()

	frame:StartMoving()
end

function wmfStopMoving(frame)
	frame:StopMovingOrSizing()
	LibWindow.SavePosition(frame)

	Mapster:ShowBlobs()
end

function dropdownScaleFix(self)
	ToggleDropDownMenu(nil, nil, self:GetParent())
	DropDownList1:SetScale(db.scale)
end

function Mapster:ShowBlobs()
	local blobFrame = WorldMapBlobFrame or _G.WorldMapBlobFrame
	local settings = WORLDMAP_SETTINGS or _G.WORLDMAP_SETTINGS
	if not blobFrame or not settings then return end
	
	WorldMapBlobFrame_CalculateHitTranslations()
	local selectedQuest = settings.selectedQuest
	if selectedQuest and not selectedQuest.completed then
		blobFrame:DrawQuestBlob(selectedQuest.questId, true)
	end
end

function Mapster:HideBlobs()
	local blobFrame = WorldMapBlobFrame or _G.WorldMapBlobFrame
	local settings = WORLDMAP_SETTINGS or _G.WORLDMAP_SETTINGS
	if not blobFrame or not settings then return end
	
	local selectedQuest = settings.selectedQuest
	if selectedQuest then
		blobFrame:DrawQuestBlob(selectedQuest.questId, false)
	end
end

function Mapster:SetStrata()
	local mapFrame = WorldMapFrame or _G.WorldMapFrame
	if mapFrame then
		mapFrame:SetFrameStrata(db.strata)
	end
end

function Mapster:SetAlpha()
	self:ApplyVisualSettings(true)
end

function Mapster:SetArrow()
	-- Ensure we read fresh value from database
	local arrowScale = db.arrowScale
	
	local arrowFrame = _G.PlayerArrowFrame or PlayerArrowFrame
	local effectFrame = _G.PlayerArrowEffectFrame or PlayerArrowEffectFrame
	
	-- Always try to update immediately
	if arrowFrame then
		arrowFrame:SetModelScale(arrowScale)
		-- Force a visual refresh by toggling model
		if arrowFrame.ShowModel then
			arrowFrame:ShowModel()
		end
	end
	if effectFrame then
		effectFrame:SetModelScale(arrowScale)
		if effectFrame.ShowModel then
			effectFrame:ShowModel()
		end
	end
	
	-- If map is visible, use multiple delayed updates to ensure it sticks
	if WorldMapFrame and WorldMapFrame:IsVisible() then
		for _, delay in ipairs({0.01, 0.05, 0.1}) do
			C_Timer.After(delay, function()
				if arrowFrame then
					arrowFrame:SetModelScale(arrowScale)
				end
				if effectFrame then
					effectFrame:SetModelScale(arrowScale)
				end
			end)
		end
	end
end

function Mapster:SetPOIScale()
	-- Ensure we read fresh value from database
	local poiScale = db.poiScale
	
	-- Update POI max bounds first
	if WorldMapFrame_SetPOIMaxBounds then
		WorldMapFrame_SetPOIMaxBounds()
	end
	
	-- Function to update all POIs
	local function updatePOIs()
		-- Update POI max bounds
		if WorldMapFrame_SetPOIMaxBounds then
			WorldMapFrame_SetPOIMaxBounds()
		end
		
		-- Try to update existing POI icons directly
		local updatedCount = 0
		if WorldMapQuestScrollChildFrame then
			local numEntries = WorldMapQuestScrollChildFrame:GetNumChildren()
			for i = 1, numEntries do
				local questFrame = select(i, WorldMapQuestScrollChildFrame:GetChildren())
				if questFrame and questFrame.questId and questFrame.poiIcon then
					if questFrame.poiIcon and not questFrame.poiIcon:IsProtected() then
						-- Recalculate position and apply new scale
						local _, posX, posY = QuestPOIGetIconInfo(questFrame.questId)
						if posX and posY then
							local detailFrame = WorldMapDetailFrame or _G.WorldMapDetailFrame
							if detailFrame then
								local POIscale = (WORLDMAP_SETTINGS or _G.WORLDMAP_SETTINGS).size
								local detailWidth = detailFrame:GetWidth()
								local detailHeight = detailFrame:GetHeight()
								posX = posX * detailWidth * POIscale
								posY = -posY * detailHeight * POIscale
								
								-- Keep within bounds
								if (posY > WORLDMAP_POI_MIN_Y) then
									posY = WORLDMAP_POI_MIN_Y
								elseif (posY < WORLDMAP_POI_MAX_Y) then
									posY = WORLDMAP_POI_MAX_Y
								end
								if (posX < WORLDMAP_POI_MIN_X) then
									posX = WORLDMAP_POI_MIN_X
								elseif (posX > WORLDMAP_POI_MAX_X) then
									posX = WORLDMAP_POI_MAX_X
								end
								
								questFrame.poiIcon:SetPoint("CENTER", "WorldMapPOIFrame", "TOPLEFT", posX / poiScale, posY / poiScale)
								questFrame.poiIcon:SetScale(poiScale)
								updatedCount = updatedCount + 1
							end
						end
					end
				end
			end
		end
		
		-- Also try to find POI icons via WorldMapPOIFrame directly
		if WorldMapPOIFrame then
			for i = 1, NUM_WORLDMAP_POI_TEXTURES or 512 do
				local poiTexture = _G["WorldMapPOI" .. i]
				if poiTexture then
					if poiTexture:IsShown() then
						poiTexture:SetScale(poiScale)
						updatedCount = updatedCount + 1
					end
				else
					break
				end
			end
		end
		
		-- Force re-display of all quest POIs by calling the display functions
		-- This ensures any POIs we missed get updated via the hook
		if WorldMapFrame_DisplayQuests then
			WorldMapFrame_DisplayQuests()
		end
		if WorldMapFrame_UpdateQuests then
			WorldMapFrame_UpdateQuests()
		end
	end
	
	-- If map is visible, update immediately and multiple times with delays
	if WorldMapFrame and WorldMapFrame:IsVisible() then
		-- Immediate update
		updatePOIs()
		
		-- Multiple delayed updates to catch any frames that get recreated
		for _, delay in ipairs({0.01, 0.05, 0.1, 0.2}) do
			C_Timer.After(delay, updatePOIs)
		end
	else
		-- If map not visible, still update bounds for when it opens
		if WorldMapFrame_SetPOIMaxBounds then
			WorldMapFrame_SetPOIMaxBounds()
		end
	end
end

function Mapster:SetScale()
	self:ApplyVisualSettings(true)
end

function Mapster:ApplyVisualSettings(force)
	local mapFrame = FrameExists()
	if not mapFrame then return end

	local desiredAlpha = db.alpha or 1
	if force or abs(mapFrame:GetAlpha() - desiredAlpha) > 0.001 then
		mapFrame:SetAlpha(desiredAlpha)
	end

	local desiredScale = db.scale or 1
	if force or abs(mapFrame:GetScale() - desiredScale) > 0.001 then
		mapFrame:SetScale(desiredScale)
	end
end

function Mapster:SetPosition()
	local mapFrame = WorldMapFrame or _G.WorldMapFrame
	if mapFrame then
		LibWindow.RestorePosition(mapFrame)
	end
end

function Mapster:GetModuleEnabled(module)
	-- Use rawget to bypass metatable default and get actual stored value
	-- This ensures false values are properly returned instead of defaulting to true
	local value = rawget(db_.modules, module)
	if value == nil then
		return true  -- Default to enabled if never set
	end
	return value
end

function Mapster:UpdateBorderVisibility()
	if db.hideBorder then
		Mapster.bordersVisible = false
		if self.miniMap then
			WorldMapFrameMiniBorderLeft:Hide()
			WorldMapFrameMiniBorderRight:Hide()
			--WorldMapQuestShowObjectives:SetPoint("BOTTOMRIGHT", WorldMapDetailFrame, "TOPRIGHT", -50 - WorldMapQuestShowObjectivesText:GetWidth(), 2);
		else
			-- TODO
		end
		WorldMapFrameTitle:Hide()
		self:RegisterEvent("WORLD_MAP_UPDATE", "UpdateDetailTiles")
		self:UpdateDetailTiles()
		self.optionsButton:Hide()
		if not self.hookedOnUpdate then
			self:HookScript(WorldMapFrame, "OnUpdate", "UpdateMapElements")
			self.hookedOnUpdate = true
		end
		self:UpdateMapElements()
	else
		Mapster.bordersVisible = true
		if self.miniMap then
			WorldMapFrameMiniBorderLeft:Show()
			WorldMapFrameMiniBorderRight:Show()
		else
			-- TODO
		end
		--WorldMapQuestShowObjectives_AdjustPosition()
		WorldMapFrameTitle:Show()
		self:UnregisterEvent("WORLD_MAP_UPDATE")
		self:UpdateDetailTiles()
		if not db.hideMapButton then
			self.optionsButton:Show()
		end
		if self.hookedOnUpdate then
			self:Unhook(WorldMapFrame, "OnUpdate")
			self.hookedOnUpdate = nil
		end
		self:UpdateMapElements()
	end

	for k,v in self:IterateModules() do
		if v:IsEnabled() and type(v.BorderVisibilityChanged) == "function" then
			v:BorderVisibilityChanged(not db.hideBorder)
		end
	end
end

function Mapster:UpdateMapElements()
	-- Cache frame reference and hideBorder check for performance
	local mapFrame = WorldMapFrame or _G.WorldMapFrame
	if not mapFrame then return end
	
	local mouseOver = mapFrame:IsMouseOver()
	local hideBorder = db.hideBorder
	
	if self.elementsHidden and (mouseOver or not hideBorder) then
		self.elementsHidden = nil
		(self.miniMap and WorldMapFrameSizeUpButton or WorldMapFrameSizeDownButton):Show()
		WorldMapFrameCloseButton:Show()
		--WorldMapQuestShowObjectives:Show()
		for _, frame in pairs(self.elementsToHide) do
			frame:Show()
		end
	elseif not self.elementsHidden and not mouseOver and hideBorder then
		self.elementsHidden = true
		WorldMapFrameSizeUpButton:Hide()
		WorldMapFrameSizeDownButton:Hide()
		WorldMapFrameCloseButton:Hide()
		--WorldMapQuestShowObjectives:Hide()
		for _, frame in pairs(self.elementsToHide) do
			frame:Hide()
		end
	end
end

function Mapster:UpdateMouseInteractivity()
	local mapButton = WorldMapButton or _G.WorldMapButton
	local mapFrame = WorldMapFrame or _G.WorldMapFrame
	if not mapButton or not mapFrame then return end
	
	if db.disableMouse then
		mapButton:EnableMouse(false)
		mapFrame:EnableMouse(false)
	else
		mapButton:EnableMouse(true)
		mapFrame:EnableMouse(true)
	end
end

function Mapster:RefreshQuestObjectivesDisplay()
	WorldMapQuestShowObjectives:SetChecked(db.questObjectives ~= 0)
	WorldMapQuestShowObjectives:GetScript("OnClick")(WorldMapQuestShowObjectives)
end

function Mapster:WorldMapFrame_DisplayQuests()
	local settings = WORLDMAP_SETTINGS or _G.WORLDMAP_SETTINGS
	local blobFrame = WorldMapBlobFrame or _G.WorldMapBlobFrame
	if not settings or not blobFrame then return end
	
	if settings.size == WORLDMAP_WINDOWED_SIZE then return end
	if WatchFrame.showObjectives and WorldMapFrame.numQuests > 0 then
		if db.questObjectives == 1 then
			WorldMapFrame_SetFullMapView()
			
			blobFrame:SetScale(WORLDMAP_FULLMAP_SIZE)
			blobFrame.xRatio = nil		-- force hit recalculations
			WorldMapFrame_SetPOIMaxBounds()
			WorldMapFrame_UpdateQuests()
		elseif db.questObjectives == 2 then
			WorldMapFrame_SetQuestMapView()
			
			blobFrame:SetScale(WORLDMAP_QUESTLIST_SIZE)
			blobFrame.xRatio = nil		-- force hit recalculations
			WorldMapFrame_SetPOIMaxBounds()
			WorldMapFrame_UpdateQuests()
		end
	end
end

-- Cache FogClear module lookup to avoid repeated GetModule calls
local fogClearModule
local function hasOverlays()
	-- Cache module lookup for performance
	if not fogClearModule then
		if Mapster:GetModuleEnabled("FogClear") then
			fogClearModule = Mapster:GetModule("FogClear", true)
		end
	end
	
	if fogClearModule and fogClearModule:IsEnabled() then
		return fogClearModule:RealHasOverlays()
	else
		return GetNumMapOverlays() > 0
	end
end

function Mapster:UpdateDetailTiles()
	-- Cache API call for performance
	local getZone = GetCurrentMapZone or _G.GetCurrentMapZone
	if db.hideBorder and getZone() > 0 and hasOverlays() then
		for i=1, NUM_WORLDMAP_DETAIL_TILES do
			_G["WorldMapDetailTile"..i]:Hide()
		end
	else
		for i=1, NUM_WORLDMAP_DETAIL_TILES do
			_G["WorldMapDetailTile"..i]:Show()
		end
	end
end

function Mapster:SetModuleEnabled(module, value)
	-- Use rawget to get actual stored value, not metatable default
	local old = rawget(db_.modules, module)
	if old == nil then
		old = true  -- Default to enabled if never set
	end
	-- Explicitly set the value using rawset to ensure false values are saved
	-- This bypasses the metatable and stores the value directly
	rawset(db_.modules, module, value)
	
	-- Force the value to be explicitly stored (in case ElvUI has special handling)
	-- This ensures false values are definitely saved to the database
	if value == false then
		-- Explicitly mark as disabled by storing false
		db_.modules[module] = false
	elseif value == true then
		db_.modules[module] = true
	end
	
	if old ~= value then
		if value then
			self:EnableModule(module)
		else
			self:DisableModule(module)
		end
	end
end

local function questObjDropDownOnClick(button)
	UIDropDownMenu_SetSelectedValue(MapsterQuestObjectivesDropDown, button.value)
	db.questObjectives = button.value
	Mapster:RefreshQuestObjectivesDisplay()
end

local questObjTexts = {
	[0] = L["Hide Completely"],
	[1] = L["Only WorldMap Blobs"],
	[2] = L["Blobs & Panels"],
}

function questObjDropDownInit()
	local info = UIDropDownMenu_CreateInfo()
	local value = db.questObjectives

	for i=0,2 do
		info.value = i
		info.text = questObjTexts[i]
		info.func = questObjDropDownOnClick
		if ( value == i ) then
			info.checked = 1
			UIDropDownMenu_SetText(MapsterQuestObjectivesDropDown, info.text)
		else
			info.checked = nil
		end
		UIDropDownMenu_AddButton(info)
	end
end

function questObjDropDownUpdate()
	UIDropDownMenu_SetSelectedValue(MapsterQuestObjectivesDropDown, db.questObjectives)
	UIDropDownMenu_SetText(MapsterQuestObjectivesDropDown,questObjTexts[db.questObjectives])
end

-- ElvUI Integration
local function InitializeCallback()
	Mapster:Initialize()
	Mapster:Enable()
end

E:RegisterInitialModule(Mapster:GetName(), InitializeCallback)

function Mapster:ScheduleWarmup()
	if self._warmupHooked then return end

	local function hookWarmup()
		if self._warmupHooked or not WorldMapFrame then
			return
		end

		self._warmupHooked = true

		local function performWarmup()
			if not WorldMapFrame then return end

			self:Unhook(WorldMapFrame, "OnHide")
			self._warmupHooked = nil

			if WorldMapFrame:IsShown() then return end

			local alpha = WorldMapFrame:GetAlpha()
			WorldMapFrame:SetAlpha(0)

			local ok, err = pcall(function()
				WorldMapFrame:Show()
				WorldMapFrame:Hide()
			end)

			WorldMapFrame:SetAlpha(alpha)

			if not ok and E.DebugPrint then
				E:DebugPrint("Mapster warmup failed:", err)
			end
		end

		self:SecureHook(_G, "WorldMapFrame_OnShow", function()
			self:Unhook(_G, "WorldMapFrame_OnShow")
			if WorldMapFrame then
				self:SecureHook(_G, "WorldMapFrame_OnHide", function()
					if not self._deferredWarmup then
						self._deferredWarmup = true
						C_Timer.After(0.2 + math.random() * 0.3, function()
							performWarmup()
							self._deferredWarmup = nil
						end)
					end
				end)
			end
		end)
	end

	if WorldMapFrame then
		hookWarmup()
	else
		self:RegisterEvent("ADDON_LOADED", function(_, addon)
			if addon == "Blizzard_WorldMap" or addon == "Blizzard_WorldMapClassic" then
				self:UnregisterEvent("ADDON_LOADED")
				hookWarmup()
			end
		end)
	end
end
