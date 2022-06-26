--[[----------------------------------------------------------------------------

  LiteMount/PlayerMounts.lua

  Information on all your mounts.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local IndexAttributes = { 'mountID', 'name', 'spellID' }

LM.PlayerMounts = CreateFrame("Frame", nil, UIParent)

-- Type, type class create args
local MOUNT_SPELLS = {
    { "RunningWild", LM.SPELL.RUNNING_WILD },
    { "GhostWolf", LM.SPELL.GHOST_WOLF, 'RUN', 'SLOW' },
    { "TravelForm", LM.SPELL.TRAVEL_FORM, 'RUN', 'FLY', 'SWIM' },
--  { "TravelForm", LM.SPELL.FLIGHT_FORM, 'FLY' },
    { "TravelForm", LM.SPELL.MOUNT_FORM, 'RUN' },
    { "Nagrand", LM.SPELL.FROSTWOLF_WAR_WOLF, 'Horde', 'RUN' },
    { "Nagrand", LM.SPELL.TELAARI_TALBUK, 'Alliance', 'RUN' },
--  { "Soulshape", LM.SPELL.SOULSHAPE, 'RUN', 'SLOW' },
    { "ItemSummoned",
        LM.ITEM.LOANED_GRYPHON_REINS, LM.SPELL.LOANED_GRYPHON, 'FLY' },
    { "ItemSummoned",
        LM.ITEM.LOANED_WIND_RIDER_REINS, LM.SPELL.LOANED_WIND_RIDER, 'FLY' },
    { "ItemSummoned",
        LM.ITEM.FLYING_BROOM, LM.SPELL.FLYING_BROOM, 'FLY', },
    { "ItemSummoned",
        LM.ITEM.MAGIC_BROOM, LM.SPELL.MAGIC_BROOM, 'RUN', 'FLY', },
    { "ItemSummoned",
        LM.ITEM.SHIMMERING_MOONSTONE, LM.SPELL.MOONFANG, 'RUN', },
    { "ItemSummoned",
        LM.ITEM.RATSTALLION_HARNESS, LM.SPELL.RATSTALLION_HARNESS, 'RUN', },
    { "ItemSummoned",
        LM.ITEM.SAPPHIRE_QIRAJI_RESONATING_CRYSTAL, LM.SPELL.BLUE_QIRAJI_WAR_TANK, 'RUN', },
    { "ItemSummoned",
        LM.ITEM.RUBY_QIRAJI_RESONATING_CRYSTAL, LM.SPELL.RED_QIRAJI_WAR_TANK, 'RUN', },
    { "ItemSummoned",
        LM.ITEM.DRAGONWRATH_TARECGOSAS_REST, LM.SPELL.TARECGOSAS_VISAGE, 'FLY' },
    { "ItemSummoned",
        LM.ITEM.MAWRAT_HARNESS, LM.SPELL.MAWRAT_HARNESS, 'RUN' },
    { "ItemSummoned",
        LM.ITEM.SPECTRAL_BRIDLE, LM.SPELL.SPECTRAL_BRIDLE, 'RUN' },
    { "ItemSummoned",
        LM.ITEM.DEADSOUL_HOUND_HARNESS, LM.SPELL.DEADSOUL_HOUND_HARNESS, 'RUN' },
    { "ItemSummoned",
        LM.ITEM.MAW_SEEKER_HARNESS, LM.SPELL.MAW_SEEKER_HARNESS, 'RUN' },
}

local RefreshEvents = {
    -- Companion change. Don't add COMPANION_UPDATE to this as it fires
    -- for units other than "player" and triggers constantly.
    ["COMPANION_LEARNED"] = true,
    ["COMPANION_UNLEARNED"] = true,
    -- This fires when something is favorited or unfavorited
    ["MOUNT_JOURNAL_SEARCH_UPDATED"] = true,
    -- Talents (might have mount abilities). Glyphs that teach spells
    -- fire PLAYER_TALENT_UPDATE too, don't need to watch GLYPH_ events.
    ["ACTIVE_TALENT_GROUP_CHANGED"] = true,
    ["PLAYER_LEVEL_UP"] = true,
    ["PLAYER_TALENT_UPDATE"] = true,
    -- You might have received a mount item (e.g., Magic Broom).
    ["BAG_UPDATE_DELAYED"] = true,
    -- Draenor flying is an achievement
    ["ACHIEVEMENT_EARNED"] = true,
}

function LM.PlayerMounts:Initialize()

    self.mounts = LM.MountList:New()

    -- These are in this order so custom stuff is prioritized
    self:AddSpellMounts()
    self:AddJournalMounts()

    self:BuildIndexes()

    -- Refresh event setup
    self:SetScript("OnEvent",
            function (self, event, ...)
                if RefreshEvents[event] then
                    LM.Debug("Got refresh event "..event)
                    self.needRefresh = true
                elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
                    local _, _, spellID = ...
                    local m = self.indexes.spellID[spellID]
                    if m then
                        m:OnSummon()
                    end
                end
            end)

    for ev in pairs(RefreshEvents) do
        self:RegisterEvent(ev)
    end
    self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
end

function LM.PlayerMounts:BuildIndexes()
    self.indexes = { }
    for _, index in ipairs(IndexAttributes) do
        self.indexes[index] = {}
        for _, m in ipairs(self.mounts) do
            if m[index] then
                self.indexes[index][m[index]] = m
            end
        end
    end
end

-- All This dumbassery is to deal with the fact that two item-summoned mounts
-- (Blue/Red Qiraji War Tank) are in the journal but are actually summoned by
-- items. It copies across enough that the tooltip looks like LM.Journal
-- version (including preview) but the actions are all still LM.ItemSummoned.

local CopyAttributesFromJournal = {
    'modelID', 'sceneID', 'mountID', 'isSelfMount', 'description',
    'sourceType', 'sourceText'
}

function LM.PlayerMounts:AddMount(m)
    local existing = self:GetMountBySpell(m.spellID)

    if existing then
        for _, attr in ipairs(CopyAttributesFromJournal) do
            existing[attr] = existing[attr] or m[attr]
        end
    else
        tinsert(self.mounts, m)
    end
end

function LM.PlayerMounts:AddJournalMounts()
    -- This is horrible but I can't find any other way to get the "unusable" flag
    local usableMounts = {}

    C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED, true)
    C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED, true)
    C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_UNUSABLE, false)
    C_MountJournal.SetAllSourceFilters(true)
    C_MountJournal.SetAllTypeFilters(true)
    C_MountJournal.SetSearch('')

    for i = 1, C_MountJournal.GetNumDisplayedMounts() do
        local mountID = select(12, C_MountJournal.GetDisplayedMountInfo(i))
        usableMounts[mountID] = true
    end

    for _, mountID in ipairs(C_MountJournal.GetMountIDs()) do
        local m = LM.Mount:Get("Journal", mountID, usableMounts[mountID])
        self:AddMount(m)
    end
end

-- The unpack function turns a table into a list. I.e.,
--      unpack({ a, b, c }) == a, b, c
function LM.PlayerMounts:AddSpellMounts()
    for _,typeAndArgs in ipairs(MOUNT_SPELLS) do
        local m = LM.Mount:Get(unpack(typeAndArgs))
        self:AddMount(m)
    end
end

function LM.PlayerMounts:RefreshMounts()
    if self.needRefresh then
        LM.Debug("Refreshing status of all mounts.")

        for _,m in ipairs(self.mounts) do
            m:Refresh()
        end
        self.needRefresh = nil
    end
end

function LM.PlayerMounts:FilterSearch(...)
    return self.mounts:FilterSearch(...)
end

-- Limits can be filter (no prefix), set (=), reduce (-) or extend (+).

function LM.PlayerMounts:Limit(...)
    return self.mounts:Limit(...)
end


-- This is deliberately by spell name instead of using the
-- spell ID because there are some horde/alliance mounts with
-- the same name but different spells.

function LM.PlayerMounts:GetMountFromUnitAura(unitid)
    local buffs = { }
    local i = 1
    while true do
        local aura = UnitAura(unitid, i)
        if aura then buffs[aura] = true else break end
        i = i + 1
    end
    return self.mounts:Find(function (m) return buffs[m.name] end)
end

function LM.PlayerMounts:GetActiveMount()
    local buffIDs = { }
    local i = 1
    while true do
        local id = select(10, UnitAura('player', i))
        if id then buffIDs[id] = true else break end
        i = i + 1
    end
    for _,m in pairs(self.mounts) do
        if m:IsActive(buffIDs) then
            return m
        end
    end
end

function LM.PlayerMounts:GetMountByName(name)
    local function match(m) return m.name == name end
    return self.mounts:Find(match)
end

function LM.PlayerMounts:GetMountBySpell(id)
    local function match(m) return m.spellID == id end
    return self.mounts:Find(match)
end

function LM.PlayerMounts:GetMountByID(id)
    local function match(m) return m.mountID == id end
    return self.mounts:Find(match)
end

-- For some reason GetShapeshiftFormInfo doesn't work on Ghost Wolf.
function LM.PlayerMounts:GetMountByShapeshiftForm(i)
    if not i then
        return
    elseif i == 1 and select(2, UnitClass("player")) == "SHAMAN" then
         return self:GetMountBySpell(LM.SPELL.GHOST_WOLF)
    else
        local spellID
        spellID = select(4, GetShapeshiftFormInfo(i))
        if spellID then return self:GetMountBySpell(spellID) end
    end
end

local function IsRightFaction(info)
    if not info[9] then
        return true
    end
    local faction = UnitFactionGroup('player')
    local fnum = PLAYER_FACTION_GROUP[faction]
    if info[9] == fnum then
        return true
    end
end

-- Paladin level 20/40 mounts and felsaber are only counted if actually usable.
-- Everything else is counted if you're the right faction, irrespective of
-- whether you can mount up on it. This makes no sense at all.

local notCounted = {
    [367]   = true,     -- Exarch's Elekk
    [368]   = true,     -- Great Exarch's Elekk
    [1046]  = true,     -- Darkforge Ram
    [1047]  = true,     -- Dawnforge Ram
    [350]   = true,     -- Sunwalker Kodo
    [351]   = true,     -- Great Sunwalker Kodo
    [149]   = true,     -- Thalassian Charger
    [150]   = true,     -- Thalassian Warhorse
    [1225]  = true,     -- Crusader's Direhorn
    [780]   = true,     -- Felsaber
}

local function IsCounted(info)
    if notCounted[info[12]] then
        return info[4]
    else
        return true
    end
end

function LM.PlayerMounts:GetJournalTotals()
    local c = { total=0, collected=0, usable=0 }

    for _,id in ipairs(C_MountJournal.GetMountIDs()) do
        local info = { C_MountJournal.GetMountInfoByID(id) }
        c.total = c.total + 1
        if info[11] and not info[10] then
            c.collected = c.collected + 1
            if IsRightFaction(info) and IsCounted(info) then
                c.usable = c.usable + 1
            end
        end
    end
    return c
end

