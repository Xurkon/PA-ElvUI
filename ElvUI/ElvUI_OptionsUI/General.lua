local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
local Misc = E:GetModule("Misc")
local Layout = E:GetModule("Layout")
local Totems = E:GetModule("Totems")
local Blizzard = E:GetModule("Blizzard")
local Threat = E:GetModule("Threat")
local AFK = E:GetModule("AFK")
local LSM = E.Libs.LSM

local _G = _G

local FCF_GetNumActiveChatFrames = FCF_GetNumActiveChatFrames

local function GetTakeAllMailModule()
	return E:GetModule("Enhanced_TakeAllMail", true)
end

local function GetEnhancedBlizzardModule()
	return E:GetModule("Enhanced_Blizzard", true)
end

local function GetChatWindowInfo()
	local ChatTabInfo = {}
	for i = 1, FCF_GetNumActiveChatFrames() do
		if i ~= 2 then
			ChatTabInfo["ChatFrame"..i] = _G["ChatFrame"..i.."Tab"]:GetText()
		end
	end

	return ChatTabInfo
end

local function EnsurePortalBoxDB()
	E.db.warcraftenhanced = E.db.warcraftenhanced or {}
	local db = E.db.warcraftenhanced.portalBox
	if not db then
		db = E:CopyTable({}, P.warcraftenhanced.portalBox)
		E.db.warcraftenhanced.portalBox = db
	end

	return db
end
local function EnsureButtonGrabberDB()
	E.db.warcraftenhanced = E.db.warcraftenhanced or {}
	local db = E.db.warcraftenhanced.buttonGrabber
	if not db then
		db = E:CopyTable({}, P.warcraftenhanced.buttonGrabber)
		E.db.warcraftenhanced.buttonGrabber = db
	end

	return db
end

local function SavePortalBoxSettings()
	local we = _G.WarcraftEnhanced
	if we and we.PortalBox and we.PortalBox.SaveSettings then
		we.PortalBox:SaveSettings()
	end
end

local function EnsureAutoQuestDB()
	E.db.warcraftenhanced = E.db.warcraftenhanced or {}
	local db = E.db.warcraftenhanced.autoQuest
	if not db then
		db = E:CopyTable({}, P.warcraftenhanced.autoQuest)
		E.db.warcraftenhanced.autoQuest = db
	end

	db.overrideList = db.overrideList or {}

	return db
end

local function EnsureUIEnhancementDB()
	E.db.warcraftenhanced = E.db.warcraftenhanced or {}
	local db = E.db.warcraftenhanced.uiEnhancements
	if not db then
		db = E:CopyTable({}, P.warcraftenhanced.uiEnhancements)
		E.db.warcraftenhanced.uiEnhancements = db
	end

	db.errorFilters = db.errorFilters or {}
	if not db.tooltipIcon then
		db.tooltipIcon = E:CopyTable({}, P.warcraftenhanced.uiEnhancements.tooltipIcon)
	end

	return db
end

local function EnsureSocialDB()
	E.db.warcraftenhanced = E.db.warcraftenhanced or {}
	local db = E.db.warcraftenhanced.social
	if not db then
		db = E:CopyTable({}, P.warcraftenhanced.social)
		E.db.warcraftenhanced.social = db
	end

	return db
end

local function EnsureAutomationDB()
	E.db.warcraftenhanced = E.db.warcraftenhanced or {}
	local db = E.db.warcraftenhanced.automation
	if not db then
		db = E:CopyTable({}, P.warcraftenhanced.automation)
		E.db.warcraftenhanced.automation = db
	end

	return db
end

local function EnsureSystemDB()
	E.db.warcraftenhanced = E.db.warcraftenhanced or {}
	local db = E.db.warcraftenhanced.system
	if not db then
		db = E:CopyTable({}, P.warcraftenhanced.system)
		E.db.warcraftenhanced.system = db
	end

	return db
end

local function EnsureAchievementDB()
	E.db.warcraftenhanced = E.db.warcraftenhanced or {}
	local db = E.db.warcraftenhanced.achievements
	if not db then
		db = E:CopyTable({}, P.warcraftenhanced.achievements)
		E.db.warcraftenhanced.achievements = db
	end

	return db
end

local function EnsureLootRollDB()
	E.db.warcraftenhanced = E.db.warcraftenhanced or {}
	local db = E.db.warcraftenhanced.lootRoll
	if not db then
		db = E:CopyTable({}, P.warcraftenhanced.lootRoll)
		E.db.warcraftenhanced.lootRoll = db
	end

	return db
end

local function EnsureBlizzardExtrasDB()
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
		if defaults.mailRecipientHistory ~= nil then
			db.mailRecipientHistory = defaults.mailRecipientHistory
		else
			db.mailRecipientHistory = true
		end
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

local function EnsureErrorFrameDB()
	return EnsureBlizzardExtrasDB().errorFrame
end

local function ApplyUIEnhancements()
	local module = E:GetModule("UIEnhancements", true)
	if module then
		module.db = EnsureUIEnhancementDB()
	end
end

local function ApplyLeatrixSocial()
	local module = E:GetModule("LeatrixFeatures", true)
	if module and module.ApplySocial then
		module:ApplySocial()
	end
end

local function ApplyLeatrixAutomation()
	local module = E:GetModule("LeatrixFeatures", true)
	if module and module.ApplyAutomation then
		module:ApplyAutomation()
	end
end

local function ApplyLeatrixSystem()
	local module = E:GetModule("LeatrixFeatures", true)
	if module and module.ApplySystem then
		module:ApplySystem()
	end
end

local function ApplyLootRollSettings()
	local module = E:GetModule("LootRollEnhancement", true)
	if module and module.SetSkipConfirmation then
		module:SetSkipConfirmation(EnsureLootRollDB().skipConfirmation)
	end
end

local function ApplyAchievementSettings()
	if not IsAddOnLoaded("Blizzard_AchievementUI") then
		return
	end

	if AchievementFrameSummaryCategoriesStatusBar_Update then
		AchievementFrameSummaryCategoriesStatusBar_Update()
	end
end

E.Options.args.general = {
	order = 2, -- Below Search (moved from alphabetical position)
	type = "group",
	name = L["General"],
	childGroups = "tab",
	get = function(info) return E.db.general[info[#info]] end,
	set = function(info, value) E.db.general[info[#info]] = value end,
	args = {
		intro = {
			order = 1,
			type = "description",
			name = L["ELVUI_DESC"]
		},
		general = {
			order = 2,
			type = "group",
			name = L["General"],
			args = {
				generalHeader = {
					order = 1,
					type = "header",
					name = L["General"]
				},
				messageRedirect = {
					order = 2,
					type = "select",
					name = L["Chat Output"],
					desc = L["This selects the Chat Frame to use as the output of ElvUI messages."],
					values = GetChatWindowInfo()
				},
				AutoScale = {
					order = 3,
					type = "execute",
					name = L["Auto Scale"],
					func = function()
						E.global.general.UIScale = E:PixelBestSize()
						E:StaticPopup_Show("UISCALE_CHANGE")
					end
				},
				UIScale = {
					order = 4,
					type = "range",
					name = L["UI_SCALE"],
					min = 0.1, max = 1.25, step = 0.0000000000000001,
					softMin = 0.40, softMax = 1.15, bigStep = 0.01,
					get = function(info) return E.global.general.UIScale end,
					set = function(info, value)
						E.global.general.UIScale = value
						E:StaticPopup_Show("UISCALE_CHANGE")
					end
				},
				ignoreScalePopup = {
					order = 5,
					type = "toggle",
					name = L["Ignore UI Scale Popup"],
					desc = L["This will prevent the UI Scale Popup from being shown when changing the game window size."],
					get = function(info) return E.global.general.ignoreScalePopup end,
					set = function(info, value) E.global.general.ignoreScalePopup = value end
				},
				pixelPerfect = {
					order = 6,
					type = "toggle",
					name = L["Thin Border Theme"],
					desc = L["The Thin Border Theme option will change the overall apperance of your UI. Using Thin Border Theme is a slight performance increase over the traditional layout."],
					get = function(info) return E.private.general.pixelPerfect end,
					set = function(info, value) E.private.general.pixelPerfect = value E:StaticPopup_Show("PRIVATE_RL") end
				},
				eyefinity = {
					order = 7,
					type = "toggle",
					name = L["Multi-Monitor Support"],
					desc = L["Attempt to support eyefinity/nvidia surround."],
					get = function(info) return E.global.general.eyefinity end,
					set = function(info, value) E.global.general.eyefinity = value E:StaticPopup_Show("GLOBAL_RL") end
				},
				taintLog = {
					order = 8,
					type = "toggle",
					name = L["Log Taints"],
					desc = L["Send ADDON_ACTION_BLOCKED errors to the Lua Error frame. These errors are less important in most cases and will not effect your game performance. Also a lot of these errors cannot be fixed. Please only report these errors if you notice a Defect in gameplay."]
				},
				bottomPanel = {
					order = 9,
					type = "toggle",
					name = L["Bottom Panel"],
					desc = L["Display a panel across the bottom of the screen. This is for cosmetic only."],
					set = function(info, value) E.db.general.bottomPanel = value Layout:BottomPanelVisibility() end
				},
				topPanel = {
					order = 10,
					type = "toggle",
					name = L["Top Panel"],
					desc = L["Display a panel across the top of the screen. This is for cosmetic only."],
					set = function(info, value) E.db.general.topPanel = value Layout:TopPanelVisibility() end
				},
				afk = {
					order = 11,
					type = "toggle",
					name = L["AFK Mode"],
					desc = L["When you go AFK display the AFK screen."],
					set = function(info, value) E.db.general.afk = value AFK:Toggle() end
				},
				decimalLength = {
					order = 12,
					type = "range",
					name = L["Decimal Length"],
					desc = L["Controls the amount of decimals used in values displayed on elements like NamePlates and UnitFrames."],
					min = 0, max = 4, step = 1,
					set = function(info, value)
						E.db.general.decimalLength = value
						E:BuildPrefixValues()
						E:StaticPopup_Show("CONFIG_RL")
					end
				},
				numberPrefixStyle = {
					order = 13,
					type = "select",
					name = L["Unit Prefix Style"],
					desc = L["The unit prefixes you want to use when values are shortened in ElvUI. This is mostly used on UnitFrames."],
					set = function(info, value)
						E.db.general.numberPrefixStyle = value
						E:BuildPrefixValues()
						E:StaticPopup_Show("CONFIG_RL")
					end,
					values = {
						["CHINESE"] = "Chinese (W, Y)",
						["ENGLISH"] = "English (K, M, B)",
						["GERMAN"] = "German (Tsd, Mio, Mrd)",
						["KOREAN"] = "Korean (천, 만, 억)",
						["METRIC"] = "Metric (k, M, G)"
					}
				},
				smoothingAmount = {
					order = 14,
					type = "range",
					isPercent = true,
					name = L["Smoothing Amount"],
					desc = L["Controls the speed at which smoothed bars will be updated."],
					min = 0.1, max = 0.8, softMax = 0.75, softMin = 0.25, step = 0.01,
					set = function(info, value)
						E.db.general.smoothingAmount = value
						E:SetSmoothingAmount(value)
					end
				},
				locale = {
					order = 15,
					type = "select",
					name = L["LANGUAGE"],
					get = function(info) return E.global.general.locale end,
					set = function(info, value)
						E.global.general.locale = value
						E:StaticPopup_Show("CONFIG_RL")
					end,
					values = {
						["deDE"] = "Deutsch",
						["enUS"] = "English",
						["esMX"] = "Español",
						["frFR"] = "Français",
						["ptBR"] = "Português",
						["ruRU"] = "Русский",
						["zhCN"] = "简体中文",
						["zhTW"] = "正體中文",
						["koKR"] = "한국어"
					}
				}
			}
		},
		media = {
			order = 3,
			type = "group",
			name = L["Media"],
			get = function(info) return E.db.general[info[#info]] end,
			set = function(info, value) E.db.general[info[#info]] = value end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Media"]
				},
				fontGroup = {
					order = 2,
					type = "group",
					name = L["Font"],
					guiInline = true,
					args = {
						font = {
							order = 1,
							type = "select", dialogControl = "LSM30_Font",
							name = L["Default Font"],
							desc = L["The font that the core of the UI will use."],
							values = AceGUIWidgetLSMlists.font,
							set = function(info, value) E.db.general[info[#info]] = value E:UpdateMedia() E:UpdateFontTemplates() end
						},
						fontSize = {
							order = 2,
							type = "range",
							name = L["FONT_SIZE"],
							desc = L["Set the font size for everything in UI. Note: This doesn't effect somethings that have their own seperate options (UnitFrame Font, Datatext Font, ect..)"],
							min = 4, max = 32, step = 1,
							set = function(info, value) E.db.general[info[#info]] = value E:UpdateMedia() E:UpdateFontTemplates() end
						},
						fontStyle = {
							order = 3,
							type = "select",
							name = L["Font Outline"],
							values = C.Values.FontFlags,
							set = function(info, value) E.db.general[info[#info]] = value E:UpdateMedia() E:UpdateFontTemplates() end
						},
						applyFontToAll = {
							order = 4,
							type = "execute",
							name = L["Apply Font To All"],
							desc = L["Applies the font and font size settings throughout the entire user interface. Note: Some font size settings will be skipped due to them having a smaller font size by default."],
							func = function() E:StaticPopup_Show("APPLY_FONT_WARNING") end
						},
						dmgfont = {
							order = 5,
							type = "select", dialogControl = "LSM30_Font",
							name = L["CombatText Font"],
							desc = L["The font that combat text will use. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"],
							values = AceGUIWidgetLSMlists.font,
							get = function(info) return E.private.general[info[#info]] end,
							set = function(info, value) E.private.general[info[#info]] = value E:UpdateMedia() E:UpdateFontTemplates() E:StaticPopup_Show("PRIVATE_RL") end
						},
						namefont = {
							order = 6,
							type = "select", dialogControl = "LSM30_Font",
							name = L["Name Font"],
							desc = L["The font that appears on the text above players heads. |cffFF0000WARNING: This requires a game restart or re-log for this change to take effect.|r"],
							values = AceGUIWidgetLSMlists.font,
							get = function(info) return E.private.general[info[#info]] end,
							set = function(info, value) E.private.general[info[#info]] = value E:UpdateMedia() E:UpdateFontTemplates() E:StaticPopup_Show("PRIVATE_RL") end
						},
						replaceBlizzFonts = {
							order = 7,
							type = "toggle",
							name = L["Replace Blizzard Fonts"],
							desc = L["Replaces the default Blizzard fonts on various panels and frames with the fonts chosen in the Media section of the ElvUI Options. NOTE: Any font that inherits from the fonts ElvUI usually replaces will be affected as well if you disable this. Enabled by default."],
							get = function(info) return E.private.general[info[#info]] end,
							set = function(info, value) E.private.general[info[#info]] = value E:StaticPopup_Show("PRIVATE_RL") end
						}
					}
				},
				textureGroup = {
					order = 3,
					type = "group",
					name = L["Textures"],
					guiInline = true,
					get = function(info) return E.private.general[info[#info]] end,
					args = {
						normTex = {
							order = 1,
							type = "select", dialogControl = "LSM30_Statusbar",
							name = L["Primary Texture"],
							desc = L["The texture that will be used mainly for statusbars."],
							values = AceGUIWidgetLSMlists.statusbar,
							set = function(info, value)
								local previousValue = E.private.general[info[#info]]
								E.private.general[info[#info]] = value

								if E.db.unitframe.statusbar == previousValue then
									E.db.unitframe.statusbar = value
									E:UpdateAll(true)
								else
									E:UpdateMedia()
									E:UpdateStatusBars()
								end
							end
						},
						glossTex = {
							order = 2,
							type = "select", dialogControl = "LSM30_Statusbar",
							name = L["Secondary Texture"],
							desc = L["This texture will get used on objects like chat windows and dropdown menus."],
							values = AceGUIWidgetLSMlists.statusbar,
							set = function(info, value)
								E.private.general[info[#info]] = value
								E:UpdateMedia()
								E:UpdateFrameTemplates()
							end
						},
						applyTextureToAll = {
							order = 3,
							type = "execute",
							name = L["Apply Texture To All"],
							desc = L["Applies the primary texture to all statusbars."],
							func = function()
								local texture = E.private.general.normTex
								E.db.unitframe.statusbar = texture
								E.db.nameplates.statusbar = texture
								E:UpdateAll(true)
							end
						}
					}
				},
				colorsGroup = {
					order = 4,
					type = "group",
					name = L["COLORS"],
					guiInline = true,
					get = function(info)
						local t = E.db.general[info[#info]]
						local d = P.general[info[#info]]
						return t.r, t.g, t.b, t.a, d.r, d.g, d.b, d.a
					end,
					set = function(info, r, g, b, a)
						local setting = info[#info]
						local t = E.db.general[setting]
						t.r, t.g, t.b, t.a = r, g, b, a
						E:UpdateMedia()
						if setting == "bordercolor" then
							E:UpdateBorderColors()
						elseif setting == "backdropcolor" or setting == "backdropfadecolor" then
							E:UpdateBackdropColors()
						end
					end,
					args = {
						bordercolor = {
							order = 1,
							type = "color",
							name = L["Border Color"],
							desc = L["Main border color of the UI."],
							hasAlpha = false,
						},
						backdropcolor = {
							order = 2,
							type = "color",
							name = L["Backdrop Color"],
							desc = L["Main backdrop color of the UI."],
							hasAlpha = false,
						},
						backdropfadecolor = {
							order = 3,
							type = "color",
							name = L["Backdrop Faded Color"],
							desc = L["Backdrop color of transparent frames"],
							hasAlpha = true,
						},
						valuecolor = {
							order = 4,
							type = "color",
							name = L["Value Color"],
							desc = L["Color some texts use."],
							hasAlpha = false,
						},
						herocolor = {
							order = 5,
							type = "color",
							name = "My Class Color",
							desc = "Color of class colored elements.",
							hasAlpha = false,
						},
						cropIcon = {
							order = 6,
							type = "toggle",
							tristate = true,
							name = L["Crop Icons"],
							desc = L["This is for Customized Icons in your Interface/Icons folder."],
							get = function(info)
								local value = E.db.general[info[#info]]
								if value == 2 then return true
								elseif value == 1 then return nil
								else return false end
							end,
							set = function(info, value)
								E.db.general[info[#info]] = (value and 2) or (value == nil and 1) or 0
								E:StaticPopup_Show("PRIVATE_RL")
							end
						}
					}
				}
			}
		},
		totems = {
			order = 4,
			type = "group",
			name = L["Class Totems"],
			get = function(info) return E.db.general.totems[info[#info]] end,
			set = function(info, value) E.db.general.totems[info[#info]] = value Totems:PositionAndSize() end,
			hidden = function() return false end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = TUTORIAL_TITLE47
				},
				enable = {
					order = 2,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) E.db.general.totems[info[#info]] = value Totems:ToggleEnable() end
				},
				size = {
					order = 3,
					type = "range",
					name = L["Button Size"],
					min = 24, max = 60, step = 1,
					disabled = function() return not E.db.general.totems.enable end
				},
				spacing = {
					order = 4,
					type = "range",
					name = L["Button Spacing"],
					min = 1, max = 10, step = 1,
					disabled = function() return not E.db.general.totems.enable end
				},
				sortDirection = {
					order = 5,
					type = "select",
					name = L["Sort Direction"],
					values = {
						["ASCENDING"] = L["Ascending"],
						["DESCENDING"] = L["Descending"]
					},
					disabled = function() return not E.db.general.totems.enable end
				},
				growthDirection = {
					order = 6,
					type = "select",
					name = L["Bar Direction"],
					values = {
						["VERTICAL"] = L["Vertical"],
						["HORIZONTAL"] = L["Horizontal"]
					},
					disabled = function() return not E.db.general.totems.enable end
				}
			}
		},
		chatBubblesGroup = {
			order = 5,
			type = "group",
			name = L["Chat Bubbles"],
			get = function(info) return E.private.general[info[#info]] end,
			set = function(info, value) E.private.general[info[#info]] = value E:StaticPopup_Show("PRIVATE_RL") end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Chat Bubbles"]
				},
				chatBubbles = {
					order = 2,
					type = "select",
					name = L["Chat Bubbles Style"],
					desc = L["Skin the blizzard chat bubbles."],
					values = {
						["backdrop"] = L["Skin Backdrop"],
						["nobackdrop"] = L["Remove Backdrop"],
						["backdrop_noborder"] = L["Skin Backdrop (No Borders)"],
						["disabled"] = L["DISABLE"]
					}
				},
				chatBubbleFont = {
					order = 3,
					type = "select",
					name = L["Font"],
					dialogControl = "LSM30_Font",
					values = AceGUIWidgetLSMlists.font,
					disabled = function() return E.private.general.chatBubbles == "disabled" end
				},
				chatBubbleFontSize = {
					order = 4,
					type = "range",
					name = L["FONT_SIZE"],
					min = 4, max = 32, step = 1,
					disabled = function() return E.private.general.chatBubbles == "disabled" end
				},
				chatBubbleFontOutline = {
					order = 5,
					type = "select",
					name = L["Font Outline"],
					disabled = function() return E.private.general.chatBubbles == "disabled" end,
					values = C.Values.FontFlags
				},
				chatBubbleName = {
					order = 6,
					type = "toggle",
					name = L["Chat Bubble Names"],
					desc = L["Display the name of the unit on the chat bubble."],
					disabled = function() return E.private.general.chatBubbles == "disabled" or E.private.general.chatBubbles == "nobackdrop" end
				}
			}
		},
		objectiveFrameGroup = {
			order = 6,
			type = "group",
			name = L["Objective Frame"],
			get = function(info) return E.db.general[info[#info]] end,
			args = {
				objectiveFrameHeader = {
					order = 1,
					type = "header",
					name = L["Objective Frame"],
				},
				watchFrameAutoHide = {
					order = 2,
					type = "toggle",
					name = L["Auto Hide"],
					desc = L["Automatically hide the objetive frame during boss or arena fights."],
					set = function(info, value) E.db.general.watchFrameAutoHide = value; Blizzard:SetObjectiveFrameAutoHide() end,
				},
				watchFrameHeight = {
					order = 3,
					type = "range",
					name = L["Objective Frame Height"],
					desc = L["Height of the objective tracker. Increase size to be able to see more objectives."],
					min = 400, max = E.screenheight, step = 1,
					set = function(info, value) E.db.general.watchFrameHeight = value; Blizzard:SetWatchFrameHeight() end,
				},
			},
		},
		threatGroup = {
			order = 7,
			type = "group",
			name = L["Threat"],
			get = function(info) return E.db.general.threat[info[#info]] end,
			args = {
				threatHeader = {
					order = 1,
					type = "header",
					name = L["Threat"]
				},
				enable = {
					order = 2,
					type = "toggle",
					name = L["Enable"],
					set = function(info, value) E.db.general.threat.enable = value Threat:ToggleEnable()end
				},
				position = {
					order = 3,
					type = "select",
					name = L["Position"],
					desc = L["Adjust the position of the threat bar to either the left or right datatext panels."],
					values = {
						["LEFTCHAT"] = L["Left Chat"],
						["RIGHTCHAT"] = L["Right Chat"]
					},
					set = function(info, value) E.db.general.threat.position = value Threat:UpdatePosition() end,
					disabled = function() return not E.db.general.threat.enable end
				},
				spacer = {
					order = 4,
					type = "description",
					name = ""
				},
				textSize = {
					order = 5,
					type = "range",
					name = L["FONT_SIZE"],
					min = 6, max = 22, step = 1,
					set = function(info, value) E.db.general.threat.textSize = value Threat:UpdatePosition() end,
					disabled = function() return not E.db.general.threat.enable end
				},
				textOutline = {
					order = 6,
					type = "select",
					name = L["Font Outline"],
					values = C.Values.FontFlags,
					set = function(info, value) E.db.general.threat.textOutline = value Threat:UpdatePosition() end,
					disabled = function() return not E.db.general.threat.enable end
				}
			}
		},
		blizzUIImprovements = {
			order = 8,
			type = "group",
			name = L["BlizzUI Improvements"],
			get = function(info) return E.db.general[info[#info]] end,
			set = function(info, value) E.db.general[info[#info]] = value end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["BlizzUI Improvements"]
				},
				loot = {
					order = 2,
					type = "toggle",
					name = L["LOOT"],
					desc = L["Enable/Disable the loot frame."],
					get = function(info) return E.private.general[info[#info]] end,
					set = function(info, value)
						E.private.general[info[#info]] = value
						E:StaticPopup_Show("PRIVATE_RL")
					end
				},
				lootRoll = {
					order = 3,
					type = "toggle",
					name = L["Loot Roll"],
					desc = L["Enable/Disable the loot roll frame."],
					get = function(info) return E.private.general[info[#info]] end,
					set = function(info, value)
						E.private.general[info[#info]] = value
						E:StaticPopup_Show("PRIVATE_RL")
					end
				},
				hideErrorFrame = {
					order = 4,
					type = "toggle",
					name = L["Hide Error Text"],
					desc = L["Hides the red error text at the top of the screen while in combat."],
					set = function(info, value)
						E.db.general[info[#info]] = value
						Misc:ToggleErrorHandling()
					end
				},
				filterScriptErrors = {
					order = 4.5,
					type = "toggle",
					name = "Filter Script Errors",
					desc = "Filters out common annoying error messages from the error frame (prevents specific errors from showing)",
				get = function() return EnsureUIEnhancementDB().errorFiltering end,
				set = function(_, value)
					local db = EnsureUIEnhancementDB()
					db.errorFiltering = value
					local module = E:GetModule("UIEnhancements", true)
					if module and module.ToggleErrorFiltering then
						module:ToggleErrorFiltering(value)
					end
				end
				},
				autoFillDelete = {
					order = 4.6,
					type = "toggle",
					name = "Auto-Fill Delete Confirmation",
					desc = "Automatically fills 'Delete' in item deletion confirmation dialogs",
				get = function() return EnsureUIEnhancementDB().autoDelete end,
				set = function(_, value)
					local db = EnsureUIEnhancementDB()
					db.autoDelete = value
					local module = E:GetModule("UIEnhancements", true)
					if module and module.ToggleAutoDelete then
						module:ToggleAutoDelete(value)
					end
				end
				},
				maxCameraZoom = {
					order = 4.7,
					type = "toggle",
					name = "Max Camera Zoom",
					desc = "Increase maximum camera zoom distance",
					get = function() return EnsureSystemDB().maxCameraZoom end,
					set = function(_, value)
						local db = EnsureSystemDB()
						db.maxCameraZoom = value
						ApplyLeatrixSystem()
					end
				},
				animatedAchievementBars = {
					order = 4.8,
					type = "toggle",
					name = L["Animated Achievement Bars"],
					get = function() return EnsureAchievementDB().animatedBars end,
					set = function(_, value)
						local db = EnsureAchievementDB()
						db.animatedBars = value
						ApplyAchievementSettings()
					end
				},
				mailRecipientHistory = {
					order = 4.9,
					type = "toggle",
					name = L["Remember Mail Recipients"],
					desc = L["Keep the last mail recipient entered and show a list of recent contacts."],
					get = function()
						return EnsureBlizzardExtrasDB().mailRecipientHistory
					end,
					set = function(_, value)
						local db = EnsureBlizzardExtrasDB()
						db.mailRecipientHistory = value

						if Misc and Misc.Mail_OnSettingChanged then
							Misc:Mail_OnSettingChanged()
						end
					end
				},
				takeAllMail = {
					order = 4.95,
					type = "toggle",
					name = L["Take All Mail"],
					desc = L["Adds buttons to the mailbox frame to loot all mail or only gold with one click."],
					get = function()
						return EnsureBlizzardExtrasDB().takeAllMail
					end,
					set = function(_, value)
						local db = EnsureBlizzardExtrasDB()
						db.takeAllMail = value

						if value then
							local module = GetTakeAllMailModule()
							if module then
								if not module.initialized then
									module:Initialize()
								else
									module:UpdateState()
								end
							end
						else
							local module = GetTakeAllMailModule()
							if module and module.initialized and module.UpdateState then
								module:UpdateState()
							end
						end
					end
				},
				worldMapZoneLevels = {
					order = 4.98,
					type = "toggle",
					name = L["Show Zone Levels"],
					desc = L["Display recommended character levels on the world map zone label."],
					get = function()
						return E.global.general.worldMapZoneLevels
					end,
					set = function(_, value)
						E.global.general.worldMapZoneLevels = value
						local module = E:GetModule("WorldMap", true)
						if module then
							module:ResetZoneLevelText()
							module:UpdateZoneLevelText()
						end
					end
				},
				errorFrame = {
					order = 4.99,
					type = "group",
					name = L["Error Frame"],
					guiInline = true,
					get = function(info)
						return EnsureErrorFrameDB()[info[#info]]
					end,
					set = function(info, value)
						local db = EnsureErrorFrameDB()
						db[info[#info]] = value
						local module = GetEnhancedBlizzardModule()
						if module and module.initialized then
							if info[#info] == "enable" then
								module:CustomErrorFrameToggle()
							else
								module:ErrorFrameSize()
							end
						end
					end,
					args = {
						enable = {
							order = 1,
							type = "toggle",
							name = L["Enable"],
							set = function(_, value)
								local db = EnsureErrorFrameDB()
								db.enable = value
								local module = GetEnhancedBlizzardModule()
								if module and module.initialized then
									module:CustomErrorFrameToggle()
								end
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
				},
				enhancedPvpMessages = {
					order = 5,
					type = "toggle",
					name = L["Enhanced PVP Messages"],
					desc = L["Display battleground messages in the middle of the screen."],
				},
				raidUtility = {
					order = 7,
					type = "toggle",
					name = L["RAID_CONTROL"],
					desc = L["Enables the ElvUI Raid Control panel."],
					get = function(info) return E.private.general[info[#info]] end,
					set = function(info, value)
						E.private.general[info[#info]] = value
						E:StaticPopup_Show("PRIVATE_RL")
					end
				},
			vehicleSeatIndicatorSize = {
				order = 8,
				type = "range",
				name = L["Vehicle Seat Indicator Size"],
				min = 64, max = 128, step = 4,
				set = function(info, value)
					E.db.general[info[#info]] = value
					Blizzard:UpdateVehicleFrame()
				end
			},
			spacer1 = {
				order = 9,
				type = "description",
				name = " ",
			},
			lootHeader = {
				order = 10,
				type = "header",
				name = "Loot Enhancements",
			},
			skipLootRollConfirmation = {
				order = 11,
				type = "toggle",
				name = L["Skip Loot Roll Confirmation"],
				desc = L["Skip the confirmation dialog when clicking Need, Greed, Disenchant, or Pass on BoP loot rolls. Your selection will be immediately submitted."],
				get = function() return EnsureLootRollDB().skipConfirmation end,
				set = function(_, value)
					local db = EnsureLootRollDB()
					db.skipConfirmation = value
					ApplyLootRollSettings()
				end,
				disabled = function() return not E.private.general.lootRoll end
			}
		}
	},
		automation = {
			order = 8.5,
			type = "group",
			name = "Automation",
			get = function(info) 
				if E.db and E.db.warcraftenhanced then
					return E.db.warcraftenhanced[info[#info]]
				elseif E.db and E.db.general then
					return E.db.general[info[#info]]
				end
				return false
			end,
			set = function(info, value) 
				if E.db and E.db.warcraftenhanced then
					E.db.warcraftenhanced[info[#info]] = value 
				elseif E.db and E.db.general then
					E.db.general[info[#info]] = value
				end
			end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = "Automation Features"
				},
				description = {
					order = 2,
					type = "description",
					name = "Automated actions for quests, vendors, combat, and resurrection."
				},
				spacer1 = {
					order = 5,
					type = "description",
					name = " ",
				},
				-- Quest Automation Section
				questHeader = {
					order = 10,
					type = "header",
					name = "Quest Automation"
				},
				questDesc = {
					order = 11,
					type = "description",
					name = "Automatically accept and complete quests. Hold any modifier key (Shift/Ctrl/Alt) when talking to NPCs to temporarily disable.",
				},
				autoAcceptQuests = {
					order = 12,
					type = "toggle",
					name = "Auto Accept All Quests",
					desc = "Automatically accept all available quests",
					get = function() return EnsureAutoQuestDB().autoAccept end,
					set = function(info, value)
						local db = EnsureAutoQuestDB()
						db.autoAccept = value
						AutoQuestSave = db
					end,
				},
				autoDaily = {
					order = 13,
					type = "toggle",
					name = "Auto Accept Daily Quests",
					desc = "Automatically accept daily quests",
					get = function() return EnsureAutoQuestDB().autoDaily end,
					set = function(info, value)
						local db = EnsureAutoQuestDB()
						db.autoDaily = value
						AutoQuestSave = db
					end,
				},
				autoFate = {
					order = 14,
					type = "toggle",
					name = "Auto Accept Fate Quests",
					desc = "Automatically accept Hand of Fate leveling quests",
					get = function() return EnsureAutoQuestDB().autoFate end,
					set = function(info, value)
						local db = EnsureAutoQuestDB()
						db.autoFate = value
						AutoQuestSave = db
					end,
				},
				autoRepeatQuests = {
					order = 15,
					type = "toggle",
					name = "Auto Accept Repeatable Quests",
					desc = "Automatically accept repeatable quests if you have the required items",
					get = function() return EnsureAutoQuestDB().autoRepeat end,
					set = function(info, value)
						local db = EnsureAutoQuestDB()
						db.autoRepeat = value
						AutoQuestSave = db
					end,
				},
				autoComplete = {
					order = 16,
					type = "toggle",
					name = "Auto Complete Quests",
					desc = "Automatically complete and turn in quests",
					get = function() return EnsureAutoQuestDB().autoComplete end,
					set = function(info, value)
						local db = EnsureAutoQuestDB()
						db.autoComplete = value
						AutoQuestSave = db
					end,
				},
				autoHighRisk = {
					order = 17,
					type = "toggle",
					name = "Auto Accept High-Risk Quests",
					desc = "Automatically accept high-risk quests (Bloody Expedition, Ill Gotten Goods, etc.)",
					get = function() return EnsureAutoQuestDB().autoHighRisk end,
					set = function(info, value)
						local db = EnsureAutoQuestDB()
						db.autoHighRisk = value
						AutoQuestSave = db
					end,
				},
				questAdvanced = {
					order = 18,
					type = "description",
					name = "\n|cffffcc00Advanced:|r Use |cffffcc00/aq toggle <quest name>|r to enable/disable specific quests.",
				},
				spacer2 = {
					order = 25,
					type = "description",
					name = " ",
				},
				-- Vendor Automation Section
				vendorHeader = {
					order = 30,
					type = "header",
					name = "Vendor Automation"
				},
				autoSellJunk = {
					order = 31,
					type = "toggle",
					name = "Sell Junk Automatically",
					desc = "Automatically sell all grey items at vendors (hold Shift to skip)",
					get = function() return EnsureAutomationDB().autoSellJunk end,
					set = function(_, value)
						local db = EnsureAutomationDB()
						db.autoSellJunk = value
						ApplyLeatrixAutomation()
					end
				},
				autoSellJunkSummary = {
					order = 32,
					type = "toggle",
					name = "Show Sell Junk Summary",
					desc = "Show chat message with total from selling junk",
					get = function() return EnsureAutomationDB().autoSellJunkSummary end,
					set = function(_, value)
						local db = EnsureAutomationDB()
						db.autoSellJunkSummary = value
					end
				},
				autoRepair = {
					order = 33,
					type = "toggle",
					name = "Repair Automatically",
					desc = "Automatically repair at vendors (hold Shift to skip)",
					get = function() return EnsureAutomationDB().autoRepair end,
					set = function(_, value)
						local db = EnsureAutomationDB()
						db.autoRepair = value
						ApplyLeatrixAutomation()
					end
				},
				autoRepairGuildFunds = {
					order = 34,
					type = "toggle",
					name = "Repair Using Guild Funds",
					desc = "Use guild funds for repairs if available and permitted",
					get = function() return EnsureAutomationDB().autoRepairGuildFunds end,
					set = function(_, value)
						local db = EnsureAutomationDB()
						db.autoRepairGuildFunds = value
					end
				},
				autoRepairSummary = {
					order = 35,
					type = "toggle",
					name = "Show Repair Summary",
					desc = "Show chat message with repair costs",
					get = function() return EnsureAutomationDB().autoRepairSummary end,
					set = function(_, value)
						local db = EnsureAutomationDB()
						db.autoRepairSummary = value
					end
				},
				spacer3 = {
					order = 45,
					type = "description",
					name = " ",
				},
				-- Combat & Death Automation Section
				combatHeader = {
					order = 50,
					type = "header",
					name = "Combat & Death Automation"
				},
				autoReleasePvP = {
					order = 51,
					type = "toggle",
					name = "Release in PvP",
					desc = "Automatically release spirit in battlegrounds/arenas",
					get = function() return EnsureAutomationDB().autoReleasePvP end,
					set = function(_, value)
						local db = EnsureAutomationDB()
						db.autoReleasePvP = value
						ApplyLeatrixAutomation()
					end
				},
				autoSpiritRes = {
					order = 52,
					type = "toggle",
					name = "Auto Spirit Res Confirm",
					desc = "Automatically accept resurrection from spirit healer",
					get = function() return EnsureAutomationDB().autoSpiritRes end,
					set = function(_, value)
						local db = EnsureAutomationDB()
						db.autoSpiritRes = value
						ApplyLeatrixAutomation()
					end
				},
			}
		},
		misc = {
			order = 9,
			type = "group",
			name = L["MISCELLANEOUS"],
			get = function(info) return E.db.general[info[#info]] end,
			set = function(info, value) E.db.general[info[#info]] = value end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["MISCELLANEOUS"]
				},
				interruptAnnounce = {
					order = 2,
					type = "select",
					name = L["Announce Interrupts"],
					desc = L["Announce when you interrupt a spell to the specified chat channel."],
					values = {
						["NONE"] = L["NONE"],
						["SAY"] = L["SAY"],
						["PARTY"] = L["Party Only"],
						["RAID"] = L["Party / Raid"],
						["RAID_ONLY"] = L["Raid Only"],
						["EMOTE"] = L["EMOTE"]
					},
					set = function(info, value)
						E.db.general[info[#info]] = value
						Misc:ToggleInterruptAnnounce()
					end
				},
			autoAcceptInvite = {
				order = 3,
				type = "toggle",
				name = L["Accept Invites"],
				desc = L["Automatically accept invites from guild/friends."]
			},
			autoRoll = {
				order = 4,
				type = "toggle",
				name = L["Auto Greed/DE"],
				desc = L["Automatically select greed or disenchant (when available) on green quality items. This will only work if you are the max level."],
				disabled = function() return not E.private.general.lootRoll end
			},
			socialHeader = {
				order = 10,
				type = "header",
				name = "Social Filtering"
			},
			blockDuels = {
				order = 11,
				type = "toggle",
				name = "Block Duels",
				desc = "Block duel requests unless from friends/guild",
				get = function() return EnsureSocialDB().blockDuels end,
				set = function(_, value)
					local db = EnsureSocialDB()
					db.blockDuels = value
					ApplyLeatrixSocial()
				end
			},
			blockGuildInvites = {
				order = 12,
				type = "toggle",
				name = "Block Guild Invites",
				desc = "Block guild invitations unless from friends",
				get = function() return EnsureSocialDB().blockGuildInvites end,
				set = function(_, value)
					local db = EnsureSocialDB()
					db.blockGuildInvites = value
					ApplyLeatrixSocial()
				end
			},
			blockPartyInvites = {
				order = 13,
				type = "toggle",
				name = "Block Party Invites",
				desc = "Block party invitations unless from friends/guild",
				get = function() return EnsureSocialDB().blockPartyInvites end,
				set = function(_, value)
					local db = EnsureSocialDB()
					db.blockPartyInvites = value
					ApplyLeatrixSocial()
				end
			},
			portalBoxHeader = {
				order = 20,
				type = "header",
				name = "PortalBox",
			},
			portalBoxDesc = {
				order = 21,
				type = "description",
				name = "PortalBox provides quick access to all your teleport and portal spells.",
			},
			openPortalBox = {
				order = 22,
				type = "execute",
				name = "Open PortalBox",
				desc = "Open the PortalBox spell selection window",
				func = function()
					if portalbox_toggle then 
						portalbox_toggle()
					else
						print("|cffff0000PortalBox is not loaded.|r")
					end
				end,
			},
			hidePortalBoxMinimap = {
				order = 23,
				type = "toggle",
				name = "Hide PortalBox Minimap Button",
				desc = "Hide the PortalBox minimap button",
				get = function()
					return EnsurePortalBoxDB().hideMinimapButton
				end,
				set = function(_, value)
					local db = EnsurePortalBoxDB()
					db.hideMinimapButton = value
					HideMMIcon = value and "1" or "0"

					if value then
						if PortalBox_MinimapButton then PortalBox_MinimapButton:Hide() end
						if PortalBox_MinimapButtonUnbound then PortalBox_MinimapButtonUnbound:Hide() end
					else
						if MinimapButtonUnbind == "0" and PortalBox_MinimapButton then
							PortalBox_MinimapButton:Show()
						elseif PortalBox_MinimapButtonUnbound then
							PortalBox_MinimapButtonUnbound:Show()
						end
					end

					SavePortalBoxSettings()
				end,
			},
			detachPortalBoxMinimap = {
				order = 23.5,
				type = "toggle",
				name = "Detach Minimap Button",
				desc = "Allows the PortalBox minimap button to be moved freely",
				get = function()
					return EnsurePortalBoxDB().detachMinimapButton
				end,
				set = function(_, value)
					local db = EnsurePortalBoxDB()
					db.detachMinimapButton = value
					MinimapButtonUnbind = value and "1" or "0"

					if value then
						if PortalBox_MinimapButton then PortalBox_MinimapButton:Hide() end
						if PortalBox_MinimapButtonUnbound then PortalBox_MinimapButtonUnbound:Show() end
					else
						if HideMMIcon ~= "1" and PortalBox_MinimapButton then
							PortalBox_MinimapButton:Show()
						end
						if PortalBox_MinimapButtonUnbound then PortalBox_MinimapButtonUnbound:Hide() end
					end

					SavePortalBoxSettings()
				end,
			},
			portalBoxKeepWindowOpen = {
				order = 23.6,
				type = "toggle",
				name = "Keep Window Open",
				desc = "Keeps the PortalBox window open after casting a teleport or portal",
				get = function()
					return EnsurePortalBoxDB().keepWindowOpen
				end,
				set = function(_, value)
					local db = EnsurePortalBoxDB()
					db.keepWindowOpen = value
					KeepWindowOpen = value and "1" or "0"

					SavePortalBoxSettings()
				end,
			},
			portalBoxCommand = {
				order = 24,
				type = "description",
				name = "\n|cffffcc00Command:|r Type |cffffcc00/port|r or |cffffcc00/portalbox|r to toggle the PortalBox window.",
			},
		}
		},
		taintFix = {
			order = 8,
			type = "group",
			name = "Taint Fix",
			get = function(info)
				if not E.db.general.taintFix then
					E.db.general.taintFix = {
						enable = true,
						enableActionBarFix = true,
						enableCompactRaidFrameFix = true,
						debug = false
					}
				end
				return E.db.general.taintFix[info[#info]]
			end,
			set = function(info, value)
				if not E.db.general.taintFix then
					E.db.general.taintFix = {
						enable = true,
						enableActionBarFix = true,
						enableCompactRaidFrameFix = true,
						debug = false
					}
				end
				E.db.general.taintFix[info[#info]] = value
				local TF = E:GetModule("TaintFix")
				if TF then
					TF:Toggle()
				end
			end,
			args = {
				header = {
					order = 1,
					type = "header",
					name = "Taint Fix"
				},
				description = {
					order = 2,
					type = "description",
					name = "The Taint Fix module prevents common taint issues that can cause errors with action bars and raid frames. These fixes ensure compatibility with other addons and prevent secure function call blocking."
				},
				enable = {
					order = 3,
					type = "toggle",
					name = "Enable Taint Fix",
					desc = "Enable or disable the entire taint fix module. Disabling this may cause errors if you have conflicting addons."
				},
				spacer1 = {
					order = 4,
					type = "description",
					name = ""
				},
				actionBarHeader = {
					order = 5,
					type = "header",
					name = "Action Bar Protection"
				},
				enableActionBarFix = {
					order = 6,
					type = "toggle",
					name = "Enable Action Bar Fix",
					desc = "Protects action bar buttons from taint. This prevents errors like 'prevented the call of secure function MultiBarBottomLeftButton:Hide()'. Recommended: Enabled",
					disabled = function() return not E.db.general.taintFix.enable end
				},
				spacer2 = {
					order = 7,
					type = "description",
					name = ""
				},
				raidFrameHeader = {
					order = 8,
					type = "header",
					name = "Raid Frame Protection"
				},
				enableCompactRaidFrameFix = {
					order = 9,
					type = "toggle",
					name = "Enable Compact Raid Frame Fix",
					desc = "Protects CompactRaidFrames from taint and creates stub frames if they don't exist. This prevents errors when ElvUI hides Blizzard raid frames. Recommended: Enabled",
					disabled = function() return not E.db.general.taintFix.enable end
				},
				spacer3 = {
					order = 10,
					type = "description",
					name = ""
				},
				debugHeader = {
					order = 11,
					type = "header",
					name = "Debug Options"
				},
				debug = {
					order = 12,
					type = "toggle",
					name = "Debug Mode",
					desc = "Enable debug mode to see messages in chat when taint fixes are applied. Use this for troubleshooting only.",
					disabled = function() return not E.db.general.taintFix.enable end
				},
				applyNow = {
					order = 13,
					type = "execute",
					name = "Apply Fixes Now",
					desc = "Manually apply all taint fixes immediately. This is normally done automatically.",
					disabled = function() return not E.db.general.taintFix.enable end,
					func = function()
						local TF = E:GetModule("TaintFix")
						if TF then
							TF:ApplyFixes()
							E:Print("Taint fixes have been applied.")
						end
					end
				}
			}
		}
	}
}

local takeAllModule = GetTakeAllMailModule()
if takeAllModule and E.db and E.db.warcraftenhanced and E.db.warcraftenhanced.blizzard and E.db.warcraftenhanced.blizzard.takeAllMail and not takeAllModule.initialized then
	takeAllModule:Initialize()
end