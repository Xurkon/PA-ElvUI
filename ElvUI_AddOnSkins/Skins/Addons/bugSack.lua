local E, L, V, P, G = unpack(ElvUI)
local S = E:GetModule("Skins")
local AS = E:GetModule("AddOnSkins")

if not AS:IsAddonLODorEnabled("BugSack") then return end

-- BugSack r229
-- https://www.curseforge.com/wow/addons/bugsack/files/448833

-- Event name uses "_Skin" suffix to avoid duplicate registration errors
S:AddCallbackForAddon("BugSack", "BugSack_Skin", function()
	if not E.private.addOnSkins.BugSack then return end

	if not S:IsHooked(BugSack, "OpenSack") then
		S:SecureHook(BugSack, "OpenSack", function()
		BugSackFrame:StripTextures()
		BugSackFrame:SetTemplate("Transparent")

		for _, child in ipairs({BugSackFrame:GetChildren()}) do
			if child:IsObjectType("Button") and child:GetScript("OnClick") == BugSack.CloseSack then
				S:HandleCloseButton(child)
			end
		end

		S:HandleButton(BugSackNextButton)
		S:HandleButton(BugSackPrevButton)

		if BugSack.Serialize then
			S:HandleButton(BugSackSendButton)
			BugSackSendButton:Point("LEFT", BugSackPrevButton, "RIGHT", E.PixelMode and 1 or 3, 0)
			BugSackSendButton:Point("RIGHT", BugSackNextButton, "LEFT", -(E.PixelMode and 1 or 3), 0)
		end

		local scrollBar = BugSackScrollScrollBar or BugSackFrameScrollScrollBar
		S:HandleScrollBar(scrollBar)

		BugSackTabAll:Point("TOPLEFT", BugSackFrame, "BOTTOMLEFT", 0, 2)
		S:HandleTab(BugSackTabAll)
		S:HandleTab(BugSackTabSession)
		S:HandleTab(BugSackTabLast)

		S:Unhook(BugSack, "OpenSack")
	end)
	end
end)