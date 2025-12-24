local E, L, V, P, G = unpack(ElvUI);
local RM = E:NewModule("RaidMarkersBar")

local ipairs = ipairs;
local format = string.format;

local UnregisterStateDriver = UnregisterStateDriver;
local RegisterStateDriver = RegisterStateDriver;

-- Profile
P.actionbar = P.actionbar or {}
P.actionbar.raidmarkersbar = {
	["visible"] = "AUTOMATIC",
	["orient"] = "HORIZONTAL",
	["sort"] = "DESCENDING",
	["buttonSize"] = 18,
	["buttonSpacing"] = 5
}

-- Options are now defined in ElvUI_OptionsUI/ActionBars.lua

function RM:UpdateBar(first)
	if(first) then
		self.frame:ClearAllPoints()
		self.frame:Point("CENTER")
	end
	
	if(self.db.orient == "VERTICAL") then
		self.frame:Height((self.db.buttonSize + self.db.buttonSpacing) * 9 + self.db.buttonSpacing);
		self.frame:Width(self.db.buttonSize + (self.db.buttonSpacing*2));
	else
		self.frame:Width((self.db.buttonSize + self.db.buttonSpacing) * 9 + self.db.buttonSpacing);
		self.frame:Height(self.db.buttonSize + (self.db.buttonSpacing*2));
	end

	for i = 1, 9 do
		local button = self.frame.buttons[i]
		local prev = self.frame.buttons[i - 1]
		button:Size(self.db.buttonSize);
		button:ClearAllPoints()

		if(self.db.orient == "HORIZONTAL" and self.db.sort == "ASCENDING") then
			if(i == 1) then
				button:Point("LEFT", self.db.buttonSpacing, 0);
			elseif(prev) then
				button:Point("LEFT", prev, "RIGHT", self.db.buttonSpacing, 0);
			end
		elseif(self.db.orient == "VERTICAL" and self.db.sort == "ASCENDING") then
			if(i == 1) then
				button:Point("TOP", 0, -self.db.buttonSpacing);
			elseif(prev) then
				button:Point("TOP", prev, "BOTTOM", 0, -self.db.buttonSpacing);
			end
		elseif(self.db.orient == "HORIZONTAL" and self.db.sort == "DESCENDING") then
			if(i == 1) then
				button:Point("RIGHT", -self.db.buttonSpacing, 0);
			elseif prev then
				button:Point("RIGHT", prev, "LEFT", -self.db.buttonSpacing, 0);
			end
		else
			if(i == 1) then
				button:Point("BOTTOM", 0, self.db.buttonSpacing, 0);
			elseif(prev) then
				button:Point("BOTTOM", prev, "TOP", 0, self.db.buttonSpacing);
			end
		end
	end

	if(self.db.visible == "HIDE") then
		UnregisterStateDriver(self.frame, "visibility")
		if(self.frame:IsShown()) then
			self.frame:Hide()
		end
	elseif(self.db.visible == "SHOW") then
		UnregisterStateDriver(self.frame, "visibility")
		if(not self.frame:IsShown()) then
			self.frame:Show()
		end
	else
		RegisterStateDriver(self.frame, "visibility", "[noexists,nogroup] hide; show")
	end
end

function RM:ButtonFactory()
	for i = 1, 9 do
		local button = CreateFrame("Button", ("ElvUI_RaidMarkersBarButton%d"):format(i), self.frame, "SecureActionButtonTemplate")
		button:SetTemplate("Default", true)

		local image = button:CreateTexture(nil, "OVERLAY")
		image:SetInside()
		image:SetTexture(i == 9 and "Interface\\BUTTONS\\UI-GroupLoot-Pass-Up" or ("Interface\\TargetingFrame\\UI-RaidTargetingIcon_%d"):format(i))

		button:SetAttribute("type1", "macro")
		button:SetAttribute("macrotext1", ("/run SetRaidTargetIcon(\"target\", %d)"):format(i < 9 and i or 0))

		button:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
			GameTooltip:AddLine(i == 9 and L["Click to clear the mark."] or L["Click to mark the target."], 1, 1, 1)
			GameTooltip:Show()
		end)
		button:SetScript("OnLeave", function() GameTooltip:Hide() end)

		button:StyleButton()
		button:RegisterForClicks("AnyDown")
		self.frame.buttons[i] = button
	end
end

function RM:Initialize()
	self.db = E.db.actionbar.raidmarkersbar

	self.frame = CreateFrame("Frame", "ElvUI_RaidMarkersBar", E.UIParent, "SecureHandlerStateTemplate")
	self.frame:SetResizable(false)
	self.frame:SetClampedToScreen(true)
	self.frame:SetTemplate("Transparent")

	self.frame.buttons = {}
	self:ButtonFactory()
	self:UpdateBar(true)

	E:CreateMover(self.frame, "ElvUI_RMBarMover", L["Raid Markers Bar"])
end

E:RegisterModule(RM:GetName())