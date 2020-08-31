--[[----------------------------------------------------------------------------

  LiteMount/PlayerMounts.lua

  Information on all your mounts.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

LM.PlayerMounts = CreateFrame("Frame", nil, UIParent)

-- Type, type class create args
local MOUNT_SPELLS = {
    { "RunningWild", LM.SPELL.RUNNING_WILD },
    { "GhostWolf", LM.SPELL.GHOST_WOLF },
    { "TravelForm", LM.SPELL.TRAVEL_FORM, 'RUN', 'FLY', 'SWIM' },
    { "TravelForm", LM.SPELL.FLIGHT_FORM, 'FLY' },
    { "TravelForm", LM.SPELL.STAG_FORM, 'RUN' },
    { "Nagrand", LM.SPELL.FROSTWOLF_WAR_WOLF },
    { "Nagrand", LM.SPELL.TELAARI_TALBUK },
    { "Soulshape", LM.SPELL.SOULSHAPE, 'WALK' },
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
}

local RefreshEvents = {
    -- Companion change. Don't add COMPANION_UPDATE to this as it fires
    -- for units other than "player" and triggers constantly.
    "COMPANION_LEARNED", "COMPANION_UNLEARNED",
    -- This fires when something is favorited or unfavorited
    "MOUNT_JOURNAL_SEARCH_UPDATED",
    -- Talents (might have mount abilities). Glyphs that teach spells
    -- fire PLAYER_TALENT_UPDATE too, don't need to watch GLYPH_ events.
    "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_LEVEL_UP", "PLAYER_TALENT_UPDATE",
    -- You might have received a mount item (e.g., Magic Broom).
    "BAG_UPDATE",
    -- Draenor flying is an achievement
    "ACHIEVEMENT_EARNED",
}

function LM.PlayerMounts:Initialize()

    self.mounts = LM.MountList:New()

    self:AddSpellMounts()
    self:AddJournalMounts()

    -- Refresh event setup
    self:SetScript("OnEvent",
            function (self, event, ...)
                LM.Debug("Got refresh event "..event)
                self.needRefresh = true
            end)

    for _,ev in ipairs(RefreshEvents) do
        self:RegisterEvent(ev)
    end

end

function LM.PlayerMounts:AddMount(m)
    tinsert(self.mounts, m)
end

function LM.PlayerMounts:AddJournalMounts()
    -- This is horrible but I can't find any other way to get the "unusable" flag
    local usableMounts = {}

    C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_COLLECTED, true)
    C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_NOT_COLLECTED, true)
    C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_UNUSABLE, false)
    C_MountJournal.SetAllSourceFilters(true)
    C_MountJournal.SetSearch('')

    for i = 1, C_MountJournal.GetNumDisplayedMounts() do
        local mountID = select(12, C_MountJournal.GetDisplayedMountInfo(i))
        usableMounts[mountID] = true
    end

    C_MountJournal.SetCollectedFilterSetting(LE_MOUNT_JOURNAL_FILTER_UNUSABLE, true)

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
    return self:GetMountFromUnitAura('player')
end

function LM.PlayerMounts:GetMountByName(name)
    local function match(m) return m.name == name end
    return self.mounts:Find(match)
end

function LM.PlayerMounts:GetMountBySpell(id)
    local function match(m) return m.spellID == id end
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
