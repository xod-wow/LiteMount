--[[----------------------------------------------------------------------------

  LiteMount/SpellInfo.lua

  Constants for mount spell information.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local C_Spell = LM.C_Spell or C_Spell

local L = LM.Localize

local tocVersion = select(4, GetBuildInfo())

-- The values are sort order / UI display order
LM.FLAG = { }
LM.FLAG.SWIM                = 0
LM.FLAG.RUN                 = 1
LM.FLAG.FLY                 = 2
if tocVersion > 100000 then
    LM.FLAG.DRAGONRIDING    = 3
end
if tocVersion >= 110000 and false then
    LM.FLAG.DRIVE           = 4
end

LM.SPELL = { }
LM.SPELL.TRAVEL_FORM = 783
LM.SPELL.GHOST_WOLF = 2645
LM.SPELL.MAGIC_BROOM = 47977
LM.SPELL.RUNNING_WILD = 87840
LM.SPELL.TARECGOSAS_VISAGE = 101641
LM.SPELL.GARRISON_ABILITY = 161691
LM.SPELL.FROSTWOLF_WAR_WOLF = 164222
LM.SPELL.TELAARI_TALBUK = 165803
LM.SPELL.MOONFANG = 145133
LM.SPELL.DUSTMANE_DIREWOLF = 171844
LM.SPELL.SOARING_SKYTERROR = 191633
LM.SPELL.RATSTALLION_HARNESS = 220123
LM.SPELL.BLUE_QIRAJI_WAR_TANK = 239766
LM.SPELL.RED_QIRAJI_WAR_TANK = 239767
LM.SPELL.SOULSHAPE = 310143
LM.SPELL.FLICKER = 324701
LM.SPELL.SPECTRAL_BRIDLE = 315315
LM.SPELL.MAWRAT_HARNESS = 342780
LM.SPELL.DEADSOUL_HOUND_HARNESS = 343635
LM.SPELL.MAW_SEEKER_HARNESS = 343632
LM.SPELL.FLIGHT_FORM = 165962
LM.SPELL.MOUNT_FORM = 210053
LM.SPELL.FLIGHT_FORM_CLASSIC = 33943
LM.SPELL.SWIFT_FLIGHT_FORM_CLASSIC = 40120
LM.SPELL.AQUATIC_FORM_CLASSIC = 1066
LM.SPELL.SOAR = 369536
LM.SPELL.FLIGHT_STYLE_SKYRIDING = 404464
LM.SPELL.FLIGHT_STYLE_STEADY_FLIGHT = 404468
LM.SPELL.G_99_BREAKNECK = 1215279

LM.ITEM = { }
LM.ITEM.MAGIC_BROOM = 37011
LM.ITEM.DRAGONWRATH_TARECGOSAS_REST = 71086
LM.ITEM.SHIMMERING_MOONSTONE = 101675
LM.ITEM.RATSTALLION_HARNESS = 139421
LM.ITEM.RUBY_QIRAJI_RESONATING_CRYSTAL = 151625
LM.ITEM.SAPPHIRE_QIRAJI_RESONATING_CRYSTAL = 151626
LM.ITEM.MAWRAT_HARNESS = 168035
LM.ITEM.DEADSOUL_HOUND_HARNESS = 170498
LM.ITEM.SPECTRAL_BRIDLE = 174464
LM.ITEM.MAW_SEEKER_HARNESS = 170499
LM.ITEM.AQUATIC_SHADES = 202042

local vashjirMap = C_Map.GetMapInfo(203)
local aqMap = C_Map.GetMapInfo(319)

LM.MOUNT_TYPE_INFO = {
    [0] = {
        name = OTHER,
        flags = { },
    },
    [225] = {
        -- Cataclysm Classic: Spectral Steed/Wolf
        name = MOUNT_JOURNAL_FILTER_GROUND,
        flags = {
            RUN = true,
        }
    },
    [229] = {
        -- Cataclysm Classic: Drakes
        name = MOUNT_JOURNAL_FILTER_FLYING,
        flags = {
            FLY = true,
        }
    },
    [230] = {
        -- Ground Mount
        name = MOUNT_JOURNAL_FILTER_GROUND,
        flags = {
            RUN = true,
        },
    },
    [231] = {
        -- Riding/Sea Turtle
        name = C_Spell.GetSpellName(64731),
        flags = {
            SWIM = true,
        },
    },
    [232] = {
        -- Vashj'ir Seahorse
        name = vashjirMap and vashjirMap.name,
        flags = { },
    },
    [238] = {
        -- Cataclysm Classic: Flying Mounts
        name = MOUNT_JOURNAL_FILTER_FLYING,
        flags = {
            FLY = true,
        },
    },
    [241] = {
        -- AQ-only bugs
        name = aqMap and aqMap.name,
        flags = { },
    },
    [242] = {
        -- Flyers for when dead in some zones
        name = DEAD,
        skip = true,
        flags = { },
    },
    [247] = {
        -- Cataclysm Classic: Flying Carpets
        -- Pre-TWW Red Flying Cloud
        -- TWW [DND] Test Mount JZB
        name = C_MountJournal.GetMountInfoByID(285), -- Flying Carpets CC
        skip = tocVersion >= 110000,
        flags = {
            FLY = true,
        },
    },
    [248] = {
        -- Cataclysm Classic: Nether Drakes
        -- Pre-TWW: Nether Drakes
        name = MOUNT_JOURNAL_FILTER_FLYING,    -- Cataclysm Classic
        flags = {
            FLY = true,
        },
    },
    [254] = {
        -- Aquatic-only mounts
        name = MOUNT_JOURNAL_FILTER_AQUATIC,
        flags = {
            SWIM = true,
        },
    },
    [284] = {
        -- Chauffeured Mekgineer's Chopper etc
        name = HEIRLOOMS,
        flags = {
            RUN = true,
            SLOW = true,
        },
    },
    [398] = {
        -- Pre-TWW Kua'fon
        name = C_MountJournal.GetMountInfoByID(1043),
        flags = {
            -- Dynamically handled in LM.Journal
        },
    },
    [402] = {
        -- TWW: Flying mounts with Ride-Along
        name = MOUNT_JOURNAL_FILTER_FLYING,
        flags = {
            FLY = tocVersion >= 110000 and true or nil,
            DRAGONRIDING = true,
            RIDEALONG = true,
        },
    },
    [407] = {
        -- Flying + Aquatic, can't skyride (at least for now
        name = MOUNT_JOURNAL_FILTER_FLYING .. ' + ' .. MOUNT_JOURNAL_FILTER_AQUATIC,
        flags = {
            FLY = true,
            SWIM = true,
        },
    },
    [408] = {
        -- Unsuccessful Prototype Fleetpod
        name = C_MountJournal.GetMountInfoByID(1539),
        flags = {
            RUN = true,
            SLOW = true,
        },
    },
    [411] = {
        -- Whelpling? What is this
        name = C_MountJournal.GetMountInfoByID(1690),
        skip = true,
    },
    [412] = {
        -- Ground + Aquatic mounts
        name = MOUNT_JOURNAL_FILTER_GROUND .. ' + ' .. MOUNT_JOURNAL_FILTER_AQUATIC,
        flags = {
            RUN = true,
            SWIM = true,
        },
    },
    [424] = {
        -- Flying + Skyriding
        name = MOUNT_JOURNAL_FILTER_FLYING,
        flags = {
            FLY = true,
            DRAGONRIDING = tocVersion >= 110000 and true or nil,
        },
    },
    [426] = {
        -- Copies of the OG skyriding mounts use for racing
        name = MOUNT_JOURNAL_FILTER_DRAGONRIDING,
        skip = true,
    },
    [430] = {
        -- Another Whelpling? Even more peculiar
        name = C_MountJournal.GetMountInfoByID(1796),
        skip = true,
    },
    [436] = {
        -- Flying + Skyriding Aurelids
        -- These don't benefit from mount equipment?
        name = MOUNT_JOURNAL_FILTER_FLYING,
        flags = {
            FLY = true,
            DRAGONRIDING = true,
        },
    },
    [437] = {
        -- Flying + Skyriding discs
        name = MOUNT_JOURNAL_FILTER_FLYING,
        flags = {
            FLY = true,
            DRAGONRIDING = true,
        },
    },
    [442] = {
        -- Soar, doesn't work though (spell works).
        name = C_Spell.GetSpellName(LM.SPELL.SOAR),
        skip = true,
        flags = {
            FLY = true,
            DRAGONRIDING = true,
        },
    },
    [444] = {
        -- Flying + Skyriding Charming Courier (on beta at least)
        name = MOUNT_JOURNAL_FILTER_FLYING,
        flags = {
            FLY = true,
            DRAGONRIDING = true,
        },
    },
    [445] = {
        -- Voyaging Wilderling got its own type for some reason
        name = MOUNT_JOURNAL_FILTER_FLYING,
        flags = {
            FLY = true,
            DRAGONRIDING = true,
        },
    },
    [446] = {
        -- Unstable Rocket whatever that is
        name = C_MountJournal.GetMountInfoByID(1796),
        skip = true,
    },
    [447] = {
        -- Unstable Rocket whatever that is
        name = C_MountJournal.GetMountInfoByID(1796),
        skip = true,
    },
}

do
    LM.MOUNT_TYPE_NAMES = {}
    for typeID, typeInfo in pairs(LM.MOUNT_TYPE_INFO) do
        if typeInfo.name then
            LM.MOUNT_TYPE_NAMES[typeInfo.name] = LM.MOUNT_TYPE_NAMES[typeInfo.name] or {}
            table.insert(LM.MOUNT_TYPE_NAMES[typeInfo.name], typeID)
        end
    end
end

function LM.UnitAura(unit, aura, filter)
    local i = 1
    while true do
        local auraInfo = C_UnitAuras.GetAuraDataByIndex(unit, i, filter)
        if not auraInfo then
            return
        end
        if auraInfo.name == aura or auraInfo.spellId == tonumber(aura) then
            return auraInfo
        end
        i = i + 1
    end
end
