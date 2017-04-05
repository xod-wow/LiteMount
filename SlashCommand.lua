--[[----------------------------------------------------------------------------

  LiteMount/SlashCommand.lua

  Chat slash command (/litemount or /lmt) and macro maintenance.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

local MacroName = "LiteMount"
local MacroText = [[
# Auto-created by LiteMount addon, it is safe to delete or edit this macro.
# To re-create it run "/litemount macro"
/click [btn:1] LM_B1; [btn:2] LM_B2; [btn:3] LM_B3; [btn:4] LM_B4
]]

local function CreateOrUpdateMacro()
    local index = GetMacroIndexByName(MacroName)
    if index == 0 then
        index = CreateMacro(MacroName, "ABILITY_MOUNT_MECHASTRIDER", MacroText)
    else
        EditMacro(index, nil, nil, MacroText)
    end
    return index
end

local function UpdateActiveMount(arg)
    local m = LM_PlayerMounts:GetMountFromUnitAura("player")
    if not m then return end

    local mDisabled = LM_Options:IsExcludedMount(m)

    if arg == "enable" or (arg == "toggle" and mDisabled) then
        LM_Print("Enabling current mount: " .. m.name)
        LM_Options:IncludeMount(m)
    elseif arg == "disable" or (arg == "toggle" and not mDisabled) then
        LM_Print("Disabling current mount: " .. m.name)
        LM_Options:ExcludeMount(m)
    end
end

local LOCALIZED_MACRO_WORD = CaseAccentInsensitiveParse(MACRO)

function LiteMount_SlashCommandFunc(argstr)

    local args = { strsplit(" ", argstr) }

    for _,arg in ipairs(args) do
        arg = CaseAccentInsensitiveParse(arg)
        if arg == "macro" or arg == LOCALIZED_MACRO_WORD then
            local i = CreateOrUpdateMacro()
            if i then PickupMacro(i) end
            return true
        elseif arg == "toggle" or arg == "enable" or arg == "disable" then
            UpdateActiveMount(arg)
            LM_OptionsUIMounts_UpdateMountList()
            return true
        end
    end

    return LM_OptionsUIPanel_Open()
end

