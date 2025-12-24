-- Skip guard for all addon skin files
-- If ElvUI has built-in AddOnSkins (marker not set), skip loading all these skins
local E = unpack(ElvUI)
if not E.AddOnSkinsExternalModule then
    ElvUI_AddOnSkins_Skip = true
end
