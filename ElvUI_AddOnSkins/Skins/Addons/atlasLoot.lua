local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")
local AS = E:GetModule("AddOnSkins")

if not AS:IsAddonLODorEnabled("AtlasLoot") then return end

local select = select
local unpack = unpack

-- AtlasLoot Enhanced 5.11.04
-- https://www.curseforge.com/wow/addons/atlasloot-enhanced/files/445202

-- Event name uses "_Skin" suffix to avoid duplicate registration errors
S:AddCallbackForAddon("AtlasLoot", "AtlasLoot_Skin", function()
	if not E.private.addOnSkins.AtlasLoot then return end

	if AtlasLootTooltip then
		AtlasLootTooltip:HookScript("OnShow", function(self)
			self:SetTemplate("Transparent", nil, true)

			local r, g, b = self:GetBackdropColor()
			self:SetBackdropColor(r, g, b, E.db.tooltip.colorAlpha)

			local iLink = select(2, self:GetItem())
			local quality = iLink and select(3, GetItemInfo(iLink))
			if quality and quality >= 2 then
				self:SetBackdropBorderColor(GetItemQualityColor(quality))
			else
				self:SetBackdropBorderColor(unpack(E.media.bordercolor))
			end
		end)
	end

	if not AtlasLootDefaultFrame then return end
	
	AtlasLootDefaultFrame:StripTextures()
	AtlasLootDefaultFrame:SetTemplate("Transparent")

	S:HandleCloseButton(AtlasLootDefaultFrame_CloseButton, AtlasLootDefaultFrame)

	if AtlasLootDefaultFrame_Options then S:HandleButton(AtlasLootDefaultFrame_Options) end
	if AtlasLootDefaultFrame_LoadModules then S:HandleButton(AtlasLootDefaultFrame_LoadModules) end
	if AtlasLootDefaultFrame_Menu then S:HandleButton(AtlasLootDefaultFrame_Menu) end
	if AtlasLootDefaultFrame_SubMenu then S:HandleButton(AtlasLootDefaultFrame_SubMenu) end

	if AtlasLootDefaultFrame_LootBackground_Back then
		AtlasLootDefaultFrame_LootBackground_Back:SetTexture()
	end
	if AtlasLootDefaultFrame_LootBackground then
		AtlasLootDefaultFrame_LootBackground:SetTemplate("Transparent")
	end

	if AtlasLootDefaultFrame_Preset1 then S:HandleButton(AtlasLootDefaultFrame_Preset1) end
	if AtlasLootDefaultFrame_Preset2 then S:HandleButton(AtlasLootDefaultFrame_Preset2) end
	if AtlasLootDefaultFrame_Preset3 then S:HandleButton(AtlasLootDefaultFrame_Preset3) end
	if AtlasLootDefaultFrame_Preset4 then S:HandleButton(AtlasLootDefaultFrame_Preset4) end

	if AtlasLootDefaultFrameWishListButton then S:HandleButton(AtlasLootDefaultFrameWishListButton) end
	if AtlasLootDefaultFrameSearchBox then S:HandleEditBox(AtlasLootDefaultFrameSearchBox) end
	if AtlasLootDefaultFrameSearchButton then S:HandleButton(AtlasLootDefaultFrameSearchButton) end
	if AtlasLootDefaultFrameSearchOptionsButton then S:HandleNextPrevButton(AtlasLootDefaultFrameSearchOptionsButton) end
	if AtlasLootDefaultFrameSearchClearButton then S:HandleButton(AtlasLootDefaultFrameSearchClearButton) end
	if AtlasLootDefaultFrameLastResultButton then S:HandleButton(AtlasLootDefaultFrameLastResultButton) end

	if AtlasLootDefaultFrame_Options then
		AtlasLootDefaultFrame_Options:Point("TOPLEFT", 43, -11)
	end
	if AtlasLootDefaultFrame_LoadModules then
		AtlasLootDefaultFrame_LoadModules:Point("TOPRIGHT", -42, -11)
	end

	if AtlasLootDefaultFrame_Preset1 then
		AtlasLootDefaultFrame_Preset1:Point("BOTTOMLEFT", 83, 59)
	end

	if AtlasLootDefaultFrameSearchBox then
		AtlasLootDefaultFrameSearchBox:Height(22)
		AtlasLootDefaultFrameSearchBox:Point("BOTTOM", AtlasLootDefaultFrame, "BOTTOM", -83, 29)
	end

	if AtlasLootDefaultFrameSearchButton and AtlasLootDefaultFrameSearchBox then
		AtlasLootDefaultFrameSearchButton:Point("LEFT", AtlasLootDefaultFrameSearchBox, "RIGHT", 6, 0)
	end

	if AtlasLootDefaultFrameSearchOptionsButton and AtlasLootDefaultFrameSearchButton then
		AtlasLootDefaultFrameSearchOptionsButton:Size(24)
		AtlasLootDefaultFrameSearchOptionsButton:Point("LEFT", AtlasLootDefaultFrameSearchButton, "RIGHT", 5, 0)
	end
	if AtlasLootDefaultFrameSearchClearButton and AtlasLootDefaultFrameSearchOptionsButton then
		AtlasLootDefaultFrameSearchClearButton:Point("LEFT", AtlasLootDefaultFrameSearchOptionsButton, "RIGHT", 5, 0)
	end
	if AtlasLootDefaultFrameLastResultButton and AtlasLootDefaultFrameSearchClearButton then
		AtlasLootDefaultFrameLastResultButton:Point("LEFT", AtlasLootDefaultFrameSearchClearButton, "RIGHT", 5, 0)
	end
	if AtlasLootDefaultFrameWishListButton and AtlasLootDefaultFrameSearchBox then
		AtlasLootDefaultFrameWishListButton:Point("RIGHT", AtlasLootDefaultFrameSearchBox, "LEFT", -6, 0)
	end

	if AtlasLootDefaultFrame_Notice then
		AtlasLootDefaultFrame_Notice:Point("BOTTOM", 0, 9)
	end

	if AtlasLootItemsFrame_CloseButton then S:HandleCloseButton(AtlasLootItemsFrame_CloseButton) end
	if AtlasLootInfoHidePanel then S:HandleButton(AtlasLootInfoHidePanel) end

	for i = 1, 30 do
		if _G["AtlasLootItem_" .. i .. "_Icon"] then
			_G["AtlasLootItem_" .. i .. "_Icon"]:SetTexCoord(unpack(E.TexCoords))
			_G["AtlasLootItem_" .. i]:CreateBackdrop("Default")
			_G["AtlasLootItem_" .. i].backdrop:SetOutside(_G["AtlasLootItem_" .. i .. "_Icon"])
		end

		if _G["AtlasLootMenuItem_" .. i .. "_Icon"] then
			_G["AtlasLootMenuItem_" .. i .. "_Icon"]:SetTexCoord(unpack(E.TexCoords))
			_G["AtlasLootMenuItem_" .. i]:CreateBackdrop("Default")
			_G["AtlasLootMenuItem_" .. i].backdrop:SetOutside(_G["AtlasLootMenuItem_" .. i .. "_Icon"])
		end
	end

	if AtlasLoot10Man25ManSwitch then
		S:HandleButton(AtlasLoot10Man25ManSwitch)
		AtlasLoot10Man25ManSwitch:Height(24)
		AtlasLoot10Man25ManSwitch:Point("BOTTOM", -130, 3)
	end

	if AtlasLootServerQueryButton then
		S:HandleButton(AtlasLootServerQueryButton)
		AtlasLootServerQueryButton:Height(24)
		AtlasLootServerQueryButton:Point("BOTTOM", 131, 3)
	end

	if AtlasLootItemsFrame_Heroic then
		S:HandleCheckBox(AtlasLootItemsFrame_Heroic)
		AtlasLootItemsFrame_Heroic:Point("BOTTOM", -185, 28)
	end
	
	if AtlasLootFilterCheck then
		S:HandleCheckBox(AtlasLootFilterCheck)
		AtlasLootFilterCheck:Point("BOTTOM", 115, 28)
	end

	if AtlasLootItemsFrame_BACK then
		S:HandleButton(AtlasLootItemsFrame_BACK)
		AtlasLootItemsFrame_BACK:Height(24)
		AtlasLootItemsFrame_BACK:Point("BOTTOM", 0, 3)
	end
	
	if AtlasLootQuickLooksButton then
		S:HandleNextPrevButton(AtlasLootQuickLooksButton)
		AtlasLootQuickLooksButton:Point("BOTTOM", 58, 32)
	end
	
	if AtlasLootItemsFrame_PREV then
		S:HandleNextPrevButton(AtlasLootItemsFrame_PREV)
		AtlasLootItemsFrame_PREV:Point("BOTTOMLEFT", 7, 6)
	end
	
	if AtlasLootItemsFrame_NEXT then
		S:HandleNextPrevButton(AtlasLootItemsFrame_NEXT)
		AtlasLootItemsFrame_NEXT:Point("BOTTOMRIGHT", -6, 6)
	end

	if AtlasLootItemsFrame_Back then AtlasLootItemsFrame_Back:SetTexture() end

	if AtlasLootOptionsFrameDefaultTT then S:HandleCheckBox(AtlasLootOptionsFrameDefaultTT) end
	if AtlasLootOptionsFrameLootlinkTT then S:HandleCheckBox(AtlasLootOptionsFrameLootlinkTT) end
	if AtlasLootOptionsFrameItemSyncTT then S:HandleCheckBox(AtlasLootOptionsFrameItemSyncTT) end
	if AtlasLootOptionsFrameOpaque then S:HandleCheckBox(AtlasLootOptionsFrameOpaque) end
	if AtlasLootOptionsFrameItemID then S:HandleCheckBox(AtlasLootOptionsFrameItemID) end
	if AtlasLootOptionsFrameLoDStartup then S:HandleCheckBox(AtlasLootOptionsFrameLoDStartup) end
	if AtlasLootOptionsFrameSafeLinks then S:HandleCheckBox(AtlasLootOptionsFrameSafeLinks) end
	if AtlasLootOptionsFrameEquipCompare then S:HandleCheckBox(AtlasLootOptionsFrameEquipCompare) end
	if AtlasLootOptionsFrameItemSpam then S:HandleCheckBox(AtlasLootOptionsFrameItemSpam) end
	if AtlasLootOptionsFrameHidePanel then S:HandleCheckBox(AtlasLootOptionsFrameHidePanel) end

	if AtlasLoot_SelectLootBrowserStyle then S:HandleDropDownBox(AtlasLoot_SelectLootBrowserStyle) end
	if AtlasLoot_CraftingLink then S:HandleDropDownBox(AtlasLoot_CraftingLink) end

	if AtlasLootOptionsFrameLootBrowserScale then S:HandleSliderFrame(AtlasLootOptionsFrameLootBrowserScale) end

	if AtlasLootOptionsFrame_ResetWishlist then S:HandleButton(AtlasLootOptionsFrame_ResetWishlist) end
	if AtlasLootOptionsFrame_ResetAtlasLoot then S:HandleButton(AtlasLootOptionsFrame_ResetAtlasLoot) end
	if AtlasLootOptionsFrame_ResetQuicklooks then S:HandleButton(AtlasLootOptionsFrame_ResetQuicklooks) end
	if AtlasLootOptionsFrame_FuBarShow then S:HandleButton(AtlasLootOptionsFrame_FuBarShow) end
	if AtlasLootOptionsFrame_FuBarHide then S:HandleButton(AtlasLootOptionsFrame_FuBarHide) end

	if AtlasLootPanel then
		AtlasLootPanel:StripTextures()
		AtlasLootPanel:SetTemplate("Transparent")
	
		if AtlasLootPanel_WorldEvents then
			S:HandleButton(AtlasLootPanel_WorldEvents)
			AtlasLootPanel_WorldEvents:Point("LEFT", AtlasLootPanel, "LEFT", 7, 29)
		end
		if AtlasLootPanel_Sets then
			S:HandleButton(AtlasLootPanel_Sets)
			AtlasLootPanel_Sets:Point("LEFT", AtlasLootPanel_WorldEvents, "RIGHT", 2, 0)
		end
		if AtlasLootPanel_Reputation then
			S:HandleButton(AtlasLootPanel_Reputation)
			AtlasLootPanel_Reputation:Point("LEFT", AtlasLootPanel_Sets, "RIGHT", 2, 0)
		end
		if AtlasLootPanel_PvP then
			S:HandleButton(AtlasLootPanel_PvP)
			AtlasLootPanel_PvP:Point("LEFT", AtlasLootPanel_Reputation, "RIGHT", 2, 0)
		end
		if AtlasLootPanel_Crafting then
			S:HandleButton(AtlasLootPanel_Crafting)
			AtlasLootPanel_Crafting:Point("LEFT", AtlasLootPanel_PvP, "RIGHT", 2, 0)
		end
		if AtlasLootPanel_WishList then
			S:HandleButton(AtlasLootPanel_WishList)
			AtlasLootPanel_WishList:Point("LEFT", AtlasLootPanel_Crafting, "RIGHT", 2, 0)
		end
		
		if AtlasLootPanel_Options then S:HandleButton(AtlasLootPanel_Options) end
		if AtlasLootPanel_LoadModules then S:HandleButton(AtlasLootPanel_LoadModules) end
		if AtlasLootPanel_Preset1 then S:HandleButton(AtlasLootPanel_Preset1) end
		if AtlasLootPanel_Preset2 then S:HandleButton(AtlasLootPanel_Preset2) end
		if AtlasLootPanel_Preset3 then S:HandleButton(AtlasLootPanel_Preset3) end
		if AtlasLootPanel_Preset4 then S:HandleButton(AtlasLootPanel_Preset4) end
	end

	if AtlasLootSearchBox then
		S:HandleEditBox(AtlasLootSearchBox)
		AtlasLootSearchBox:Height(20)
	end
	
	if AtlasLootSearchButton then
		S:HandleButton(AtlasLootSearchButton)
		AtlasLootSearchButton:Height(22)
		if AtlasLootSearchBox then AtlasLootSearchButton:Point("LEFT", AtlasLootSearchBox, "RIGHT", 3, 0) end
	end
	
	if AtlasLootSearchOptionsButton then
		S:HandleNextPrevButton(AtlasLootSearchOptionsButton)
		if AtlasLootSearchButton then AtlasLootSearchOptionsButton:Point("LEFT", AtlasLootSearchButton, "RIGHT", 2, 0) end
	end
	
	if AtlasLootSearchClearButton then
		S:HandleButton(AtlasLootSearchClearButton)
		AtlasLootSearchClearButton:Height(22)
		if AtlasLootSearchOptionsButton then AtlasLootSearchClearButton:Point("LEFT", AtlasLootSearchOptionsButton, "RIGHT", 2, 0) end
	end
	
	if AtlasLootLastResultButton then
		S:HandleButton(AtlasLootLastResultButton)
		AtlasLootLastResultButton:Height(22)
		if AtlasLootSearchClearButton then AtlasLootLastResultButton:Point("LEFT", AtlasLootSearchClearButton, "RIGHT", 2, 0) end
	end

	if AS:IsAddonEnabled("Atlas") then
		hooksecurefunc("AtlasLoot_SetupForAtlas", function()
			AtlasLootInfo:Point("TOPLEFT", 546, 15)
			AtlasLootPanel:Point("TOP", "AtlasFrame", "BOTTOM", 0, 1)
		end)

		hooksecurefunc("AtlasLoot_SetItemInfoFrame", function(pFrame)
			if not pFrame or pFrame == AtlasFrame then
				AtlasLootItemsFrame:Point("TOPLEFT", 15, -74)
			end
		end)
	end

	AS:SkinLibrary("Dewdrop-2.0")
end)

S:AddCallbackForAddon("AtlasLootFu", "AtlasLootFu", function()
	AS:SkinLibrary("AceAddon-2.0")
	AS:SkinLibrary("Tablet-2.0")
end)