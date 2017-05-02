--[[----------------------------------------------------------------------------

  LiteMount/SlashCommand.lua

  Chat slash command (/litemount or /lmt) and macro maintenance.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

local L = LM_Localize

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
        LM_Print(format(L.LM_ENABLING_MOUNT, m.name))
        LM_Options:RemoveExcludedMount(m)
    elseif arg == "disable" or (arg == "toggle" and not mDisabled) then
        LM_Print(format(L.LM_DISABLING_MOUNT, m.name))
        LM_Options:AddExcludedMount(m)
    end
end

local falseValues = { nil, false, 0, "off", "no" }

local function IsTrue(x)
    if tContains(falueValues, x) then
        return false
    else
        return true
    end
end

function LiteMount_SlashCommandFunc(argstr)

    -- Look, please stop doing this, ok? Nothing good can come of it.
    if InCombatLockdown() then return true end

    local args = { strsplit(" ", strlower(argstr)) }
    local cmd = table.remove(args, 1)

    if cmd == "macro" or cmd == strlower(MACRO) then
        local i = CreateOrUpdateMacro()
        if i then PickupMacro(i) end
        return true
    elseif cmd == "toggle" or cmd == "enable" or cmd == "disable" then
        UpdateActiveMount(cmd)
        -- This really needs to be switched to a callback
        LiteMountOptions_UpdateMountList()
        return true
    elseif cmd == "dumplocation" then
        LM_Location:Dump()
        return true
    elseif cmd == "debug" then
        LM_Options.db.char.debugEnabled = IsTrue(args[1])
        return true
    end

    return LiteMountOptionsPanel_Open()
end

