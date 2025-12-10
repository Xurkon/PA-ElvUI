-- Cooldowns.lua - DISABLED STUB VERSION
-- This stub provides all necessary functions/tables without displaying cooldown text

local E, L, V, P, G = unpack(select(2, ...))

-- Initialize required tables that other modules expect
E.RegisteredCooldowns = {}

-- Ensure TimeThreshold is set early (Math.lua also sets this, but we ensure it here too)
E.TimeThreshold = E.TimeThreshold or 3

-- Create TimeColors with metatable for any index access
local dummyColor = {r = 1, g = 1, b = 1, a = 1}

E.TimeColors = setmetatable({}, {
	__index = function(t, k)
		return dummyColor
	end
})

E.TimeIndicatorColors = setmetatable({}, {
	__index = function(t, k)
		return dummyColor
	end
})

-- Pre-populate common indices (0-6)
for i = 0, 6 do
	E.TimeColors[i] = {r = 1, g = 1, b = 1, a = 1}
	E.TimeIndicatorColors[i] = {r = 1, g = 1, b = 1, a = 1}
end

-- Stub function: Register cooldown (called by many modules)
function E:RegisterCooldown(cooldown, module)
	if not cooldown then return end
	
	-- Always set timeColors and textColors to prevent nil errors
	cooldown.timeColors = cooldown.timeColors or E.TimeColors
	cooldown.textColors = cooldown.textColors or E.TimeIndicatorColors
	cooldown.isRegisteredCooldown = true
	cooldown.forceDisabled = true -- Disable text display
	
	-- Hide cooldown text if it has a text element
	if cooldown.text then
		cooldown.text:SetText("")
		if cooldown.text.Hide then
			cooldown.text:Hide()
		end
	end
end

-- Stub function: Update cooldown settings
function E:UpdateCooldownSettings(module)
	-- No-op: Cooldowns are disabled
end

-- Stub function: OnSetCooldown
function E:OnSetCooldown(start, duration)
	-- No-op: Cooldowns are disabled
end

-- Stub function: Update cooldown override
function E:UpdateCooldownOverride(module)
	-- No-op: Cooldowns are disabled
end

-- Stub function: Get cooldown colors
function E:GetCooldownColors(db)
	-- Return 14 dummy color values as expected
	local d = dummyColor
	return d, d, d, d, d, d, d, d, d, d, d, d, d, d
end

-- Stub function: Force update cooldown
function E:Cooldown_ForceUpdate(cd)
	-- No-op: Cooldowns are disabled
end

-- Stub function: Check if cooldown is enabled
function E:Cooldown_IsEnabled(cd)
	return false -- Always disabled
end

-- Stub function: Stop cooldown timer
function E:Cooldown_StopTimer(cd)
	-- No-op: Cooldowns are disabled
end

-- Stub function: OnUpdate handler
function E:Cooldown_OnUpdate(elapsed)
	-- No-op: Cooldowns are disabled
end

-- Stub function: OnSizeChanged handler
function E:Cooldown_OnSizeChanged(cd, width, force)
	-- No-op: Cooldowns are disabled
end

-- Stub function: Text threshold check
function E:Cooldown_TextThreshold(cd, now)
	return false
end

-- Stub function: Below scale check
function E:Cooldown_BelowScale(cd)
	return true -- Always below scale when disabled
end

-- Stub function: Cooldown options
function E:Cooldown_Options(button, db, parent)
	-- Set required threshold values to prevent nil comparison errors
	button.threshold = button.threshold or E.TimeThreshold or 3
	button.hhmmThreshold = button.hhmmThreshold or 0
	button.mmssThreshold = button.mmssThreshold or 0
end
