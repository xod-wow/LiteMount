--[[----------------------------------------------------------------------------

  LiteMount/PlayerMounts.lua

  Information on all your mounts.

  This keeps the shuffle order too, so we aren't constantly reshuffling things.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

_G.LM_PlayerMounts = CreateFrame("Frame", "LM_PlayerMounts", UIParent)

-- Type, type class create args
local LM_MOUNT_SPELLS = {
    { "RunningWild", LM_SPELL.RUNNING_WILD },
    { "FlightForm", LM_SPELL.FLIGHT_FORM },
    { "GhostWolf", LM_SPELL.GHOST_WOLF },
    { "TravelForm", LM_SPELL.TRAVEL_FORM },
    { "Nagrand", LM_SPELL.FROSTWOLF_WAR_WOLF },
    { "Nagrand", LM_SPELL.TELAARI_TALBUK },
    { "Spell", LM_SPELL.STAG_FORM, 'RUN' },
    { "ItemSummoned",
        LM_ITEM.LOANED_GRYPHON_REINS, LM_SPELL.LOANED_GRYPHON, 'FLY' },
    { "ItemSummoned",
        LM_ITEM.LOANED_WIND_RIDER_REINS, LM_SPELL.LOANED_WIND_RIDER, 'FLY' },
    { "ItemSummoned",
        LM_ITEM.FLYING_BROOM, LM_SPELL.FLYING_BROOM, 'FLY', },
    { "ItemSummoned",
        LM_ITEM.MAGIC_BROOM, LM_SPELL.MAGIC_BROOM, 'RUN', 'FLY', },
    { "ItemSummoned",
        LM_ITEM.SHIMMERING_MOONSTONE, LM_SPELL.MOONFANG, 'RUN', },
    { "ItemSummoned",
        LM_ITEM.RATSTALLION_HARNESS, LM_SPELL.RATSTALLION_HARNESS, 'RUN', },
    { "ItemSummoned",
        LM_ITEM.SAPPHIRE_QIRAJI_RESONATING_CRYSTAL, LM_SPELL.BLUE_QIRAJI_WAR_TANK, 'RUN', },
    { "ItemSummoned",
        LM_ITEM.RUBY_QIRAJI_RESONATING_CRYSTAL, LM_SPELL.RED_QIRAJI_WAR_TANK, 'RUN', },
    { "ItemSummoned",
        LM_ITEM.DRAGONWRATH_TARECGOSAS_REST, LM_SPELL.TARECGOSAS_VISAGE, 'FLY' },
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

function LM_PlayerMounts:Initialize()

    self.mounts = LM_MountList:New()

    self:AddSpellMounts()
    self:AddJournalMounts()

    for _,m in ipairs(self.mounts) do
        LM_Options:InitializeExcludedMount(m)
    end

    -- Refresh event setup
    self:SetScript("OnEvent",
            function (self, event, ...)
                LM_Debug("Got refresh event "..event)
                self.needRefresh = true
            end)

    for _,ev in ipairs(RefreshEvents) do
        self:RegisterEvent(ev)
    end

end

function LM_PlayerMounts:AddMount(m)
    tinsert(self.mounts, m)
end

function LM_PlayerMounts:Shuffle()
    self.mounts:Shuffle()
end

function LM_PlayerMounts:AddJournalMounts()
    for _, mountID in ipairs(C_MountJournal.GetMountIDs()) do
        local m = LM_Mount:Get("Journal", mountID)
        self:AddMount(m)
    end
end

-- The unpack function turns a table into a list. I.e.,
--      unpack({ a, b, c }) == a, b, c
function LM_PlayerMounts:AddSpellMounts()
    for _,typeAndArgs in ipairs(LM_MOUNT_SPELLS) do
        local m = LM_Mount:Get(unpack(typeAndArgs))
        self:AddMount(m)
    end
end

function LM_PlayerMounts:RefreshMounts()
    if self.needRefresh then
        LM_Debug("Refreshing status of all mounts.")

        for _,m in ipairs(self.mounts) do
            m:Refresh()
        end
        self.needRefresh = nil
    end
end

function LM_PlayerMounts:FilterSearch(...)
    return self.mounts:FilterSearch(...)
end

function LM_PlayerMounts:FilterFind(...)
    return self.mounts:FilterFind(...)
end

-- This is deliberately by spell name instead of using the
-- spell ID because there are some horde/alliance mounts with
-- the same name but different spells.

function LM_PlayerMounts:GetMountFromUnitAura(unitid)
    local buffs = { }
    local i = 1
    while true do
        local aura = UnitAura(unitid, i)
        if aura then buffs[aura] = true else break end
        i = i + 1
    end
    local function match(m)
        local spellName = GetSpellInfo(m.spellID)
        return m.isCollected and buffs[spellName] and m:IsCastable()
    end
    return self.mounts:Find(match)
end

function LM_PlayerMounts:GetMountByName(name)
    local function match(m) return m.name == name end
    return self.mounts:Find(match)
end

function LM_PlayerMounts:GetMountBySpell(id)
    local function match(m) return m.spellID == id end
    return self.mounts:Find(match)
end

-- For some reason GetShapeshiftFormInfo doesn't work on Ghost Wolf.
function LM_PlayerMounts:GetMountByShapeshiftForm(i)
    if not i then
        return
    elseif i == 1 and select(2, UnitClass("player")) == "SHAMAN" then
         return self:GetMountBySpell(LM_SPELL.GHOST_WOLF)
    else
        local spellID
        spellID = select(4, GetShapeshiftFormInfo(i))
        if spellID then return self:GetMountBySpell(spellID) end
    end
end
