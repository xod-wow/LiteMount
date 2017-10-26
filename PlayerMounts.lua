--[[----------------------------------------------------------------------------

  LiteMount/PlayerMounts.lua

  Information on all your mounts.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

LM_PlayerMounts = LM_CreateAutoEventFrame("Frame", "LM_PlayerMounts", UIParent)
Mixin(LM_PlayerMounts, LM_MountList)

-- Type, type class create args
local LM_MOUNT_SPELLS = {
    { "RunningWild", LM_SPELL.RUNNING_WILD },
    { "FlightForm", LM_SPELL.FLIGHT_FORM },
    { "GhostWolf", LM_SPELL.GHOST_WOLF },
    { "TravelForm", LM_SPELL.TRAVEL_FORM },
    { "Nagrand", LM_SPELL.FROSTWOLF_WAR_WOLF },
    { "Nagrand", LM_SPELL.TELAARI_TALBUK },
    { "ItemSummoned",
        LM_ITEM.LOANED_GRYPHON_REINS, LM_SPELL.LOANED_GRYPHON,
        { 'FLY' }
    },
    { "ItemSummoned",
        LM_ITEM.LOANED_WIND_RIDER_REINS, LM_SPELL.LOANED_WIND_RIDER,
        { 'FLY' }
    },
    { "ItemSummoned",
        LM_ITEM.FLYING_BROOM, LM_SPELL.FLYING_BROOM,
        { 'FLY' },
    },
    { "ItemSummoned",
        LM_ITEM.MAGIC_BROOM, LM_SPELL.MAGIC_BROOM,
        { 'RUN', 'FLY' },
    },
    { "ItemSummoned",
        LM_ITEM.DRAGONWRATH_TARECGOSAS_REST, LM_SPELL.TARECGOSAS_VISAGE,
        { 'FLY' }
    },
    { "ItemSummoned",
        LM_ITEM.SHIMMERING_MOONSTONE, LM_SPELL.MOONFANG,
        { 'RUN' },
    },
    { "ItemSummoned",
        LM_ITEM.RATSTALLION_HARNESS, LM_SPELL.RATSTALLION_HARNESS,
        { 'RUN' },
    },
}

local RefreshEvents = {
    -- Companion change. Don't add COMPANION_UPDATE to this as it fires
    -- for units other than "player" and triggers constantly.
    "COMPANION_LEARNED", "COMPANION_UNLEARNED",
    -- Talents (might have mount abilities). Glyphs that teach spells
    -- fire PLAYER_TALENT_UPDATE too, don't need to watch GLYPH_ events.
    "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_LEVEL_UP", "PLAYER_TALENT_UPDATE",
    -- You might have received a mount item (e.g., Magic Broom).
    "BAG_UPDATE",
    -- Draenor flying is an achievement
    "ACHIEVEMENT_EARNED",
}

function LM_PlayerMounts:Initialize()

    self:AddJournalMounts()
    self:AddSpellMounts()

    for _,m in ipairs(self) do
        LM_Options:SeenMount(m)
    end

    -- Refresh event setup
    for _,ev in ipairs(RefreshEvents) do
        self[ev] = function (self, event, ...)
                            LM_Debug("Got refresh event "..event)
                            self.needRefresh = true
                        end
        self:RegisterEvent(ev)
    end
end

function LM_PlayerMounts:AddMount(m)
    tinsert(self, m)
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

        for _,m in ipairs(self) do
            m:Refresh()
        end
        self.needRefresh = nil
    end
end
