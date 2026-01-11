-- ElvUI_UtilityBar.lua
-- Final Polish: Smooth, symmetric animation.
-- Slide Speed: 12 (Up/Down).
-- Fade Speed: 18 (Close) - Smooth fade, no instant vanish, no overlap.

local addonName = ...
local E, L, V, P, G
if IsAddOnLoaded("ElvUI") then
    E, L, V, P, G = unpack(ElvUI)
end

-- DB is initialized in ADDON_LOADED
ElvUI_UtilityBarDB = ElvUI_UtilityBarDB or {}

------------------------------------------------------------
-- Defaults & Helpers
------------------------------------------------------------
local defaults = {
    qualities = {
        poor      = false,
        common    = false,
        uncommon  = true,
        rare      = true,
        epic      = true,
        legendary = true,
        vanity    = true,
    },
    buttonsShown = false,
}

local function InitializeDB()
    if not ElvUI_UtilityBarDB.qualities then
        ElvUI_UtilityBarDB.qualities = {}
    end
    
    for k, v in pairs(defaults.qualities) do
        if ElvUI_UtilityBarDB.qualities[k] == nil then
            ElvUI_UtilityBarDB.qualities[k] = v
        end
    end
    
    if ElvUI_UtilityBarDB.buttonsShown == nil then
        ElvUI_UtilityBarDB.buttonsShown = false
    end
end

local function InCombat()
    return InCombatLockdown and InCombatLockdown()
end

local function SafeCall(func)
    local success, err = pcall(func)
    if not success then
        print("|cffff0000[UtilityBar Error]|r " .. tostring(err))
    end
end

local function GetSkinModule()
    if E and E.GetModule then
        return E:GetModule('Skins', true)
    end
    return nil
end

------------------------------------------------------------
-- LOGIC: Bank Detection & Item Transfer
------------------------------------------------------------
local function IsBankOpen()
    return (BankFrame and BankFrame:IsShown()) or 
           (GuildBankFrame and GuildBankFrame:IsShown()) or 
           (_G["ElvUI_BankContainerFrame"] and _G["ElvUI_BankContainerFrame"]:IsShown()) or
           (_G["BagnonFramebank"] and _G["BagnonFramebank"]:IsShown())
end

_G.ElvUI_UtilityBar_Run = function(mode)
    if InCombat() then print("|cffff0000Cannot use in combat.|r"); return end
    
    SafeCall(function()
        local db = ElvUI_UtilityBarDB.qualities
        
        local function IsQualityMatch(link)
            if not link then return false end
            if db.poor      and link:find("9d9d9d") then return true end
            if db.common    and link:find("ffffff") then return true end
            if db.uncommon  and link:find("1eff00") then return true end
            if db.rare      and link:find("0070dd") then return true end
            if db.epic      and link:find("a335ee") then return true end
            if db.legendary and link:find("ff8000") then return true end
            if db.vanity    and link:find("e6cc80") then return true end 
            return false
        end

        if mode ~= "vanity" and not IsBankOpen() then
            print("|cffffee00Open a Bank (Normal, Personal, or Realm) first.|r")
            return
        end

        if mode == "bagsToBank" then
            for bag = 0, 4 do
                for slot = 1, GetContainerNumSlots(bag) do
                    local link = GetContainerItemLink(bag, slot)
                    if IsQualityMatch(link) then
                        UseContainerItem(bag, slot)
                    end
                end
            end
            
        elseif mode == "bankToBags" then
            if (GuildBankFrame and GuildBankFrame:IsShown()) then
                local tab = GetCurrentGuildBankTab()
                for slot = 1, 98 do
                    local link = GetGuildBankItemLink(tab, slot)
                    if IsQualityMatch(link) then
                        AutoStoreGuildBankItem(tab, slot)
                    end
                end
            end
            if (BankFrame and BankFrame:IsShown()) or 
               (_G["ElvUI_BankContainerFrame"] and _G["ElvUI_BankContainerFrame"]:IsShown()) or 
               (_G["BagnonFramebank"] and _G["BagnonFramebank"]:IsShown()) then
                for bag = 5, 11 do
                    for slot = 1, GetContainerNumSlots(bag) do
                        local link = GetContainerItemLink(bag, slot)
                        if IsQualityMatch(link) then
                            UseContainerItem(bag, slot)
                        end
                    end
                end
                for slot = 1, GetContainerNumSlots(-1) do
                    local link = GetContainerItemLink(-1, slot)
                    if IsQualityMatch(link) then
                        UseContainerItem(-1, slot)
                    end
                end
            end

        elseif mode == "vanity" then
            if C_AppearanceCollection and C_AppearanceCollection.CollectItemAppearance then
                local c = C_AppearanceCollection
                for bag = 0, 4 do
                    for slot = 1, GetContainerNumSlots(bag) do
                        local itemID = GetContainerItemID(bag, slot)
                        if itemID then
                            local appearanceID = C_Appearance.GetItemAppearanceID(itemID)
                            if appearanceID and not c.IsAppearanceCollected(appearanceID) then
                                local guid = GetContainerItemGUID(bag, slot)
                                c.CollectItemAppearance(guid)
                            end
                        end
                    end
                end
            else
                print("|cffff0000Vanity API not found.|r")
            end
        end
    end)
end

------------------------------------------------------------
-- Frame References
------------------------------------------------------------
local holderFrame
local barContainer
local arrowBtn
local settingsFrame
local buttonList = {}

------------------------------------------------------------
-- Settings GUI
------------------------------------------------------------
local function CreateSettingsFrame()
    if settingsFrame then return end

    settingsFrame = CreateFrame("Frame", "ElvUI_UtilityBarSettings", UIParent)
    settingsFrame:SetSize(160, 260)
    settingsFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    settingsFrame:EnableMouse(true)
    
    if E then
        settingsFrame:SetTemplate("Transparent")
    else
        settingsFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = {left = 4, right = 4, top = 4, bottom = 4},
        })
    end
    settingsFrame:Hide()

    local title = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -12)
    title:SetText("Filter Quality")

    local S = GetSkinModule()

    local function AddCheck(y, label, key, r, g, b)
        local cbName = "ElvUI_UtilityBarCheck_" .. key
        local cb = CreateFrame("CheckButton", cbName, settingsFrame, "UICheckButtonTemplate")
        cb:SetPoint("TOPLEFT", 20, y)
        
        cb.text = cb:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        cb.text:SetPoint("LEFT", cb, "RIGHT", 5, 0)
        cb.text:SetText(label)
        cb.text:SetTextColor(r, g, b)

        if S and S.HandleCheckBox then S:HandleCheckBox(cb) end

        cb:SetScript("OnClick", function(self)
            local checked = self:GetChecked() and true or false
            ElvUI_UtilityBarDB.qualities[key] = checked
            PlaySound("igMainMenuOptionCheckBoxOn")
        end)
        cb:SetScript("OnShow", function(self)
            local val = ElvUI_UtilityBarDB.qualities[key]
            self:SetChecked(val and true or false)
        end)
    end

    AddCheck(-40,  "Poor",      "poor",      .61, .61, .61)
    AddCheck(-65,  "Common",    "common",    1,   1,   1)
    AddCheck(-90,  "Uncommon",  "uncommon",  .12, 1,   0)
    AddCheck(-115, "Rare",      "rare",      0,   .44, .87)
    AddCheck(-140, "Epic",      "epic",      .64, .21, .93)
    AddCheck(-165, "Legendary", "legendary", 1,   .5,  0)
    AddCheck(-190, "Vanity",    "vanity",    .9,  .8,  .5)
    
    local close = CreateFrame("Button", nil, settingsFrame, "UIPanelButtonTemplate")
    close:SetSize(80, 22)
    close:SetPoint("BOTTOM", 0, 15)
    close:SetText("Close")
    if S and S.HandleButton then S:HandleButton(close) end
    close:SetScript("OnClick", function() settingsFrame:Hide() end)
end

------------------------------------------------------------
-- UI Construction
------------------------------------------------------------
local ARROW_TEX = "Interface\\AddOns\\ElvUI\\Media\\Textures\\ArrowUp"

local function PlayClickSound()
    PlaySound("igMainMenuOptionCheckBoxOn") 
end

local function UpdateArrowState()
    if not arrowBtn or not arrowBtn.tex then return end
    if ElvUI_UtilityBarDB.buttonsShown then
        arrowBtn.tex:SetTexCoord(0, 1, 1, 0) -- Down
    else
        arrowBtn.tex:SetTexCoord(0, 1, 0, 1) -- Up
    end
end

local function CreateUI()
    if holderFrame then return end

    holderFrame = CreateFrame("Frame", "ElvUI_UtilityBarHolder", UIParent)
    holderFrame:SetSize(1, 1) 
    holderFrame:SetFrameStrata("FULLSCREEN_DIALOG") 
    holderFrame:SetFrameLevel(128)
    holderFrame:Hide()

    arrowBtn = CreateFrame("Button", nil, holderFrame)
    arrowBtn:SetSize(16, 16)
    arrowBtn:SetPoint("TOPLEFT", holderFrame, "TOPLEFT", 6, -6)
    
    arrowBtn.tex = arrowBtn:CreateTexture(nil, "ARTWORK")
    arrowBtn.tex:SetAllPoints()
    arrowBtn.tex:SetTexture(ARROW_TEX)
    
    arrowBtn:SetScript("OnClick", function()
        if InCombat() then return end
        ElvUI_UtilityBarDB.buttonsShown = not ElvUI_UtilityBarDB.buttonsShown
        UpdateArrowState()
        PlayClickSound()
    end)
    arrowBtn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")

    barContainer = CreateFrame("Frame", nil, holderFrame)
    barContainer:SetSize(130, 32)
    barContainer:SetPoint("BOTTOMLEFT", holderFrame, "TOPLEFT", 0, 4) 
    barContainer:SetFrameStrata("FULLSCREEN_DIALOG")
    barContainer:SetFrameLevel(127)
    barContainer:SetAlpha(0)

    local function MakeButton(icon, tip, macroFunc)
        local b = CreateFrame("Button", nil, barContainer, "SecureActionButtonTemplate")
        b:SetSize(28, 28)
        
        local bg = b:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0, 0, 0, 0.9)
        
        if E then
            b:SetTemplate("Default")
            b.template = true
        else
            b:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1})
            b:SetBackdropBorderColor(0,0,0,1)
        end

        local ic = b:CreateTexture(nil, "ARTWORK")
        ic:SetPoint("TOPLEFT", 1, -1)
        ic:SetPoint("BOTTOMRIGHT", -1, 1)
        ic:SetTexture(icon)
        ic:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        
        b:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(tip)
        end)
        b:SetScript("OnLeave", GameTooltip_Hide)
        
        b:SetAttribute("type", "macro")
        b:SetAttribute("macrotext", "/run ElvUI_UtilityBar_Run('"..macroFunc.."')")
        b:HookScript("OnClick", PlayClickSound)
        
        table.insert(buttonList, b)
        return b
    end

    -- BUTTON 1: Deposit (Left Flank)
    local b1 = MakeButton("Interface\\Icons\\misc_arrowleft", "Bank <----- Bags (Deposit)", "bagsToBank")
    -- BUTTON 2: Withdraw (Right Flank)
    local b2 = MakeButton("Interface\\Icons\\misc_arrowright_disabled", "Bank -----> Bags (Withdraw)", "bankToBags")
    -- BUTTON 3: Vanity (Tabard)
    local b3 = MakeButton("Interface\\Icons\\inv_misc_tabardpvp_01", "Collect Transmog", "vanity")
    
    -- BUTTON 4: Settings
    local b4 = CreateFrame("Button", nil, barContainer)
    b4:SetSize(28, 28)
    if E then
        b4:SetTemplate("Default")
    else
        b4:SetBackdrop({edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1})
        b4:SetBackdropBorderColor(0,0,0,1)
        local bg4 = b4:CreateTexture(nil, "BACKGROUND")
        bg4:SetAllPoints(); bg4:SetColorTexture(0,0,0,0.9)
    end

    local b4icon = b4:CreateTexture(nil, "ARTWORK")
    b4icon:SetAllPoints()
    b4icon:SetTexture("Interface\\Icons\\Trade_Engineering")
    b4icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    
    b4:SetScript("OnEnter", function(self) 
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT"); GameTooltip:SetText("Settings"); 
    end)
    b4:SetScript("OnLeave", GameTooltip_Hide)
    
    b4:SetScript("OnClick", function(self)
        PlayClickSound()
        CreateSettingsFrame()
        if settingsFrame:IsShown() then 
            settingsFrame:Hide() 
        else 
            settingsFrame:ClearAllPoints()
            settingsFrame:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -5)
            settingsFrame:Show() 
        end
    end)
    table.insert(buttonList, b4)

    b1:SetPoint("LEFT", barContainer, "LEFT", 0, 0)
    b2:SetPoint("LEFT", b1, "RIGHT", 4, 0)
    b3:SetPoint("LEFT", b2, "RIGHT", 4, 0)
    b4:SetPoint("LEFT", b3, "RIGHT", 4, 0)
    
    UpdateArrowState()
end

------------------------------------------------------------
-- Animation & Position Loop
------------------------------------------------------------
local watcher = CreateFrame("Frame")
local timer = 0
local currentYOffset = -20
local currentAlpha = 0

watcher:SetScript("OnUpdate", function(self, elapsed)
    timer = timer + elapsed
    if timer < 0.016 then return end
    timer = 0

    if InCombat() then
        if holderFrame and holderFrame:IsShown() then holderFrame:Hide() end
        if settingsFrame and settingsFrame:IsShown() then settingsFrame:Hide() end
        return
    end

    local bag = _G["ElvUI_ContainerFrame"]
    
    if bag and bag:IsShown() then
        if not holderFrame then CreateUI() end
        
        local x = bag:GetLeft()
        local y = bag:GetTop()
        local s = bag:GetEffectiveScale()
        
        if x and y then
            holderFrame:SetScale(s)
            holderFrame:ClearAllPoints()
            holderFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", x, y)
            holderFrame:Show()
        end
        
        -- ANIMATION LOGIC
        local isOpen = ElvUI_UtilityBarDB.buttonsShown
        local targetAlpha = isOpen and 1 or 0
        local targetY = isOpen and 4 or -20 
        
        -- 1. POSITION (Speed 12 - Identical for Open/Close)
        local yDiff = targetY - currentYOffset
        if math.abs(yDiff) > 0.5 then
            currentYOffset = currentYOffset + (yDiff * 12 * elapsed)
        else
            currentYOffset = targetY
        end
        
        -- 2. OPACITY
        if isOpen then
            -- Opening: Sync with slide
            if currentYOffset > -5 then
                 local aDiff = targetAlpha - currentAlpha
                 currentAlpha = currentAlpha + (aDiff * 12 * elapsed)
            end
        else
            -- Closing: Fade Slightly Faster (Speed 18)
            -- This creates the "Smooth but no overlap" effect. 
            -- It is NOT instant (speed 60), but fast enough to clear the header.
            local aDiff = targetAlpha - currentAlpha
            currentAlpha = currentAlpha + (aDiff * 18 * elapsed)
        end

        if barContainer then
            barContainer:SetPoint("BOTTOMLEFT", holderFrame, "TOPLEFT", 0, currentYOffset)
            barContainer:SetAlpha(currentAlpha)
            
            if currentAlpha < 0.05 then
                barContainer:Hide()
            else
                barContainer:Show()
            end
        end
    else
        if holderFrame then holderFrame:Hide() end
        if settingsFrame then settingsFrame:Hide() end
        
        if ElvUI_UtilityBarDB.buttonsShown then
            ElvUI_UtilityBarDB.buttonsShown = false
            UpdateArrowState()
            currentAlpha = 0
            currentYOffset = -20
        end
    end
end)

------------------------------------------------------------
-- Init
------------------------------------------------------------
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        InitializeDB()
        self:UnregisterEvent("ADDON_LOADED")
        
    elseif event == "PLAYER_REGEN_DISABLED" then
        if settingsFrame then settingsFrame:Hide() end
        if holderFrame then holderFrame:Hide() end
    end
end)