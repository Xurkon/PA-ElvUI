local _, _, _, enhancedEnabled = GetAddOnInfo and GetAddOnInfo("ElvUI_Enhanced")
if enhancedEnabled then return end

local E, _, _, P = unpack(ElvUI)
local WE = E.WarcraftEnhanced
local mod = E:GetModule("Enhanced_Blizzard")
local LSM = E.Libs.LSM
local L = E.Libs.ACL:GetLocale("ElvUI", true)

local defaultSettings = {
	width = 512,
	height = 60,
	font = "PT Sans Narrow",
	fontSize = 15,
	fontOutline = "NONE"
}

local errorDefaults = P and P.warcraftenhanced and P.warcraftenhanced.blizzard and P.warcraftenhanced.blizzard.errorFrame or {
	enable = false,
	width = 300,
	height = 60,
	font = "PT Sans Narrow",
	fontSize = 12,
	fontOutline = "NONE",
}

local function GetBlizzardDB()
	if mod and mod.db then
		return mod.db
	end

	if not WE then return end

	WE.db = WE.db or {}
	if not WE.db.blizzard then
		WE.db.blizzard = {
			takeAllMail = false,
			errorFrame = E:CopyTable({}, errorDefaults),
		}
	end

	if mod then
		mod.db = WE.db.blizzard
	end

	return WE.db.blizzard
end

local function GetErrorFrameDB()
	local db = GetBlizzardDB()
	if not db then return end

	db.errorFrame = db.errorFrame or E:CopyTable({}, errorDefaults)

	if E.db.enhanced and E.db.enhanced.blizzard and E.db.enhanced.blizzard.errorFrame then
		E:CopyTable(db.errorFrame, E.db.enhanced.blizzard.errorFrame)
		E.db.enhanced.blizzard.errorFrame = nil
	end

	return db.errorFrame
end

function mod:ErrorFrameSize(db)
	db = db or GetErrorFrameDB()
	if not db then return end

	UIErrorsFrame:Size(db.width, db.height)
	UIErrorsFrame:SetFont(LSM:Fetch("font", db.font), db.fontSize, db.fontOutline)

	if not UIErrorsFrame.mover then
		E:CreateMover(UIErrorsFrame, "UIErrorsFrameMover", L["Error Frame"], nil, nil, nil, "ALL,GENERAL", nil, "elvuiPlugins,enhanced,miscGroup,errorFrame")
	end
end

function mod:CustomErrorFrameToggle(forceDisable)
	local db = GetErrorFrameDB()
	if not db then return end

	if db.enable and not forceDisable then
		self:ErrorFrameSize(db)
		if UIErrorsFrame.mover then
			E:EnableMover(UIErrorsFrame.mover:GetName())
		end
	else
		self:ErrorFrameSize(defaultSettings)
		UIErrorsFrame:Point("TOP", 0, -122)

		if UIErrorsFrame.mover then
			E:DisableMover(UIErrorsFrame.mover:GetName())
			UIErrorsFrame.mover:ClearAllPoints()
			UIErrorsFrame.mover:Point("TOP", 0, -122)
		end
	end
end

