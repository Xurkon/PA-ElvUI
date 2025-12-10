local E, L, V, P, G = unpack(ElvUI)

P.enhanced = {
	general = {
		autoRepChange = false,
		merchant = false,
		showQuestLevel = false,
		undressButton = false,
		alreadyKnown = false,
		ghostEffect = true,
		trainAllSkills = false,
	},
	actionbar = {
		keyPressAnimation = {
			color = {r = 1, g = 1, b = 1},
			scale = 1.5,
			rotation = 90,
		}
	},
	blizzard = {
		dressUpFrame = {
			enable = false,
			multiplier = 1.25
		},
		takeAllMail = false
	},
	chat = {
		dpsLinks = false,
	},
	character = {
		animations = false,
		characterBackground = false,
		petBackground = false,
		inspectBackground = false,
		companionBackground = false,
		desaturateCharacter = false,
		desaturatePet = false,
		desaturateInspect = false,
		desaturateCompanion = false
	},
	nameplates = {
		classCache = false,
		chatBubbles = false,
		titleCache = false,
		guild = {
			font = "PT Sans Narrow",
			fontSize = 11,
			fontOutline = "OUTLINE",
			separator = " ",
			colors = {
				raid = {r = 1, g = 127/255, b = 0},
				party = {r = 118/255, g = 200/255, b = 1},
				guild = {r = 64/255, g = 1, b = 64/255},
				none = {r = 1, g = 1, b = 1}
			},
			visibility = {
				city = true,
				pvp = true,
				arena = true,
				party = true,
				raid = true
			}
		},
		npc = {
			font = "PT Sans Narrow",
			fontSize = 11,
			fontOutline = "OUTLINE",
			reactionColor = false,
			color = {r = 1, g = 1, b = 1},
			separator = " ",
		}
	},
	tooltip = {
		itemQualityBorderColor = false,
		tooltipIcon = {
			enable = false,
			tooltipIconSpells = true,
			tooltipIconItems = true,
			tooltipIconAchievements = true
		},
		progressInfo = {
			enable = false,
			checkAchievements = false,
			checkPlayer = false,
			modifier = "SHIFT",
			tiers = {
				["RS"] = true,
				["ICC"] = true,
				["ToC"] = true,
				["Ulduar"] = true
			}
		}
	},
	loseControl = {
		iconSize = 60,
		compactMode = false,
		CC = true,
		PvE = true,
		Silence = true,
		Disarm = true,
		Root = false,
		Snare = false
	},
	timerTracker = {
		dbm = true,
		dbmTimerType = 3
	},
	unitframe = {
		portraitHDModelFix = {
			enable = false,
			debug = false,
			modelsToFix = "scourgemale.m2; scourgefemale.m2; humanfemale.m2; dwarfmale.m2; orcmalenpc.m2; scourgemalenpc.m2; scourgefemalenpc.m2; dwarfmalenpc.m2; humanmalekid.m2; humanfemalekid.m2; chicken.m2; rat.m2"
		},
		detachPortrait = {
			player = {
				enable = false,
				width = 54,
				height = 54
			},
			target = {
				enable = false,
				width = 54,
				height = 54
			}
		},
		units = {
			target = {
				classicon = {
					enable = false,
					size = 28,
					xOffset = -58,
					yOffset = -22
				}
			}
		},
		hideRoleInCombat = false
	},
	watchframe = {
		enable = false,
		level = false,
		city = "COLLAPSED",
		pvp = "HIDDEN",
		arena = "HIDDEN",
		party = "COLLAPSED",
		raid = "COLLAPSED"
	}
}
