--[[----------------------------------------------------------------------------

  LiteMount/SpellInfo.lua

  Constants for mount spell information.

  Copyright 2011-2016 Mike Battersby

----------------------------------------------------------------------------]]--

-- These used to match the returns from the old API function GetCompanionInfo,
-- plus more of my own. But since 6.0 that was replaced with C_MountJournal
-- and specific type numbers.

LM_FLAG = { }
LM_FLAG.RUN = "run"
LM_FLAG.FLY = "fly"
LM_FLAG.FLOAT = "float"
LM_FLAG.SWIM = "swim"
LM_FLAG.JUMP = "jump"
LM_FLAG.WALK = "walk"
LM_FLAG.AQ = "aq"
LM_FLAG.VASHJIR = "vashjir"
LM_FLAG.NAGRAND = "nagrand"
LM_FLAG.CUSTOM1 = "custom1"
LM_FLAG.CUSTOM2 = "custom2"

LM_SPELL = { }
LM_SPELL.TRAVEL_FORM = 783
LM_SPELL.GHOST_WOLF = 2645
LM_SPELL.RUNNING_WILD = 87840
LM_SPELL.FLIGHT_FORM = 165962
LM_SPELL.FLYING_BROOM = 42667
LM_SPELL.MAGIC_BROOM = 47977
LM_SPELL.TARECGOSAS_VISAGE = 101641
LM_SPELL.FROSTWOLF_WAR_WOLF = 164222
LM_SPELL.TELAARI_TALBUK = 165803
LM_SPELL.MOONFANG = 145133

LM_ITEM = { }
LM_ITEM.FLYING_BROOM = 33176
LM_ITEM.MAGIC_BROOM = 37011
LM_ITEM.DRAGONWRATH_TARECGOSAS_REST = 71086
LM_ITEM.SHIMMERING_MOONSTONE = 101675


-- Type, type class create args
LM_MOUNT_SPELLS = {
    { "RunningWild", LM_SPELL.RUNNING_WILD },
    { "FlightForm", LM_SPELL.FLIGHT_FORM },
    { "TravelForm", LM_SPELL.TRAVEL_FORM },
    { "Nagrand", LM_SPELL.FROSTWOLF_WAR_WOLF },
    { "Nagrand", LM_SPELL.TELAARI_TALBUK },
    { "ItemSummoned",
        LM_ITEM.FLYING_BROOM, LM_SPELL.FLYING_BROOM, { LM_FLAG.FLY }
    },
    { "ItemSummoned",
        LM_ITEM.MAGIC_BROOM, LM_SPELL.MAGIC_BROOM, { LM_FLAG.FLY, LM_FLAG.RUN }
    },
    { "ItemSummoned",
        LM_ITEM.DRAGONWRATH_TARECGOSAS_REST, LM_SPELL.TARECGOSAS_VISAGE,
        { LM_FLAG.FLY }
    },
    { "ItemSummoned",
        LM_ITEM.SHIMMERING_MOONSTONE, LM_SPELL.MOONFANG, { LM_FLAG.RUN }
    },
}
