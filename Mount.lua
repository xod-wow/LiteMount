--[[----------------------------------------------------------------------------

  LiteMount/Mount.lua

  Information about one mount.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local C_Spell = LM.C_Spell or C_Spell
local C_MountJournal = LM.C_MountJournal or C_MountJournal

local L = LM.Localize

-- Rarity data repackaged daily from DataForAzeroth by Sören Gade
--  https://github.com/sgade/MountsRarity
local MountsRarity = LibStub("MountsRarity-2.0")

LM.Mount = { }
LM.Mount.__index = LM.Mount

function LM.Mount:new()
    return setmetatable({ }, self)
end

function LM.Mount:Get(className, ...)
    local class = LM[className]

    local m = class:Get(...)
    if not m then return end

    if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then
        m.family = LM.MountInfo.GetMountFamilyBySpellID(m.spellID)

        if not m.family then
            m.family = UNKNOWN
            --@debug@
            LM.PrintError('No family: %s (%d)', m.name, m.spellID)
            --@end-debug@
        end
    end

    return m
end

function LM.Mount:GetFlags()
    return LM.Options:GetMountFlags(self)
end

function LM.Mount:GetGroups()
    return LM.Options:GetMountGroups(self)
end

function LM.Mount:Refresh()
    -- Nothing in base
end

function LM.Mount.FilterToDisplay(f)
    if not f or f == "NONE" then
        return NONE
    elseif f == "ALL" then
        return ALL
    elseif f == "FAVORITES" then
        return FAVORITES
    elseif f:sub(1,1) == '~' then
        return string.format(L.LM_NOT_FORMAT, LM.Mount.FilterToDisplay(f:sub(2)))
    elseif f:match('^id:%d+$') then
        local _, id = string.split(':', f, 2)
        return C_MountJournal.GetMountInfoByID(tonumber(id))
    elseif f:match('^family:') then
        local _, family = string.split(':', f, 2)
        return L.LM_FAMILY .. ' : ' .. LM.MountInfo.GetMountFamilyNameByID(m.family)
    elseif f:match('^mt:%d+$') then
        local _, id = string.split(':', f, 2)
        local typeInfo = LM.MOUNT_TYPE_INFO[tonumber(id)]
        if typeInfo and not typeInfo.skip then
            return TYPE .. " : " .. typeInfo.name
        else
            return TYPE .. " : " .. id
        end
    elseif LM.Options:IsGroup(f) then
        return L.LM_GROUP .. ' : ' .. f
    elseif LM.Options:IsFlag(f) then
        -- XXX LOCALIZE XXX
        return TYPE .. ' : ' .. L[f]
    else
        local n = C_Spell.GetSpellName(f)
        if n then return n end
        return DISABLED_FONT_COLOR:WrapTextInColorCode(f)
    end
end

function LM.Mount:MatchesOneFilter(flags, groups, f)
    if f == "" or f == "ALL" or f == self.name then
        return true
    elseif f == "NONE" then
        return false
    elseif f == "CASTABLE" then
        return self:IsCastable() == true
    elseif f == "COLLECTED" then
        return self:IsCollected() == true
    elseif f == "MAWUSABLE" then
        return self:MawUsable() == true
    elseif f == "JOURNAL" then
        return self.mountTypeID ~= nil
    elseif f == "FAVORITES" then
        return self:IsFavorite()
    elseif f == "ZONEMATCH" then
        local zone = GetZoneText()
        return self:IsFromZone(zone)
    elseif tonumber(f) then
        return self.spellID == tonumber(f)
    elseif f:sub(1, 3) == 'id:' then
        return self.mountID == tonumber(f:sub(4))
    elseif f:sub(1, 3) == 'mt:' then
        return self.mountTypeID == tonumber(f:sub(4))
    elseif f:sub(1, 7) == 'family:' then
        local familyName = LM.MountInfo.GetMountFamilyNameByID(self.family)
        return ( self.family == f:sub(8) or familyName == f:sub(8) )
    elseif f:sub(1, 1) == '~' then
        return not self:MatchesOneFilter(flags, groups, f:sub(2))
    elseif flags[f] ~= nil then
        return true
    elseif groups[f] ~= nil then
        return true
    end
end

function LM.Mount:MatchesFilters(...)
    local currentFlags = self:GetFlags()
    local currentGroups = self:GetGroups()
    for i = 1, select('#', ...) do
        local f = select(i, ...)
        if not self:MatchesOneFilter(currentFlags, currentGroups, f) then
            return false
        end
    end
    return true
end

function LM.Mount:EvalLeaf(f, g, e)
    return self:MatchesOneFilter(f, g, e)
end

function LM.Mount:EvalAnd(f, g, e)
    local result = true
    for _, term in ipairs(e) do
        result = result and self:Eval(f, g, term)
    end
    return result
end

function LM.Mount:EvalOr(f, g, e)
    local result = false
    for _, term in ipairs(e) do
        result = result or self:Eval(f, g, term)
    end
    return result
end

function LM.Mount:EvalNot(f, g, e)
    return not self:Eval(f, g, e[1])
end

function LM.Mount:Eval(f, g, e)
    if type(e) ~= 'table' then
        return self:EvalLeaf(f, g, e)
    elseif e.op == ',' then
        return self:EvalAnd(f, g, e)
    elseif e.op == '/' then
        return self:EvalOr(f, g, e)
    elseif e.op == '~' then
        return self:EvalNot(f, g, e)
    else
    --@debug@
        DevTools_Dump(e)
        LM.WarningAndPrint('Bad operator made it through somehow: ' .. e.op)
    --@end-debug@
    end
end

function LM.Mount:MatchesExpression(e)
    local currentFlags = self:GetFlags()
    local currentGroups = self:GetGroups()
    return self:Eval(currentFlags, currentGroups, e)
end

function LM.Mount:FlagsSet(checkFlags)
    for _,f in ipairs(checkFlags) do
        if self.flags[f] == nil then return false end
    end
    return true
end

function LM.Mount:IsActive(buffTable)
    return buffTable[self.spellID]
end

function LM.Mount:IsCastable()
    local info = C_Spell.GetSpellInfo(self.spellID)
    if LM.Environment:IsMovingOrFalling() then
        if info.castTime > 0 then return false end
    elseif LM.Options:GetOption('instantOnlyMoving') then
        if info.castTime == 0 then return false end
    end
    return true
end

function LM.Mount:IsCancelable()
    return true
end

function LM.Mount:IsUsable()
    return true
end

function LM.Mount:IsMountable()
    return true
end

function LM.Mount:IsFavorite()
    return false
end

function LM.Mount:IsCollected()
    return true
end

function LM.Mount:IsFiltered()
    return false
end

function LM.Mount:IsFromZone(zone)
    if self.source then
        zone = zone:gsub('%-', '%%-')
        local source = self.source:gsub("|c........(.-)|r", "%1")
        local zt = ZONE_COLON .. '[^|]+' .. zone
        local lt = LOCATION_COLON .. '[^|]+' .. zone
        return source:find(zt, 1) ~= nil or source:find(lt, 1) ~= nil
    end
end

-- These should probably not be making new identical objects all the time.

function LM.Mount:GetCastAction()
    local spellName = C_Spell.GetSpellName(self.spellID)
    return LM.SecureAction:Spell(spellName)
end

function LM.Mount:GetCancelAction()
    local spellName = C_Spell.GetSpellName(self.spellID)
    return LM.SecureAction:CancelAura(spellName)
end

function LM.Mount:OnSummon()
    local n = LM.Options:IncrementSummonCount(self)

    if not LM.Options:GetOption('announceViaChat') then return end

    if LM.Options:GetOption('randomWeightStyle') == 'Rarity' then
        local rarity = self:GetRarity()
        rarity = string.format(L.LM_RARITY_FORMAT, rarity or 0)
        LM.Print(L.LM_SUMMON_CHAT_MESSAGE_RARITY, self.name, rarity, n)
    else
        LM.Print(L.LM_SUMMON_CHAT_MESSAGE, self.name, self:GetPriority(), n)
    end
end

function LM.Mount:GetSummonCount()
    return LM.Options:GetSummonCount(self)
end

function LM.Mount:GetPriority()
    return LM.Options:GetPriority(self)
end

function LM.Mount:GetRarity()
    if self.mountID then
        return MountsRarity:GetRarityByID(self.mountID) or 0
    end
end

-- This is gross

local MawUsableSpells = {
    [LM.SPELL.TRAVEL_FORM] = true,
    [LM.SPELL.MOUNT_FORM] = true,
    [LM.SPELL.RUNNING_WILD] = true,
    [LM.SPELL.SOULSHAPE] = true,
    [LM.SPELL.GHOST_WOLF] = true,
    [312762] = true,                -- Mawsworn Soulhunter
    [344578] = true,                -- Corridor Creeper
    [344577] = true,                -- Bound Shadehound
}

function LM.Mount:MawUsable()
    -- The True Maw Walker unlocks all mounts, but the spell (353214) doesn't
    -- seem to return true for IsPlayerSpell(). The unlock is not account-wide
    -- so the quest is good enough (for now).

    if C_QuestLog.IsQuestFlaggedCompleted(63994) then
        return true
    else
        return MawUsableSpells[self.spellID]
    end
end

function LM.Mount:Dump(prefix)
    prefix = prefix or ""

    local spellName = C_Spell.GetSpellName(self.spellID)

    local currentFlags, defaultFlags = {}, {}
    for f in pairs(self:GetFlags()) do tinsert(currentFlags, f) end
    for f in pairs(self.flags) do tinsert(defaultFlags, f) end
    sort(currentFlags)
    sort(defaultFlags)

    LM.Print("--- Mount Dump ---")
    LM.Print(prefix .. self.name)
    LM.Print(prefix .. " spell: " .. format("%s (id %d)", spellName, self.spellID))
    LM.Print(prefix .. " flags: " ..
             format("%s (default %s)",
                    table.concat(currentFlags, ','),
                    table.concat(defaultFlags, ',')
                   )
            )
    LM.Print(prefix .. " mountID: " .. tostring(self.mountID))
    LM.Print(prefix .. " family: " .. LM.MountInfo.GetMountFamilyNameByID(self.family))
    LM.Print(prefix .. " isCollected: " .. tostring(self:IsCollected()))
    LM.Print(prefix .. " isMountable: " .. tostring(self:IsMountable()))
    LM.Print(prefix .. " isFavorite: " .. tostring(self:IsFavorite()))
    LM.Print(prefix .. " isFiltered: " .. tostring(self:IsFiltered()))
    LM.Print(prefix .. " priority: " .. tostring(self:GetPriority()))
    LM.Print(prefix .. " castable: " .. tostring(self:IsCastable()) .. " (spell " .. tostring(C_Spell.IsSpellUsable(self.spellID)) .. ")")
end
