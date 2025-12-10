local E, L, V, P, G = unpack(ElvUI)
local UF = E:GetModule("UnitFrames")

--Lua functions
--WoW API / Variables

local HAPPINESS_TEX_COORDS = {
	[1] = {0.375, 0.5625, 0, 0.359375},
	[2] = {0.1875, 0.375, 0, 0.359375},
	[3] = {0, 0.1875, 0, 0.359375}
}

function UF:Construct_Happiness(frame)
	local HappinessIndicator = CreateFrame("Statusbar", nil, frame)

	HappinessIndicator.backdrop = CreateFrame("Frame", nil, HappinessIndicator)
	UF.statusbars[HappinessIndicator] = true
	HappinessIndicator.backdrop:SetTemplate("Default", nil, nil, self.thinBorders, true)
	HappinessIndicator.backdrop:SetFrameLevel(HappinessIndicator:GetFrameLevel() - 1)
	HappinessIndicator:SetInside(HappinessIndicator.backdrop)
	HappinessIndicator:SetOrientation("VERTICAL")
	HappinessIndicator:SetMinMaxValues(0, 100)
	HappinessIndicator:SetFrameLevel(50)

	HappinessIndicator.bg = HappinessIndicator:CreateTexture(nil, "BORDER")
	HappinessIndicator.bg:SetAllPoints(HappinessIndicator)
	HappinessIndicator.bg:SetTexture(E.media.blankTex)
	HappinessIndicator.bg.multiplier = 0.3

	local iconHolder = CreateFrame("Frame", nil, frame)
	iconHolder:SetFrameLevel(frame:GetFrameLevel() + 5)
	iconHolder:Hide()
	iconHolder:EnableMouse(false)

	local icon = iconHolder:CreateTexture(nil, "ARTWORK")
	icon:SetAllPoints()
	icon:SetTexture("Interface\\PetPaperDollFrame\\UI-PetHappiness")
	icon:SetTexCoord(unpack(HAPPINESS_TEX_COORDS[2]))

	HappinessIndicator.IconHolder = iconHolder
	HappinessIndicator.Icon = icon

	HappinessIndicator.Override = UF.HappinessOverride

	return HappinessIndicator
end

function UF:Configure_Happiness(frame)
	if not frame.VARIABLES_SET then return end

	local HappinessIndicator = frame.HappinessIndicator
	local db = frame.db

	frame.HAPPINESS_WIDTH = HappinessIndicator and frame.HAPPINESS_SHOWN and (db.happiness.width + (frame.BORDER*3)) or 0

	if db.happiness.enable then
		if not frame:IsElementEnabled("HappinessIndicator") then
			frame:EnableElement("HappinessIndicator")
		end

		local iconHolder = HappinessIndicator.IconHolder
		if iconHolder then
			local size = frame.UNIT_HEIGHT or 30
			iconHolder:Size(size, size)
			iconHolder:ClearAllPoints()

			if frame.ORIENTATION == "RIGHT" then
				iconHolder:Point("RIGHT", frame, "LEFT", -(frame.BORDER*2 + frame.SPACING), 0)
			else
				iconHolder:Point("LEFT", frame, "RIGHT", (frame.BORDER*2 + frame.SPACING), 0)
			end
		end

		HappinessIndicator.backdrop:ClearAllPoints()
		if db.power.enable and not frame.USE_MINI_POWERBAR and not frame.USE_INSET_POWERBAR and not frame.POWERBAR_DETACHED and not frame.USE_POWERBAR_OFFSET then
			if frame.ORIENTATION == "RIGHT" then
				HappinessIndicator.backdrop:Point("BOTTOMRIGHT", frame.Power, "BOTTOMLEFT", -frame.BORDER + (frame.BORDER - frame.SPACING*3), -frame.BORDER)
				HappinessIndicator.backdrop:Point("TOPLEFT", frame.Health, "TOPLEFT", -frame.HAPPINESS_WIDTH, frame.BORDER)
			else
				HappinessIndicator.backdrop:Point("BOTTOMLEFT", frame.Power, "BOTTOMRIGHT", frame.BORDER + (-frame.BORDER + frame.SPACING*3), -frame.BORDER)
				HappinessIndicator.backdrop:Point("TOPRIGHT", frame.Health, "TOPRIGHT", frame.HAPPINESS_WIDTH, frame.BORDER)
			end
		else
			if frame.ORIENTATION == "RIGHT" then
				HappinessIndicator.backdrop:Point("BOTTOMRIGHT", frame.Health, "BOTTOMLEFT", -frame.BORDER + (frame.BORDER - frame.SPACING*3), -frame.BORDER)
				HappinessIndicator.backdrop:Point("TOPLEFT", frame.Health, "TOPLEFT", -frame.HAPPINESS_WIDTH, frame.BORDER)
			else
				HappinessIndicator.backdrop:Point("BOTTOMLEFT", frame.Health, "BOTTOMRIGHT", frame.BORDER + (-frame.BORDER + frame.SPACING*3), -frame.BORDER)
				HappinessIndicator.backdrop:Point("TOPRIGHT", frame.Health, "TOPRIGHT", frame.HAPPINESS_WIDTH, frame.BORDER)
			end
		end
	else
		if frame:IsElementEnabled("HappinessIndicator") then
			frame:DisableElement("HappinessIndicator")
		end

		if HappinessIndicator.IconHolder then
			HappinessIndicator.IconHolder:Hide()
		end
		if HappinessIndicator.Icon then
			HappinessIndicator.Icon:Hide()
		end
	end
end

function UF:HappinessOverride(event, unit)
	if not unit or self.unit ~= unit then return end

	local db = self.db
	if not db then return end

	local element = self.HappinessIndicator

	if element.PreUpdate then
		element:PreUpdate()
	end

	local _, hunterPet = HasPetUI()
	local happiness, damagePercentage = GetPetHappiness()
	local value, r, g, b

	if hunterPet and happiness then
		if damagePercentage == 75 then
			value = 33
			r, g, b = 0.8, 0.2, 0.1
		elseif damagePercentage == 100 then
			value = 66
			r, g, b = 1, 1, 0
		elseif damagePercentage == 125 then
			value = 100
			r, g, b = 0, 0.8, 0
		end

		element:SetValue(value)
		element:SetStatusBarColor(r, g, b)
		element.bg:SetVertexColor(r, g, b, 0.15)

		local iconHolder, icon = element.IconHolder, element.Icon
		if icon then
			icon:SetTexture("Interface\\PetPaperDollFrame\\UI-PetHappiness")

			local texCoords = HAPPINESS_TEX_COORDS[happiness]
			if texCoords then
				icon:SetTexCoord(unpack(texCoords))
			end
		end

		local shouldHide = (damagePercentage == 125 and db.happiness.autoHide)

		if shouldHide then
			element:Hide()
			if iconHolder then
				iconHolder:Hide()
			elseif icon then
				icon:Hide()
			end
		else
			element:Show()
			if iconHolder then
				iconHolder:Show()
			elseif icon then
				icon:Show()
			end
		end
	else
		if element.IconHolder then
			element.IconHolder:Hide()
		end
		if element.Icon then
			element.Icon:Hide()
		end

		return element:Hide()
	end

	local isShown = element:IsShown()
	local stateChanged

	if (self.HAPPINESS_SHOWN and not isShown) or (not self.HAPPINESS_SHOWN and isShown) then
		stateChanged = true
	end

	self.HAPPINESS_SHOWN = isShown

	if stateChanged then
		UF:Configure_Happiness(self)
		UF:Configure_HealthBar(self)
		UF:Configure_Power(self)
		UF:Configure_InfoPanel(self, true)
	end

	if element.PostUpdate then
		return element:PostUpdate(unit, happiness, damagePercentage)
	end
end