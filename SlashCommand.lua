--[[----------------------------------------------------------------------------

  LiteMount/SlashCommand.lua

  Chat slash command (/litemount or /lmt) and macro maintenance.

  Copyright 2011-2018 Mike Battersby

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

local function IsTrue(x)
    if x == nil or x == false or x == "0" or x == "off" then
        return false
    else
        return true
    end
end

local function PrintUsage()
    LM_Print("Usage:")
    LM_Print("  /litemount enable | disable | toggle")
    LM_Print("  /litemount mounts [<substring>]")
    LM_Print("  /litemount areas [<substring>]")
    LM_Print("  /litemount continents [<substring>]")
    LM_Print("  /litemount location")
    LM_Print("  /litemount macro")
    LM_Print("  /litemount flags add <flagname>")
    LM_Print("  /litemount flags del <flagname>")
    LM_Print("  /litemount flags rename <oldname> <newname>")
    LM_Print("  /litemount xmog <slotnumber>")
end

local function PrintAreas(str)
    local areas = GetAreaMaps()

    local searchStr = string.lower(str or "")

    for _,areaID in ipairs(areas) do
        local areaName = GetMapNameByID(areaID)
        local searchName = string.lower(areaName)
        if areaID == tonumber(str) or searchName:find(searchStr) then
            LM_Print(format("% 4d : %s", areaID, areaName))
        end
    end
end

local function PrintContinents(str)
    local continents = { GetMapContinents() }
    local searchStr = string.lower(str or "")

    local cID, cName, searchName
    for i = 1, #continents, 2 do
        cID, cName = continents[i], continents[i+1]
        searchName = string.lower(cName)
        if cID == tonumber(str) or searchName:find(searchStr) then
            LM_Print(format("% 4d : %s", cID, cName))
        end
    end
end

_G.LiteMount_SlashCommandFunc = function (argstr)

    -- Look, please stop doing this, ok? Nothing good can come of it.
    if InCombatLockdown() then return true end

    local args = { strsplit(" ", argstr) }
    local cmd = table.remove(args, 1)

    if cmd == "macro" or cmd == strlower(MACRO) then
        local i = CreateOrUpdateMacro()
       if i then PickupMacro(i) end
        return true
    elseif cmd == "toggle" or cmd == "enable" or cmd == "disable" then
        UpdateActiveMount(cmd)
        LiteMountOptions_UpdateMountList()
        return true
    elseif cmd == "location" then
        LM_Location:Dump()
        return true
    elseif cmd == "areas" then
        PrintAreas(table.concat(args, ' '))
        return true
    elseif cmd == "continents" then
        PrintContinents(table.concat(args, ' '))
        return true
    elseif cmd == "mounts" then
        local m
        if not args[1] then
            m = LM_PlayerMounts:GetMountFromUnitAura("player")
            if m then m:Dump() end
        else
            local n = string.lower(table.concat(args, ' '))
            local mounts = LM_PlayerMounts.mounts:Search(function (m) return string.match(strlower(m.name), n) end)
            for _,m in ipairs(mounts) do
                m:Dump()
            end
        end
        return true
    elseif cmd == "flags" then
        if args[1] == "add" and #args == 2 then
            LM_Options:CreateFlag(args[2])
            LiteMountOptions_UpdateFlagPaging()
            LiteMountOptions_UpdateMountList()
            return true
        elseif args[1] == "del" and #args == 2 then
            LM_Options:DeleteFlag(args[2])
            LiteMountOptions_UpdateFlagPaging()
            LiteMountOptions_UpdateMountList()
            return true
        elseif args[1] == "rename" and #args == 3 then
            LM_Options:RenameFlag(args[2], args[3])
            LiteMountOptions_UpdateFlagPaging()
            LiteMountOptions_UpdateMountList()
            return true
        elseif args[1] == "list" and #args == 1 then
            local flags = LM_Options:GetAllFlags()
            for i = 1, #flags do
                if LM_Options:IsPrimaryFlag(flags[i]) then
                    flags[i] = ORANGE_FONT_COLOR_CODE .. flags[i] .. FONT_COLOR_CODE_CLOSE
                end
            end
            LM_Print(table.concat(flags, ' '))
            return true
        end
    elseif cmd == "xmog" then
        local slotID = tonumber(args[1])
        if slotID then
            local ok, _, _, _, id = pcall(C_Transmog.GetSlotVisualInfo, slotID, LE_TRANSMOG_TYPE_APPEARANCE)
            if ok == true then
                LM_Print(format("Transmog appearance ID for slot %d = %s", slotID, tostring(id)))
            else
                LM_Print("Bad transmog slot number: " .. slotID)
            end
            return true
        end
    elseif cmd == "debug" then
        if IsTrue(args[1]) then
            LM_Print("Debugging enabled.")
            LM_Options.db.char.debugEnabled = true
        else
            LM_Print("Debugging disabled.")
            LM_Options.db.char.debugEnabled = false
        end
        return true
    elseif cmd == ""then
        return LiteMountOptionsPanel_Open()
    end

    PrintUsage()
    return true
end

