local function EnsureWarcraftEnhancedBlizzardDB()
	E.db.warcraftenhanced = E.db.warcraftenhanced or {}

	local defaults = (P.warcraftenhanced and P.warcraftenhanced.blizzard) or {}
	local db = E.db.warcraftenhanced.blizzard
	if not db then
		db = E:CopyTable({}, defaults)
		E.db.warcraftenhanced.blizzard = db
	end

	if db.takeAllMail == nil then
		db.takeAllMail = defaults.takeAllMail or false
	end

	if db.mailRecipientHistory == nil then
		db.mailRecipientHistory = defaults.mailRecipientHistory or false
	end

	local errorDefaults = defaults.errorFrame or {
		enable = false,
		width = 300,
		height = 60,
		font = "PT Sans Narrow",
		fontSize = 12,
		fontOutline = "NONE",
	}

	db.errorFrame = db.errorFrame or E:CopyTable({}, errorDefaults)

	if E.db.enhanced and E.db.enhanced.blizzard then
		local legacy = E.db.enhanced.blizzard
		if legacy.takeAllMail ~= nil then
			db.takeAllMail = legacy.takeAllMail
			legacy.takeAllMail = nil
		end
		if legacy.mailRecipientHistory ~= nil then
			db.mailRecipientHistory = legacy.mailRecipientHistory
			legacy.mailRecipientHistory = nil
		end
		if legacy.errorFrame then
			E:CopyTable(db.errorFrame, legacy.errorFrame)
			legacy.errorFrame = nil
		end
		if not next(legacy) then
			E.db.enhanced.blizzard = nil
		end
	end

	return db
end
local E, _, V, P, G = unpack(ElvUI)
local C, L = unpack(select(2, ...))
local LSM = E.Libs.LSM

local function EnsureEnhancedDB()
	E.db.enhanced = E.db.enhanced or {}
	E.db.enhanced.actionbar = E.db.enhanced.actionbar or {}
	E.db.enhanced.actionbar.keyPressAnimation = E.db.enhanced.actionbar.keyPressAnimation or {}
	local kpa = E.db.enhanced.actionbar.keyPressAnimation
	if not kpa.color then kpa.color = {r = 1, g = 1, b = 1} end
	if kpa.scale == nil then kpa.scale = 1.5 end
	if kpa.rotation == nil then kpa.rotation = 90 end

	return {
		keyPress = kpa
	}
end

local function GetKeyPressModule()
	return E:GetModule("Enhanced_KeyPressAnimation", true)
end

local function GetBlizzardModule()
	return E:GetModule("Enhanced_Blizzard", true)
end

local function GetTakeAllMailModule()
	return E:GetModule("Enhanced_TakeAllMail", true)
end

local function GetTooltipIconModule()
	return E:GetModule("Enhanced_TooltipIcon", true)
end

local function GetItemBorderModule()
	return E:GetModule("Enhanced_ItemBorderColor", true)
end

local function GetProgressionModule()
	return E:GetModule("Enhanced_ProgressionInfo", true)
end

local function EnsureProgressionDB()
	E.db.warcraftenhanced = E.db.warcraftenhanced or {}
	local db = E.db.warcraftenhanced.progression
	if not db then
		db = E:CopyTable({}, P.warcraftenhanced.progression)
		E.db.warcraftenhanced.progression = db
	end

	db.tiers = db.tiers or {}

	return db
end

local function ApplyProgressionSettings()
	local db = EnsureProgressionDB()
	local module = GetProgressionModule()
	if not module then return end

	if db.enable then
		if not module.initialized then
			module:Initialize()
		else
			module:ToggleState()
		end
	elseif module.initialized then
		module:ToggleState()
	end
end

local function EnsureUIEnhancementsDB()
	E.db.warcraftenhanced = E.db.warcraftenhanced or {}

	local defaults = (P.warcraftenhanced and P.warcraftenhanced.uiEnhancements) or {}
	local db = E.db.warcraftenhanced.uiEnhancements
	if not db then
		db = E:CopyTable({}, defaults)
		E.db.warcraftenhanced.uiEnhancements = db
	end

	db.errorFilters = db.errorFilters or {}
	if db.itemBorderColor == nil then
		db.itemBorderColor = defaults.itemBorderColor or false
	end

	return db
end

local function EnsureTooltipIconDB()
	local parent = EnsureUIEnhancementsDB()

	local defaultChild = (P.warcraftenhanced and P.warcraftenhanced.uiEnhancements and P.warcraftenhanced.uiEnhancements.tooltipIcon) or {
		enable = false,
		tooltipIconItems = true,
		tooltipIconSpells = true,
		tooltipIconAchievements = true
	}

	parent.tooltipIcon = parent.tooltipIcon or E:CopyTable({}, defaultChild)

	return parent.tooltipIcon
end

local function EnsureWarcraftEnhancedBlizzardDB()
	E.db.warcraftenhanced = E.db.warcraftenhanced or {}

	local defaults = (P.warcraftenhanced and P.warcraftenhanced.blizzard) or {}
	local db = E.db.warcraftenhanced.blizzard
	if not db then
		db = E:CopyTable({}, defaults)
		E.db.warcraftenhanced.blizzard = db
	end

	if db.takeAllMail == nil then
		db.takeAllMail = defaults.takeAllMail or false
	end

	local errorDefaults = defaults.errorFrame or {
		enable = false,
		width = 300,
		height = 60,
		font = "PT Sans Narrow",
		fontSize = 12,
		fontOutline = "NONE",
	}

	db.errorFrame = db.errorFrame or E:CopyTable({}, errorDefaults)

	if E.db.enhanced and E.db.enhanced.blizzard then
		local legacy = E.db.enhanced.blizzard
		if legacy.takeAllMail ~= nil then
			db.takeAllMail = legacy.takeAllMail
			legacy.takeAllMail = nil
		end
		if legacy.errorFrame then
			E:CopyTable(db.errorFrame, legacy.errorFrame)
			legacy.errorFrame = nil
		end
		if not next(legacy) then
			E.db.enhanced.blizzard = nil
		end
	end

	return db
end

local function EnsureErrorFrameDB()
	return EnsureWarcraftEnhancedBlizzardDB().errorFrame
end

local function ApplyErrorFrameDimensions()
	local module = GetBlizzardModule()
	if module and module.initialized then
		module:ErrorFrameSize()
	end
end

local function ToggleErrorFrame()
	local module = GetBlizzardModule()
	if module and module.initialized then
		module:CustomErrorFrameToggle()
	end
end

local function ApplyTooltipIconSettings()
	local module = GetTooltipIconModule()
	if not module then return end

	if EnsureTooltipIconDB().enable then
		if not module.initialized then
			module:Initialize()
		else
			module:ToggleItemsState()
			module:ToggleSpellsState()
			module:ToggleAchievementsState()
		end
	else
		module:ToggleItemsState()
		module:ToggleSpellsState()
		module:ToggleAchievementsState()
	end
end

local function UpdateProgressionModifier()
	local module = GetProgressionModule()
	if module and module.initialized then
		module:UpdateModifier()
	end
end

local function EnhancedConfig()
	if E.Options.args.enhanced then return end

	E.Options.args.enhanced = {
		order = 75,
		type = "group",
		name = L["Enhanced"],
		childGroups = "tab",
		args = {
			actionbar = {
				order = 1,
				type = "group",
				name = L["ActionBars"],
				args = {
					header = {
						order = 0,
						type = "header",
						name = L["ActionBars"]
					},
					keyPress = {
						order = 1,
						type = "group",
						name = L["Key Press Animation"],
						guiInline = true,
						args = {
							enable = {
								order = 1,
								type = "toggle",
								name = L["Enable"],
								get = function()
									E.private.enhanced = E.private.enhanced or {}
									E.private.enhanced.actionbar = E.private.enhanced.actionbar or {}
									return E.private.enhanced.actionbar.keyPressAnimation
								end,
								set = function(_, value)
									E.private.enhanced.actionbar.keyPressAnimation = value
									E:StaticPopup_Show("PRIVATE_RL")
								end
							},
							color = {
								order = 2,
								type = "color",
								name = L["COLOR"],
								get = function()
									local data = EnsureEnhancedDB()
									local t = data.keyPress.color
									return t.r, t.g, t.b
								end,
								set = function(_, r, g, b)
									local data = EnsureEnhancedDB()
									local keyPress = data.keyPress
									keyPress.color.r, keyPress.color.g, keyPress.color.b = r, g, b

									local module = GetKeyPressModule()
									if module and module.initialized then
										module:UpdateSetting()
									end
								end,
								disabled = function() return not E.private.enhanced.actionbar.keyPressAnimation end
							},
							scale = {
								order = 3,
								type = "range",
								name = L["Scale"],
								min = 1, max = 3, step = 0.1,
								get = function()
									local data = EnsureEnhancedDB()
									return data.keyPress.scale
								end,
								set = function(_, value)
									local data = EnsureEnhancedDB()
									data.keyPress.scale = value
									local module = GetKeyPressModule()
									if module and module.initialized then
										module:UpdateSetting()
									end
								end,
								disabled = function() return not E.private.enhanced.actionbar.keyPressAnimation end
							},
							rotation = {
								order = 4,
								type = "range",
								name = L["Rotation"],
								min = 0, max = 360, step = 1,
								get = function()
									local data = EnsureEnhancedDB()
									return data.keyPress.rotation
								end,
								set = function(_, value)
									local data = EnsureEnhancedDB()
									data.keyPress.rotation = value
									local module = GetKeyPressModule()
									if module and module.initialized then
										module:UpdateSetting()
									end
								end,
								disabled = function() return not E.private.enhanced.actionbar.keyPressAnimation end
							}
						}
					}
				}
			},
			blizzard = {
				order = 2,
				type = "group",
				name = L["BlizzUI Improvements"],
				args = {
					header = {
						order = 0,
						type = "header",
						name = L["BlizzUI Improvements"]
					},
					animatedAchievementBars = {
						order = 1,
						type = "toggle",
						name = L["Animated Achievement Bars"],
						get = function()
							E.private.enhanced = E.private.enhanced or {}
							return E.private.enhanced.animatedAchievementBars
						end,
						set = function(_, value)
							E.private.enhanced.animatedAchievementBars = value
							E:StaticPopup_Show("PRIVATE_RL")
						end
					},
					takeAllMail = {
						order = 2,
						type = "toggle",
						name = L["Take All Mail"],
						get = function()
							return EnsureWarcraftEnhancedBlizzardDB().takeAllMail
						end,
						set = function(_, value)
							local db = EnsureWarcraftEnhancedBlizzardDB()
							db.takeAllMail = value
							if value then
								local module = GetTakeAllMailModule()
								if module and not module.initialized then
									module:Initialize()
								end
							else
								E:StaticPopup_Show("CONFIG_RL")
							end
						end
					},
					errorFrame = {
						order = 3,
						type = "group",
						name = L["Error Frame"],
						guiInline = true,
						get = function(info)
							local db = EnsureErrorFrameDB()
							return db[info[#info]]
						end,
						set = function(info, value)
							local db = EnsureErrorFrameDB()
							db[info[#info]] = value
							ApplyErrorFrameDimensions()
						end,
						args = {
							enable = {
								order = 1,
								type = "toggle",
								name = L["Enable"],
								get = function()
									return EnsureErrorFrameDB().enable
								end,
								set = function(_, value)
									local db = EnsureErrorFrameDB()
									db.enable = value
									ToggleErrorFrame()
								end
							},
							width = {
								order = 2,
								type = "range",
								name = L["Width"],
								min = 200, max = 1024, step = 1,
								disabled = function() return not EnsureErrorFrameDB().enable end
							},
							height = {
								order = 3,
								type = "range",
								name = L["Height"],
								min = 32, max = 256, step = 1,
								disabled = function() return not EnsureErrorFrameDB().enable end
							},
							font = {
								order = 4,
								type = "select",
								dialogControl = "LSM30_Font",
								name = L["Font"],
								values = LSM:HashTable("font"),
								disabled = function() return not EnsureErrorFrameDB().enable end
							},
							fontSize = {
								order = 5,
								type = "range",
								name = L["Font Size"],
								min = 8, max = 32, step = 1,
								disabled = function() return not EnsureErrorFrameDB().enable end
							},
							fontOutline = {
								order = 6,
								type = "select",
								name = L["Font Outline"],
								values = C.Values.FontFlags,
								disabled = function() return not EnsureErrorFrameDB().enable end
							}
						}
					}
				}
			},
			tooltip = {
				order = 3,
				type = "group",
				name = L["Tooltip"],
				args = {
					header = {
						order = 0,
						type = "header",
						name = L["Tooltip"]
					},
					itemQualityBorderColor = {
						order = 1,
						type = "toggle",
						name = L["Item Border Color"],
						get = function()
							return EnsureUIEnhancementsDB().itemBorderColor
						end,
						set = function(_, value)
							local db = EnsureUIEnhancementsDB()
							db.itemBorderColor = value

							local module = GetItemBorderModule()
							if module then
								if value and not module.initialized then
									module:Initialize()
								else
									module:ToggleState()
								end
							end
						end
					},
					tooltipIcon = {
						order = 2,
						type = "group",
						name = L["Tooltip Icon"],
						guiInline = true,
						get = function(info)
							local db = EnsureTooltipIconDB()
							return db[info[#info]] ~= nil and db[info[#info]] or false
						end,
						set = function(info, value)
							local db = EnsureTooltipIconDB()
							db[info[#info]] = value
							ApplyTooltipIconSettings()
						end,
						args = {
							enable = {
								order = 1,
								type = "toggle",
								name = L["Enable"]
							},
							tooltipIconItems = {
								order = 2,
								type = "toggle",
								name = L["ITEMS"],
								disabled = function() return not EnsureTooltipIconDB().enable end
							},
							tooltipIconSpells = {
								order = 3,
								type = "toggle",
								name = L["Spells"],
								disabled = function() return not EnsureTooltipIconDB().enable end
							},
							tooltipIconAchievements = {
								order = 4,
								type = "toggle",
								name = L["Achievements"],
								disabled = function() return not EnsureTooltipIconDB().enable end
							}
						}
					},
					progressInfo = {
						order = 3,
						type = "group",
						name = L["Progress Info"],
						guiInline = true,
						args = {
							enable = {
								order = 1,
								type = "toggle",
								name = L["Enable"],
								get = function() return EnsureProgressionDB().enable end,
								set = function(_, value)
									local db = EnsureProgressionDB()
									db.enable = value
									ApplyProgressionSettings()
								end
							},
							checkAchievements = {
								order = 2,
								type = "toggle",
								name = L["Check Achievements"],
								get = function() return EnsureProgressionDB().checkAchievements end,
								set = function(_, value)
									local db = EnsureProgressionDB()
									db.checkAchievements = value
									ApplyProgressionSettings()
								end,
								disabled = function() return not EnsureProgressionDB().enable end
							},
							checkPlayer = {
								order = 3,
								type = "toggle",
								name = L["Check Player"],
								get = function() return EnsureProgressionDB().checkPlayer end,
								set = function(_, value)
									local db = EnsureProgressionDB()
									db.checkPlayer = value
								end,
								disabled = function() return not EnsureProgressionDB().enable end
							},
							modifier = {
								order = 4,
								type = "select",
								name = L["Modifier"],
								values = {
									ALL = L["ALL"],
									SHIFT = L["SHIFT_KEY"],
									CTRL = L["CTRL_KEY"],
									ALT = L["ALT_KEY"]
								},
								get = function() return EnsureProgressionDB().modifier end,
								set = function(_, value)
									local db = EnsureProgressionDB()
									db.modifier = value
									UpdateProgressionModifier()
								end,
								disabled = function() return not EnsureProgressionDB().enable end
							},
							groups = {
								order = 5,
								type = "group",
								name = L["Tiers"],
								guiInline = true,
								get = function(info)
									local db = EnsureProgressionDB()
									return db.tiers[info[#info]]
								end,
								set = function(info, value)
									local db = EnsureProgressionDB()
									db.tiers[info[#info]] = value
									ApplyProgressionSettings()
								end,
								disabled = function() return not EnsureProgressionDB().enable end,
								args = {
									RS = {
										order = 1,
										type = "toggle",
										name = L["Ruby Sanctum"]
									},
									ICC = {
										order = 2,
										type = "toggle",
										name = L["Icecrown Citadel"]
									},
									ToC = {
										order = 3,
										type = "toggle",
										name = L["Trial of the Crusader"]
									},
									ToGC = {
										order = 4,
										type = "toggle",
										name = L["Trial of the Grand Crusader"]
									},
									Ulduar = {
										order = 5,
										type = "toggle",
										name = L["Ulduar"]
									}
								}
							}
						}
					}
				}
			}
		}
	}
end

E.ConfigFuncs = E.ConfigFuncs or {}
tinsert(E.ConfigFuncs, EnhancedConfig)
EnhancedConfig()

