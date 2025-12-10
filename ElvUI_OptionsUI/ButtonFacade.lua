local E, _, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local C, L = unpack(select(2, ...))

-- Early safety check
if not E or not E.db then return end

-- ButtonFacade is optional, silently skip if not available
local BF = E:GetModule("ButtonFacade", true)
if not BF then return end

local LBF = E.Libs.LBF
if not LBF then return end

local ACH = E.Libs.ACH
if not ACH then return end

-- Create reload popup for ButtonFacade changes
E.PopupDialogs.BUTTONFACADE_RL = {
	text = L["ButtonFacade changes require a UI reload to take full effect. Reload now?"],
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function()
		ReloadUI()
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
}

local function GetSkinList()
	local skins = {}
	local skinList = LBF:ListSkins()
	if skinList then
		for skinID in pairs(skinList) do
			skins[skinID] = skinID
		end
	end
	return skins
end

-- Function to get ButtonFacade options for ActionBars (to inject into ActionBar settings)
local function GetActionBarButtonFacadeOptions()
	return {
		buttonFacadeHeader = {
			order = 1000,
			type = 'header',
			name = L["ButtonFacade Skinning"],
		},
		buttonFacadeDesc = {
			order = 1001,
			type = 'description',
			name = L["ButtonFacade allows you to skin your action bar buttons with various styles. The LBF Support option below must be enabled."],
		},
		lbfSpacer = {
			order = 1002,
			type = 'description',
			name = ' ',
		},
		buttonFacadeSkin = {
			order = 1003,
			type = 'select',
			name = L["Button Skin"],
			desc = L["Select the button skin style to use for action bars"],
			disabled = function() return not (E.private and E.private.actionbar and E.private.actionbar.lbf and E.private.actionbar.lbf.enable) end,
			get = function(info)
				if E.private and E.private.actionbar and E.private.actionbar.lbf then
					return E.private.actionbar.lbf.skin
				end
			end,
			set = function(info, value)
				if E.private and E.private.actionbar and E.private.actionbar.lbf then
					E.private.actionbar.lbf.skin = value
					local BF = E:GetModule("ButtonFacade", true)
					if BF then BF:UpdateSkins() end
				end
			end,
			values = function() return GetSkinList() end,
		},
		buttonFacadeGloss = {
			order = 1004,
			type = 'range',
			name = L["Gloss"],
			desc = L["Adjust the gloss/shine intensity on buttons"],
			disabled = function() return not (E.private and E.private.actionbar and E.private.actionbar.lbf and E.private.actionbar.lbf.enable) end,
			min = 0,
			max = 1,
			step = 0.01,
			isPercent = true,
			get = function(info)
				if E.db and E.db.buttonFacade and E.db.buttonFacade.actionbars then
					return E.db.buttonFacade.actionbars.Gloss
				end
			end,
			set = function(info, value)
				if E.db and E.db.buttonFacade and E.db.buttonFacade.actionbars then
					E.db.buttonFacade.actionbars.Gloss = value
					local BF = E:GetModule("ButtonFacade", true)
					if BF then BF:UpdateSkins() end
				end
			end,
		},
		buttonFacadeBackdrop = {
			order = 1005,
			type = 'toggle',
			name = L["Backdrop"],
			desc = L["Show backdrop behind buttons"],
			disabled = function() return not (E.private and E.private.actionbar and E.private.actionbar.lbf and E.private.actionbar.lbf.enable) end,
			get = function(info)
				if E.db and E.db.buttonFacade and E.db.buttonFacade.actionbars then
					return E.db.buttonFacade.actionbars.Backdrop
				end
			end,
			set = function(info, value)
				if E.db and E.db.buttonFacade and E.db.buttonFacade.actionbars then
					E.db.buttonFacade.actionbars.Backdrop = value
					local BF = E:GetModule("ButtonFacade", true)
					if BF then BF:UpdateSkins() end
				end
			end,
		},
	}
end

local function configTable()
	local config = {
		order = 2,
		type = 'group',
		name = L["ButtonFacade"],
		childGroups = 'tab',
		get = function(info) 
			if E.db and E.db.buttonFacade then 
				return E.db.buttonFacade[info[#info]] 
			end 
		end,
		set = function(info, value) 
			if E.db and E.db.buttonFacade then 
				E.db.buttonFacade[info[#info]] = value 
			end 
		end,
		args = {
			intro = {
				order = 1,
				type = 'description',
				name = L["ButtonFacade Settings"] .. "\n\n|cffFF0000IMPORTANT:|r You must enable |cff1784d1LBF Support|r in |cff1784d1ActionBars > General Options|r for ButtonFacade to work. After enabling, a reload is required.",
			},
			spacer1 = {
				order = 2,
				type = 'description',
				name = ' ',
			},
			actionbars = {
				order = 10,
				type = 'group',
				name = L["Action Bars"],
				get = function(info) 
					if E.db and E.db.buttonFacade and E.db.buttonFacade.actionbars then
						return E.db.buttonFacade.actionbars[info[#info]] 
					end
				end,
				set = function(info, value)
					if E.db and E.db.buttonFacade and E.db.buttonFacade.actionbars then
						E.db.buttonFacade.actionbars[info[#info]] = value
						if BF then BF:UpdateSkins() end
					end
				end,
				args = {
					header = {
						order = 1,
						type = 'header',
						name = L["Action Bar Skins"],
					},
					note = {
						order = 2,
						type = 'description',
						name = L["Customize the appearance of your action bar buttons."],
					},
					spacer1 = {
						order = 3,
						type = 'description',
						name = ' ',
					},
					enable = {
						order = 4,
						type = 'toggle',
						name = L["Enable"],
						desc = L["Enable ButtonFacade skinning for action bars"] .. "\n\n|cffFF0000Note:|r A UI reload is required for changes to take full effect.",
						get = function(info)
							if E.db and E.db.actionbar and E.db.actionbar.lbf then
								return E.db.actionbar.lbf.enable
							end
						end,
						set = function(info, value)
							if E.db and E.db.actionbar and E.db.actionbar.lbf then
								E.db.actionbar.lbf.enable = value
								if BF then BF:UpdateSkins() end
								-- Show reload popup
								E:StaticPopup_Show('BUTTONFACADE_RL')
							end
						end,
					},
					spacer2 = {
						order = 5,
						type = 'description',
						name = ' ',
					},
					SkinID = {
						order = 6,
						type = 'select',
						name = L["Skin"],
						desc = L["Select the button skin to use"] .. "\n\n|cffFF0000Note:|r Some skins may require a UI reload to display correctly.",
						disabled = function() return not (E.db and E.db.actionbar and E.db.actionbar.lbf and E.db.actionbar.lbf.enable) end,
						get = function(info)
							if E.db and E.db.actionbar and E.db.actionbar.lbf then
								return E.db.actionbar.lbf.skin
							end
						end,
						set = function(info, value)
							if E.db and E.db.actionbar and E.db.actionbar.lbf then
								local oldSkin = E.db.actionbar.lbf.skin
								E.db.actionbar.lbf.skin = value
								if BF then BF:UpdateSkins() end
								-- Only show reload popup if skin actually changed
								if oldSkin ~= value then
									E:StaticPopup_Show('BUTTONFACADE_RL')
								end
							end
						end,
						values = function() return GetSkinList() end,
					},
					Gloss = {
						order = 7,
						type = 'range',
						name = L["Gloss"],
						desc = L["Adjust the gloss/shine intensity on buttons"],
						disabled = function() return not (E.db and E.db.actionbar and E.db.actionbar.lbf and E.db.actionbar.lbf.enable) end,
						min = 0,
						max = 1,
						step = 0.01,
						isPercent = true,
						get = function(info)
							if E.db and E.db.buttonFacade and E.db.buttonFacade.actionbars then
								return E.db.buttonFacade.actionbars.Gloss
							end
						end,
						set = function(info, value)
							if E.db and E.db.buttonFacade and E.db.buttonFacade.actionbars then
								E.db.buttonFacade.actionbars.Gloss = value
								if BF then BF:UpdateSkins() end
							end
						end,
					},
					Backdrop = {
						order = 8,
						type = 'toggle',
						name = L["Backdrop"],
						desc = L["Show backdrop behind buttons"],
						disabled = function() return not (E.db and E.db.actionbar and E.db.actionbar.lbf and E.db.actionbar.lbf.enable) end,
						get = function(info)
							if E.db and E.db.buttonFacade and E.db.buttonFacade.actionbars then
								return E.db.buttonFacade.actionbars.Backdrop
							end
						end,
						set = function(info, value)
							if E.db and E.db.buttonFacade and E.db.buttonFacade.actionbars then
								E.db.buttonFacade.actionbars.Backdrop = value
								if BF then BF:UpdateSkins() end
							end
						end,
					},
					spacer3 = {
						order = 9,
						type = 'description',
						name = ' ',
					},
					reset = {
						order = 10,
						type = 'execute',
						name = L["Reset All Button Skins"],
						desc = L["Reset all button skins to default"],
						func = function() BF:ResetActionBarSkins() end,
					},
				},
			},
			auras = {
				order = 20,
				type = 'group',
				name = L["Auras"],
				get = function(info) 
					if E.db and E.db.buttonFacade and E.db.buttonFacade.auras then
						return E.db.buttonFacade.auras[info[#info]] 
					end
				end,
				set = function(info, value)
					if E.db and E.db.buttonFacade and E.db.buttonFacade.auras then
						E.db.buttonFacade.auras[info[#info]] = value
						if BF then BF:UpdateSkins() end
					end
				end,
				args = {
					enabled = {
						order = 1,
						type = 'toggle',
						name = L["Enable"],
						desc = L["Enable ButtonFacade for Action Bars"],
					},
					spacer1 = {
						order = 2,
						type = 'description',
						name = ' ',
					},
					SkinID = {
						order = 3,
						type = 'select',
						name = L["Skin"],
						desc = L["Select the button skin to use"],
						values = function() return GetSkinList() end,
					},
					Gloss = {
						order = 4,
						type = 'range',
						name = L["Gloss"],
						desc = L["Adjust the gloss/shine intensity on buttons"],
						min = 0,
						max = 1,
						step = 0.01,
						isPercent = true,
					},
					Backdrop = {
						order = 5,
						type = 'toggle',
						name = L["Backdrop"],
						desc = L["Show backdrop behind buttons"],
					},
					spacer2 = {
						order = 6,
						type = 'description',
						name = ' ',
					},
					reset = {
						order = 7,
						type = 'execute',
						name = L["Reset All Button Skins"],
						desc = L["Reset all button skins to default"],
						func = function() BF:ResetActionBarSkins() end,
					},
				},
			},
			auras = {
				order = 20,
				type = 'group',
				name = L["Auras"],
				get = function(info) 
					if E.db and E.db.buttonFacade and E.db.buttonFacade.auras then
						return E.db.buttonFacade.auras[info[#info]] 
					end
				end,
				set = function(info, value)
					if E.db and E.db.buttonFacade and E.db.buttonFacade.auras then
						E.db.buttonFacade.auras[info[#info]] = value
						if BF then BF:UpdateSkins() end
					end
				end,
				args = {
					enabled = {
						order = 1,
						type = 'toggle',
						name = L["Enable"],
						desc = L["Enable ButtonFacade for Auras"],
					},
					spacer1 = {
						order = 2,
						type = 'description',
						name = ' ',
					},
					SkinID = {
						order = 3,
						type = 'select',
						name = L["Skin"],
						desc = L["Select the button skin to use"],
						values = function() return GetSkinList() end,
					},
					Gloss = {
						order = 4,
						type = 'range',
						name = L["Gloss"],
						desc = L["Adjust the gloss/shine intensity on buttons"],
						min = 0,
						max = 1,
						step = 0.01,
						isPercent = true,
					},
					Backdrop = {
						order = 5,
						type = 'toggle',
						name = L["Backdrop"],
						desc = L["Show backdrop behind buttons"],
					},
					spacer2 = {
						order = 6,
						type = 'description',
						name = ' ',
					},
					reset = {
						order = 7,
						type = 'execute',
						name = L["Reset All Button Skins"],
						desc = L["Reset all button skins to default"],
						func = function() BF:ResetAuraSkins() end,
					},
				},
			},
		},
	}
	
	return config
end

E.Options.args.buttonFacade = configTable()
