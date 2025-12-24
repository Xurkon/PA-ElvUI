-- PortalBox Module for WarcraftEnhanced
-- Teleport and portal spell manager

local QH = QH or WarcraftEnhanced
local PB = {}
QH.PortalBox = PB
local HookSettingsSave

local function GetPortalBoxDB()
	if not QH or not QH.db then return end

	QH.db.portalBox = QH.db.portalBox or {}
	local db = QH.db.portalBox

	if db.hideMinimapButton == nil then db.hideMinimapButton = false end
	if db.keepWindowOpen == nil then db.keepWindowOpen = false end
	if db.detachMinimapButton == nil then db.detachMinimapButton = false end
	if db.minimapAngle == nil then db.minimapAngle = 1 end
	if db.unboundX == nil then db.unboundX = 0 end
	if db.unboundY == nil then db.unboundY = 0 end
	if db.windowCollapsed == nil then db.windowCollapsed = false end

	return db
end

local function LoadSettingsFromDB()
	local db = GetPortalBoxDB()
	if not db then return end

	HideMMIcon = db.hideMinimapButton and "1" or "0"
	KeepWindowOpen = db.keepWindowOpen and "1" or "0"
	MinimapButtonUnbind = db.detachMinimapButton and "1" or "0"
	MinimapPos = db.minimapAngle or 1
	MinimapPosUnboundX = db.unboundX or 0
	MinimapPosUnboundY = db.unboundY or 0
	windowCollapseState = db.windowCollapsed and "1" or "0"
end

-- Initialize global variables (for compatibility with XML)
HideMMIcon = HideMMIcon or "0"
KeepWindowOpen = KeepWindowOpen or "0"
MinimapButtonUnbind = MinimapButtonUnbind or "0"
MinimapPos = MinimapPos or 1
MinimapPosUnboundX = MinimapPosUnboundX or 0
MinimapPosUnboundY = MinimapPosUnboundY or 0
windowCollapseState = windowCollapseState or "0"

-- Module initialization
function PB:Initialize()
	LoadSettingsFromDB()
	
	-- Register slash commands
	SLASH_PORTALBOX1 = "/portalbox"
	SLASH_PORTALBOX2 = "/port"
	SlashCmdList["PORTALBOX"] = portalbox_SlashCommandHandler
	
	HookSettingsSave()

	-- Silent load
end

-- Save settings to DB
function PB:SaveSettings()
	local db = GetPortalBoxDB()
	if not db then return end

	db.hideMinimapButton = HideMMIcon == "1"
	db.keepWindowOpen = KeepWindowOpen == "1"
	db.detachMinimapButton = MinimapButtonUnbind == "1"
	db.minimapAngle = MinimapPos
	db.unboundX = MinimapPosUnboundX
	db.unboundY = MinimapPosUnboundY
	db.windowCollapsed = windowCollapseState == "1"
end

function PortalBox_MinimapButton_Reposition()
	
	PortalBox_MinimapButton:SetPoint("TOPLEFT","Minimap","TOPLEFT",52-(80*cos(MinimapPos)),(80*sin(MinimapPos))-52)
	
	if (MinimapButtonUnbind == "0") then
		PortalBox_MinimapButtonUnbound:Hide();
	end
end

function PortalBox_MinimapButtonUnbound_Reposition()
	local xpos,ypos = PortalBox_MinimapButton:GetLeft(), PortalBox_MinimapButton:GetBottom()

	PortalBox_MinimapButtonUnbound:ClearAllPoints();
	PortalBox_MinimapButtonUnbound:SetPoint("BOTTOMLEFT","UIParent","BOTTOMLEFT", MinimapPosUnboundX, MinimapPosUnboundY)
	if (MinimapButtonUnbind == "1") then
		PortalBox_MinimapButton:Hide();
	end
	if (MinimapPosUnboundY == NIL) then
		PortalBox_MinimapButtonUnbound:SetPoint("BOTTOMLEFT","UIParent","BOTTOMLEFT", xpos-16, ypos-16)
		MinimapPosUnboundY = ypos-16
		MinimapPosUnboundX = xpos-16
	end
	
end

function PortalBox_LoadPrefsPane(panel)
	panel.name = "PortalBox";
	InterfaceOptions_AddCategory(panel);
end

function portalbox_OnLoad()
	this:RegisterEvent("VARIABLES_LOADED");
	this:RegisterEvent("UNIT_SPELLCAST_START");
	out("• PortalBox 0.7 Loaded •");
	SLASH_PORTALBOX1 = "/portalbox";
	SLASH_PORTALBOX2 = "/port";
	SlashCmdList["PORTALBOX"] = function(msg)
					portalbox_SlashCommandHandler(msg);					
	end
	
end

function portalbox_OnEvent()
	if ( event == "VARIABLES_LOADED" ) then
		if (MinimapPos == NIL) then
			MinimapPos = 1
		end
    	PortalBox_MinimapButton_Reposition();
		PortalBox_MinimapButtonUnbound_Reposition();
		if (HideMMIcon == "1") then
			PortalBox_MinimapButton:Hide();
		end
	end
	if (event == "UNIT_SPELLCAST_START" and arg1 == "player") then
		-- Use a timer to avoid secure frame taint
		if (KeepWindowOpen == "0") then
			PortalBox_HideTimer = 0.1
		end
	end
	
end

function PortalBox_OnUpdate(elapsed)
	if PortalBox_HideTimer then
		PortalBox_HideTimer = PortalBox_HideTimer - elapsed
		if PortalBox_HideTimer <= 0 then
			PortalBox_HideTimer = nil
			if PortalboxMainFrame:IsShown() then
				PortalboxMainFrame:Hide()
			end
			if PortalboxHordeFrame:IsShown() then
				PortalboxHordeFrame:Hide()
			end
		end
	end
end

function PortalBox_MinimapButton_DraggingFrame_OnUpdate()

	local xpos,ypos = GetCursorPosition()
	local xmin,ymin = Minimap:GetLeft(), Minimap:GetBottom()

	xpos = xmin-xpos/UIParent:GetScale()+70 -- get coordinates as differences from the center of the minimap
	ypos = ypos/UIParent:GetScale()-ymin-70

	MinimapPos = math.deg(math.atan2(ypos,xpos)) -- save the degrees we are relative to the minimap center
	PortalBox_MinimapButton_Reposition() -- move the button
end

function PortalBox_MinimapButtonUnbound_DraggingFrame_OnUpdate()

	local xpos,ypos = GetCursorPosition()

	xpos = xpos/UIParent:GetScale()
	ypos = ypos/UIParent:GetScale()

	MinimapPosUnboundY = ypos
	MinimapPosUnboundX = xpos
	PortalBox_MinimapButtonUnbound_Reposition() -- move the button
end

function PortalBox_MinimapButton_OnClick(arg1)
	if (arg1 == "LeftButton") then
		portalbox_toggle(msg);
	else
		-- Open WarcraftEnhanced options to PortalBox tab
		local AceConfigDialog = LibStub("AceConfigDialog-3.0", true)
		if AceConfigDialog then
			AceConfigDialog:Open("WarcraftEnhanced")
			AceConfigDialog:SelectGroup("WarcraftEnhanced", "portalbox")
		elseif QH and QH.OpenOptions then
			QH.OpenOptions()
		end
	end
end

function out(text)
	DEFAULT_CHAT_FRAME:AddMessage(text)
end

function portalbox_SlashCommandHandler(msg)
	if msg == "" then
		portalbox_toggle();
	elseif msg == "config" then
		-- Open WarcraftEnhanced options to PortalBox tab
		local AceConfigDialog = LibStub("AceConfigDialog-3.0", true)
		if AceConfigDialog then
			AceConfigDialog:Open("WarcraftEnhanced")
			AceConfigDialog:SelectGroup("WarcraftEnhanced", "portalbox")
		elseif QH and QH.OpenOptions then
			QH.OpenOptions()
		end
	end
end

function portalBox_toggleCollapseState()
	if (windowCollapseState ~= "1") then
		PortalboxMainFrame:SetScale(0.7);
		PortalboxHordeFrame:SetScale(0.7);
		collapseButton:SetNormalTexture("Interface/Buttons/UI-PlusButton-Up");
		collapseButton:SetPushedTexture("Interface/Buttons/UI-PlusButton-Down");
		collapseButtonHorde:SetNormalTexture("Interface/Buttons/UI-PlusButton-Up");
		collapseButtonHorde:SetPushedTexture("Interface/Buttons/UI-PlusButton-Down");
		windowCollapseState = "1";
	else
		PortalboxMainFrame:SetScale(1.0);
		PortalboxHordeFrame:SetScale(1.0);
		collapseButton:SetNormalTexture("Interface/Buttons/UI-MinusButton-Up");
		collapseButton:SetPushedTexture("Interface/Buttons/UI-MinusButton-Down");
		collapseButtonHorde:SetNormalTexture("Interface/Buttons/UI-MinusButton-Up");
		collapseButtonHorde:SetPushedTexture("Interface/Buttons/UI-MinusButton-Down");
		windowCollapseState = "0";
	end

	if PB and PB.SaveSettings then
		PB:SaveSettings()
	end
end

function portalbox_toggle(num)
	faction = UnitFactionGroup("player")
	local frame = getglobal("PortalboxMainFrame")
	local hordeFrame = getglobal("PortalboxHordeFrame")
	
	
	if (faction == "Horde") then
		if (hordeFrame) then
			if (hordeFrame:IsVisible()) then
				hordeFrame:Hide();
			else
				hordeFrame:Show();
				end
			end
		else
	if (frame) then
		if (frame:IsVisible()) then
			frame:Hide();
		else
			frame:Show();
			end
		end
	end
end

-- Hook to save settings when they change
HookSettingsSave = function()
	local originalReposition = PortalBox_MinimapButton_Reposition
	PortalBox_MinimapButton_Reposition = function()
		originalReposition()
		if PB and PB.SaveSettings then
			PB:SaveSettings()
		end
	end

	local originalUnbound = PortalBox_MinimapButtonUnbound_Reposition
	PortalBox_MinimapButtonUnbound_Reposition = function()
		originalUnbound()
		if PB and PB.SaveSettings then
			PB:SaveSettings()
		end
	end
end

-- Register module with WarcraftEnhanced
if QH then
	QH:RegisterModule("PortalBox", PB)
end
