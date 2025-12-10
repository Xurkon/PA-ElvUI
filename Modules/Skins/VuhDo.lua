local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")

local _G = _G
local pairs, ipairs = pairs, ipairs

-- VuhDo Integration Module
local VuhDoSkin = {}

function VuhDoSkin:SkinVuhDoPanel(panel)
	if not panel or panel.IsElvUISkinned then return end
	
	-- Apply ElvUI template
	if panel.SetTemplate then
		panel:SetTemplate("Transparent")
	elseif panel.SetBackdrop then
		panel:SetBackdrop(nil)
		panel:CreateBackdrop("Transparent")
		panel.backdrop:SetAllPoints()
	end
	
	panel.IsElvUISkinned = true
end

function VuhDoSkin:SkinVuhDoButton(button)
	if not button or button.IsElvUISkinned then return end
	
	if button.SetTemplate then
		button:SetTemplate("Default")
	end
	
	if button.StyleButton then
		button:StyleButton()
	end
	
	button.IsElvUISkinned = true
end

function VuhDoSkin:SkinVuhDoBar(bar)
	if not bar or bar.IsElvUISkinned then return end
	
	if bar.SetStatusBarTexture then
		bar:SetStatusBarTexture(E.media.normTex)
	end
	
	if bar.CreateBackdrop then
		bar:CreateBackdrop("Transparent")
	end
	
	bar.IsElvUISkinned = true
end

function VuhDoSkin:SkinAllVuhDoPanels()
	-- Skin main panels
	for i = 1, 10 do
		local panel = _G["VuhDoPanel"..i]
		if panel then
			self:SkinVuhDoPanel(panel)
			
			-- Skin panel bars
			if panel.GetChildren then
				for _, child in ipairs({panel:GetChildren()}) do
					if child.GetObjectType and child:GetObjectType() == "StatusBar" then
						self:SkinVuhDoBar(child)
					elseif child.GetObjectType and child:GetObjectType() == "Button" then
						self:SkinVuhDoButton(child)
					end
				end
			end
		end
	end
	
	-- Skin header panels
	for i = 1, 10 do
		local header = _G["VuhDoHeader"..i]
		if header then
			self:SkinVuhDoPanel(header)
		end
	end
	
	-- Skin tooltip
	if VuhDoTooltip then
		VuhDoTooltip:SetTemplate("Transparent")
	end
	
	-- Skin options frames
	if VuhDoNewOptionsMainFrame then
		self:SkinVuhDoPanel(VuhDoNewOptionsMainFrame)
	end
	
	if VuhDoLookAndFeelFrame then
		self:SkinVuhDoPanel(VuhDoLookAndFeelFrame)
	end
end

function VuhDoSkin:Initialize()
	if not E.private.skins.vuhdo then return end
	
	-- Wait for VuhDo to load
	if not IsAddOnLoaded("VuhDo") then
		local frame = CreateFrame("Frame")
		frame:RegisterEvent("ADDON_LOADED")
		frame:SetScript("OnEvent", function(self, event, addon)
			if addon == "VuhDo" then
				VuhDoSkin:SkinAllVuhDoPanels()
				
				-- Hook panel creation to skin new panels
				if VUHDO_lnfSetupFrameAppearance then
					hooksecurefunc("VUHDO_lnfSetupFrameAppearance", function()
						VuhDoSkin:SkinAllVuhDoPanels()
					end)
				end
				
				self:UnregisterEvent("ADDON_LOADED")
			end
		end)
	else
		self:SkinAllVuhDoPanels()
		
		-- Hook panel creation
		if VUHDO_lnfSetupFrameAppearance then
			hooksecurefunc("VUHDO_lnfSetupFrameAppearance", function()
				self:SkinAllVuhDoPanels()
			end)
		end
	end
end

-- Register with ElvUI Skins module
S:AddCallback("VuhDo", function() VuhDoSkin:Initialize() end)

-- Make VuhDoSkin globally accessible
E.VuhDoSkin = VuhDoSkin

