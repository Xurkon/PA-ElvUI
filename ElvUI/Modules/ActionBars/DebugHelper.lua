-- Debug helper for ActionBar issues
local E, L, V, P, G = unpack(select(2, ...))

-- Create debug commands
SLASH_ELVUIDEBUGAB1 = "/debugab"
SlashCmdList["ELVUIDEBUGAB"] = function(msg)
	local AB = E:GetModule("ActionBars")
	local AT = E:GetModule("AuraTracker", true)
	
	print("|cff1784d1ElvUI Debug|r - ActionBars & AuraTracker")
	print("----------------------------------------")
	
	-- Check ActionBars
	if AB then
		print("|cff00ff00ActionBars module loaded|r")
		print("  - Initialized:", AB.Initialized or false)
		print("  - DB exists:", AB.db ~= nil)
		if AB.db then
			print("  - LBF enabled:", AB.db.lbf and AB.db.lbf.enable or false)
			print("  - LBF skin:", AB.db.lbf and AB.db.lbf.skin or "none")
		end
		
		-- Check first button count visibility
		local btn = _G["ElvUI_Bar1Button1"]
		if btn then
			local count = _G["ElvUI_Bar1Button1Count"]
			if count then
				print("  - Button1 Count exists:", count ~= nil)
				print("  - Button1 Count visible:", count:IsShown())
				print("  - Button1 Count alpha:", count:GetAlpha())
				print("  - Button1 Count text:", count:GetText() or "empty")
				
				-- Force show it
				count:Show()
				count:SetAlpha(1)
				print("  - |cffff00Forced count to show|r")
			else
				print("  - |cffff0000Button1 Count NOT FOUND|r")
			end
		else
			print("  - |cffff0000Button1 NOT FOUND|r")
		end
	else
		print("|cffff0000ActionBars module NOT loaded|r")
	end
	
	print("----------------------------------------")
	
	-- Check AuraTracker
	if AT then
		print("|cff00ff00AuraTracker module loaded|r")
		print("  - Initialized:", AT.Initialized or false)
		print("  - Enabled:", AT.enabled or false)
		
		-- Count buttons correctly (AT.Buttons is indexed by button objects, not numbers)
		local buttonCount = 0
		if AT.Buttons then
			for _ in pairs(AT.Buttons) do
				buttonCount = buttonCount + 1
			end
		end
		print("  - Button count:", buttonCount)
		
		if E.db and E.db.actionbar and E.db.actionbar.auraTracker then
			print("  - Settings exist: true")
			print("  - Setting enabled:", E.db.actionbar.auraTracker.enable)
			print("  - Font:", E.db.actionbar.auraTracker.font)
			print("  - Font size:", E.db.actionbar.auraTracker.fontSize)
			
			-- Try to manually enable
			if not AT.enabled then
				print("  - |cffff00Attempting to enable AuraTracker...|r")
				AT:Enable()
				print("  - Now enabled:", AT.enabled)
			end
		else
			print("  - |cffff0000Settings NOT FOUND|r")
		end
	else
		print("|cffff0000AuraTracker module NOT loaded|r")
	end
	
	print("----------------------------------------")
	print("Use |cff00ff00/reloadui|r after checking/fixing issues")
end

-- Force count to show on all buttons
SLASH_ELVUIFIXCOUNT1 = "/fixcount"
SlashCmdList["ELVUIFIXCOUNT"] = function()
	local AB = E:GetModule("ActionBars")
	if not AB then
		print("|cffff0000ActionBars not loaded|r")
		return
	end
	
	local BF = E:GetModule("ButtonFacade", true)
	
	-- Try using ButtonFacade's fix first if available
	if BF and BF.FixAllCounts then
		BF:FixAllCounts()
		print("|cff1784d1ElvUI|r - ButtonFacade count fix applied")
		return
	end
	
	-- Fallback to manual fix
	local fixed = 0
	for barName, bar in pairs(AB.handledBars) do
		if bar and bar.buttons then
			for i, button in pairs(bar.buttons) do
				local name = button:GetName()
				if name then
					local count = _G[name.."Count"]
					if count then
						local width = count:GetWidth()
						local height = count:GetHeight()
						if width == 0 or height == 0 then
							count:SetWidth(36)
							count:SetHeight(10)
						end
						count:Show()
						count:SetAlpha(1)
						fixed = fixed + 1
					end
				end
			end
		end
	end
	
	print("|cff1784d1ElvUI|r - Fixed count display on " .. fixed .. " buttons")
	if fixed == 0 then
		print("No counts needed fixing. If you still don't see counts, check if ButtonFacade is enabled")
	end
end

-- Test AuraTracker manually
SLASH_ELVUITESTAUTRACK1 = "/testautrack"
SlashCmdList["ELVUITESTAUTRACK"] = function()
	local AT = E:GetModule("AuraTracker", true)
	if not AT then
		print("|cffff0000AuraTracker not loaded|r")
		return
	end
	
	print("|cff1784d1Testing AuraTracker...|r")
	
	-- Force initialization
	if not AT.Initialized then
		print("Initializing...")
		AT:Initialize()
	end
	
	-- Force enable
	if not AT.enabled then
		print("Enabling...")
		AT:Enable()
	end
	
	-- Register all buttons
	print("Registering buttons...")
	AT:RegisterAllButtons()
	
	-- Force update
	print("Updating all buttons...")
	AT:UpdateAllButtons()
	
	print("Status:")
	print("  - Initialized:", AT.Initialized)
	print("  - Enabled:", AT.enabled)
	
	-- Count registered buttons
	local buttonCount = 0
	for _ in pairs(AT.Buttons) do
		buttonCount = buttonCount + 1
	end
	print("  - Registered buttons:", buttonCount)
	
	-- Check if we have a target
	if UnitExists("target") then
		print("  - Target exists: |cff00ff00YES|r")
		print("  - Target name:", UnitName("target"))
		
		-- Check for auras on target
		local buffCount = 0
		local debuffCount = 0
		for i = 1, 40 do
			local name = UnitAura("target", i, "HELPFUL")
			if name then buffCount = buffCount + 1 else break end
		end
		for i = 1, 40 do
			local name = UnitAura("target", i, "HARMFUL")
			if name then debuffCount = debuffCount + 1 else break end
		end
		print("  - Buffs on target:", buffCount)
		print("  - Debuffs on target:", debuffCount)
		
		-- Test text display on first button
		local testButton = _G["ElvUI_Bar1Button1"]
		if testButton and testButton.auraText then
			print("  - Test button has auraText: |cff00ff00YES|r")
			print("  - Current text:", testButton.auraText:GetText() or "empty")
			print("  - Text visible:", testButton.auraText:IsShown())
			print("  - Text alpha:", testButton.auraText:GetAlpha())
			print("  - Text layer:", testButton.auraText:GetDrawLayer())
			
			-- Check text properties
			local font, size, flags = testButton.auraText:GetFont()
			print("  - Font:", font or "none", "Size:", size or 0, "Flags:", flags or "none")
			
			-- Check parent chain
			local parent = testButton.auraText:GetParent()
			print("  - Parent:", parent and parent:GetName() or "nil")
			if parent then
				print("  - Parent visible:", parent:IsShown())
				print("  - Parent alpha:", parent:GetAlpha())
				print("  - Button frame level:", testButton:GetFrameLevel())
				print("  - Button frame strata:", testButton:GetFrameStrata())
			end
			
			-- Force a test display
			testButton.auraText:SetText("TEST 99")
			testButton.auraText:SetTextColor(1, 0, 1) -- Magenta for test
			testButton.auraText:SetAlpha(1)
			testButton.auraText:Show()
			testButton.auraText:SetDrawLayer("OVERLAY", 7)
			
			-- Try reparenting to UIParent as a test
			local testFrame = CreateFrame("Frame", "AuraTrackerTestFrame", UIParent)
			testFrame:SetFrameStrata("TOOLTIP")
			testFrame:SetFrameLevel(100)
			testFrame:SetAllPoints(testButton)
			
			local testText = testFrame:CreateFontString(nil, "OVERLAY")
			testText:SetPoint("CENTER", testButton, "CENTER", 0, 0)
			testText:SetFont(font, size, flags)
			testText:SetText("UI 99")
			testText:SetTextColor(1, 1, 0) -- Yellow
			testText:SetAlpha(1)
			testText:Show()
			
			print("  - |cffff00Created yellow 'UI 99' on UIParent at TOOLTIP strata|r")
			
			-- Prevent UpdateButtonDuration from clearing it
			testButton.auraText.__testMode = true
			
			print("  - |cffff00Forced 'TEST 99' on Button1 (magenta color)|r")
			print("  - Text after force:", testButton.auraText:GetText() or "STILL EMPTY!")
			print(" ")
			print("  |cffFFFF00LOOK AT BUTTON 1 NOW:|r")
			print("  - If you see |cffFF00FFTEST 99|r (magenta) = button parenting works")
			print("  - If you see |cffFFFF00UI 99|r (yellow) = only UIParent works")  
			print("  - If you see NOTHING = rendering completely broken")
		else
			print("  - |cffff0000Button1 has no auraText!|r")
		end
	else
		print("  - Target exists: |cffff0000NO - select a target to test|r")
	end
	
	print(" ")
	print("If you see 'TEST 99' on button 1 (in magenta), layering works!")
	print("If not, the text might be hidden behind other elements.")
end

-- Clear test mode
SLASH_CLEARTEST1 = "/cleartest"
SlashCmdList["CLEARTEST"] = function()
	local AT = E:GetModule("AuraTracker", true)
	if not AT then
		print("|cffff0000AuraTracker not loaded|r")
		return
	end
	
	local count = 0
	-- Clear all registered buttons
	if AT.Buttons then
		for button in pairs(AT.Buttons) do
			if button and button.auraText then
				button.auraText.__testMode = nil
				button.auraText:SetText("")
				button.auraText:SetTextColor(1, 1, 1)  -- Reset to white
				count = count + 1
			end
		end
	end
	
	print("|cff1784d1ElvUI|r - Test mode cleared from " .. count .. " buttons")
	print("Use /refreshautrack to update timers")
end

-- Debug spell names on buttons AND match with target auras
SLASH_DEBUGSPELLS1 = "/debugspells"
SlashCmdList["DEBUGSPELLS"] = function()
	local AT = E:GetModule("AuraTracker", true)
	if not AT then 
		print("|cffff0000AuraTracker not loaded|r")
		return
	end
	
	print("|cff1784d1Spell Names on Action Bars:|r")
	local spellsOnBars = {}
	
	-- Use AuraTracker's registered buttons and its own GetButtonSpellName method
	if AT.Buttons then
		for button in pairs(AT.Buttons) do
			if button then
				-- Use AuraTracker's own spell detection method
				local spellName = AT:GetButtonSpellName(button)
				
				if spellName then
					local buttonName = button:GetName() or "Unknown"
					spellsOnBars[spellName] = buttonName
					print("  "..spellName..": |cff00ff00"..buttonName.."|r")
				end
			end
		end
	end
	
	if next(spellsOnBars) == nil then
		print("  |cffff0000No spells found on action bars!|r")
		print("  |cffFFFF00This might mean:|r")
		print("    - Buttons not registered with AuraTracker")
		print("    - Action slots not set correctly")
		print("    - Try dragging spells to bars again")
	end
	
	-- Check target auras
	if UnitExists("target") then
		print(" ")
		print("|cff1784d1Auras on Target:|r")
		local targetName = UnitName("target")
		print("  Target: "..targetName)
		
		local foundMatch = false
		
		-- Check debuffs
		print("  |cffFF0000Debuffs:|r")
		for i = 1, 40 do
			local name, _, _, _, _, expirationTime, caster = UnitAura("target", i, "HARMFUL")
			if not name then break end
			
			-- Strip rank from aura name
			local auraName = name:match("^(.-)%(") or name
			
			local timeLeft = expirationTime and expirationTime > 0 and (expirationTime - GetTime()) or 0
			
			-- Debug caster value (using same logic as AuraTracker)
			local casterType = type(caster)
			local casterStr = tostring(caster)
			
			-- Use same caster detection as AuraTracker
			local isMine = false
			if caster == nil then
				isMine = true
			elseif type(caster) == "number" then
				-- Ascension: numeric caster, treat >= 0 as ours
				isMine = (caster >= 0)
			else
				-- Standard WoW: unit string
				isMine = UnitIsUnit(caster, "player")
			end
			local isPlayer = (type(caster) ~= "number") and caster and UnitIsUnit(caster, "player")
			
			local onBar = spellsOnBars[auraName]
			
			if onBar then
				print("    "..i..". |cff00ff00"..name.."|r ["..floor(timeLeft).."s] Mine:"..tostring(isMine).." caster="..casterStr.." isPlayer="..tostring(isPlayer).." |cffFFFF00ON "..onBar.."|r")
				foundMatch = true
			else
				print("    "..i..". "..name.." ["..floor(timeLeft).."s] Mine:"..tostring(isMine).." caster="..casterStr.." isPlayer="..tostring(isPlayer).." (stripped: "..auraName..")")
			end
		end
		
		-- Check buffs
		print("  |cff00FF00Buffs:|r")
		for i = 1, 40 do
			local name, _, _, _, _, expirationTime, caster = UnitAura("target", i, "HELPFUL")
			if not name then break end
			
			-- Strip rank from aura name
			local auraName = name:match("^(.-)%(") or name
			
			local timeLeft = expirationTime and expirationTime > 0 and (expirationTime - GetTime()) or 0
			
			-- Debug caster value (using same logic as AuraTracker)
			local casterType = type(caster)
			local casterStr = tostring(caster)
			
			-- Use same caster detection as AuraTracker
			local isMine = false
			if caster == nil then
				isMine = true
			elseif type(caster) == "number" then
				-- Ascension: numeric caster, treat >= 0 as ours
				isMine = (caster >= 0)
			else
				-- Standard WoW: unit string
				isMine = UnitIsUnit(caster, "player")
			end
			local isPlayer = (type(caster) ~= "number") and caster and UnitIsUnit(caster, "player")
			
			local onBar = spellsOnBars[auraName]
			
			if onBar then
				print("    "..i..". |cff00ff00"..name.."|r ["..floor(timeLeft).."s] Mine:"..tostring(isMine).." caster="..casterStr.." isPlayer="..tostring(isPlayer).." |cffFFFF00ON "..onBar.."|r")
				foundMatch = true
			else
				print("    "..i..". "..name.." ["..floor(timeLeft).."s] Mine:"..tostring(isMine).." caster="..casterStr.." isPlayer="..tostring(isPlayer).." (stripped: "..auraName..")")
			end
		end
		
		if foundMatch then
			print(" ")
			print("|cff00FF00MATCHES FOUND!|r Countdown should appear on highlighted bars!")
		else
			print(" ")
			print("|cffFF0000NO MATCHES!|r Your debuffs/buffs don't match any spells on your bars")
		end
	else
		print(" ")
		print("|cffFF0000No target selected!|r Target something to see auras")
	end
end

-- Force register buttons and update
SLASH_FORCEAUTRACK1 = "/forceautrack"
SlashCmdList["FORCEAUTRACK"] = function()
	local AT = E:GetModule("AuraTracker", true)
	if not AT then
		print("|cffff0000AuraTracker not loaded|r")
		return
	end
	
	print("|cff1784d1Force registering all buttons...|r")
	
	-- Force register all buttons
	AT:RegisterAllButtons()
	
	-- Count buttons
	local buttonCount = 0
	if AT.Buttons then
		for _ in pairs(AT.Buttons) do
			buttonCount = buttonCount + 1
		end
	end
	print("  - Registered:", buttonCount, "buttons")
	
	-- Force enable if not enabled
	if not AT.enabled then
		print("  - Enabling AuraTracker...")
		AT:Enable()
	end
	
	-- Force update all buttons
	print("  - Forcing update...")
	AT:UpdateAllButtons()
	
	print("|cff00ff00Done! Check your action bars for countdown timers.|r")
	print("If still not working, target something with your debuffs and try again.")
end

-- Dump all UnitAura return values to find duration
SLASH_DUMPBUFF1 = "/dumpbuff"
SlashCmdList["DUMPBUFF"] = function(msg)
	if not UnitExists("target") then
		print("|cffff0000No target! Target yourself first.|r")
		return
	end
	
	local buffNum = tonumber(msg)
	
	-- If no number provided, search for Mark of the Wild
	if not buffNum then
		print("|cff1784d1Searching for Mark of the Wild...|r")
		for i = 1, 40 do
			local name = UnitAura("target", i, "HELPFUL")
			if not name then break end
			local stripped = name:match("^(.-)%(") or name
			if stripped == "Mark of the Wild" then
				buffNum = i
				print("  Found at buff #"..i)
				break
			end
		end
		
		if not buffNum then
			print("|cffff0000Mark of the Wild not found! Cast it and try again.|r")
			print("Or specify buff number: /dumpbuff [number]")
			return
		end
	end
	
	print("|cff1784d1Dumping ALL return values from UnitAura for buff #"..buffNum..":|r")
	
	local name, rank, icon, count, debuffType, duration, expirationTime, caster, isStealable, shouldConsolidate, spellId, canApplyAura, isBossDebuff, isCastByPlayer, value1, value2, value3 = UnitAura("target", buffNum, "HELPFUL")
	
	if not name then
		print("|cffff0000Buff #"..buffNum.." not found on target|r")
		return
	end
	
	print("  1. name:", name or "nil")
	print("  2. rank:", rank or "nil")
	print("  3. icon:", icon or "nil")
	print("  4. count:", count or "nil")
	print("  5. debuffType:", debuffType or "nil")
	print("  6. duration:", duration or "nil", "(BASE DURATION)")
	print("  7. expirationTime:", expirationTime or "nil", "(WHEN IT EXPIRES)")
	print("  8. caster:", tostring(caster), "(type:", type(caster)..")")
	print("  9. isStealable:", tostring(isStealable))
	print(" 10. shouldConsolidate:", tostring(shouldConsolidate))
	print(" 11. spellId:", tostring(spellId))
	print(" 12. canApplyAura:", tostring(canApplyAura))
	print(" 13. isBossDebuff:", tostring(isBossDebuff))
	print(" 14. isCastByPlayer:", tostring(isCastByPlayer))
	print(" 15. value1:", tostring(value1))
	print(" 16. value2:", tostring(value2))
	print(" 17. value3:", tostring(value3))
	
	print(" ")
	print("|cffFFFF00Calculating time left:|r")
	print("  - GetTime() returns:", GetTime())
	if duration and duration > 0 then
		print("  - Base duration:", duration, "seconds")
	end
	if expirationTime then
		print("  - ExpirationTime:", expirationTime)
		if expirationTime > 0 then
			local timeLeft = expirationTime - GetTime()
			print("  - Time left (exp - now):", timeLeft, "seconds")
			print("  - Is timeLeft > 0?", timeLeft > 0)
			print("  - Is timeLeft < 604800?", timeLeft < 604800)
			if timeLeft > 0 and timeLeft < 604800 then
				print("  |cff00ff00SHOULD SHOW COUNTDOWN!|r")
			else
				print("  |cffff0000Would show UP (time out of range)|r")
			end
		else
			print("  - ExpirationTime negative or 0, would show UP")
		end
	end
	
	print(" ")
	print("|cff00ff00Look for 'duration' (value 6) or other values that make sense!|r")
end

-- Refresh all auraText with current settings
SLASH_REFRESHAUTRACK1 = "/refreshautrack"
SlashCmdList["REFRESHAUTRACK"] = function()
	local AT = E:GetModule("AuraTracker", true)
	if not AT then
		print("|cffff0000AuraTracker not loaded|r")
		return
	end
	
	print("|cff1784d1Refreshing all AuraTracker text elements...|r")
	
	-- Clear all existing buttons and re-register
	for button in pairs(AT.Buttons) do
		if button.auraText then
			button.auraText = nil
		end
		if button.auraTextFrame then
			button.auraTextFrame:Hide()
			button.auraTextFrame = nil
		end
		button.auraTrackerSpell = nil
		button.auraTrackerLastAction = nil
	end
	
	-- Clear and re-register all
	AT.Buttons = {}
	AT:RegisterAllButtons()
	
	local count = 0
	for _ in pairs(AT.Buttons) do
		count = count + 1
	end
	
	print("|cff00ff00Refreshed", count, "buttons with new settings!|r")
	print("Font size is now:", E.db.actionbar.auraTracker.fontSize)
end

-- Force show test text on matched buttons
SLASH_SHOWTIMERS1 = "/showtimers"
SlashCmdList["SHOWTIMERS"] = function()
	local AT = E:GetModule("AuraTracker", true)
	if not AT then
		print("|cffff0000AuraTracker not loaded|r")
		return
	end
	
	print("|cff1784d1Forcing countdown timers on matched buttons...|r")
	
	-- Get spell-to-button mapping
	local spellsOnBars = {}
	if AT.Buttons then
		for button in pairs(AT.Buttons) do
			local spellName = AT:GetButtonSpellName(button)
			if spellName then
				spellsOnBars[spellName] = button
			end
		end
	end
	
	-- Check buffs on target and force display
	if UnitExists("target") then
		local count = 0
		for i = 1, 40 do
			local name = UnitAura("target", i, "HELPFUL")
			if not name then break end
			
			local auraName = name:match("^(.-)%(") or name
			local button = spellsOnBars[auraName]
			
			if button and button.auraText then
				button.auraText:SetText("TEST")
				button.auraText:SetTextColor(1, 0, 1)  -- Magenta
				button.auraText:SetAlpha(1)
				button.auraText:Show()
				print("  - Set TEST on:", button:GetName(), "for", auraName)
				count = count + 1
			end
		end
		print("|cff00ff00Updated", count, "buttons with TEST text|r")
	else
		print("|cffff0000No target! Target yourself first.|r")
	end
end

-- Debug a specific button in detail
SLASH_DEBUGBUTTON1 = "/debugbutton"
SlashCmdList["DEBUGBUTTON"] = function(msg)
	local barNum, buttonNum = msg:match("^(%d+)%s+(%d+)$")
	barNum = tonumber(barNum) or 1
	buttonNum = tonumber(buttonNum) or tonumber(msg) or 1
	
	local button = _G["ElvUI_Bar"..barNum.."Button"..buttonNum]
	
	if not button then
		print("|cffff0000Button not found: ElvUI_Bar"..barNum.."Button"..buttonNum.."|r")
		print("Usage: /debugbutton [bar] [button] or /debugbutton [button]")
		print("Example: /debugbutton 2 12  (Bar 2, Button 12)")
		print("Example: /debugbutton 5  (Bar 1, Button 5)")
		return
	end
	
	print("|cff1784d1Debugging ElvUI_Bar"..barNum.."Button"..buttonNum..":|r")
	print("  - Button exists:", button ~= nil)
	print("  - Button name:", button:GetName() or "nil")
	print("  - Button visible:", button:IsVisible())
	
	-- Check action slot detection methods
	print(" ")
	print("|cff1784d1Action Slot Detection:|r")
	
	local actionSlot = nil
	
	-- Try GetAttribute FIRST (ElvUI priority)
	if button.GetAttribute then
		local attr = button:GetAttribute("action")
		print("  - GetAttribute() exists: true")
		print("  - GetAttribute('action'):", attr or "nil")
		if attr and attr > 0 then
			actionSlot = attr
			print("  - Using GetAttribute value:", actionSlot)
		end
	else
		print("  - GetAttribute() exists: false")
	end
	
	-- Try GetActionID
	if not actionSlot and button.GetActionID then
		local id = button:GetActionID()
		print("  - GetActionID() exists: true")
		print("  - GetActionID() returned:", id or "nil")
		if id and id > 0 then
			actionSlot = id
			print("  - Using GetActionID value:", actionSlot)
		end
	elseif not button.GetActionID then
		print("  - GetActionID() exists: false")
	end
	
	-- Try button.action (but validate > 0)
	if not actionSlot and button.action then
		print("  - button.action exists: true")
		print("  - button.action value:", button.action or "nil")
		if button.action > 0 then
			actionSlot = button.action
			print("  - Using button.action value:", actionSlot)
		else
			print("  - Skipping button.action (invalid: 0)")
		end
	else
		print("  - button.action exists: false")
	end
	
	print(" ")
	print("|cff1784d1Action Slot Result:|r")
	print("  - Final actionSlot:", actionSlot or "nil")
	
	-- Try GetActionInfo
	if actionSlot then
		local actionType, id, subType = GetActionInfo(actionSlot)
		print(" ")
		print("|cff1784d1GetActionInfo("..actionSlot.."):|r")
		print("  - actionType:", actionType or "nil")
		print("  - id:", id or "nil")
		print("  - subType:", subType or "nil")
		
		if actionType == "spell" and id then
			local spellName, spellRank = GetSpellInfo(id)
			print(" ")
			print("|cff1784d1GetSpellInfo("..id.."):|r")
			print("  - spellName:", spellName or "nil")
			print("  - spellRank:", spellRank or "nil")
		end
	else
		print("  |cffff0000No action slot found - button is empty or detection failed|r")
	end
	
	-- Try tooltip method (last resort)
	print(" ")
	print("|cff1784d1Tooltip Detection:|r")
	local tooltipOwner = GameTooltip:GetOwner()
	local wasShown = GameTooltip:IsShown()
	
	GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	GameTooltip:SetAction(actionSlot or 0)
	local tooltipText = GameTooltipTextLeft1 and GameTooltipTextLeft1:GetText()
	
	-- Restore tooltip
	if not wasShown then
		GameTooltip:Hide()
	elseif tooltipOwner then
		GameTooltip:SetOwner(tooltipOwner, "ANCHOR_CURSOR")
	end
	
	print("  - Tooltip text:", tooltipText or "nil")
	if tooltipText then
		local stripped = tooltipText:match("^(.-)%(") or tooltipText
		print("  - Stripped name:", stripped)
	end
	
	-- Try GetSpell if it exists
	if button.GetSpell then
		local spell = button:GetSpell()
		print(" ")
		print("|cff1784d1GetSpell():|r")
		print("  - Returned:", spell or "nil")
	end
	
	-- Try icon texture
	local btnName = button:GetName()
	if btnName then
		local icon = _G[btnName.."Icon"]
		if icon then
			local texture = icon:GetTexture()
			print(" ")
			print("|cff1784d1Icon Texture:|r")
			print("  - Texture path:", texture or "nil")
		end
	end
end

print("|cff1784d1ElvUI Debug Helper|r loaded. Commands:")
print("  |cff00ff00/debugab|r - Debug ActionBars and AuraTracker")
print("  |cff00ff00/debugspells|r - Show spell names and matches")
print("  |cff00ff00/forceautrack|r - Force register buttons and update")
print("  |cff00ff00/refreshautrack|r - Refresh all buttons with new settings")
print("  |cff00ff00/showtimers|r - Force TEST text (visual test)")
print("  |cff00ff00/dumpbuff [num]|r - Dump UnitAura data for buff #")
print("  |cff00ff00/debugbutton [bar] [btn]|r - Debug specific button")
print("  |cff00ff00/fixcount|r - Force count display")
print("  |cff00ff00/testautrack|r - Test AuraTracker")
print("  |cff00ff00/cleartest|r - Clear test mode")


