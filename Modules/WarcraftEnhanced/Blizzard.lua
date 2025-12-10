local _, _, _, enhancedEnabled = GetAddOnInfo and GetAddOnInfo("ElvUI_Enhanced")
if enhancedEnabled then return end

local E, _, _, P = unpack(ElvUI)
local WE = E.WarcraftEnhanced
local mod = E:NewModule("Enhanced_Blizzard", "AceEvent-3.0")

local defaults = P and P.warcraftenhanced and P.warcraftenhanced.blizzard

function mod:PLAYER_ENTERING_WORLD()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:CustomErrorFrameToggle()
end

local function EnsureBlizzardDB()
	if not WE then return end

	WE.db = WE.db or {}

	if not WE.db.blizzard then
		WE.db.blizzard = E:CopyTable({}, defaults or {})
	end

	local db = WE.db.blizzard

	if db.takeAllMail == nil then
		db.takeAllMail = defaults and defaults.takeAllMail or false
	end

	local errorDefaults = defaults and defaults.errorFrame or {
		enable = false,
		width = 300,
		height = 60,
		font = "PT Sans Narrow",
		fontSize = 12,
		fontOutline = "NONE",
	}

	db.errorFrame = db.errorFrame or E:CopyTable({}, errorDefaults)

	return db
end

local function MigrateLegacyBlizzardDB()
	if not E.db.enhanced or not E.db.enhanced.blizzard then return end

	local legacy = E.db.enhanced.blizzard
	local db = EnsureBlizzardDB()
	if not db then return end

	if legacy.takeAllMail ~= nil then
		db.takeAllMail = legacy.takeAllMail
	end

	if legacy.errorFrame then
		db.errorFrame = db.errorFrame or {}
		E:CopyTable(db.errorFrame, legacy.errorFrame)
	end

	E.db.enhanced.blizzard = nil
end

function mod:Initialize()
	MigrateLegacyBlizzardDB()

	local db = EnsureBlizzardDB()
	if not db then return end

	self.db = db

	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	if db.takeAllMail then
		local TAM = E:GetModule("Enhanced_TakeAllMail", true)
		if TAM and not TAM.initialized then
			TAM:Initialize()
		end
	end

	self.initialized = true
end

local function InitializeCallback()
	mod:Initialize()
end

E:RegisterModule(mod:GetName(), InitializeCallback)

