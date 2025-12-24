local E = unpack(ElvUI)
local WE = E.WarcraftEnhanced
local QH = WarcraftEnhanced or QuestHelper or WE
local UIE = {}

local function GetDB()
	if WE and WE.db then
		WE.db.uiEnhancements = WE.db.uiEnhancements or E:CopyTable({}, P.warcraftenhanced.uiEnhancements)
		WE.db.uiEnhancements.errorFilters = WE.db.uiEnhancements.errorFilters or {}
		return WE.db.uiEnhancements
	end
end

function UIE:Initialize()
	self.db = GetDB()
	if not self.db then
		return
	end

	self:SetupErrorFiltering()
	self:SetupAutoDelete()
end

function UIE:SetupErrorFiltering()
	if self.errorHooked then return end

	if not ScriptErrorsFrame.QH_originalAddMessage then
		ScriptErrorsFrame.QH_originalAddMessage = ScriptErrorsFrame.AddMessage
	end

	ScriptErrorsFrame.AddMessage = function(frame, msg, ...)
		if not UIE:ShouldFilterError(msg) then
			return ScriptErrorsFrame.QH_originalAddMessage(frame, msg, ...)
		end
	end

	self.errorHooked = true
end

function UIE:ShouldFilterError(msg)
	if not self.db or not self.db.errorFiltering then return false end
	if not msg then return false end

	for filter in pairs(self.db.errorFilters) do
		if msg:find(filter) then
			return true
		end
	end

	return false
end

function UIE:SetupAutoDelete()
	if self.deleteHooked then return end

	local dialog = StaticPopupDialogs["DELETE_GOOD_ITEM"]
	if not dialog then return end

	self._originalDeleteOnShow = self._originalDeleteOnShow or dialog.OnShow
	dialog.OnShow = function(frame, ...)
		if UIE._originalDeleteOnShow then
			UIE._originalDeleteOnShow(frame, ...)
		end

		if UIE.db and UIE.db.autoDelete then
			frame.editBox:SetText(DELETE_ITEM_CONFIRM_STRING or "Delete")
		end
	end

	self.deleteHooked = true
end

function UIE:ToggleErrorFiltering(enabled)
	local db = GetDB()
	if not db then return end

	db.errorFiltering = enabled
end

function UIE:ToggleAutoDelete(enabled)
	local db = GetDB()
	if not db then return end

	db.autoDelete = enabled
end

function UIE:SetErrorFilter(pattern, enabled)
	local db = GetDB()
	if not db or not pattern or pattern == "" then return end

	if enabled then
		db.errorFilters[pattern] = true
	else
		db.errorFilters[pattern] = nil
	end
end

function UIE:GetErrorFilters()
	local db = GetDB()
	if not db then return {} end

	return db.errorFilters
end

QH:RegisterModule("UIEnhancements", UIE)

