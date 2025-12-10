-- ElvUI AuraTracker Module
-- Displays buff/debuff duration remaining on action bar buttons
-- Shows time left for your buffs/DoTs on the current target

local E, L, V, P, G = unpack(select(2, ...))
local AB = E:GetModule('ActionBars')
local LSM = E.Libs.LSM

local _G = _G
local pairs, ipairs = pairs, ipairs
local select, type = select, type
local UnitExists, UnitIsUnit = UnitExists, UnitIsUnit
local UnitAura, GetSpellInfo = UnitAura, GetSpellInfo
local GetActionInfo, GetActionText = GetActionInfo, GetActionText
local GetPetActionInfo = GetPetActionInfo
local format, floor = string.format, math.floor

-- Module
local AT = E:NewModule('AuraTracker', 'AceEvent-3.0', 'AceTimer-3.0')
AT.Buttons = {} -- Store references to all action buttons
AT.Initialized = false
AT.enabled = false

-- Helper function to get spell name from action slot
local function GetActionSpellName(actionSlot)
	if not actionSlot then return nil end
	local actionType, id = GetActionInfo(actionSlot)
	if actionType == "spell" and id then
		local spellName = GetSpellInfo(id)
		-- Strip rank information (e.g., "Moonfire(Rank 10)" -> "Moonfire")
		if spellName then
			spellName = spellName:match("^(.-)%(") or spellName
		end
		return spellName
	end
	return nil
end

-- Helper function to get pet action spell name
local function GetPetActionSpellName(petSlot)
	if not petSlot then return nil end
	local name, _, _, isToken = GetPetActionInfo(petSlot)
	if not isToken then
		return name
	end
	return nil
end

-- Helper function to get spell name from button (handles LibActionButton)
-- Made as AT method so debug commands can use it
function AT:GetButtonSpellName(button)
	if not button then return nil end
	
	-- Try to get action slot from button
	local actionSlot = nil
	
	-- Try GetAttribute first (most reliable for ElvUI buttons)
	if button.GetAttribute then
		local attr = button:GetAttribute("action")
		if attr and attr > 0 then
			actionSlot = attr
		end
	end
	
	-- Try LibActionButton GetActionID method
	if not actionSlot and button.GetActionID then
		local id = button:GetActionID()
		if id and id > 0 then
			actionSlot = id
		end
	end
	
	-- Try action property (but validate it's > 0)
	if not actionSlot and button.action and button.action > 0 then
		actionSlot = button.action
	end
	
	-- On Ascension, GetActionInfo is unreliable, so try TOOLTIP FIRST
	local spellName = nil
	
	if actionSlot and actionSlot > 0 and GameTooltip then
		-- Save tooltip state to avoid disrupting player tooltips
		local tooltipOwner = GameTooltip:GetOwner()
		local wasShown = GameTooltip:IsShown()
		
		GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
		GameTooltip:SetAction(actionSlot)
		local tooltipText = GameTooltipTextLeft1 and GameTooltipTextLeft1:GetText()
		
		-- Restore tooltip state
		if not wasShown then
			GameTooltip:Hide()
		elseif tooltipOwner then
			GameTooltip:SetOwner(tooltipOwner, "ANCHOR_CURSOR")
		end
		
		if tooltipText and tooltipText ~= "" then
			-- Strip rank from tooltip text
			local baseName = tooltipText:match("^(.-)%(") or tooltipText
			spellName = baseName
		end
	end
	
	-- If tooltip didn't work, try GetActionInfo
	if not spellName and actionSlot and actionSlot > 0 then
		spellName = GetActionSpellName(actionSlot)
	end
	
	-- Try GetID for pet/stance bars
	if not spellName then
		local buttonID = button:GetID()
		if buttonID then
			local parent = button:GetParent()
			if parent then
				local parentName = parent:GetName() or ""
				if parentName:match("PetBar") then
					spellName = GetPetActionSpellName(buttonID)
				end
			end
		end
	end
	
	-- Try GetSpell method if it exists
	if not spellName and button.GetSpell then
		local spell = button:GetSpell()
		if spell then
			spellName = spell
		end
	end
	
	-- Return whatever we found (might still be nil if button is empty)
	if spellName then
		return spellName
	end
	
	-- Try using the button's icon texture to identify the spell
	local buttonName = button:GetName()
	if buttonName then
		local icon = _G[buttonName.."Icon"]
		if icon then
			local texture = icon:GetTexture()
			if texture then
				-- Texture path might give us a clue, but this is unreliable
				-- Skip for now, just note it's available
			end
		end
	end
	
	return nil
end

-- Format time remaining
local function FormatTime(seconds)
	if not seconds or seconds <= 0 then return "" end
	
	-- Handle permanent/passive auras - don't show anything
	if seconds >= 999999 then
		return ""  -- Don't show text for permanent auras
	end
	
	if seconds < 60 then
		return format("%d", floor(seconds)) -- Whole seconds only, no suffix
	elseif seconds < 3600 then
		return format("%dm", floor(seconds / 60)) -- Minutes
	else
		return format("%dh", floor(seconds / 3600)) -- Hours
	end
end

-- Update duration text on a button
function AT:UpdateButtonDuration(button)
	if not button or not button:IsVisible() then return end
	if not E.db.actionbar.auraTracker or not E.db.actionbar.auraTracker.enable then return end
	
	-- Check if action slot changed (spell was swapped)
	local currentAction = nil
	if button.GetAttribute then
		currentAction = button:GetAttribute("action")
	end
	
	if currentAction ~= button.auraTrackerLastAction then
		-- Action changed, re-cache spell name
		button.auraTrackerSpell = self:GetButtonSpellName(button)
		button.auraTrackerLastAction = currentAction
	end
	
	-- Use cached spell name (avoids tooltip checks every update)
	local spellName = button.auraTrackerSpell
	
	if not spellName then
		if button.auraText then
			button.auraText:SetText("")
		end
		return
	end
	
	-- Check target for this buff/debuff
	local timeLeft = nil
	local unit = "target"
	
	if UnitExists(unit) then
		-- Check buffs
		for i = 1, 40 do
			local name, _, _, _, _, duration, expirationTime, caster = UnitAura(unit, i, "HELPFUL")
			if not name then break end
			
			-- Strip rank from aura name for matching
			local auraName = name:match("^(.-)%(") or name
			
			if auraName == spellName then
				-- Filter by caster if enabled
				-- On Ascension, caster returns a number instead of unit string, so we can't use UnitIsUnit
				local isMine = false
				if caster == nil then
					-- No caster info, assume it's ours
					isMine = true
				elseif type(caster) == "number" then
					-- Ascension returns numeric caster - treat as ours if non-zero
					-- 0 = passive auras, >0 = player-cast auras
					isMine = (caster >= 0)
				else
					-- Standard WoW: caster is a unit string
					isMine = UnitIsUnit(caster, "player")
				end
				
				if not E.db.actionbar.auraTracker.onlyPlayer or isMine then
					-- Calculate time left
					if expirationTime then
						local currentTime = GetTime()
						timeLeft = expirationTime - currentTime
						
						-- Check if time is reasonable
						if timeLeft > 0 and timeLeft < 604800 then
							-- Valid countdown time!
							break
						elseif timeLeft < 0 then
							-- Negative time left means buff already expired or corrupted data
							-- Try using duration as fallback
							if duration and duration > 0 and duration < 604800 then
								timeLeft = duration
								break
							else
								-- Show "UP" for active buffs with bad data
								timeLeft = 999999
								break
							end
						else
							-- Time too large (> 1 week), probably corrupted
							timeLeft = 999999
							break
						end
					elseif duration and duration > 0 then
						-- No expirationTime, use duration
						timeLeft = duration
						break
					else
						-- No valid time data at all, show "UP"
						timeLeft = 999999
						break
					end
				end
			end
		end
		
		-- Check debuffs if no buff found
		if not timeLeft then
			for i = 1, 40 do
				local name, _, _, _, _, duration, expirationTime, caster = UnitAura(unit, i, "HARMFUL")
				if not name then break end
				
				-- Strip rank from aura name for matching
				local auraName = name:match("^(.-)%(") or name
				-- Remove any whitespace (trim manually since trim may not exist in WoW 3.3.5)
				auraName = auraName:match("^%s*(.-)%s*$") or auraName
				
				if auraName == spellName then
					-- Filter by caster if enabled
					-- On Ascension, caster returns a number instead of unit string, so we can't use UnitIsUnit
					local isMine = false
					if caster == nil then
						-- No caster info, assume it's ours
						isMine = true
					elseif type(caster) == "number" then
						-- Ascension returns numeric caster - treat as ours if non-zero
						-- 0 = passive auras, >0 = player-cast auras
						isMine = (caster >= 0)
					else
						-- Standard WoW: caster is a unit string
						isMine = UnitIsUnit(caster, "player")
					end
					
				if not E.db.actionbar.auraTracker.onlyPlayer or isMine then
					-- Calculate time left
					if expirationTime then
						local currentTime = GetTime()
						timeLeft = expirationTime - currentTime
						
						-- Check if time is reasonable
						if timeLeft > 0 and timeLeft < 604800 then
							-- Valid countdown time!
							break
						elseif timeLeft < 0 then
							-- Negative time left means debuff already expired or corrupted data
							-- Try using duration as fallback
							if duration and duration > 0 and duration < 604800 then
								timeLeft = duration
								break
							else
								-- Show "UP" for active debuffs with bad data
								timeLeft = 999999
								break
							end
						else
							-- Time too large (> 1 week), probably corrupted
							timeLeft = 999999
							break
						end
					elseif duration and duration > 0 then
						-- No expirationTime, use duration
						timeLeft = duration
						break
					else
						-- No valid time data at all, show "UP"
						timeLeft = 999999
						break
					end
				end
				end
			end
		end
	end
	
	-- Update font settings (auraText should already exist from RegisterButton)
	if button.auraText then
		local font = LSM:Fetch("font", E.db.actionbar.auraTracker.font)
		local fontSize = E.db.actionbar.auraTracker.fontSize
		local fontOutline = E.db.actionbar.auraTracker.fontOutline
		
		-- Apply white outline if invertOutline is enabled
		if E.db.actionbar.auraTracker.invertOutline and fontOutline ~= "NONE" then
			if fontOutline == "OUTLINE" then
				fontOutline = "OUTLINE, MONOCHROME"
			elseif fontOutline == "THICKOUTLINE" then
				fontOutline = "THICKOUTLINE, MONOCHROME"
			end
		end
		
		button.auraText:FontTemplate(font, fontSize, fontOutline)
		button.auraText:Show() -- Ensure it's visible
	end
	
	-- Update text (only if auraText exists)
	if button.auraText then
		-- Don't clear text if in test mode
		if button.auraText.__testMode then
			return
		end
		
		if timeLeft and timeLeft > 0 then
			button.auraText:SetText(FormatTime(timeLeft))
			
			-- Color based on time remaining
			if E.db.actionbar.auraTracker.colorByTime then
				local urgentThreshold = E.db.actionbar.auraTracker.urgentThreshold or 5
				local warningThreshold = E.db.actionbar.auraTracker.warningThreshold or 10
				
				if timeLeft < urgentThreshold then
					-- Urgent color (default: red)
					local c = E.db.actionbar.auraTracker.colorUrgent
					button.auraText:SetTextColor(c.r, c.g, c.b)
				elseif timeLeft < warningThreshold then
					-- Warning color (default: yellow)
					local c = E.db.actionbar.auraTracker.colorWarning
					button.auraText:SetTextColor(c.r, c.g, c.b)
				else
					-- Default color (default: white)
					local c = E.db.actionbar.auraTracker.colorDefault
					button.auraText:SetTextColor(c.r, c.g, c.b)
				end
			else
				-- No color coding, use white
				button.auraText:SetTextColor(1, 1, 1)
			end
		else
			button.auraText:SetText("")
		end
	end
end

-- Update all registered buttons
function AT:UpdateAllButtons()
	for _, button in pairs(self.Buttons) do
		self:UpdateButtonDuration(button)
	end
end

-- Register a button for aura tracking
function AT:RegisterButton(button)
	if not button then return end
	self.Buttons[button] = button
	
	-- Create auraText element immediately when registering
	if not button.auraText then
		-- Create a frame parented to UIParent to hold the text
		-- This fixes rendering issues where button-parented text doesn't show
		local textFrame = CreateFrame("Frame", nil, UIParent)
		textFrame:SetFrameStrata("TOOLTIP")
		textFrame:SetFrameLevel(100)
		textFrame:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
		textFrame:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
		
		button.auraText = textFrame:CreateFontString(nil, "OVERLAY")
		button.auraText:SetPoint("BOTTOM", textFrame, "BOTTOM", 0, 2)  -- Bottom of button with small offset
		button.auraText:SetSize(50, 20)  -- Give it enough width/height for "999h" text
		button.auraText:SetJustifyH("CENTER")
		button.auraText:SetJustifyV("BOTTOM")
		button.auraText:SetWordWrap(false)  -- Don't wrap text
		
		-- Set initial font
		if E.db and E.db.actionbar and E.db.actionbar.auraTracker then
			local font = LSM:Fetch("font", E.db.actionbar.auraTracker.font)
			local fontSize = E.db.actionbar.auraTracker.fontSize
			local fontOutline = E.db.actionbar.auraTracker.fontOutline
			
			-- Apply white outline if invertOutline is enabled
			if E.db.actionbar.auraTracker.invertOutline and fontOutline ~= "NONE" then
				if fontOutline == "OUTLINE" then
					fontOutline = "OUTLINE, MONOCHROME"
				elseif fontOutline == "THICKOUTLINE" then
					fontOutline = "THICKOUTLINE, MONOCHROME"
				end
			end
			
			button.auraText:FontTemplate(font, fontSize, fontOutline)
		end
		
		button.auraText:SetText("") -- Start empty
		button.auraText:SetAlpha(1)
		button.auraText:Show() -- Make it visible
		
		-- Store reference to the frame so we can manage it
		button.auraTextFrame = textFrame
	end
	
	-- Cache the spell name to avoid constant tooltip checks
	button.auraTrackerSpell = self:GetButtonSpellName(button)
	if button.GetAttribute then
		button.auraTrackerLastAction = button:GetAttribute("action")
	end
end

-- Unregister a button
function AT:UnregisterButton(button)
	if not button then return end
	self.Buttons[button] = nil
	if button.auraText then
		button.auraText:SetText("")
	end
	-- Clean up the text frame
	if button.auraTextFrame then
		button.auraTextFrame:Hide()
		button.auraTextFrame = nil
	end
end

-- Event handler for target aura changes
function AT:UNIT_AURA(event, unit)
	if unit == "target" then
		self:UpdateAllButtons()
	end
end

-- Event handler for target change
function AT:PLAYER_TARGET_CHANGED()
	self:UpdateAllButtons()
end

-- Update timer (fallback for smooth countdown)
function AT:OnUpdate()
	if self.throttle and self.throttle > GetTime() then return end
	self.throttle = GetTime() + 0.1 -- Update 10 times per second
	
	if E.db.actionbar.auraTracker and E.db.actionbar.auraTracker.enable then
		self:UpdateAllButtons()
	end
end

-- Enable the module
function AT:Enable()
	if self.enabled then return end
	
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	
	-- Start update ticker
	if not self.ticker then
		self.ticker = self:ScheduleRepeatingTimer("OnUpdate", 0.1)
	end
	
	self.enabled = true
	self:UpdateAllButtons()
end

-- Disable the module
function AT:Disable()
	if not self.enabled then return end
	
	self:UnregisterEvent("UNIT_AURA")
	self:UnregisterEvent("PLAYER_TARGET_CHANGED")
	
	-- Stop update ticker
	if self.ticker then
		self:CancelTimer(self.ticker)
		self.ticker = nil
	end
	
	-- Clear all button text
	for _, button in pairs(self.Buttons) do
		if button.auraText then
			button.auraText:SetText("")
		end
	end
	
	self.enabled = false
end

-- Toggle based on settings
function AT:Toggle()
	if E.db.actionbar.auraTracker and E.db.actionbar.auraTracker.enable then
		self:Enable()
	else
		self:Disable()
	end
end

-- Register all action bar buttons
function AT:RegisterAllButtons()
	-- Register main action bar buttons (Bars 1-6)
	for bar = 1, 6 do
		for i = 1, 12 do
			local button = _G["ElvUI_Bar"..bar.."Button"..i]
			if button then
				self:RegisterButton(button)
			end
		end
	end
	
	-- Register pet bar buttons
	for i = 1, 10 do
		local button = _G["ElvUI_PetBarButton"..i]
		if button then
			self:RegisterButton(button)
		end
	end
	
	-- Register stance bar buttons
	for i = 1, 10 do
		local button = _G["ElvUI_StanceBarButton"..i]
		if button then
			self:RegisterButton(button)
		end
	end
end

-- Initialize
function AT:Initialize()
	-- Make sure we're not already initialized
	if self.Initialized then return end
	
	-- Wait for ActionBars module to be ready
	if not AB or not AB.Initialized then
		self:ScheduleTimer("Initialize", 1)
		return
	end
	
	-- Mark as initialized first to prevent double initialization
	self.Initialized = true
	
	-- Register all buttons after a short delay to ensure all bars are created
	-- ActionBars.lua already registers buttons in StyleButton, but we'll also scan for any existing ones
	self:ScheduleTimer(function()
		self:RegisterAllButtons()
		self:Toggle()
	end, 0.5)
end

-- Register module with initialization callback
local function InitializeCallback()
	AT:Initialize()
end

E:RegisterModule(AT:GetName(), InitializeCallback)

