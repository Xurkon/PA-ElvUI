local E, L, V, P, G = unpack(select(2, ...)) --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule("Skins")
local TT = E:GetModule("Tooltip")

--Lua functions
--WoW API / Variables

S:AddCallback("Skin_Tooltip", function()
	if not E.private.skins.blizzard.enable or not E.private.skins.blizzard.tooltip then return end

	S:HandleCloseButton(ItemRefCloseButton, ItemRefTooltip)

	local tooltips = {
		GameTooltip,
		ItemRefTooltip,
		ItemRefShoppingTooltip1,
		ItemRefShoppingTooltip2,
		ItemRefShoppingTooltip3,
		AutoCompleteBox,
		FriendsTooltip,
		ConsolidatedBuffsTooltip,
		ShoppingTooltip1,
		ShoppingTooltip2,
		ShoppingTooltip3,
		WorldMapTooltip,
		WorldMapCompareTooltip1,
		WorldMapCompareTooltip2,
		WorldMapCompareTooltip3
	}
	if VanityBuffsTooltip then
		table.insert(tooltips, VanityBuffsTooltip)
	end
	for _, tt in ipairs(tooltips) do
		if TT.SetStyle then
			TT:SecureHookScript(tt, "OnShow", "SetStyle")
		end
	end

	GameTooltipStatusBar:SetStatusBarTexture(E.media.normTex)
	E:RegisterStatusBar(GameTooltipStatusBar)
	GameTooltipStatusBar:CreateBackdrop("Transparent")
	GameTooltipStatusBar:ClearAllPoints()
	GameTooltipStatusBar:Point("TOPLEFT", GameTooltip, "BOTTOMLEFT", E.Border, -(E.Spacing * 3))
	GameTooltipStatusBar:Point("TOPRIGHT", GameTooltip, "BOTTOMRIGHT", -E.Border, -(E.Spacing * 3))

	if TT.GameTooltip_ShowStatusBar then
		TT:SecureHook("GameTooltip_ShowStatusBar", "GameTooltip_ShowStatusBar")
	end

	if TT.CheckBackdropColor then
		TT:SecureHookScript(GameTooltip, "OnSizeChanged", "CheckBackdropColor")
		TT:SecureHookScript(GameTooltip, "OnUpdate", "CheckBackdropColor")
	end
end)