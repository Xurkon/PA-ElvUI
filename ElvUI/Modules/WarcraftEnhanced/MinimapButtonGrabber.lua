local enhancedEnabled
if GetAddOnInfo then
	local _, _, _, enabled = GetAddOnInfo("ElvUI_Enhanced")
	enhancedEnabled = enabled
end
if enhancedEnabled then return end

local E, L = unpack(ElvUI)
local WE = E.WarcraftEnhanced

local MBG = E:NewModule("WarcraftEnhanced_MinimapButtonGrabber", "AceHook-3.0", "AceTimer-3.0")

local ipairs, select, unpack = ipairs, select, unpack
local ceil = math.ceil
local find, len, sub = string.find, string.len, string.sub
local tinsert = table.insert

local UIFrameFadeIn = UIFrameFadeIn
local UIFrameFadeOut = UIFrameFadeOut

local ignoreButtons = {
	["ElvConfigToggle"] = true,

	["BattlefieldMinimap"] = true,
	["ButtonCollectFrame"] = true,
	["GameTimeFrame"] = true,
	["MiniMapBattlefieldFrame"] = true,
	["MiniMapLFGFrame"] = true,
	["MiniMapMailFrame"] = true,
	["MiniMapPing"] = true,
	["MiniMapRecordingButton"] = true,
	["MiniMapTracking"] = true,
	["MiniMapTrackingButton"] = true,
	["MiniMapVoiceChatFrame"] = true,
	["MiniMapWorldMapButton"] = true,
	["Minimap"] = true,
	["MinimapBackdrop"] = true,
	["MinimapToggleButton"] = true,
	["MinimapZoneTextButton"] = true,
	["MinimapZoomIn"] = true,
	["MinimapZoomOut"] = true,
	["TimeManagerClockButton"] = true,
}

local genericIgnores = {
	"GuildInstance",

	-- GatherMate
	"GatherMatePin",
	-- Gatherer
	"GatherNote",
	-- GuildMap3
	"GuildMap3Mini",
	-- HandyNotes
	"HandyNotesPin",
	-- LibRockConfig
	"LibRockConfig-1.0_MinimapButton",
	-- Nauticus
	"NauticusMiniIcon",
	"WestPointer",
	-- QuestPointer
	"poiMinimap",
	-- Spy
	"Spy_MapNoteList_mini",
}

local partialIgnores = {
	"Node",
	"Note",
	"Pin",
}

local whiteList = {
	"LibDBIcon",
}

local buttonFunctions = {
	"SetParent",
	"SetFrameStrata",
	"SetFrameLevel",
	"ClearAllPoints",
	"SetPoint",
	"SetScale",
	"SetSize",
	"SetWidth",
	"SetHeight"
}

local function FrameOnEnter()
	if not MBG.db or not MBG.db.mouseover or not MBG.frame then
		return
	end

	UIFrameFadeIn(MBG.frame, 0.1, MBG.frame:GetAlpha(), MBG.maxAlpha)
end

local function FrameOnLeave()
	if not MBG.db or not MBG.db.mouseover or not MBG.frame then
		return
	end

	UIFrameFadeOut(MBG.frame, 0.1, MBG.frame:GetAlpha(), 0)
end

local function ButtonOnEnter()
	FrameOnEnter()
end

local function ButtonOnLeave()
	FrameOnLeave()
end

function MBG:LockButton(button)
	for _, func in ipairs(buttonFunctions) do
		button[func] = E.noop
	end
end

function MBG:UnlockButton(button)
	for _, func in ipairs(buttonFunctions) do
		button[func] = nil
	end
end

function MBG:CheckVisibility()
	local updateLayout

	for _, button in ipairs(self.skinnedButtons) do
		if button:IsVisible() and button.__hidden then
			button.__hidden = false
			updateLayout = true
		elseif not button:IsVisible() and not button.__hidden then
			button.__hidden = true
			updateLayout = true
		end
	end

	return updateLayout
end

function MBG:GetVisibleList()
	local t = {}

	for _, button in ipairs(self.skinnedButtons) do
		if button:IsVisible() then
			tinsert(t, button)
		end
	end

	return t
end

function MBG:GrabMinimapButtons()
	if not self.frame or not self.db then return end

	for _, frame in ipairs(self.minimapFrames) do
		if frame and frame.GetNumChildren then
			for i = 1, frame:GetNumChildren() do
				local object = select(i, frame:GetChildren())

				if object and object:IsObjectType("Button") then
					self:SkinMinimapButton(object)
				end
			end
		end
	end

	if AtlasButton and AtlasButtonFrame then self:SkinMinimapButton(AtlasButton) end
	if FishingBuddyMinimapButton and FishingBuddyMinimapFrame then self:SkinMinimapButton(FishingBuddyMinimapButton) end
	if HealBot_MMButton then self:SkinMinimapButton(HealBot_MMButton) end

	if self.needUpdate or self:CheckVisibility() then
		self:UpdateLayout()
	end
end

function MBG:SkinMinimapButton(button)
	if not button or button.isSkinned then return end

	local name = button:GetName()
	if not name then return end

	if button:IsObjectType("Button") then
		local validIcon

		for i = 1, #whiteList do
			if sub(name, 1, len(whiteList[i])) == whiteList[i] then
				validIcon = true
				break
			end
		end

		if not validIcon then
			if ignoreButtons[name] then return end

			for i = 1, #genericIgnores do
				if sub(name, 1, len(genericIgnores[i])) == genericIgnores[i] then return end
			end

			for i = 1, #partialIgnores do
				if find(name, partialIgnores[i]) then return end
			end
		end

		button:SetPushedTexture(nil)
		button:SetHighlightTexture(nil)
		button:SetDisabledTexture(nil)
	end

	for i = 1, button:GetNumRegions() do
		local region = select(i, button:GetRegions())

		if region and region:GetObjectType() == "Texture" then
			local texture = region:GetTexture()

			if texture and (find(texture, "Border") or find(texture, "Background") or find(texture, "AlphaMask")) then
				region:SetTexture(nil)
			else
				if name == "BagSync_MinimapButton" then
					region:SetTexture("Interface\\AddOns\\BagSync\\media\\icon")
				elseif name == "DBMMinimapButton" then
					region:SetTexture("Interface\\Icons\\INV_Helmet_87")
				elseif name == "OutfitterMinimapButton" then
					if region:GetTexture() == "Interface\\Addons\\Outfitter\\Textures\\MinimapButton" then
						region:SetTexture(nil)
					end
				elseif name == "SmartBuff_MiniMapButton" then
					region:SetTexture("Interface\\Icons\\Spell_Nature_Purge")
				elseif name == "VendomaticButtonFrame" then
					region:SetTexture("Interface\\Icons\\INV_Misc_Rabbit_2")
				end

				region:ClearAllPoints()
				region:SetInside()
				region:SetTexCoord(unpack(E.TexCoords))
				button:HookScript("OnLeave", function() region:SetTexCoord(unpack(E.TexCoords)) end)

				region:SetDrawLayer("ARTWORK")
				region.SetPoint = E.noop
			end
		end
	end

	button.__MBGOriginalParent = button.__MBGOriginalParent or button:GetParent()
	button:SetParent(self.frame)
	button:SetFrameLevel(self.frame:GetFrameLevel() + 5)
	button:SetTemplate()

	self:LockButton(button)

	button:SetScript("OnDragStart", nil)
	button:SetScript("OnDragStop", nil)

	if not button.__MBGHooked then
		button:HookScript("OnEnter", ButtonOnEnter)
		button:HookScript("OnLeave", ButtonOnLeave)
		button.__MBGHooked = true
	end

	button.__hidden = button:IsVisible() and true or false
	button.isSkinned = true
	tinsert(self.skinnedButtons, button)

	self.needUpdate = true
end

function MBG:UpdateLayout()
	if not self.frame or #self.skinnedButtons == 0 then return end

	local db = self.db
	local spacing = (db.backdrop and (E.Border + db.backdropSpacing) or E.Spacing)

	local visibleButtons = self:GetVisibleList()

	if #visibleButtons == 0 then
		self.frame:Size(db.buttonSize + (spacing * 2))
		if self.frame.backdrop then
			self.frame.backdrop:Hide()
		end
		return
	end

	local numButtons = #visibleButtons
	local buttonsPerRow = db.buttonsPerRow
	local numColumns = ceil(numButtons / buttonsPerRow)

	if buttonsPerRow > numButtons then
		buttonsPerRow = numButtons
	end

	local barWidth = (db.buttonSize * buttonsPerRow) + (db.buttonSpacing * (buttonsPerRow - 1)) + spacing * 2
	local barHeight = (db.buttonSize * numColumns) + (db.buttonSpacing * (numColumns - 1)) + spacing * 2

	self.frame:Size(barWidth, barHeight)
	if self.frame.mover then
		self.frame.mover:Size(barWidth, barHeight)
	end

	if db.backdrop and self.frame.backdrop then
		self.frame.backdrop:Show()
	elseif self.frame.backdrop then
		self.frame.backdrop:Hide()
	end

	local verticalGrowth = (db.growFrom == "TOPLEFT" or db.growFrom == "TOPRIGHT") and "DOWN" or "UP"
	local horizontalGrowth = (db.growFrom == "TOPLEFT" or db.growFrom == "BOTTOMLEFT") and "RIGHT" or "LEFT"

	for i, button in ipairs(visibleButtons) do
		self:UnlockButton(button)

		button:Size(db.buttonSize)
		button:ClearAllPoints()

		if i == 1 then
			local x, y
			if db.growFrom == "TOPLEFT" then
				x, y = spacing, -spacing
			elseif db.growFrom == "TOPRIGHT" then
				x, y = -spacing, -spacing
			elseif db.growFrom == "BOTTOMLEFT" then
				x, y = spacing, spacing
			else
				x, y = -spacing, spacing
			end

			button:Point(db.growFrom, self.frame, db.growFrom, x, y)
		elseif (i - 1) % buttonsPerRow == 0 then
			if verticalGrowth == "DOWN" then
				button:Point("TOP", visibleButtons[i - buttonsPerRow], "BOTTOM", 0, -db.buttonSpacing)
			else
				button:Point("BOTTOM", visibleButtons[i - buttonsPerRow], "TOP", 0, db.buttonSpacing)
			end
		elseif horizontalGrowth == "RIGHT" then
			button:Point("LEFT", visibleButtons[i - 1], "RIGHT", db.buttonSpacing, 0)
		elseif horizontalGrowth == "LEFT" then
			button:Point("RIGHT", visibleButtons[i - 1], "LEFT", -db.buttonSpacing, 0)
		end

		self:LockButton(button)
	end

	self.needUpdate = false
end

function MBG:UpdatePosition()
	if not self.frame then return end

	local inside = self.db.insideMinimap

	if inside.enable then
		self.frame:ClearAllPoints()
		self.frame:Point(inside.position, Minimap, inside.position, inside.xOffset, inside.yOffset)

		if self.frame.mover then
			E:DisableMover(self.frame.mover:GetName())
		end
	else
		if self.frame.mover then
			self.frame:ClearAllPoints()
			self.frame:SetAllPoints(self.frame.mover)
			E:EnableMover(self.frame.mover:GetName())
		end
	end
end

function MBG:UpdateAlpha()
	if not self.frame then return end

	self.maxAlpha = self.db.alpha

	if not self.db.mouseover then
		self.frame:SetAlpha(self.maxAlpha)
	end
end

function MBG:ToggleMouseover()
	if not self.frame then return end

	local mouseover = self.db.mouseover
	self.frame:SetAlpha(mouseover and 0 or self.db.alpha)
end

function MBG:CreateHolder()
	if self.frame then return end

	self.frame = CreateFrame("Frame", "ElvUI_MinimapButtonGrabber", UIParent)
	self.frame:SetFrameStrata("LOW")
	self.frame:SetClampedToScreen(true)
	self.frame:CreateBackdrop()
	local defaultAnchor = _G.MMHolder or Minimap or UIParent
	self.frame:Point("TOPRIGHT", defaultAnchor, "BOTTOMRIGHT", 0, 1)

	self.frame.backdrop:SetPoint("TOPLEFT", self.frame, "TOPLEFT", E.Spacing, -E.Spacing)
	self.frame.backdrop:SetPoint("BOTTOMRIGHT", self.frame, "BOTTOMRIGHT", -E.Spacing, E.Spacing)
	self.frame.backdrop:Hide()

	E:CreateMover(self.frame, "MinimapButtonGrabberMover", L["Minimap Button Grabber"], nil, nil, nil, "ALL,GENERAL")
	self.frame:SetScript("OnEnter", FrameOnEnter)
	self.frame:SetScript("OnLeave", FrameOnLeave)

	if self.frame.mover and self.frame.mover:GetScript("OnSizeChanged") then
		self.frame.mover:SetScript("OnSizeChanged", nil)
	end
end

function MBG:StartGrabTimer()
	if self.timer then
		self:CancelTimer(self.timer)
	end

	self.timer = self:ScheduleRepeatingTimer("GrabMinimapButtons", 5)
end

function MBG:StopGrabTimer()
	if self.timer then
		self:CancelTimer(self.timer)
		self.timer = nil
	end
end

local function EnsureButtonGrabberDB()
	WE.db.buttonGrabber = WE.db.buttonGrabber or {}
	local db = WE.db.buttonGrabber

	if db.enable == nil then db.enable = false end
	if db.backdrop == nil then db.backdrop = false end
	if db.backdropSpacing == nil then db.backdropSpacing = 1 end
	if db.mouseover == nil then db.mouseover = false end
	if db.alpha == nil then db.alpha = 1 end
	if db.buttonSize == nil then db.buttonSize = 22 end
	if db.buttonSpacing == nil then db.buttonSpacing = 0 end
	if db.buttonsPerRow == nil then db.buttonsPerRow = 1 end
	if not db.growFrom then db.growFrom = "TOPLEFT" end

	db.insideMinimap = db.insideMinimap or {}
	local inside = db.insideMinimap
	if inside.enable == nil then inside.enable = true end
	if not inside.position then inside.position = "TOPLEFT" end
	if inside.xOffset == nil then inside.xOffset = -1 end
	if inside.yOffset == nil then inside.yOffset = 1 end

	return db
end

function MBG:EnableModule()
	self.db = EnsureButtonGrabberDB()

	if not self.db then
		return
	end

	self:CreateHolder()

	local spacing = (self.db.backdrop and (E.Border + self.db.backdropSpacing) or E.Spacing)
	self.frame:Size(self.db.buttonSize + (spacing * 2))
	local holder = _G.MMHolder or Minimap
	self.frame:Point("TOPRIGHT", holder, "BOTTOMRIGHT", 0, 1)
	self.frame:Show()

	self:ToggleMouseover()
	self:UpdateAlpha()
	self:UpdatePosition()

	self:GrabMinimapButtons()
	self:StartGrabTimer()

	self.enabled = true
end

function MBG:DisableModule()
	self:StopGrabTimer()

	if self.frame then
		self.frame:Hide()
	end

	self.enabled = false
end

-- Release all grabbed buttons back to their original parents (for MBF integration)
function MBG:ReleaseButtonsToMBF()
	if not self.skinnedButtons then return end
	
	for _, button in ipairs(self.skinnedButtons) do
		if button and button.__MBGOriginalParent then
			self:UnlockButton(button)
			button:SetParent(button.__MBGOriginalParent)
			button.isSkinned = nil
			button.__MBGHooked = nil
		end
	end
	
	self.skinnedButtons = {}
	self:StopGrabTimer()
	
	if self.frame then
		self.frame:Hide()
	end
	
	self.enabled = false
end

function MBG:HandleEnableState()
	if not self.initialized then return end

	-- Check if MBF addon is loaded
	local mbfLoaded = IsAddOnLoaded("MinimapButtonFrame")
	
	-- If MBF is loaded AND mbfControlEnabled is true, let MBF control buttons
	if mbfLoaded and E.db.general and E.db.general.minimap and E.db.general.minimap.mbfControlEnabled then
		self:ReleaseButtonsToMBF()
		return
	end
	
	-- Otherwise, ElvUI controls buttons (MBF not loaded OR flag is false)
	if WE.db.buttonGrabber.enable then
		if not self.enabled then
			self:EnableModule()
		else
			self.db = WE.db.buttonGrabber
			self:ToggleMouseover()
			self:UpdateAlpha()
			self:UpdatePosition()
			self:UpdateLayout()
			self:GrabMinimapButtons()
			self:StartGrabTimer()
		end
	else
		self:DisableModule()
	end
end

function MBG:ForUpdateAll()
	self:HandleEnableState()
end

function MBG:Initialize()
	self.skinnedButtons = self.skinnedButtons or {}
	self.minimapFrames = {Minimap, MinimapBackdrop, MinimapCluster}
	self.needUpdate = false
	self.maxAlpha = 1
	self.db = EnsureButtonGrabberDB()

	self.initialized = true

	self:HandleEnableState()
end

WE:RegisterModule("MinimapButtonGrabber", MBG)
E:RegisterModule(MBG:GetName())

