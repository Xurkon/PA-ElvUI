-- Magnify World Map Zoom Module for ElvUI
-- Integrated from Magnify-WotLK by rissole

local E, L, V, P, G = unpack(select(2, ...))
local WM = E:GetModule("WorldMap")

if not WM then return end -- Safety check

-- Constants
local MIN_ZOOM = 1.0
local MINIMODE_MIN_ZOOM = 1.0
local MINIMODE_MAX_ZOOM = 3.0
local MINIMODE_ZOOM_STEP = 0.1
local WORLDMAP_POI_MIN_X = 12
local WORLDMAP_POI_MIN_Y = -12
local PLAYER_ARROW_SIZE = 36

-- Dynamic bounds (set by SetPOIMaxBounds)
local worldmapPoiMaxX, worldmapPoiMaxY

-- Previous state for zoom persistence
local PreviousState = {
	panX = 0,
	panY = 0,
	scale = 1,
	zone = 0
}

-- Helper function to update frame point relationships
local function updatePointRelativeTo(frame, newRelativeFrame)
	if not frame then return end
	local currentPoint, _, currentRelativePoint, currentOffsetX, currentOffsetY = frame:GetPoint()
	frame:ClearAllPoints()
	frame:SetPoint(currentPoint, newRelativeFrame, currentRelativePoint, currentOffsetX, currentOffsetY)
end

-- Resize POI markers to match zoom
local function resizePOI(poiButton)
	if not poiButton then return end
	
	local _, _, _, x, y = poiButton:GetPoint()
	if not (x and y) then return end
	
	local s = WORLDMAP_SETTINGS.size / WorldMapDetailFrame:GetEffectiveScale()
	local posX = x / s
	local posY = y / s
	
	poiButton:SetScale(s)
	poiButton:SetPoint("CENTER", poiButton:GetParent(), "TOPLEFT", posX, posY)
	
	-- Clamp positions
	if posY > WORLDMAP_POI_MIN_Y then
		posY = WORLDMAP_POI_MIN_Y
	elseif worldmapPoiMaxY and posY < worldmapPoiMaxY then
		posY = worldmapPoiMaxY
	end
	
	if posX < WORLDMAP_POI_MIN_X then
		posX = WORLDMAP_POI_MIN_X
	elseif worldmapPoiMaxX and posX > worldmapPoiMaxX then
		posX = worldmapPoiMaxX
	end
end

-- Store current map scroll and pan state
local function PersistMapScrollAndPan()
	PreviousState.panX = WorldMapScrollFrame:GetHorizontalScroll()
	PreviousState.panY = WorldMapScrollFrame:GetVerticalScroll()
	PreviousState.scale = WorldMapDetailFrame:GetScale()
	PreviousState.zone = GetCurrentMapZone()
end

-- Called after scrolling or panning
local function AfterScrollOrPan()
	PersistMapScrollAndPan()
	if WORLDMAP_SETTINGS.selectedQuest then
		WorldMapBlobFrame:DrawQuestBlob(WORLDMAP_SETTINGS.selectedQuestId, false)
		WorldMapBlobFrame:DrawQuestBlob(WORLDMAP_SETTINGS.selectedQuestId, true)
	end
end

-- Resize all quest POI buttons
local function ResizeQuestPOIs()
	local QUEST_POI_MAX_TYPES = 4
	local POI_TYPE_MAX_BUTTONS = 25
	
	for i = 1, QUEST_POI_MAX_TYPES do
		for j = 1, POI_TYPE_MAX_BUTTONS do
			local buttonName = "poiWorldMapPOIFrame" .. i .. "_" .. j
			resizePOI(_G[buttonName])
		end
	end
	
	if QUEST_POI_SWAP_BUTTONS and QUEST_POI_SWAP_BUTTONS["WorldMapPOIFrame"] then
		resizePOI(QUEST_POI_SWAP_BUTTONS["WorldMapPOIFrame"])
	end
end

-- Set POI bounds based on current map size
local function SetPOIMaxBounds()
	worldmapPoiMaxY = WorldMapDetailFrame:GetHeight() * -WORLDMAP_SETTINGS.size + 12
	worldmapPoiMaxX = WorldMapDetailFrame:GetWidth() * WORLDMAP_SETTINGS.size + 12
end

-- Set the detail frame scale and update related frames
local function SetDetailFrameScale(num)
	WorldMapDetailFrame:SetScale(num)
	SetPOIMaxBounds()
	
	WorldMapPOIFrame:SetScale(1 / WORLDMAP_SETTINGS.size)
	WorldMapBlobFrame:SetScale(num)
	
	WorldMapPlayer:SetScale(1 / WorldMapDetailFrame:GetScale())
	WorldMapDeathRelease:SetScale(1 / WorldMapDetailFrame:GetScale())
	WorldMapCorpse:SetScale(1 / WorldMapDetailFrame:GetScale())
	
	-- Scale flags
	local numFlags = GetNumBattlefieldFlagPositions()
	for i = 1, numFlags do
		local flagFrame = _G["WorldMapFlag" .. i]
		if flagFrame then
			flagFrame:SetScale(1 / WorldMapDetailFrame:GetScale())
		end
	end
	
	-- Scale party frames
	for i = 1, MAX_PARTY_MEMBERS do
		local partyFrame = _G["WorldMapParty" .. i]
		if partyFrame then
			partyFrame:SetScale(1 / WorldMapDetailFrame:GetScale())
		end
	end
	
	-- Scale raid frames
	for i = 1, MAX_RAID_MEMBERS do
		local raidFrame = _G["WorldMapRaid" .. i]
		if raidFrame then
			raidFrame:SetScale(1 / WorldMapDetailFrame:GetScale())
		end
	end
	
	-- Scale vehicles
	for i = 1, #MAP_VEHICLES do
		if MAP_VEHICLES[i] then
			MAP_VEHICLES[i]:SetScale(1 / WorldMapDetailFrame:GetScale())
		end
	end
	
	WorldMapFrame_OnEvent(WorldMapFrame, "DISPLAY_SIZE_CHANGED")
	if WorldMapFrame_UpdateQuests() > 0 then
		WM:RedrawSelectedQuest()
	end
end

-- Setup ElvUI-specific world map elements
function WM:ElvUI_SetupMagnify()
	if not self.coordsHolder or not self.coordsHolder.playerCoords then return end
	updatePointRelativeTo(self.coordsHolder.playerCoords, WorldMapScrollFrame)
	
	if WorldMapDetailFrame.backdrop then
		WorldMapDetailFrame.backdrop:Hide()
	end
	
	if WorldMapFrame.backdrop then
		WorldMapFrame.backdrop.Point = function() return end
		WorldMapFrame.backdrop:ClearAllPoints()
		
		if WorldMapZoneMinimapDropDown:IsVisible() then
			WorldMapFrame.backdrop:SetPoint("TOPLEFT", WorldMapZoneMinimapDropDown, "TOPLEFT", -20, 40)
		else
			WorldMapFrame.backdrop:SetPoint("TOPLEFT", WorldMapTitleButton, "TOPLEFT", 0, 0)
		end
		
		WorldMapFrame.backdrop:SetPoint("BOTTOM", WorldMapQuestShowObjectives, "BOTTOM", 0, 0)
		WorldMapFrame.backdrop:SetPoint("RIGHT", WorldMapFrameCloseButton, "RIGHT", 0, 0)
	end
end

-- Main setup function for world map frame
function WM:SetupMagnifyFrame()
	if not E.db.general.magnify or not E.db.general.magnify.enable then return end
	if not WorldMapScrollFrame then return end
	
	WorldMapScrollFrameScrollBar:Hide()
	WorldMapFrame:EnableMouse(true)
	WorldMapScrollFrame:EnableMouse(true)
	WorldMapScrollFrame.panning = false
	WorldMapScrollFrame.moved = false
	
	if WORLDMAP_SETTINGS.size == WORLDMAP_QUESTLIST_SIZE then
		WorldMapScrollFrame:SetPoint("TOPLEFT", WorldMapPositioningGuide, "TOP", -726, -99)
		WorldMapTrackQuest:SetPoint("BOTTOMLEFT", WorldMapPositioningGuide, "BOTTOMLEFT", 8, 4)
	elseif WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE then
		WorldMapTrackQuest:SetPoint("BOTTOMLEFT", WorldMapPositioningGuide, "BOTTOMLEFT", 16, -9)
		WorldMapFrame:SetPoint("TOPLEFT", WorldMapScreenAnchor, 0, 0)
		WorldMapFrame:SetScale(WorldMapScreenAnchor.preferredMinimodeScale or 1)
		WorldMapFrame:SetMovable(true)
		WorldMapTitleButton:Show()
		WorldMapTitleButton:ClearAllPoints()
		WorldMapFrameTitle:Show()
		WorldMapFrameTitle:ClearAllPoints()
		WorldMapFrameTitle:SetPoint("CENTER", WorldMapTitleButton, "CENTER", 32, 0)
		
		if WORLDMAP_SETTINGS.advanced then
			WorldMapScrollFrame:SetPoint("TOPLEFT", 19, -42)
			WorldMapTitleButton:SetPoint("TOPLEFT", WorldMapFrame, "TOPLEFT", 13, 0)
		else
			WorldMapScrollFrame:SetPoint("TOPLEFT", 37, -66)
			WorldMapTitleButton:SetPoint("TOPLEFT", WorldMapFrame, "TOPLEFT", 13, -14)
		end
	else
		WorldMapScrollFrame:SetPoint("TOPLEFT", WorldMapPositioningGuide, "TOPLEFT", 11, -70.5)
		WorldMapTrackQuest:SetPoint("BOTTOMLEFT", WorldMapPositioningGuide, "BOTTOMLEFT", 16, -9)
	end
	
	WorldMapScrollFrame:SetScale(WORLDMAP_SETTINGS.size)
	
	SetDetailFrameScale(1)
	WorldMapDetailFrame:SetAllPoints(WorldMapScrollFrame)
	WorldMapScrollFrame:SetHorizontalScroll(0)
	WorldMapScrollFrame:SetVerticalScroll(0)
	
	-- Restore previous zoom if persist is enabled
	if E.db.general.magnify.enablePersistZoom and GetCurrentMapZone() == PreviousState.zone then
		SetDetailFrameScale(PreviousState.scale)
		WorldMapScrollFrame:SetHorizontalScroll(PreviousState.panX)
		WorldMapScrollFrame:SetVerticalScroll(PreviousState.panY)
	end
	
	WorldMapButton:SetScale(1)
	WorldMapButton:SetAllPoints(WorldMapDetailFrame)
	pcall(function() WorldMapButton:SetParent(WorldMapDetailFrame) end)
	
	pcall(function() WorldMapPOIFrame:SetParent(WorldMapDetailFrame) end)
	pcall(function() WorldMapPlayer:SetParent(WorldMapDetailFrame) end)
	
	updatePointRelativeTo(WorldMapQuestScrollFrame, WorldMapScrollFrame)
	updatePointRelativeTo(WorldMapQuestDetailScrollFrame, WorldMapScrollFrame)
	
	self:ElvUI_SetupMagnify()
end

-- Handle panning
local function WorldMapScrollFrame_OnPan(cursorX, cursorY)
	local dX = WorldMapScrollFrame.cursorX - cursorX
	local dY = cursorY - WorldMapScrollFrame.cursorY
	dX = dX / WorldMapScrollFrame:GetEffectiveScale()
	dY = dY / WorldMapScrollFrame:GetEffectiveScale()
	
	if abs(dX) >= 1 or abs(dY) >= 1 then
		WorldMapScrollFrame.moved = true
		
		local x = max(0, dX + WorldMapScrollFrame.x)
		x = min(x, WorldMapScrollFrame.maxX)
		WorldMapScrollFrame:SetHorizontalScroll(x)
		
		local y = max(0, dY + WorldMapScrollFrame.y)
		y = min(y, WorldMapScrollFrame.maxY)
		WorldMapScrollFrame:SetVerticalScroll(y)
		
		AfterScrollOrPan()
	end
end

-- Color party member frames by class
local function ColorWorldMapPartyMemberFrame(partyMemberFrame, unit)
	if not (E.db.general.magnify and partyMemberFrame) then return end
	
	local classColor = RAID_CLASS_COLORS[select(2, UnitClass(unit))]
	if classColor and not E.db.general.magnify.enableOldPartyIcons then
		if partyMemberFrame.colorIcon then
			partyMemberFrame.colorIcon:Show()
		end
		if partyMemberFrame.icon then
			partyMemberFrame.icon:Hide()
		end
		if partyMemberFrame.colorIcon then
			partyMemberFrame.colorIcon:SetVertexColor(classColor.r, classColor.g, classColor.b, 1)
		end
	else
		if partyMemberFrame.colorIcon then
			partyMemberFrame.colorIcon:Hide()
		end
		if partyMemberFrame.icon then
			partyMemberFrame.icon:Show()
		end
	end
end

-- Button update handler
local function WorldMapButton_OnUpdate(self, elapsed)
	if not (E.db.general.magnify and E.db.general.magnify.enable) then return end
	
	local x, y = GetCursorPosition()
	x = x / self:GetEffectiveScale()
	y = y / self:GetEffectiveScale()
	
	local centerX, centerY = self:GetCenter()
	local width = self:GetWidth()
	local height = self:GetHeight()
	local adjustedY = (centerY + (height / 2) - y) / height
	local adjustedX = (x - (centerX - (width / 2))) / width
	
	local name, fileName, texPercentageX, texPercentageY, textureX, textureY, scrollChildX, scrollChildY
	if self:IsMouseOver() then
		name, fileName, texPercentageX, texPercentageY, textureX, textureY, scrollChildX, scrollChildY =
			UpdateMapHighlight(adjustedX, adjustedY)
	end
	
	WorldMapFrame.areaName = name
	if not WorldMapFrame.poiHighlight then
		WorldMapFrameAreaLabel:SetText(name)
	end
	
	if fileName then
		WorldMapHighlight:SetTexCoord(0, texPercentageX, 0, texPercentageY)
		WorldMapHighlight:SetTexture("Interface\\WorldMap\\" .. fileName .. "\\" .. fileName .. "Highlight")
		textureX = textureX * width
		textureY = textureY * height
		scrollChildX = scrollChildX * width
		scrollChildY = -scrollChildY * height
		
		if (textureX > 0) and (textureY > 0) then
			WorldMapHighlight:SetWidth(textureX)
			WorldMapHighlight:SetHeight(textureY)
			WorldMapHighlight:SetPoint("TOPLEFT", "WorldMapDetailFrame", "TOPLEFT", scrollChildX, scrollChildY)
			WorldMapHighlight:Show()
		end
	else
		WorldMapHighlight:Hide()
	end
	
	-- Position player
	UpdateWorldMapArrowFrames()
	local playerX, playerY = GetPlayerMapPosition("player")
	if (playerX == 0 and playerY == 0) then
		ShowWorldMapArrowFrame(nil)
		WorldMapPing:Hide()
		WorldMapPlayer:Hide()
	else
		playerX = playerX * WorldMapDetailFrame:GetWidth() * WorldMapDetailFrame:GetScale() * WORLDMAP_SETTINGS.size
		playerY = -playerY * WorldMapDetailFrame:GetHeight() * WorldMapDetailFrame:GetScale() * WORLDMAP_SETTINGS.size
		PositionWorldMapArrowFrame("CENTER", "WorldMapDetailFrame", "TOPLEFT", playerX, playerY)
		ShowWorldMapArrowFrame(nil)
		
		WorldMapPlayer:SetAllPoints(PlayerArrowFrame)
		if WorldMapPlayer.Icon then
			WorldMapPlayer.Icon:SetRotation(PlayerArrowFrame:GetFacing())
			WorldMapPlayer.Icon:SetSize(PLAYER_ARROW_SIZE, PLAYER_ARROW_SIZE)
		end
		WorldMapPlayer:Show()
	end
	
	-- Position party/raid members
	if GetNumRaidMembers() > 0 then
		for i = 1, MAX_PARTY_MEMBERS do
			_G["WorldMapParty" .. i]:Hide()
		end
		for i = 1, MAX_RAID_MEMBERS do
			local unit = "raid" .. i
			local partyX, partyY = GetPlayerMapPosition(unit)
			local partyFrame = _G["WorldMapRaid" .. i]
			
			if (partyX == 0 and partyY == 0) or UnitIsUnit(unit, "player") then
				partyFrame:Hide()
			else
				partyX = partyX * WorldMapDetailFrame:GetWidth() * WorldMapDetailFrame:GetScale()
				partyY = -partyY * WorldMapDetailFrame:GetHeight() * WorldMapDetailFrame:GetScale()
				partyFrame:SetPoint("CENTER", "WorldMapDetailFrame", "TOPLEFT", partyX, partyY)
				partyFrame.name = nil
				partyFrame.unit = unit
				ColorWorldMapPartyMemberFrame(partyFrame, unit)
				partyFrame:Show()
			end
		end
	else
		for i = 1, MAX_PARTY_MEMBERS do
			local partyX, partyY = GetPlayerMapPosition("party" .. i)
			local partyFrame = _G["WorldMapParty" .. i]
			
			if partyX == 0 and partyY == 0 then
				partyFrame:Hide()
			else
				partyX = partyX * WorldMapButton:GetWidth() * WorldMapDetailFrame:GetScale()
				partyY = -partyY * WorldMapButton:GetHeight() * WorldMapDetailFrame:GetScale()
				partyFrame:SetPoint("CENTER", "WorldMapButton", "TOPLEFT", partyX, partyY)
				ColorWorldMapPartyMemberFrame(partyFrame, "party" .. i)
				partyFrame:Show()
			end
		end
	end
	
	-- Handle panning
	if WorldMapScrollFrame.panning then
		WorldMapScrollFrame_OnPan(GetCursorPosition())
	end
end

-- Mouse wheel zoom handler
local function WorldMapScrollFrame_OnMouseWheel()
	if not (E.db.general.magnify and E.db.general.magnify.enable) then return end
	
	-- Ctrl + Wheel for minimode window scaling
	if IsControlKeyDown() and WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE then
		local oldScale = WorldMapFrame:GetScale()
		local newScale = oldScale + arg1 * MINIMODE_ZOOM_STEP
		newScale = max(MINIMODE_MIN_ZOOM, newScale)
		newScale = min(MINIMODE_MAX_ZOOM, newScale)
		WorldMapFrame:SetScale(newScale)
		WorldMapScreenAnchor.preferredMinimodeScale = newScale
		return
	end
	
	local cursorX, cursorY = GetCursorPosition()
	cursorX = cursorX / WorldMapScrollFrame:GetEffectiveScale()
	cursorY = cursorY / WorldMapScrollFrame:GetEffectiveScale()
	
	local frameX = cursorX - WorldMapScrollFrame:GetLeft()
	local frameY = WorldMapScrollFrame:GetTop() - cursorY
	
	local oldScale = WorldMapDetailFrame:GetScale()
	local newScale = oldScale * (1.0 + arg1 * E.db.general.magnify.zoomStep)
	newScale = max(MIN_ZOOM, newScale)
	newScale = min(E.db.general.magnify.maxZoom, newScale)
	
	SetDetailFrameScale(newScale)
	
	WorldMapScrollFrame.maxX = ((WorldMapDetailFrame:GetWidth() * newScale) - WorldMapScrollFrame:GetWidth()) / newScale
	WorldMapScrollFrame.maxY = ((WorldMapDetailFrame:GetHeight() * newScale) - WorldMapScrollFrame:GetHeight()) / newScale
	WorldMapScrollFrame.zoomedIn = WorldMapDetailFrame:GetScale() > MIN_ZOOM
	
	local oldScrollH = WorldMapScrollFrame:GetHorizontalScroll()
	local oldScrollV = WorldMapScrollFrame:GetVerticalScroll()
	
	local centerX = oldScrollH + frameX / oldScale
	local centerY = oldScrollV + frameY / oldScale
	local newScrollH = centerX - frameX / newScale
	local newScrollV = centerY - frameY / newScale
	
	newScrollH = min(newScrollH, WorldMapScrollFrame.maxX)
	newScrollH = max(0, newScrollH)
	newScrollV = min(newScrollV, WorldMapScrollFrame.maxY)
	newScrollV = max(0, newScrollV)
	
	WorldMapScrollFrame:SetHorizontalScroll(newScrollH)
	WorldMapScrollFrame:SetVerticalScroll(newScrollV)
	
	AfterScrollOrPan()
end

-- Mouse down handler for panning
local function WorldMapButton_OnMouseDown()
	if not (E.db.general.magnify and E.db.general.magnify.enable) then return end
	
	if arg1 == 'LeftButton' and WorldMapScrollFrame.zoomedIn then
		WorldMapScrollFrame.panning = true
		local x, y = GetCursorPosition()
		WorldMapScrollFrame.cursorX = x
		WorldMapScrollFrame.cursorY = y
		WorldMapScrollFrame.x = WorldMapScrollFrame:GetHorizontalScroll()
		WorldMapScrollFrame.y = WorldMapScrollFrame:GetVerticalScroll()
		WorldMapScrollFrame.moved = false
	end
end

-- Mouse up handler
local function WorldMapButton_OnMouseUp()
	if not (E.db.general.magnify and E.db.general.magnify.enable) then return end
	
	WorldMapScrollFrame.panning = false
	
	if not WorldMapScrollFrame.moved then
		WorldMapButton_OnClick(WorldMapButton, arg1)
		SetDetailFrameScale(MIN_ZOOM)
		WorldMapScrollFrame:SetHorizontalScroll(0)
		WorldMapScrollFrame:SetVerticalScroll(0)
		AfterScrollOrPan()
		WorldMapScrollFrame.zoomedIn = false
	end
	
	WorldMapScrollFrame.moved = false
end

-- Redraw selected quest
function WM:RedrawSelectedQuest()
	if WORLDMAP_SETTINGS.selectedQuestId then
		WorldMapFrame_SelectQuestById(WORLDMAP_SETTINGS.selectedQuestId)
	else
		local frame = _G["WorldMapQuestFrame1"]
		if frame then
			WorldMapFrame_SelectQuestFrame(frame)
		end
	end
end

-- Create class-colored icon for party members
local function CreateClassColorIcon(partyMemberFrame)
	if not partyMemberFrame then return end
	
	partyMemberFrame.colorIcon = partyMemberFrame:CreateTexture(nil, "ARTWORK")
	partyMemberFrame.colorIcon:SetAllPoints(partyMemberFrame)
	partyMemberFrame.colorIcon:SetTexture([[Interface\AddOns\ElvUI\Media\Textures\WorldMapPlayer]])
end

-- Initialize Magnify functionality
function WM:InitializeMagnify()
	if not (E.db.general.magnify and E.db.general.magnify.enable) then return end
	if not WorldMapScrollFrame then return end
	
	-- Set up scroll frame
	WorldMapScrollFrame:SetScrollChild(WorldMapDetailFrame)
	WorldMapScrollFrame:SetScript("OnMouseWheel", WorldMapScrollFrame_OnMouseWheel)
	WorldMapButton:SetScript("OnMouseDown", WorldMapButton_OnMouseDown)
	WorldMapButton:SetScript("OnMouseUp", WorldMapButton_OnMouseUp)
	WorldMapDetailFrame:SetParent(WorldMapScrollFrame)
	
	WorldMapFrameAreaFrame:SetParent(WorldMapFrame)
	WorldMapFrameAreaFrame:SetFrameLevel(WORLDMAP_POI_FRAMELEVEL)
	WorldMapFrameAreaFrame:SetPoint("TOP", WorldMapScrollFrame, "TOP", 0, -10)
	
	-- Disable ping display
	WorldMapPing.Show = function() return end
	WorldMapPing:SetModelScale(0)
	
	-- Create higher quality player arrow
	WorldMapPlayer.Icon = WorldMapPlayer:CreateTexture(nil, 'ARTWORK')
	WorldMapPlayer.Icon:SetSize(PLAYER_ARROW_SIZE, PLAYER_ARROW_SIZE)
	WorldMapPlayer.Icon:SetPoint("CENTER", 0, 0)
	WorldMapPlayer.Icon:SetTexture([[Interface\AddOns\ElvUI\Media\Textures\WorldMapArrow]])
	
	-- Hook functions
	hooksecurefunc("WorldMapFrame_SetFullMapView", function() WM:SetupMagnifyFrame() end)
	hooksecurefunc("WorldMapFrame_SetQuestMapView", function() WM:SetupMagnifyFrame() end)
	hooksecurefunc("WorldMap_ToggleSizeDown", function() WM:SetupMagnifyFrame() end)
	hooksecurefunc("WorldMap_ToggleSizeUp", function() WM:SetupMagnifyFrame() end)
	hooksecurefunc("WorldMapFrame_UpdateQuests", ResizeQuestPOIs)
	hooksecurefunc("WorldMapFrame_SetPOIMaxBounds", SetPOIMaxBounds)
	
	hooksecurefunc("WorldMapQuestShowObjectives_AdjustPosition", function()
		if WORLDMAP_SETTINGS.size == WORLDMAP_WINDOWED_SIZE then
			WorldMapQuestShowObjectives:SetPoint("BOTTOMRIGHT", WorldMapPositioningGuide, "BOTTOMRIGHT",
				-30 - WorldMapQuestShowObjectivesText:GetWidth(), -9)
		else
			WorldMapQuestShowObjectives:SetPoint("BOTTOMRIGHT", WorldMapPositioningGuide, "BOTTOMRIGHT",
				-15 - WorldMapQuestShowObjectivesText:GetWidth(), 4)
		end
	end)
	
	-- Set up window dragging
	WorldMapScreenAnchor:StartMoving()
	WorldMapScreenAnchor:SetPoint("TOPLEFT", 10, -118)
	WorldMapScreenAnchor:StopMovingOrSizing()
	
	-- Calculate preferred scale
	WorldMapScreenAnchor.preferredMinimodeScale = 1 + (0.4 * WorldMapFrame:GetHeight() / WorldFrame:GetHeight())
	
	-- Title button dragging
	WorldMapTitleButton:SetScript("OnDragStart", function()
		WorldMapScreenAnchor:ClearAllPoints()
		WorldMapFrame:ClearAllPoints()
		WorldMapFrame:StartMoving()
	end)
	
	WorldMapTitleButton:SetScript("OnDragStop", function()
		WorldMapFrame:StopMovingOrSizing()
		WorldMapScreenAnchor:StartMoving()
		WorldMapScreenAnchor:SetPoint("TOPLEFT", WorldMapFrame)
		WorldMapScreenAnchor:StopMovingOrSizing()
	end)
	
	-- Set button update handler
	WorldMapButton:SetScript("OnUpdate", WorldMapButton_OnUpdate)
	
	-- Hook OnShow
	local original_OnShow = WorldMapFrame:GetScript("OnShow")
	WorldMapFrame:SetScript("OnShow", function(self)
		if original_OnShow then
			original_OnShow(self)
		end
		WM:SetupMagnifyFrame()
	end)
	
	-- Create class color icons for party and raid
	for i = 1, MAX_RAID_MEMBERS do
		CreateClassColorIcon(_G["WorldMapParty" .. i])
		CreateClassColorIcon(_G["WorldMapRaid" .. i])
	end
end

