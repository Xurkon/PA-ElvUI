local E, L = unpack(ElvUI)
local PM = E:GetModule("ProfessionMenu")

E.Options.args.professionMenu = {
	order = 120, -- Alphabetical: P
	type = "group",
	name = L["Profession Menu"],
	get = function(info) return E.db.professionMenu[info[#info]] end,
	set = function(info, value) E.db.professionMenu[info[#info]] = value end,
	args = {
		header = {
			order = 1,
			type = "header",
			name = L["Profession Menu"]
		},
		intro = {
			order = 2,
			type = "description",
			name = L["Enable the profession menu button that provides quick access to all your professions."]
		},
		enable = {
			order = 3,
			type = "toggle",
			name = L["Enable"],
			desc = L["Enable the profession menu button that provides quick access to all your professions."],
			set = function(info, value)
				E.db.professionMenu[info[#info]] = value
				PM:UpdateVisibility()
			end
		},
		spacer1 = {
			order = 4,
			type = "description",
			name = " "
		},
		buttonMover = {
			order = 5,
			type = "execute",
			name = L["Toggle Anchors"],
			desc = L["Toggle Anchors for moving frames."],
			func = function() E:ToggleMoveMode() end
		}
	}
}

