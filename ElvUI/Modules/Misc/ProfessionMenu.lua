local E, L, V, P, G = unpack(ElvUI)
local PM = E:NewModule("ProfessionMenu")

local ipairs, pairs = ipairs, pairs
local format = string.format
local tinsert = table.insert

-- Profession spell IDs list
PM.profList = {
	{51304, 28596, 11611, 3464, 3101, 2259}, -- ALCHEMY
	{51300, 29844, 9785, 3538, 3100, 2018}, -- BLACKSMITHING
	{51313, 28029, 13920, 7413, 7412, 7411}, -- ENCHANTING
	{51306, 30350, 12656, 4038, 4037, 4036}, -- ENGINEERING
	{45363, 45361, 45360, 45359, 45358, 45357}, -- INSCRIPTION
	{51311, 28897, 28895, 28894, 25230, 25229}, -- JEWELCRAFTING
	{51302, 32549, 10662, 3811, 3104, 2108}, -- LEATHERWORKING
	{2656, main = 50310}, -- SMELTING
	{2383, Name = "Herbalism"}, -- HERBALISM
	{51309, 26790, 12180, 3910, 3909, 3908}, -- TAILORING
	{51296, 33359, 18260, 3413, 3102, 2550}, -- COOKING
	{45542, 27028, 10846, 7924, 3274, 3273}, -- FIRST AID
	{13977860, CraftingSpell = true}, -- WOODCUTTING
}

-- Special profession utilities
PM.profUtils = {
	{13262, Name = "Disenchant"}, -- Disenchant
	{31252, Name = "Prospecting"}, -- Prospecting
	{818, Name = "Milling"}, -- Milling
	{1804, Name = "Lockpicking"}, -- Lockpicking
	{1501804, Name = "Lockpicking (Ascension)"}, -- Lockpicking Ascension
}

function PM:Initialize()
	self.db = E.db.professionMenu
	
	-- Create the main button
	self:CreateMainButton()
	
	-- Update visibility
	self:UpdateVisibility()
end

function PM:CreateMainButton()
	-- Main button frame
	self.button = CreateFrame("Button", "ElvUI_ProfessionMenuButton", E.UIParent)
	self.button:SetSize(40, 40)
	self.button:SetPoint("CENTER", E.UIParent, "CENTER", 0, 200)
	self.button:SetFrameStrata("MEDIUM")
	self.button:SetTemplate("Default", true)
	self.button:StyleButton()
	
	-- Icon
	self.button.icon = self.button:CreateTexture(nil, "ARTWORK")
	self.button.icon:SetInside()
	self.button.icon:SetTexture("Interface\\Icons\\achievement_guildperk_bountifulbags")
	self.button.icon:SetTexCoord(unpack(E.TexCoords))
	
	-- Hover glow
	self.button:SetScript("OnEnter", function(btn)
		if E.db.general.enhancedTooltip then
			GameTooltip:SetOwner(btn, "ANCHOR_TOP")
			GameTooltip:AddLine(L["Profession Menu"], 1, 1, 1)
			GameTooltip:AddLine(L["Left Click: Toggle Menu"], 0.7, 0.7, 1)
			GameTooltip:AddLine(L["Right Click: Move"], 0.7, 0.7, 1)
			GameTooltip:Show()
		end
		btn:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
	end)
	
	self.button:SetScript("OnLeave", function(btn)
		GameTooltip:Hide()
		btn:SetBackdropBorderColor(unpack(E.media.bordercolor))
	end)
	
	-- Click handlers (use pre-click to avoid taint)
	self.button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	self.button:SetScript("PreClick", function(btn, mouseButton)
		if mouseButton == "RightButton" then
			E:ToggleMoveMode()
		end
	end)
	
	self.button:SetScript("OnClick", function(btn, mouseButton)
		if mouseButton == "LeftButton" then
			PM:ToggleMenu()
		end
	end)
	
	-- Make movable
	E:CreateMover(self.button, "ProfessionMenuButtonMover", L["Profession Menu Button"], nil, nil, nil, "ALL,GENERAL")
	
	-- Create the dropdown menu frame
	self:CreateMenuFrame()
end

function PM:CreateMenuFrame()
	-- Main menu frame (non-secure since we don't mix secure and insecure calls)
	local menu = CreateFrame("Frame", "ElvUI_ProfessionMenuDropdown", E.UIParent)
	menu:SetSize(200, 400)
	menu:SetFrameStrata("TOOLTIP")
	menu:SetTemplate("Transparent")
	menu:SetClampedToScreen(true)
	menu:SetFrameLevel(100)
	menu:Hide()
	self.menuFrame = menu
	
	-- Scroll frame
	local scrollFrame = CreateFrame("ScrollFrame", nil, menu, "UIPanelScrollFrameTemplate")
	scrollFrame:SetPoint("TOPLEFT", menu, "TOPLEFT", 4, -4)
	scrollFrame:SetPoint("BOTTOMRIGHT", menu, "BOTTOMRIGHT", -24, 4)
	menu.scrollFrame = scrollFrame
	
	-- Content frame
	local content = CreateFrame("Frame", nil, scrollFrame)
	content:SetSize(170, 1)
	scrollFrame:SetScrollChild(content)
	menu.content = content
	
	-- Buttons container
	menu.buttons = {}
	
	-- Track open state
	menu:SetScript("OnShow", function(self)
		self.isOpen = true
	end)
	
	menu:SetScript("OnHide", function(self)
		self.isOpen = false
	end)
	
	-- Prevent closing when clicking inside the menu
	menu:SetScript("OnMouseDown", function(self)
		-- Consume clicks to prevent them from propagating
	end)
end

function PM:ToggleMenu()
	if self.menuFrame:IsShown() then
		self.menuFrame:Hide()
	else
		self:PopulateMenu()
		self:PositionMenu()
		self.menuFrame:Show()
	end
end

function PM:PositionMenu()
	local button = self.button
	local menu = self.menuFrame
	
	menu:ClearAllPoints()
	
	-- Position based on button location
	local x, y = button:GetCenter()
	if not x or not y then
		menu:SetPoint("CENTER", E.UIParent)
		return
	end
	
	-- Position to the right or left based on screen position
	if x > E.UIParent:GetWidth() / 2 then
		menu:SetPoint("TOPRIGHT", button, "TOPLEFT", -2, 0)
	else
		menu:SetPoint("TOPLEFT", button, "TOPRIGHT", 2, 0)
	end
end

function PM:PopulateMenu()
	local content = self.menuFrame.content
	local buttons = self.menuFrame.buttons
	
	-- Clear existing buttons
	for _, btn in ipairs(buttons) do
		btn:Hide()
		btn:ClearAllPoints()
	end
	wipe(buttons)
	
	local yOffset = -4
	local buttonHeight = 32
	
	-- Add title
	local title = self:CreateMenuButton(content, "|cffffff00Professions|r", nil, nil, true)
	title:SetPoint("TOPLEFT", content, "TOPLEFT", 4, yOffset)
	tinsert(buttons, title)
	yOffset = yOffset - buttonHeight
	
	-- Helper function to get profession ranks
	local function getProfessionRanks(compName)
		for skillIndex = 1, GetNumSkillLines() do
			local name, _, _, rank, _, _, maxRank = GetSkillLineInfo(skillIndex)
			if name and compName:match(name) then
				return rank, maxRank
			end
		end
		return 0, 0
	end
	
	-- Add professions
	for _, prof in ipairs(self.profList) do
		for _, spellID in ipairs(prof) do
			if CA_IsSpellKnown(spellID) then
				local name, _, icon = GetSpellInfo(spellID)
				if prof.Name then
					name = prof.Name
				end
				
				local profName = name
				if prof.main then
					profName = GetSpellInfo(prof.main)
				end
				
				-- Get ranks
				local rank, maxRank = getProfessionRanks(profName)
				local displayName = format("%s |cFF00FFFF(%d/%d)|r", profName, rank, maxRank)
				
				-- Create button
				local btn = self:CreateMenuButton(content, displayName, icon, function()
					if prof.CraftingSpell then
						CastSpellByID(spellID)
					else
						CastSpellByName(name)
					end
					self.menuFrame:Hide()
				end)
				
				btn:SetPoint("TOPLEFT", content, "TOPLEFT", 4, yOffset)
				tinsert(buttons, btn)
				yOffset = yOffset - buttonHeight
				break
			end
		end
	end
	
	-- Add utilities
	local hasUtils = false
	for _, util in ipairs(self.profUtils) do
		if CA_IsSpellKnown(util[1]) then
			if not hasUtils then
				-- Add divider
				local divider = self:CreateMenuButton(content, "----------", nil, nil, true)
				divider:SetPoint("TOPLEFT", content, "TOPLEFT", 4, yOffset)
				tinsert(buttons, divider)
				yOffset = yOffset - buttonHeight
				hasUtils = true
			end
			
			local name, _, icon = GetSpellInfo(util[1])
			if util.Name then name = util.Name end
			
			local btn = self:CreateMenuButton(content, name, icon, function()
				local utilSpellName = GetSpellInfo(util[1])
				if utilSpellName then
					CastSpellByName(utilSpellName)
				end
				self.menuFrame:Hide()
			end)
			
			btn:SetPoint("TOPLEFT", content, "TOPLEFT", 4, yOffset)
			tinsert(buttons, btn)
			yOffset = yOffset - buttonHeight
		end
	end
	
	-- Add close button
	yOffset = yOffset - 4
	local closeBtn = self:CreateMenuButton(content, "|cff00ffffClose Menu|r", nil, function()
		self.menuFrame:Hide()
	end)
	closeBtn:SetPoint("TOPLEFT", content, "TOPLEFT", 4, yOffset)
	tinsert(buttons, closeBtn)
	yOffset = yOffset - buttonHeight
	
	-- Set content height
	content:SetHeight(math.abs(yOffset) + 8)
end

function PM:CreateMenuButton(parent, text, icon, onClick, isTitle)
	local btn = CreateFrame("Button", nil, parent)
	btn:SetSize(162, 28)
	
	if not isTitle then
		btn:SetTemplate("Default")
		btn:StyleButton()
		btn:RegisterForClicks("LeftButtonUp")
		
		btn:SetScript("OnEnter", function(self)
			self:SetBackdropBorderColor(unpack(E.media.rgbvaluecolor))
		end)
		
		btn:SetScript("OnLeave", function(self)
			self:SetBackdropBorderColor(unpack(E.media.bordercolor))
		end)
		
		if onClick then
			-- Use a protected call to prevent taint
			btn:SetScript("OnClick", function(self)
				local success, err = pcall(onClick)
				if not success then
					print("|cffff0000ElvUI ProfessionMenu Error:|r", err)
				end
			end)
		end
	end
	
	-- Icon
	if icon then
		btn.icon = btn:CreateTexture(nil, "ARTWORK")
		btn.icon:SetSize(24, 24)
		btn.icon:SetPoint("LEFT", btn, "LEFT", 4, 0)
		btn.icon:SetTexture(icon)
		btn.icon:SetTexCoord(unpack(E.TexCoords))
	end
	
	-- Text
	btn.text = btn:CreateFontString(nil, "OVERLAY")
	btn.text:FontTemplate()
	btn.text:SetText(text)
	
	if icon then
		btn.text:SetPoint("LEFT", btn, "LEFT", 32, 0)
		btn.text:SetPoint("RIGHT", btn, "RIGHT", -4, 0)
	else
		btn.text:SetPoint("LEFT", btn, "LEFT", 4, 0)
		btn.text:SetPoint("RIGHT", btn, "RIGHT", -4, 0)
	end
	
	btn.text:SetJustifyH("LEFT")
	btn.text:SetWordWrap(false)
	
	return btn
end

function PM:UpdateVisibility()
	if self.db.enable then
		self.button:Show()
	else
		self.button:Hide()
		self.menuFrame:Hide()
	end
end

E:RegisterModule(PM:GetName())

