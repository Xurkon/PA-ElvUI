local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))
-- local WM = E:GetModule("WorldMap") -- Removed - Using Mapster instead
local MM = E:GetModule("Minimap")
local AB = E:GetModule("ActionBars")
-- local MMk = E:GetModule("MapMarkers") -- Removed - Using Mapster instead
local function EnsureButtonGrabberDB()
	E.db.warcraftenhanced = E.db.warcraftenhanced or {}
	local db = E.db.warcraftenhanced.buttonGrabber
	if not db then
		db = E:CopyTable({}, P.warcraftenhanced.buttonGrabber)
		E.db.warcraftenhanced.buttonGrabber = db
	end

	db.insideMinimap = db.insideMinimap or {}

	return db
end

local function UpdateButtonGrabberModule(callback)
	local module = E:GetModule("WarcraftEnhanced_MinimapButtonGrabber", true)
	if not module then return end

	module.db = EnsureButtonGrabberDB()

	if callback and module[callback] then
		module[callback](module)
	else
		module:HandleEnableState()
	end
end

-- Popup dialog for when enabling ElvUI Button Grabber while MBF is installed
E.PopupDialogs.ELVUI_DISABLE_MBF = {
	text =
	"ElvUI will now control minimap buttons.\n\nMinimapButtonFrame is currently installed. Would you like to disable it to avoid conflicts?",
	button1 = "Disable & Reload",
	button2 = "Just Reload",
	button3 = "Cancel",
	OnAccept = function()
		DisableAddOn("MinimapButtonFrame")
		ReloadUI()
	end,
	OnCancel = function()
		ReloadUI()
	end,
	OnAlt = function()
		-- Cancel - do nothing, setting is already saved
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
}



local Mapster = E:GetModule("Mapster", true)


-- Build Mapster options group with all modules
local function BuildMapsterOptions()
	if not (Mapster and Mapster.GetOptions) then
		return {
			order = 1,
			type = "group",
			name = L["WORLD_MAP"],
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["WORLD_MAP"] .. " - Mapster (Loading...)"
				},
				info = {
					order = 2,
					type = "description",
					name = "Mapster world map module is loading. Please reload your UI if this message persists.",
					fontSize = "medium",
				}
			}
		}
	end

	local mapsterOpts = Mapster:GetOptions()
	if mapsterOpts and mapsterOpts.args then
		local args = mapsterOpts.args
		local generalGroup = args.general or {
			order = 1,
			type = "group",
			name = _G.GENERAL or L["WORLD_MAP"],
			args = {}
		}
		if not generalGroup.order then
			generalGroup.order = 1
		end

		local moduleArgs = {}
		for optionKey, optionTable in pairs(args) do
			if optionKey ~= "general" then
				moduleArgs[optionKey] = optionTable
			end
		end

		local modulesLabel = _G.ADDONS or "Modules"

		return {
			order = 1,
			type = "group",
			name = L["WORLD_MAP"],
			childGroups = "tab",
			args = {
				general = generalGroup,
				modules = {
					order = 2,
					type = "group",
					name = modulesLabel,
					childGroups = "tree",
					args = moduleArgs
				}
			}
		}
	end

	-- Fallback
	return {
		order = 1,
		type = "group",
		name = L["WORLD_MAP"],
		args = {
			header = {
				order = 1,
				type = "header",
				name = L["WORLD_MAP"] .. " - Mapster"
			}
		}
	}
end

E.Options.args.maps = {
	order = 90, -- Alphabetical: M
	type = "group",
	name = L["Maps"],
	childGroups = "tab",
	args = {
		worldMap = BuildMapsterOptions(),
		minimap = {
			order = 2,
			type = "group",
			name = L["MINIMAP_LABEL"],
			get = function(info) return E.db.general.minimap[info[#info]] end,
			childGroups = "tab",
			args = {
				minimapHeader = {
					order = 1,
					type = "header",
					name = L["MINIMAP_LABEL"]
				},
				generalGroup = {
					order = 2,
					type = "group",
					name = L["General"],
					guiInline = true,
					args = {
						enable = {
							order = 1,
							type = "toggle",
							name = L["Enable"],
							desc = L
								["Enable/Disable the minimap. |cffFF0000Warning: This will prevent you from seeing the consolidated buffs bar, and prevent you from seeing the minimap datatexts.|r"],
							get = function(info) return E.private.general.minimap[info[#info]] end,
							set = function(info, value)
								E.private.general.minimap[info[#info]] = value
								E:StaticPopup_Show("PRIVATE_RL")
							end
						},
						size = {
							order = 2,
							type = "range",
							name = L["Size"],
							desc = L["Adjust the size of the minimap."],
							min = 120,
							max = 250,
							step = 1,
							get = function(info) return E.db.general.minimap[info[#info]] end,
							set = function(info, value)
								E.db.general.minimap[info[#info]] = value
								MM:UpdateSettings()
							end,
							disabled = function() return not E.private.general.minimap.enable end
						},
						configButton = {
							order = 3,
							type = "toggle",
							name = L["Config Button"],
							desc = "Show/hide the ElvUI configuration button next to the minimap.",
							get = function(info) return E.db.general.minimap.configButton end,
							set = function(info, value)
								E.db.general.minimap.configButton = value
								MM:UpdateSettings()
							end,
							disabled = function()
								return not E.private.general.minimap.enable or
									not E.db.general.reminder.enable or not E.db.datatexts.minimapPanels
							end
						}
					}
				},
				locationTextGroup = {
					order = 3,
					type = "group",
					name = L["Location Text"],
					args = {
						locationHeader = {
							order = 1,
							type = "header",
							name = L["Location Text"]
						},
						locationText = {
							order = 2,
							type = "select",
							name = L["Location Text"],
							desc = L["Change settings for the display of the location text that is on the minimap."],
							get = function(info) return E.db.general.minimap.locationText end,
							set = function(info, value)
								E.db.general.minimap.locationText = value
								MM:UpdateSettings()
								MM:Update_ZoneText()
							end,
							values = {
								["MOUSEOVER"] = L["Minimap Mouseover"],
								["SHOW"] = L["Always Display"],
								["HIDE"] = L["HIDE"]
							},
							disabled = function() return not E.private.general.minimap.enable end
						},
						spacer = {
							order = 3,
							type = "description",
							name = "\n"
						},
						locationFont = {
							order = 4,
							type = "select",
							dialogControl = "LSM30_Font",
							name = L["Font"],
							values = AceGUIWidgetLSMlists.font,
							set = function(info, value)
								E.db.general.minimap.locationFont = value
								MM:Update_ZoneText()
							end,
							disabled = function() return not E.private.general.minimap.enable end
						},
						locationFontSize = {
							order = 5,
							type = "range",
							name = L["FONT_SIZE"],
							min = 6,
							max = 36,
							step = 1,
							set = function(info, value)
								E.db.general.minimap.locationFontSize = value
								MM:Update_ZoneText()
							end,
							disabled = function() return not E.private.general.minimap.enable end
						},
						locationFontOutline = {
							order = 6,
							type = "select",
							name = L["Font Outline"],
							set = function(info, value)
								E.db.general.minimap.locationFontOutline = value
								MM:Update_ZoneText()
							end,
							disabled = function() return not E.private.general.minimap.enable end,
							values = C.Values.FontFlags
						}
					}
				},
				zoomResetGroup = {
					order = 4,
					type = "group",
					name = L["Reset Zoom"],
					args = {
						zoomResetHeader = {
							order = 1,
							type = "header",
							name = L["Reset Zoom"]
						},
						enableZoomReset = {
							order = 2,
							type = "toggle",
							name = L["Reset Zoom"],
							get = function(info) return E.db.general.minimap.resetZoom.enable end,
							set = function(info, value)
								E.db.general.minimap.resetZoom.enable = value
								MM:UpdateSettings()
							end,
							disabled = function() return not E.private.general.minimap.enable end
						},
						zoomResetTime = {
							order = 3,
							type = "range",
							name = L["Seconds"],
							min = 1,
							max = 15,
							step = 1,
							get = function(info) return E.db.general.minimap.resetZoom.time end,
							set = function(info, value)
								E.db.general.minimap.resetZoom.time = value
								MM:UpdateSettings()
							end,
							disabled = function() return (not E.db.general.minimap.resetZoom.enable or not E.private.general.minimap.enable) end
						}
					}
				},
				icons = {
					order = 5,
					type = "group",
					name = L["Buttons"],
					args = {
						header = {
							order = 0,
							type = "header",
							name = L["Buttons"]
						},
						mbfIntegration = {
							order = 0.5,
							type = "group",
							name = "MinimapButtonFrame",
							hidden = function() return not IsAddOnLoaded("MinimapButtonFrame") end,
							args = {
								mbfHeader = {
									order = 1,
									type = "header",
									name = "MinimapButtonFrame Integration"
								},
								mbfControlEnabled = {
									order = 2,
									type = "toggle",
									name = "Let MBF Control Buttons",
									desc =
									"When enabled, MinimapButtonFrame will manage all minimap buttons instead of ElvUI. ElvUI's button options below will be disabled.",
									get = function() return E.db.general.minimap.mbfControlEnabled end,
									set = function(_, value)
										E.db.general.minimap.mbfControlEnabled = value
										-- Notify the Button Grabber module to update its state
										local MBG = E:GetModule("WarcraftEnhanced_MinimapButtonGrabber", true)
										if MBG then
											MBG:HandleEnableState()
										end
										MM:UpdateSettings()
										-- When disabling MBF control (value=false), ElvUI takes over - offer to disable MBF
										if not value then
											E:StaticPopup_Show("ELVUI_DISABLE_MBF")
										else
											-- Enabling MBF control, just reload
											E:StaticPopup_Show("CONFIG_RL")
										end
									end,
									width = "full"
								},
								mbfNotice = {
									order = 3,
									type = "description",
									name =
									"\n|cff00ff00MinimapButtonFrame is controlling minimap buttons.|r\n\nConfigure button settings in MBF's options instead.\n\nElvUI's button options below are disabled while this is enabled.\n",
									hidden = function() return not E.db.general.minimap.mbfControlEnabled end
								}
							}
						},
						calendar = {
							order = 1,
							type = "group",
							name = L["Calendar"],
							get = function(info) return E.db.general.minimap.icons.calendar[info[#info]] end,
							set = function(info, value)
								E.db.general.minimap.icons.calendar[info[#info]] = value
								MM:UpdateSettings()
							end,
							disabled = function()
								return not E.private.general.minimap.enable or
									E.db.general.minimap.mbfControlEnabled
							end,
							args = {
								calendarHeader = {
									order = 1,
									type = "header",
									name = L["Calendar"]
								},
								hideCalendar = {
									order = 2,
									type = "toggle",
									name = L["HIDE"],
									get = function(info) return E.private.general.minimap.hideCalendar end,
									set = function(info, value)
										E.private.general.minimap.hideCalendar = value
										MM:UpdateSettings()
									end,
									width = "full"
								},
								spacer = {
									order = 3,
									type = "description",
									name = "",
									width = "full"
								},
								position = {
									order = 4,
									type = "select",
									name = L["Position"],
									disabled = function()
										return E.private.general.minimap.hideCalendar or
											E.db.general.minimap.mbfControlEnabled
									end,
									values = {
										["LEFT"] = L["Left"],
										["RIGHT"] = L["Right"],
										["TOP"] = L["Top"],
										["BOTTOM"] = L["Bottom"],
										["TOPLEFT"] = L["Top Left"],
										["TOPRIGHT"] = L["Top Right"],
										["BOTTOMLEFT"] = L["Bottom Left"],
										["BOTTOMRIGHT"] = L["Bottom Right"]
									}
								},
								scale = {
									order = 5,
									type = "range",
									name = L["Scale"],
									min = 0.5,
									max = 2,
									step = 0.05,
									disabled = function()
										return E.private.general.minimap.hideCalendar or
											E.db.general.minimap.mbfControlEnabled
									end
								},
								xOffset = {
									order = 6,
									type = "range",
									name = L["X-Offset"],
									min = -50,
									max = 50,
									step = 1,
									disabled = function()
										return E.private.general.minimap.hideCalendar or
											E.db.general.minimap.mbfControlEnabled
									end
								},
								yOffset = {
									order = 7,
									type = "range",
									name = L["Y-Offset"],
									min = -50,
									max = 50,
									step = 1,
									disabled = function()
										return E.private.general.minimap.hideCalendar or
											E.db.general.minimap.mbfControlEnabled
									end
								}
							}
						},
						buttonGrabber = {
							order = 6,
							type = "group",
							name = L["Minimap Button Grabber"],
							disabled = function() return E.db.general.minimap.mbfControlEnabled end,
							get = function(info)
								local db = EnsureButtonGrabberDB()
								return db[info[#info]]
							end,
							set = function(info, value)
								local db = EnsureButtonGrabberDB()
								db[info[#info]] = value
								UpdateButtonGrabberModule()
							end,
							args = {
								enable = {
									order = 1,
									type = "toggle",
									name = L["Enable"],
									get = function()
										return EnsureButtonGrabberDB().enable
									end,
									set = function(_, value)
										local db = EnsureButtonGrabberDB()
										db.enable = value
										UpdateButtonGrabberModule()
										if value then
											-- Enabling Button Grabber - check for MBF conflict
											if IsAddOnLoaded("MinimapButtonFrame") then
												E:StaticPopup_Show("ELVUI_DISABLE_MBF")
											else
												E:StaticPopup_Show("CONFIG_RL")
											end
										else
											E:StaticPopup_Show("CONFIG_RL")
										end
									end,
									disabled = function() return E.db.general.minimap.mbfControlEnabled end
								},
								spacer1 = {
									order = 2,
									type = "description",
									name = " ",
									width = "full"
								},
								growFrom = {
									order = 3,
									type = "select",
									name = L["Grow direction"],
									values = {
										["TOPLEFT"] = "DOWN -> RIGHT",
										["TOPRIGHT"] = "DOWN -> LEFT",
										["BOTTOMLEFT"] = "UP -> RIGHT",
										["BOTTOMRIGHT"] = "UP -> LEFT"
									},
									disabled = function()
										if E.db.general.minimap.mbfControlEnabled then return true end
										local db = EnsureButtonGrabberDB()
										return not db.enable
									end
								},
								buttonsPerRow = {
									order = 4,
									type = "range",
									name = L["Buttons Per Row"],
									min = 1,
									max = 12,
									step = 1,
									disabled = function()
										if E.db.general.minimap.mbfControlEnabled then return true end
										local db = EnsureButtonGrabberDB()
										return not db.enable
									end
								},
								buttonSize = {
									order = 5,
									type = "range",
									name = L["Button Size"],
									min = 10,
									max = 60,
									step = 1,
									disabled = function()
										if E.db.general.minimap.mbfControlEnabled then return true end
										local db = EnsureButtonGrabberDB()
										return not db.enable
									end
								},
								buttonSpacing = {
									order = 6,
									type = "range",
									name = L["Button Spacing"],
									min = -1,
									max = 24,
									step = 1,
									disabled = function()
										if E.db.general.minimap.mbfControlEnabled then return true end
										local db = EnsureButtonGrabberDB()
										return not db.enable
									end
								},
								backdrop = {
									order = 7,
									type = "toggle",
									name = L["Backdrop"],
									set = function(info, value)
										local db = EnsureButtonGrabberDB()
										db[info[#info]] = value
										UpdateButtonGrabberModule("UpdateLayout")
									end,
									disabled = function()
										if E.db.general.minimap.mbfControlEnabled then return true end
										return not EnsureButtonGrabberDB().enable
									end
								},
								backdropSpacing = {
									order = 8,
									type = "range",
									name = L["Backdrop Spacing"],
									min = -1,
									max = 15,
									step = 1,
									disabled = function()
										if E.db.general.minimap.mbfControlEnabled then return true end
										local db = EnsureButtonGrabberDB()
										return not db.enable or not db.backdrop
									end,
								},
								mouseover = {
									order = 9,
									type = "toggle",
									name = L["Mouse Over"],
									set = function(info, value)
										local db = EnsureButtonGrabberDB()
										db[info[#info]] = value
										UpdateButtonGrabberModule("ToggleMouseover")
									end,
									disabled = function()
										if E.db.general.minimap.mbfControlEnabled then return true end
										local db = EnsureButtonGrabberDB()
										return not db.enable
									end
								},
								alpha = {
									order = 10,
									type = "range",
									name = L["Alpha"],
									min = 0,
									max = 1,
									step = 0.01,
									set = function(info, value)
										local db = EnsureButtonGrabberDB()
										db[info[#info]] = value
										UpdateButtonGrabberModule("UpdateAlpha")
									end,
									disabled = function()
										if E.db.general.minimap.mbfControlEnabled then return true end
										local db = EnsureButtonGrabberDB()
										return not db.enable
									end
								},
								insideMinimap = {
									order = 11,
									type = "group",
									name = L["Inside Minimap"],
									guiInline = true,
									get = function(info)
										local db = EnsureButtonGrabberDB()
										return db.insideMinimap[info[#info]]
									end,
									set = function(info, value)
										local db = EnsureButtonGrabberDB()
										db.insideMinimap[info[#info]] = value
										UpdateButtonGrabberModule("UpdatePosition")
									end,
									disabled = function()
										if E.db.general.minimap.mbfControlEnabled then return true end
										local db = EnsureButtonGrabberDB()
										return not db.enable
									end,
									args = {
										enable = {
											order = 1,
											type = "toggle",
											name = L["Enable"],
											set = function(info, value)
												local db = EnsureButtonGrabberDB()
												db.insideMinimap[info[#info]] = value
												UpdateButtonGrabberModule("UpdatePosition")
											end
										},
										position = {
											order = 2,
											type = "select",
											name = L["Position"],
											values = {
												["TOPLEFT"] = L["Top Left"],
												["TOPRIGHT"] = L["Top Right"],
												["BOTTOMLEFT"] = L["Bottom Left"],
												["BOTTOMRIGHT"] = L["Bottom Right"]
											},
											disabled = function()
												local db = EnsureButtonGrabberDB()
												return not db.insideMinimap.enable
											end
										},
										xOffset = {
											order = 3,
											type = "range",
											name = L["X-Offset"],
											min = -100,
											max = 100,
											step = 1,
											disabled = function()
												local db = EnsureButtonGrabberDB()
												return not db.insideMinimap.enable
											end
										},
										yOffset = {
											order = 4,
											type = "range",
											name = L["Y-Offset"],
											min = -100,
											max = 100,
											step = 1,
											disabled = function()
												local db = EnsureButtonGrabberDB()
												return not db.insideMinimap.enable
											end
										}
									}
								}
							}
						},
						mail = {
							order = 3,
							type = "group",
							name = L["MAIL_LABEL"],
							get = function(info) return E.db.general.minimap.icons.mail[info[#info]] end,
							set = function(info, value)
								E.db.general.minimap.icons.mail[info[#info]] = value
								MM:UpdateSettings()
							end,
							disabled = function()
								return not E.private.general.minimap.enable or
									E.db.general.minimap.mbfControlEnabled
							end,
							args = {
								mailHeader = {
									order = 1,
									type = "header",
									name = L["MAIL_LABEL"]
								},
								position = {
									order = 2,
									type = "select",
									name = L["Position"],
									values = {
										["LEFT"] = L["Left"],
										["RIGHT"] = L["Right"],
										["TOP"] = L["Top"],
										["BOTTOM"] = L["Bottom"],
										["TOPLEFT"] = L["Top Left"],
										["TOPRIGHT"] = L["Top Right"],
										["BOTTOMLEFT"] = L["Bottom Left"],
										["BOTTOMRIGHT"] = L["Bottom Right"]
									}
								},
								scale = {
									order = 3,
									type = "range",
									name = L["Scale"],
									min = 0.5,
									max = 2,
									step = 0.05
								},
								xOffset = {
									order = 4,
									type = "range",
									name = L["X-Offset"],
									min = -50,
									max = 50,
									step = 1
								},
								yOffset = {
									order = 5,
									type = "range",
									name = L["Y-Offset"],
									min = -50,
									max = 50,
									step = 1
								}
							}
						},
						lfgEye = {
							order = 4,
							type = "group",
							name = L["LFG Queue"],
							get = function(info) return E.db.general.minimap.icons.lfgEye[info[#info]] end,
							set = function(info, value)
								E.db.general.minimap.icons.lfgEye[info[#info]] = value
								MM:UpdateSettings()
							end,
							disabled = function()
								return not E.private.general.minimap.enable or
									E.db.general.minimap.mbfControlEnabled
							end,
							args = {
								lfgEyeHeader = {
									order = 1,
									type = "header",
									name = L["LFG Queue"]
								},
								position = {
									order = 2,
									type = "select",
									name = L["Position"],
									values = {
										["LEFT"] = L["Left"],
										["RIGHT"] = L["Right"],
										["TOP"] = L["Top"],
										["BOTTOM"] = L["Bottom"],
										["TOPLEFT"] = L["Top Left"],
										["TOPRIGHT"] = L["Top Right"],
										["BOTTOMLEFT"] = L["Bottom Left"],
										["BOTTOMRIGHT"] = L["Bottom Right"]
									}
								},
								scale = {
									order = 3,
									type = "range",
									name = L["Scale"],
									min = 0.5,
									max = 2,
									step = 0.05
								},
								xOffset = {
									order = 4,
									type = "range",
									name = L["X-Offset"],
									min = -50,
									max = 50,
									step = 1
								},
								yOffset = {
									order = 5,
									type = "range",
									name = L["Y-Offset"],
									min = -50,
									max = 50,
									step = 1
								}
							}
						},
						battlefield = {
							order = 5,
							type = "group",
							name = L["PvP Queue"],
							get = function(info) return E.db.general.minimap.icons.battlefield[info[#info]] end,
							set = function(info, value)
								E.db.general.minimap.icons.battlefield[info[#info]] = value
								MM:UpdateSettings()
							end,
							disabled = function()
								return not E.private.general.minimap.enable or
									E.db.general.minimap.mbfControlEnabled
							end,
							args = {
								battlefieldHeader = {
									order = 1,
									type = "header",
									name = L["PvP Queue"]
								},
								position = {
									order = 2,
									type = "select",
									name = L["Position"],
									values = {
										["LEFT"] = L["Left"],
										["RIGHT"] = L["Right"],
										["TOP"] = L["Top"],
										["BOTTOM"] = L["Bottom"],
										["TOPLEFT"] = L["Top Left"],
										["TOPRIGHT"] = L["Top Right"],
										["BOTTOMLEFT"] = L["Bottom Left"],
										["BOTTOMRIGHT"] = L["Bottom Right"]
									}
								},
								scale = {
									order = 3,
									type = "range",
									name = L["Scale"],
									min = 0.5,
									max = 2,
									step = 0.05
								},
								xOffset = {
									order = 4,
									type = "range",
									name = L["X-Offset"],
									min = -50,
									max = 50,
									step = 1
								},
								yOffset = {
									order = 5,
									type = "range",
									name = L["Y-Offset"],
									min = -50,
									max = 50,
									step = 1
								}
							}
						},
						difficulty = {
							order = 6,
							type = "group",
							name = L["Instance Difficulty"],
							get = function(info) return E.db.general.minimap.icons.difficulty[info[#info]] end,
							set = function(info, value)
								E.db.general.minimap.icons.difficulty[info[#info]] = value
								MM:UpdateSettings()
							end,
							disabled = function()
								return not E.private.general.minimap.enable or
									E.db.general.minimap.mbfControlEnabled
							end,
							args = {
								difficultyHeader = {
									order = 1,
									type = "header",
									name = L["Instance Difficulty"]
								},
								position = {
									order = 2,
									type = "select",
									name = L["Position"],
									values = {
										["LEFT"] = L["Left"],
										["RIGHT"] = L["Right"],
										["TOP"] = L["Top"],
										["BOTTOM"] = L["Bottom"],
										["TOPLEFT"] = L["Top Left"],
										["TOPRIGHT"] = L["Top Right"],
										["BOTTOMLEFT"] = L["Bottom Left"],
										["BOTTOMRIGHT"] = L["Bottom Right"]
									}
								},
								scale = {
									order = 3,
									type = "range",
									name = L["Scale"],
									min = 0.5,
									max = 2,
									step = 0.05
								},
								xOffset = {
									order = 4,
									type = "range",
									name = L["X-Offset"],
									min = -50,
									max = 50,
									step = 1
								},
								yOffset = {
									order = 5,
									type = "range",
									name = L["Y-Offset"],
									min = -50,
									max = 50,
									step = 1
								}
							}
						},
						vehicleLeave = {
							order = 7,
							type = "group",
							name = L["LEAVE_VEHICLE"],
							get = function(info) return E.db.general.minimap.icons.vehicleLeave[info[#info]] end,
							set = function(info, value)
								E.db.general.minimap.icons.vehicleLeave[info[#info]] = value
								AB:UpdateVehicleLeave()
							end,
							disabled = function()
								return not E.private.general.minimap.enable or
									E.db.general.minimap.mbfControlEnabled
							end,
							args = {
								vehicleLeaveHeader = {
									order = 1,
									type = "header",
									name = L["LEAVE_VEHICLE"]
								},
								hide = {
									order = 2,
									type = "toggle",
									name = L["HIDE"]
								},
								spacer = {
									order = 3,
									type = "description",
									name = "",
									width = "full"
								},
								position = {
									order = 4,
									type = "select",
									name = L["Position"],
									values = {
										["LEFT"] = L["Left"],
										["RIGHT"] = L["Right"],
										["TOP"] = L["Top"],
										["BOTTOM"] = L["Bottom"],
										["TOPLEFT"] = L["Top Left"],
										["TOPRIGHT"] = L["Top Right"],
										["BOTTOMLEFT"] = L["Bottom Left"],
										["BOTTOMRIGHT"] = L["Bottom Right"]
									}
								},
								scale = {
									order = 5,
									type = "range",
									name = L["Scale"],
									min = 0.5,
									max = 2,
									step = 0.05,
								},
								xOffset = {
									order = 6,
									type = "range",
									name = L["X-Offset"],
									min = -50,
									max = 50,
									step = 1
								},
								yOffset = {
									order = 7,
									type = "range",
									name = L["Y-Offset"],
									min = -50,
									max = 50,
									step = 1
								}
							}
						}
					}
				}
			}
		}
		-- Removed magnify options - Mapster includes similar zoom functionality
	}
}
