--[[----------------------------------------------------------------------------

  LiteMount/SlashCommand.lua

  Chat slash command (/litemount or /lmt) and macro maintenance.

  Copyright 2011-2015 Mike Battersby

----------------------------------------------------------------------------]]--

local MacroName = "LiteMount"
local MacroText = [[
# Auto-created by LiteMount addon, it is safe to delete or edit this macro.
# To re-create it run "/litemount macro"
/click [btn:1] LiteMountActionButton1; [btn:2] LiteMountActionButton2; [btn:3] LiteMountActionButton3; [btn:4] LiteMountActionButton4
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
        LM_Print("Enabling current mount: " .. m:Name())
        LM_Options:RemoveExcludedMount(m)
    elseif arg == "disable" or (arg == "toggle" and not mDisabled) then
        LM_Print("Disabling current mount: " .. m:Name())
        LM_Options:AddExcludedMount(m)
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
            return
        elseif arg == "toggle" or arg == "enable" or arg == "disable" then
            UpdateActiveMount(arg)
            LiteMount_UpdateOptionsListIfShown()
            return
        end
    end

    return LiteMountOptionsPanel_Open()
end

