local E, L, V, P, G = unpack(ElvUI)
local EE = E:GetModule("ElvUI_Enhanced")

local function GeneralOptions()
	local M = E:GetModule("Enhanced_Misc")

	return {
		order = 1,
		type = "group",
		name = L["General"],
		get = function(info) return E.db.enhanced.general[info[#info]] end,
		args = {
			header = {
				order = 1,
				type = "header",
				name = EE:ColorizeSettingName(L["General"])
			},
			autoRepChange = {
				type = "toggle",
				name = L["Track Reputation"],
				desc = L["Automatically change your watched faction on the reputation bar to the faction you got reputation points for."],
				set = function(info, value)
					E.db.enhanced.general[info[#info]] = value
					M:WatchedFaction()
				end
			},
			selectQuestReward = {
				type = "toggle",
				name = L["Select Quest Reward"],
				desc = L["Automatically select the quest reward with the highest vendor sell value."],
				get = function(info) return E.private.general[info[#info]] end,
				set = function(info, value)
					E.private.general[info[#info]] = value
					M:ToggleQuestReward()
				end
			},
			alreadyKnown = {
				type = "toggle",
				name = L["Already Known"],
				desc = L["Change color of item icons which already known."],
				set = function(info, value)
					E.db.enhanced.general[info[#info]] = value
					E:GetModule("Enhanced_AlreadyKnown"):ToggleState()
				end
			},
			showQuestLevel = {
				type = "toggle",
				name = L["Show Quest Level"],
				desc = L["Display quest levels at Quest Log."],
				set = function(info, value)
					E.db.enhanced.general.showQuestLevel = value
					M:QuestLevelToggle()
				end
			},
			dpsLinks = {
				type = "toggle",
				name = L["Filter DPS meters Spam"],
				desc = L["Replaces reports from damage meters with a clickable hyperlink to reduce chat spam"],
				get = function(info) return E.db.enhanced.chat.dpsLinks end,
				set = function(info, value)
					E.db.enhanced.chat.dpsLinks = value
					E:GetModule("Enhanced_DPSLinks"):UpdateSettings()
				end
			},
			ghostEffect = {
				order = 10,
				type = "toggle",
				name = L["Ghost Effect"] or "Ghost Effect",
				desc = L["Enable or disable the ghost effect when dead."] or "Enable or disable the ghost effect when dead.",
				get = function(info) return E.db.enhanced.general.ghostEffect end,
				set = function(info, value)
					E.db.enhanced.general.ghostEffect = value
					SetCVar("ffxDeath", value and "1" or "0")
				end
			},
		}
	}
end

local function ActionbarOptions()
	local KPA = E:GetModule("Enhanced_KeyPressAnimation")

	return {
		order = 3,
		type = "group",
		name = L["ActionBars"],
		args = {
			header = {
				order = 0,
				type = "header",
				name = EE:ColorizeSettingName(L["ActionBars"])
			},
			keyPressAnimation = {
				order = 1,
				type = "group",
				name = L["Key Press Animation"],
				guiInline = true,
				get = function(info) return E.db.enhanced.actionbar.keyPressAnimation[info[#info]] end,
				set = function(info, value)
					E.db.enhanced.actionbar.keyPressAnimation[info[#info]] = value
					KPA:UpdateSetting()
				end,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
						get = function(info) return E.private.enhanced.actionbar.keyPressAnimation end,
						set = function(info, value)
							E.private.enhanced.actionbar.keyPressAnimation = value
							E:StaticPopup_Show("PRIVATE_RL")
						end,
					},
					color = {
						order = 2,
						type = "color",
						name = L["COLOR"],
						get = function(info)
							local t = E.db.enhanced.actionbar.keyPressAnimation[info[#info]]
							local d = P.enhanced.actionbar.keyPressAnimation[info[#info]]
							return t.r, t.g, t.b, t.a, d.r, d.g, d.b
						end,
						set = function(info, r, g, b)
							local t = E.db.enhanced.actionbar.keyPressAnimation[info[#info]]
							t.r, t.g, t.b = r, g, b
							KPA:UpdateSetting()
						end,
						disabled = function() return not E.private.enhanced.actionbar.keyPressAnimation end,
					},
					scale = {
						order = 3,
						type = "range",
						min = 1, max = 3, step = 0.1,
						isPercent = true,
						name = L["Scale"],
						disabled = function() return not E.private.enhanced.actionbar.keyPressAnimation end,
					},
					rotation = {
						order = 4,
						type = "range",
						min = 0, max = 360, step = 1,
						name = L["Rotation"],
						disabled = function() return not E.private.enhanced.actionbar.keyPressAnimation end,
					},
				}
			}
		}
	}
end

local function BlizzardOptions()
	local B = E:GetModule("Enhanced_Blizzard")
	local WF = E:GetModule("Enhanced_WatchFrame")
	local TAM = E:GetModule("Enhanced_TakeAllMail")
	local CHAR = E:GetModule("Enhanced_CharacterFrame")

	local choices = {
		["NONE"] = L["NONE"],
		["COLLAPSED"] = L["Collapsed"],
		["HIDDEN"] = L["Hidden"]
	}

	return {
		order = 2,
		type = "group",
		childGroups = "tree",
		name = L["BlizzUI Improvements"],
		get = function(info) return E.private.enhanced[info[#info]] end,
		set = function(info, value)
			E.private.enhanced[info[#info]] = value
			E:StaticPopup_Show("PRIVATE_RL")
		end,
		args = {
			header = {
				order = 1,
				type = "header",
				name = EE:ColorizeSettingName(L["BlizzUI Improvements"])
			},
			general = {
				order = 2,
				type = "group",
				name = L["General"],
				args = {
					header = {
						order = 1,
						type = "header",
						name = L["General"]
					},
					deathRecap = {
						order = 2,
						type = "toggle",
						name = L["Death Recap Frame"]
					},
					takeAllMail = {
						order = 3,
						type = "toggle",
						name = L["Take All Mail"],
						get = function(info) return E.db.enhanced.blizzard.takeAllMail end,
						set = function(info, value)
							E.db.enhanced.blizzard.takeAllMail = value
							if value and not TAM.initialized then
								TAM:Initialize()
							elseif not value then
								E:StaticPopup_Show("CONFIG_RL")
							end
						end
					},
					animatedAchievementBars = {
						order = 4,
						type = "toggle",
						name = L["Animated Achievement Bars"]
					},
					trainAllSkills = {
						order = 5,
						type = "toggle",
						name = L["Train All Button"] or "Train All Button",
						desc = L["Add button to Trainer frame with ability to train all available skills in one click."] or "Add button to Trainer frame with ability to train all available skills in one click.",
						get = function(info) return E.db.enhanced.general.trainAllSkills end,
						set = function(info, value)
							E.db.enhanced.general.trainAllSkills = value
							local trainAllModule = E:GetModule("Enhanced_TrainAll", true)
							if trainAllModule then
								trainAllModule:ToggleState()
							end
						end
					}
				}
			},
			characterFrame = {
				order = 3,
				type = "group",
				name = L["Character Frame"],
				get = function(info) return E.private.enhanced.character[info[#info]] end,
				set = function(info, value)
					E.private.enhanced.character[info[#info]] = value
					E:StaticPopup_Show("PRIVATE_RL")
				end,
				args = {
					header = {
						order = 1,
						type = "header",
						name = L["Character Frame"]
					},
					enable = {
						order = 2,
						type = "toggle",
						name = L["Enhanced Character Frame"]
					},
					modelFrames = {
						order = 3,
						type = "toggle",
						name = L["Enhanced Model Frames"]
					},
					animations = {
						order = 4,
						type = "toggle",
						name = L["Smooth Animations"],
						get = function(info) return E.db.enhanced.character.animations end,
						set = function(info, value)
							E.db.enhanced.character.animations = value
							E:StaticPopup_Show("PRIVATE_RL")
						end,
						disabled = function() return not E.private.enhanced.character.enable end
					},
					paperdollBackgrounds = {
						order = 5,
						type = "group",
						name = L["Paperdoll Backgrounds"],
						guiInline = true,
						get = function(info) return E.db.enhanced.character[info[#info]] end,
						disabled = function() return not E.private.enhanced.character.enable end,
						args = {
							characterBackground = {
								order = 1,
								type = "toggle",
								name = L["Character Background"],
								set = function(info, value)
									E.db.enhanced.character.characterBackground = value
									CHAR:UpdateCharacterModelFrame()
								end
							},
							desaturateCharacter = {
								order = 2,
								type = "toggle",
								name = L["Desaturate"],
								get = function(info) return E.db.enhanced.character.desaturateCharacter end,
								set = function(info, value)
									E.db.enhanced.character.desaturateCharacter = value
									CHAR:UpdateCharacterModelFrame()
								end,
								disabled = function() return not E.private.enhanced.character.enable or not E.db.enhanced.character.characterBackground end
							},
							spacer = {
								order = 3,
								type = "description",
								name = " "
							},
							petBackground = {
								order = 4,
								type = "toggle",
								name = L["Pet Background"],
								set = function(info, value)
									E.db.enhanced.character.petBackground = value
									CHAR:UpdatePetModelFrame()
								end
							},
							desaturatePet = {
								order = 5,
								type = "toggle",
								name = L["Desaturate"],
								get = function(info) return E.db.enhanced.character.desaturatePet end,
								set = function(info, value)
									E.db.enhanced.character.desaturatePet = value
									CHAR:UpdatePetModelFrame()
								end,
								disabled = function() return not E.private.enhanced.character.enable or not E.db.enhanced.character.petBackground end
							},
							spacer2 = {
								order = 6,
								type = "description",
								name = " "
							},
							inspectBackground = {
								order = 6,
								type = "toggle",
								name = L["Inspect Background"],
								set = function(info, value)
									E.db.enhanced.character.inspectBackground = value
									CHAR:UpdateInspectModelFrame()
								end
							},
							desaturateInspect = {
								order = 8,
								type = "toggle",
								name = L["Desaturate"],
								get = function(info) return E.db.enhanced.character.desaturateInspect end,
								set = function(info, value)
									E.db.enhanced.character.desaturateInspect = value
									CHAR:UpdateInspectModelFrame()
								end,
								disabled = function() return not E.private.enhanced.character.enable or not E.db.enhanced.character.inspectBackground end
							},
							spacer3 = {
								order = 9,
								type = "description",
								name = " "
							},
							companionBackground = {
								order = 10,
								type = "toggle",
								name = L["Companion Background"],
								set = function(info, value)
									E.db.enhanced.character.companionBackground = value
									CHAR:UpdateCompanionModelFrame()
								end
							},
							desaturateCompanion = {
								order = 11,
								type = "toggle",
								name = L["Desaturate"],
								get = function(info) return E.db.enhanced.character.desaturateCompanion end,
								set = function(info, value)
									E.db.enhanced.character.desaturateCompanion = value
									CHAR:UpdateCompanionModelFrame()
								end,
								disabled = function() return not E.private.enhanced.character.enable or not E.db.enhanced.character.companionBackground end
							}
						}
					}
				}
			},
			dressingRoom = {
				order = 4,
				type = "group",
				name = L["Dressing Room"],
				get = function(info) return E.db.enhanced.blizzard.dressUpFrame[info[#info]] end,
				set = function(info, value)
					E.db.enhanced.blizzard.dressUpFrame[info[#info]] = value
					E:GetModule("Enhanced_Blizzard"):UpdateDressUpFrame()
				end,
				args = {
					header = {
						order = 1,
						type = "header",
						name = L["Dressing Room"],
					},
					enable = {
						order = 2,
						type = "toggle",
						name = L["Enable"],
						set = function(info, value)
							E.db.enhanced.blizzard.dressUpFrame[info[#info]] = value
							E:StaticPopup_Show("PRIVATE_RL")
						end,
					},
					multiplier = {
						order = 3,
						type = "range",
						min = 1, max = 2, step = 0.01,
						isPercent = true,
						name = L["Scale"],
						disabled = function() return not E.db.enhanced.blizzard.dressUpFrame.enable end
					},
					undressButton = {
						order = 4,
						type = "toggle",
						name = L["Undress Button"],
						desc = L["Add button to Dressing Room frame with ability to undress model."],
						get = function(info) return E.db.enhanced.general.undressButton end,
						set = function(info, value)
							E.db.enhanced.general.undressButton = value
							E:GetModule("Enhanced_UndressButtons"):ToggleState()
						end
					}
				}
			},
			timerTracker = {
				order = 5,
				type = "group",
				name = L["Timer Tracker"],
				get = function(info) return E.db.enhanced.timerTracker[info[#info]] end,
				args = {
					header = {
						order = 1,
						type = "header",
						name = L["Timer Tracker"]
					},
					enable = {
						order = 2,
						type = "toggle",
						name = L["Enable"],
						set = function(info, value)
							E.db.enhanced.timerTracker.enable = value
							E:GetModule("Enhanced_TimerTracker"):ToggleState()
						end
					},
					dbm = {
						order = 3,
						type = "toggle",
						name = L["Hook DBM"],
						set = function(info, value)
							E.db.enhanced.timerTracker.dbm = value
							E:GetModule("Enhanced_TimerTracker"):HookDBM()
						end,
						disabled = function() return not E.db.enhanced.timerTracker.enable end
					},
					dbmTimerType = {
						order = 8,
						type = "select",
						name = L["DBM Timer Type"],
						set = function(info, value)
							E.db.enhanced.timerTracker.dbmTimerType = value
						end,
						values = {
							[1] = L["PvP"],
							[2] = L["Challenge Mode"],
							[3] = L["Player Countdown"]
						},
						disabled = function() return not E.db.enhanced.timerTracker.enable or not E.db.enhanced.timerTracker.dbm end
					}
				}
			},
			watchframe = {
				order = 6,
				type = "group",
				name = L["Watch Frame"],
				get = function(info) return E.db.enhanced.watchframe[info[#info]] end,
				set = function(info, value)
					E.db.enhanced.watchframe[info[#info]] = value
					WF:UpdateSettings()
				end,
				args = {
					header = {
						order = 1,
						type = "header",
						name = L["Watch Frame"],
					},
					intro = {
						order = 2,
						type = "description",
						name = L["WATCHFRAME_DESC"]
					},
					enable = {
						order = 3,
						type = "toggle",
						name = L["Enable"]
					},
					level = {
						order = 4,
						type = "toggle",
						name = L["Show Quest Level"],
						desc = L["Display quest levels at Quest Tracker."],
						set = function(info, value)
							E.db.enhanced.watchframe.level = value
							WF:QuestLevelToggle()
						end
					},
					settings = {
						order = 5,
						type = "group",
						name = L["Visibility State"],
						guiInline = true,
						get = function(info) return E.db.enhanced.watchframe[info[#info]] end,
						set = function(info, value)
							E.db.enhanced.watchframe[info[#info]] = value
							WF:ChangeState()
						end,
						disabled = function() return not E.db.enhanced.watchframe.enable end,
						args = {
							city = {
								order = 1,
								type = "select",
								name = L["City (Resting)"],
								values = choices
							},
							pvp = {
								order = 2,
								type = "select",
								name = L["PvP"],
								values = choices
							},
							arena = {
								order = 3,
								type = "select",
								name = L["Arena"],
								values = choices
							},
							party = {
								order = 4,
								type = "select",
								name = L["Party"],
								values = choices
							},
							raid = {
								order = 5,
								type = "select",
								name = L["Raid"],
								values = choices
							}
						}
					}
				}
			},
		}
	}
end

local function EquipmentInfoOptions()
	return nil
end

local function MapOptions()
	return nil
end

local function MinimapOptions()
	return nil
end

local function InterruptTrackerOptions()
	return nil
end

local function TooltipOptions()
	local IBC = E:GetModule("Enhanced_ItemBorderColor")
	local TI = E:GetModule("Enhanced_TooltipIcon")
	local PI = E:GetModule("Enhanced_ProgressionInfo")

	local tooltipName = L["Tooltip"] or _G.TOOLTIP or "Tooltip"

	local modifierValues = {
		ALL = L["ALL"],
		SHIFT = SHIFT_KEY_TEXT,
		CTRL = CTRL_KEY_TEXT,
		ALT = ALT_KEY_TEXT
	}

	local tierLabels = {
		RS = L["Ruby Sanctum"] or "Ruby Sanctum",
		ICC = L["Icecrown Citadel"] or "Icecrown Citadel",
		ToC = L["Trial of the Crusader"] or "Trial of the Crusader",
		Ulduar = L["Ulduar"] or "Ulduar"
	}

	local function RefreshTooltipIcons()
		TI:ToggleItemsState()
		TI:ToggleSpellsState()
		TI:ToggleAchievementsState()
	end

	return {
		type = "group",
		name = tooltipName,
		args = {
			header = {
				order = 0,
				type = "header",
				name = EE:ColorizeSettingName(tooltipName)
			},
			itemQualityBorderColor = {
				order = 1,
				type = "toggle",
				name = L["Item Border Color"],
				desc = L["Colorize the tooltip border based on item quality."],
				get = function()
					return E.db.enhanced.tooltip.itemQualityBorderColor
				end,
				set = function(_, value)
					E.db.enhanced.tooltip.itemQualityBorderColor = value
					IBC:ToggleState()
				end
			},
			tooltipIcon = {
				order = 2,
				type = "group",
				name = L["Tooltip Icon"],
				guiInline = true,
				get = function(info)
					return E.db.enhanced.tooltip.tooltipIcon[info[#info]]
				end,
				set = function(info, value)
					E.db.enhanced.tooltip.tooltipIcon[info[#info]] = value
					RefreshTooltipIcons()
				end,
				args = {
					enable = {
						order = 1,
						type = "toggle",
						name = L["Enable"],
					},
					tooltipIconItems = {
						order = 2,
						type = "toggle",
						name = ITEMS or L["ITEMS"] or L["Items"] or "Items",
						desc = L["Show/Hides an Icon for Items on the Tooltip."],
					},
					tooltipIconSpells = {
						order = 3,
						type = "toggle",
						name = SPELLS or L["SPELLS"] or L["Spells"] or "Spells",
						desc = L["Show/Hides an Icon for Spells on the Tooltip."],
					},
					tooltipIconAchievements = {
						order = 4,
						type = "toggle",
						name = ACHIEVEMENTS or L["ACHIEVEMENTS"] or L["Achievements"] or "Achievements",
						desc = L["Show/Hides an Icon for Achievements on the Tooltip."],
					},
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
						get = function()
							return E.db.enhanced.tooltip.progressInfo.enable
						end,
						set = function(_, value)
							E.db.enhanced.tooltip.progressInfo.enable = value
							PI:ToggleState()
						end
					},
					checkAchievements = {
						order = 2,
						type = "toggle",
						name = L["Check Achievements"],
						desc = L["Check achievement completion instead of boss kill stats.\nSome servers log incorrect boss kill statistics, this is an alternative way to get player progress."],
						disabled = function()
							return not E.db.enhanced.tooltip.progressInfo.enable
						end,
						get = function()
							return E.db.enhanced.tooltip.progressInfo.checkAchievements
						end,
						set = function(_, value)
							E.db.enhanced.tooltip.progressInfo.checkAchievements = value
							PI:ToggleState()
						end
					},
					checkPlayer = {
						order = 3,
						type = "toggle",
						name = L["Check Player"],
						get = function()
							return E.db.enhanced.tooltip.progressInfo.checkPlayer
						end,
						set = function(_, value)
							E.db.enhanced.tooltip.progressInfo.checkPlayer = value
							PI:ToggleState()
						end,
						disabled = function()
							return not E.db.enhanced.tooltip.progressInfo.enable
						end,
					},
					modifier = {
						order = 4,
						type = "select",
						name = MODIFIER_KEY_TEXT or L["Modifier Key"] or "Modifier Key",
						values = modifierValues,
						get = function()
							return E.db.enhanced.tooltip.progressInfo.modifier
						end,
						set = function(_, value)
							E.db.enhanced.tooltip.progressInfo.modifier = value
							PI:UpdateModifier()
						end,
						disabled = function()
							return not E.db.enhanced.tooltip.progressInfo.enable
						end,
					},
					tiers = {
						order = 5,
						type = "group",
						name = L["Tiers"],
						guiInline = true,
						get = function(info)
							return E.db.enhanced.tooltip.progressInfo.tiers[info[#info]]
						end,
						set = function(info, value)
							E.db.enhanced.tooltip.progressInfo.tiers[info[#info]] = value
							PI:UpdateSettings()
						end,
						disabled = function()
							return not E.db.enhanced.tooltip.progressInfo.enable
						end,
						args = {
							RS = {
								order = 1,
								type = "toggle",
								name = tierLabels.RS
							},
							ICC = {
								order = 2,
								type = "toggle",
								name = tierLabels.ICC
							},
							ToC = {
								order = 3,
								type = "toggle",
								name = tierLabels.ToC
							},
							Ulduar = {
								order = 4,
								type = "toggle",
								name = tierLabels.Ulduar
							},
						}
					}
				}
			}
		}
	}
end

local function UnitFrameOptions()
	local TC = E:GetModule("Enhanced_TargetClass")

	return {
		type = "group",
		name = L["UnitFrames"],
		childGroups = "tab",
		args = {
			header = {
				order = 1,
				type = "header",
				name = EE:ColorizeSettingName(L["UnitFrames"])
			},
			general = {
				order = 2,
				type = "group",
				name = L["General"],
				args = {
					header = {
						order = 1,
						type = "header",
						name = L["General"]
					},
					portraitHDModelFix = {
						order = 2,
						type = "group",
						guiInline = true,
						name = L["Portrait HD Fix"],
						get = function(info) return E.db.enhanced.unitframe.portraitHDModelFix[info[#info]] end,
						set = function(info, value) E.db.enhanced.unitframe.portraitHDModelFix[info[#info]] = value end,
						disabled = function() return not E.db.enhanced.unitframe.portraitHDModelFix.enable end,
						args = {
							enable = {
								order = 1,
								type = "toggle",
								name = L["Enable"],
								set = function(info, value)
									E.db.enhanced.unitframe.portraitHDModelFix.enable = value
									E:GetModule("Enhanced_PortraitHDModelFix"):ToggleState()
								end,
								disabled = false
							},
							debug = {
								order = 2,
								type = "toggle",
								name = L["Debug"],
								desc = L["Print to chat model names of units with enabled 3D portraits."]
							},
							modelsToFix = {
								order = 3,
								type = "input",
								name = L["Models to fix"],
								desc = L["List of models with broken portrait camera. Separete each model name with ';' simbol"],
								width = "full",
								multiline = true,
								set = function(info, value)
									E.db.enhanced.unitframe.portraitHDModelFix.modelsToFix = value
									E:GetModule("Enhanced_PortraitHDModelFix"):UpdatePortraits()
								end
							}
						}
					}
				}
			},
			player = {
				order = 3,
				type = "group",
				name = L["PLAYER"],
				args = {
					header = {
						order = 1,
						type = "header",
						name = L["PLAYER"]
					},
					detachPortrait = {
						order = 3,
						type = "group",
						name = L["Detached Portrait"],
						get = function(info) return E.db.enhanced.unitframe.detachPortrait.player[info[#info]] end,
						set = function(info, value)
							E.db.enhanced.unitframe.detachPortrait.player[info[#info]] = value
							E:GetModule("UnitFrames"):CreateAndUpdateUF("player")
						end,
						disabled = function() return not E.db.unitframe.units.player.portrait.enable or E.db.unitframe.units.player.portrait.overlay end,
						args = {
							header = {
								order = 0,
								type = "header",
								name = L["Portrait"]
							},
							enable = {
								order = 1,
								type = "toggle",
								name = L["Detach From Frame"],
								set = function(info, value)
									E.db.enhanced.unitframe.detachPortrait.player[info[#info]] = value
									E:GetModule("Enhanced_DetachedPortrait"):ToggleState("player")
								end
							},
							spacer = {
								order = 2,
								type = "description",
								name = " "
							},
							width = {
								order = 3,
								type = "range",
								name = L["Detached Width"],
								min = 10, max = 600, step = 1
							},
							height = {
								order = 4,
								type = "range",
								name = L["Detached Height"],
								min = 10, max = 600, step = 1
							}
						}
					}
				}
			},
			target = {
				order = 4,
				type = "group",
				name = L["TARGET"],
				args = {
					header = {
						order = 1,
						type = "header",
						name = L["TARGET"]
					},
					classIcon = {
						order = 2,
						type = "group",
						name = L["Class Icons"],
						get = function(info) return E.db.enhanced.unitframe.units.target.classicon[info[#info]] end,
						set = function(info, value)
							E.db.enhanced.unitframe.units.target.classicon[info[#info]] = value
							TC:ToggleSettings()
						end,
						args = {
							header = {
								order = 0,
								type = "header",
								name = L["Class Icons"]
							},
							enable = {
								order = 1,
								type = "toggle",
								name = L["Enable"],
								desc = L["Show class icon for units."],
								disabled = false
							},
							spacer = {
								order = 2,
								type = "description",
								name = " "
							},
							size = {
								order = 3,
								type = "range",
								name = L["Size"],
								desc = L["Size of the indicator icon."],
								min = 16, max = 40, step = 1
							},
							xOffset = {
								order = 4,
								type = "range",
								name = L["X-Offset"],
								min = -100, max = 100, step = 1
							},
							yOffset = {
								order = 5,
								type = "range",
								name = L["Y-Offset"],
								min = -80, max = 40, step = 1
							}
						}
					},
					detachPortrait = {
						order = 3,
						type = "group",
						name = L["Detached Portrait"],
						get = function(info) return E.db.enhanced.unitframe.detachPortrait.target[info[#info]] end,
						set = function(info, value)
							E.db.enhanced.unitframe.detachPortrait.target[info[#info]] = value
							E:GetModule("UnitFrames"):CreateAndUpdateUF("target")
						end,
						disabled = function() return not E.db.unitframe.units.target.portrait.enable or E.db.unitframe.units.target.portrait.overlay end,
						args = {
							header = {
								order = 0,
								type = "header",
								name = L["Portrait"]
							},
							enable = {
								order = 1,
								type = "toggle",
								name = L["Detach From Frame"],
								set = function(info, value)
									E.db.enhanced.unitframe.detachPortrait.target[info[#info]] = value
									E:GetModule("Enhanced_DetachedPortrait"):ToggleState("target")
								end
							},
							spacer = {
								order = 2,
								type = "description",
								name = " "
							},
							width = {
								order = 3,
								type = "range",
								name = L["Detached Width"],
								min = 10, max = 600, step = 1
							},
							height = {
								order = 4,
								type = "range",
								name = L["Detached Height"],
								min = 10, max = 600, step = 1
							}
						}
					}
				}
			}
		}
	}
end

function EE:GetOptions()
	E.Options.args.enhanced = {
		order = 50,
		type = "group",
		childGroups = "tab",
		name = EE:ColorizeSettingName(L["Enhanced"]),
		args = {
			generalGroup = GeneralOptions(),
			actionbarGroup = ActionbarOptions(),
			blizzardGroup = BlizzardOptions(),
			tooltipGroup = TooltipOptions(),
			unitframesGroup = UnitFrameOptions(),
		}
	}

	E.Options.args.enhanced.args.generalGroup.order = 1
	E.Options.args.enhanced.args.blizzardGroup.order = 2
	E.Options.args.enhanced.args.actionbarGroup.order = 3
	E.Options.args.enhanced.args.tooltipGroup.order = 4
	E.Options.args.enhanced.args.unitframesGroup.order = 5
end
