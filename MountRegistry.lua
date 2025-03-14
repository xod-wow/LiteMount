--[[----------------------------------------------------------------------------

  LiteMount/MountRegistry.lua

  Information on all your mounts.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local C_MountJournal = LM.C_MountJournal or C_MountJournal
local C_Spell = LM.C_Spell

local CallbackHandler = LibStub:GetLibrary("CallbackHandler-1.0", true)

local IndexAttributes = { 'mountID', 'name', 'spellID', 'overrideSpellID' }

LM.MountRegistry = CreateFrame("Frame", nil, UIParent)
LM.MountRegistry.callbacks = CallbackHandler:New(LM.MountRegistry)

-- Type, type class create args
local MOUNT_SPELLS = {
    { "RunningWild", LM.SPELL.RUNNING_WILD },
    { "GhostWolf", LM.SPELL.GHOST_WOLF, 'RUN', 'SLOW' },
    { "Nagrand", LM.SPELL.FROSTWOLF_WAR_WOLF, 'Horde', 'RUN' },
    { "Nagrand", LM.SPELL.TELAARI_TALBUK, 'Alliance', 'RUN' },
    { "Soar", LM.SPELL.SOAR, 'FLY', 'DRAGONRIDING' },
    { "Drive", LM.SPELL.G_99_BREAKNECK, 'DRIVE' },
--  { "Soulshape", LM.SPELL.SOULSHAPE, 'RUN', 'SLOW' },
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
--  { "ItemSummoned",
--      LM.ITEM.DRAGONWRATH_TARECGOSAS_REST, LM.SPELL.TARECGOSAS_VISAGE, 'FLY' },
    { "ItemSummoned",
        LM.ITEM.MAWRAT_HARNESS, LM.SPELL.MAWRAT_HARNESS, 'RUN' },
    { "ItemSummoned",
        LM.ITEM.SPECTRAL_BRIDLE, LM.SPELL.SPECTRAL_BRIDLE, 'RUN' },
    { "ItemSummoned",
        LM.ITEM.DEADSOUL_HOUND_HARNESS, LM.SPELL.DEADSOUL_HOUND_HARNESS, 'RUN' },
    { "ItemSummoned",
        LM.ITEM.MAW_SEEKER_HARNESS, LM.SPELL.MAW_SEEKER_HARNESS, 'RUN' },
}

local MOUNT_SPELLS_BY_PROJECT = LM.TableWithDefault({
    [1] = {
        { "TravelForm", LM.SPELL.TRAVEL_FORM, 'DRAGONRIDING', 'RUN', 'FLY', 'SWIM' },
        { "TravelForm", LM.SPELL.MOUNT_FORM, 'RUN' },
    },
    DEFAULT = {
        { "TravelForm", LM.SPELL.TRAVEL_FORM, 'RUN', 'SLOW' },
        { "TravelForm", LM.SPELL.AQUATIC_FORM_CLASSIC, 'SWIM' },
        { "TravelForm", LM.SPELL.FLIGHT_FORM_CLASSIC, 'FLY' },
        { "TravelForm", LM.SPELL.SWIFT_FLIGHT_FORM_CLASSIC, 'FLY' },
    },
})

tAppendAll(MOUNT_SPELLS, MOUNT_SPELLS_BY_PROJECT[WOW_PROJECT_ID])

local RefreshEvents = {
    ["NEW_MOUNT_ADDED"] = true,
    -- Companion change. Don't add COMPANION_UPDATE to this as it fires
    -- for units other than "player" and triggers constantly.
    ["COMPANION_LEARNED"] = true,
    ["COMPANION_UNLEARNED"] = true,
    -- This fires when something is favorited or unfavorited
    -- ["MOUNT_JOURNAL_SEARCH_UPDATED"] = true,
    -- Talents (might have mount abilities). Glyphs that teach spells
    -- fire PLAYER_TALENT_UPDATE too, don't need to watch GLYPH_ events.
    ["ACTIVE_TALENT_GROUP_CHANGED"] = true,
    ["PLAYER_LEVEL_UP"] = true,
    ["PLAYER_TALENT_UPDATE"] = true,
    -- You might have received a mount item (e.g., Magic Broom).
    ["BAG_UPDATE_DELAYED"] = true,
    -- Some flying unlocks are an achievement
    ["ACHIEVEMENT_EARNED"] = true,
}

function LM.MountRegistry:OnEvent(event, ...)
    if RefreshEvents[event] then
        LM.Debug("Got refresh event "..event)
        self.needRefresh = true
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local _, _, spellID = ...
        local baseSpellID = FindBaseSpellByID(spellID)
        local m = self.indexes.spellID[spellID]
                    or self.indexes.spellID[baseSpellID]
                    or self.indexes.overrideSpellID[spellID]
        if m then
            self.lastSummoned = m
            m:OnSummon()
            self.callbacks:Fire("OnMountSummoned", m)
        end
    end
end

function LM.MountRegistry:Initialize()

    self.mounts = LM.MountList:New()

    -- These are in this order so custom stuff is prioritized
    self:AddSpellMounts()
    self:AddJournalMounts()
    self:UpdateFilterUsability()

    self:BuildIndexes()

    -- Refresh event setup
    self:SetScript("OnEvent", self.OnEvent)

    for ev in pairs(RefreshEvents) do
        self:RegisterEvent(ev)
    end
    self:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
end

function LM.MountRegistry:BuildIndexes()
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

function LM.MountRegistry:AddMount(m)
    local existing = self:GetMountBySpell(m.spellID)

    if existing then
        for _, attr in ipairs(CopyAttributesFromJournal) do
            existing[attr] = existing[attr] or m[attr]
        end
    else
        tinsert(self.mounts, m)
    end

    LM.UIFilter.RegisterUsedTypeID(m.mountTypeID or 0)
end

local CollectedFilterSettings = {
    [LE_MOUNT_JOURNAL_FILTER_COLLECTED] = true,
    [LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED] = true,
    [LE_MOUNT_JOURNAL_FILTER_UNUSABLE] = false,
}

local function SaveAndSetJournalFilters()
    local data = {
        collected = {},
        sources = {},
        types = {},
    }

    for setting, value in pairs(CollectedFilterSettings) do
        data.collected[setting] = C_MountJournal.GetCollectedFilterSetting(setting)
        C_MountJournal.SetCollectedFilterSetting(setting, value)
    end

    for i = 1, C_PetJournal.GetNumPetSources() do
        if C_MountJournal.IsValidSourceFilter(i) then
            data.sources[i] = C_MountJournal.IsSourceChecked(i)
            C_MountJournal.SetSourceFilter(i, true)
        end
    end

    for i = 1, Enum.MountTypeMeta.NumValues do
        if C_MountJournal.IsValidTypeFilter(i) then
            data.types[i] = C_MountJournal.IsTypeChecked(i)
            C_MountJournal.SetTypeFilter(i, true)
        end
    end

    if MountJournalSearchBox then
        data.searchText = MountJournalSearchBox:GetText()
        C_MountJournal.SetSearch("")
    else
        data.searchText = ""
    end

    return data
end

local function RestoreJournalFilters(data)
    for setting, value in pairs(data.collected) do
        C_MountJournal.SetCollectedFilterSetting(setting, value)
    end
    for i, value in pairs(data.sources) do
        C_MountJournal.SetSourceFilter(i, value)
    end
    for i, value in pairs(data.types) do
        C_MountJournal.SetTypeFilter(i, value)
    end
    C_MountJournal.SetSearch(data.searchText)
end

-- This is horrible but I can't find any other way to get the "unusable"
-- flag as per the filter except fiddle with the filter and query

function LM.MountRegistry:UpdateFilterUsability()
    local data = SaveAndSetJournalFilters()

    local filterUsableMounts = {}

    for i = 1, C_MountJournal.GetNumDisplayedMounts() do
        local mountID = select(12, C_MountJournal.GetDisplayedMountInfo(i))
        filterUsableMounts[mountID] = true
    end

    for _,m in ipairs(self:FilterSearch("JOURNAL")) do
        m.isFilterUsable = filterUsableMounts[m.mountID] or false
    end

    RestoreJournalFilters(data)
end

function LM.MountRegistry:AddJournalMounts()
    for _, mountID in ipairs(C_MountJournal.GetMountIDs()) do
        local m = LM.Mount:Get("Journal", mountID)
        if m then self:AddMount(m) end
    end
end

-- The unpack function turns a table into a list. I.e.,
--      unpack({ a, b, c }) == a, b, c
function LM.MountRegistry:AddSpellMounts()
    for _,typeAndArgs in ipairs(MOUNT_SPELLS) do
        local m = LM.Mount:Get(unpack(typeAndArgs))
        if m then
            self:AddMount(m)
        end
    end
end

function LM.MountRegistry:RefreshMounts()
    if self.needRefresh then
        LM.Debug("Refreshing status of all mounts.")
        for _,m in ipairs(self.mounts) do
            m:Refresh()
        end
        self.needRefresh = nil
    end
end

function LM.MountRegistry:FilterSearch(...)
    return self.mounts:FilterSearch(...)
end

-- Limits can be filter (no prefix), set (=), reduce (-) or extend (+).

function LM.MountRegistry:Limit(...)
    return self.mounts:Limit(...)
end


-- This is deliberately by spell name instead of using the
-- spell ID because there are some horde/alliance mounts with
-- the same name but different spells.

local function MatchMountToBuff(m, buffNames)
    if buffNames[m.name] then return true end
    local spellName = C_Spell.GetSpellName(m.spellID)
    if spellName and buffNames[spellName] then return true end
end

function LM.MountRegistry:GetMountFromUnitAura(unitid)
    local buffNames = { }
    local i = 1
    while true do
        local auraInfo = C_UnitAuras.GetAuraDataByIndex(unitid, i)
        if auraInfo then buffNames[auraInfo.name] = true else break end
        i = i + 1
    end
    return self.mounts:Find(MatchMountToBuff, buffNames)
end

-- This is not self:GetMountFromUnitAura('player') because it matches
-- by ID and not by name, making sure you get the right version of
-- mounts with one for each faction.

function LM.MountRegistry:GetActiveMount()
    local buffIDs = { }
    local i = 1
    while true do
        local auraInfo = C_UnitAuras.GetAuraDataByIndex('player', i)
        if auraInfo then buffIDs[auraInfo.spellId] = true else break end
        i = i + 1
    end
    return self.mounts:Find(function (m) return m:IsActive(buffIDs) end)
end

function LM.MountRegistry:GetMountByName(name)
    local function match(m) return m.name == name end
    return self.mounts:Find(match)
end

function LM.MountRegistry:GetMountBySpell(id)
    local function match(m) return m.spellID == id end
    return self.mounts:Find(match)
end

function LM.MountRegistry:GetMountByID(id)
    local function match(m) return m.mountID == id end
    return self.mounts:Find(match)
end

-- For some reason GetShapeshiftFormInfo doesn't work on Ghost Wolf.
function LM.MountRegistry:GetMountByShapeshiftForm(i)
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

function LM.MountRegistry:GetJournalTotals()
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


function LM.MountRegistry:GetLastSummoned()
    return self.lastSummoned
end
