--[[----------------------------------------------------------------------------

  LiteMount/SlashCommand.lua

  Chat slash command (/litemount or /lmt) and macro maintenance.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local MacroName = "LiteMount"
local MacroText = [[
# Auto-created by LiteMount addon, it is safe to delete or edit this macro.
# To re-create it run "/litemount macro"
/click LM_B1
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

local function IsTrue(x)
    if x == nil or x == false or x == "0" or x == "off" then
        return false
    else
        return true
    end
end

local function PrintUsage()
    LM.Print(GAMEMENU_HELP .. ":")
    LM.Print("  /litemount priority <0-3>")
    LM.Print("  /litemount mounts [<substring>]")
    LM.Print("  /litemount maps [<substring>]")
    LM.Print("  /litemount continents [<substring>]")
    LM.Print("  /litemount location")
    LM.Print("  /litemount macro")
    LM.Print("  /litemount flags add <flagname>")
    LM.Print("  /litemount flags del <flagname>")
    LM.Print("  /litemount flags rename <oldname> <newname>")
    LM.Print("  /litemount profile <profilename>")
    LM.Print("  /litemount xmog <slotnumber>")
end

LM.SlashCommandFunc = function (argstr)

    -- Look, please stop doing this, ok? Nothing good can come of it.
    if InCombatLockdown() then
        LM.PrintError(ERR_NOT_IN_COMBAT)
        return true
    end

    local args = { strsplit(" ", argstr) }
    local cmd = table.remove(args, 1)

    if cmd == "macro" or cmd == strlower(MACRO) then
        local i = CreateOrUpdateMacro()
        if i then PickupMacro(i) end
        return true
    elseif cmd == "priority" then
        local mount = LM.PlayerMounts:GetActiveMount()
        if mount then
            LM.Options:SetPriority(mount, tonumber(args[1]))
        end
        return true
    elseif cmd == "location" then
        LM.Print(LOCATION_COLON)
        for _,line in ipairs(LM.Location:GetLocation()) do
            LM.Print("  " .. line)
        end
        return true
    elseif cmd == "maps" then
        local str = table.concat(args, ' ')
        for _,line in ipairs(LM.Location:GetMaps(str)) do
            LM.Print(line)
        end
        return true
    elseif cmd == "continents" then
        local str = table.concat(args, ' ')
        for _,line in ipairs(LM.Location:GetContinents(str)) do
            LM.Print(line)
        end
        return true
    elseif cmd == "mounts" then
        if not args[1] then
            local m = LM.PlayerMounts:GetMountFromUnitAura("player")
            if m then m:Dump() end
        else
            local n = string.lower(table.concat(args, ' '))
            local mounts = LM.PlayerMounts.mounts:Search(function (m) return string.match(strlower(m.name), n) end)
            for _,m in ipairs(mounts) do
                m:Dump()
            end
        end
        return true
    elseif cmd == "flags" then
        if args[1] == "add" and #args == 2 then
            LM.Options:CreateFlag(args[2])
            return true
        elseif args[1] == "del" and #args == 2 then
            LM.Options:DeleteFlag(args[2])
            return true
        elseif args[1] == "rename" and #args == 3 then
            LM.Options:RenameFlag(args[2], args[3])
            return true
        elseif args[1] == "list" and #args == 1 then
            local flags = LM.Options:GetAllFlags()
            for i = 1, #flags do
                if LM.Options:IsPrimaryFlag(flags[i]) then
                    flags[i] = ORANGE_FONT_COLOR_CODE .. flags[i] .. FONT_COLOR_CODE_CLOSE
                end
            end
            LM.Print(table.concat(flags, ' '))
            return true
        end
    elseif cmd == "profile" then
        -- can't use the split args because we need the raw rest of the line
        local profileName = argstr:gsub('^profile%s+', '')
        if profileName and LM.Options.db.profiles[profileName] then
            LM.Options.db:SetProfile(profileName)
            LM.Print("Switching to profile: " .. profileName)
        else
            LM.Print("No profile found with name: " .. profileName)
        end
        return true
    elseif cmd == "xmog" then
        local slotID = tonumber(args[1])
        if slotID then
            local ok, _, _, _, id = pcall(C_Transmog.GetSlotVisualInfo, slotID, LE_TRANSMOG_TYPE_APPEARANCE)
            if ok == true then
                LM.Print(format("Transmog appearance ID for slot %d = %s", slotID, tostring(id)))
            else
                LM.Print("Bad transmog slot number: " .. slotID)
            end
            return true
        end
    elseif cmd == "debug" then
        if IsTrue(args[1]) then
            LM.Print(L.LM_DEBUGGING_ENABLED)
            LM.Options:SetDebug(true)
        else
            LM.Print(L.LM_DEBUGGING_DISABLED)
            LM.Options:SetDebug(false)
        end
        return true
    elseif cmd == "uidebug" then
        if IsTrue(args[1]) then
            LM.Print(BUG_CATEGORY5 .. ' ' .. L.LM_DEBUGGING_ENABLED)
            LM.Options:SetUIDebug(true)
        else
            LM.Print(BUG_CATEGORY5 .. ' ' .. L.LM_DEBUGGING_DISABLED)
            LM.Options:SetUIDebug(false)
        end
        return true
--@debug@
    elseif cmd == "usable" then
        LM.Developer:Initialize()
        LM.Developer:UpdateUsability()
        return true
    elseif cmd == "pi" then
        LiteMountProfileInspect:Show()
        return true
--@end-debug@
    elseif cmd == "" then
        return LiteMountOptionsPanel_Open()
    end

    PrintUsage()
    return true
end

