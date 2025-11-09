--[[----------------------------------------------------------------------------

  LiteMount/MountDB/Expansion.lua

  Adapted originally from MountJournalEnhanced by exochron.
  https://github.com/exochron/MountJournalEnhanced

----------------------------------------------------------------------------]]--

local _, LM = ...

LM.MountDB = LM.MountDB or {}

local Expansion = {

    [0] = { -- Classic
        ["minID"] = 0,
        ["maxID"] = 122,
    },

    [1] = { -- The Burning Crusade
        ["minID"] = 123,
        ["maxID"] = 226,
        [241] = true, -- Brutal Nether Drake
        [243] = true, -- Big Blizzard Bear
    },

    [2] = { -- Wrath of the Lich King
        ["minID"] = 227,
        ["maxID"] = 382,
        [211] = true, -- X-51 Nether-Rocket
        [212] = true, -- X-51 Nether-Rocket X-TREME
        [221] = true, -- Acherus Deathcharger
        [1679] = true, -- Frostbrood Proto-Wyrm (WotLK Classic)
    },

    [3] = { -- Cataclysm
        ["minID"] = 383,
        ["maxID"] = 447,
        [358] = true, -- Wrathful Gladiator's Frost Wyrm
        [373] = true, -- Abyssal Seahorse
        [1812] = true, -- Runebound Firelord (Cataclysm Classic)
    },

    [4] = { -- Mists of Pandaria
        ["minID"] = 448,
        ["maxID"] = 571,
        [467] = true, -- Cataclysmic Gladiator's Twilight Drake
        [2476] = true, -- Sha-Warped Cloud Serpent (MoP Classic)
        [2477] = true, -- Sha-Warped Riding Tiger (MoP Classic)
        [2582] = true, -- Shaohao's Sage Serpent (MoP Classic)
    },

    [5] = { -- Warlords of Draenor
        ["minID"] = 572,
        ["maxID"] = 772,
        [454] = true, -- Cindermane Charger
        [552] = true, -- Ironbound Wraithcharger
        [778] = true, -- Eclipse Dragonhawk
        [781] = true, -- Infinite Timereaver
    },

    [6] = { -- Legion
        ["minID"] = 773,
        ["maxID"] = 991,
        [476] = true, -- Yu'lei, Daughter of Jade
        [633] = true, -- Hellfire Infernal
        [656] = true, -- Llothien Prowler
        [663] = true, -- Bloodfang Widow
        [763] = true, -- Illidari Felstalker - Legion Collector's Edition
        [1006] = true, -- Lightforged Felcrusher
        [1007] = true, -- Highmountain Thunderhoof
        [1008] = true, -- Nightborne Manasaber
        [1009] = true, -- Starcursed Voidstrider
        [1011] = true, -- Shu-zen, the Divine Sentinel
    },

    [7] = { -- Battle for Azeroth
        ["minID"] = 993,
        ["maxID"] = 1329,
        [926] = true, -- Alabaster Hyena
        [928] = true, -- Dune Scavenger
        [933] = true, -- Obsidian Krolusk
        [956] = true, -- Leaping Veinseeker
        [958] = true, -- Spectral Pterrorwing
        [963] = true, -- Bloodgorged Crawg
        [1346] = true, -- Steamscale Incinerator
    },

    [8] = { -- Shadowlands
        ["minID"] = 1330,
        ["maxID"] = 1576,
        [803] = true, -- Mastercraft Gravewing
        [1289] = true, -- Ensorcelled Everwyrm
        [1298] = true, -- Hopecrusher Gargon
        [1299] = true, -- Battle Gargon Vrednic
        [1302] = true, -- Dreamlight Runestag
        [1303] = true, -- Enchanted Dreamlight Runestag
        [1304] = true, -- Mawsworn Soulhunter
        [1305] = true, -- Darkwarren Hardshell
        [1306] = true, -- Swift Gloomhoof
        [1307] = true, -- Sundancer
        [1309] = true, -- Chittering Animite
        [1310] = true, -- Horrid Dredwing
        [1580] = true, -- Heartbond Lupine
        [1581] = true, -- Nether-Gorged Greatwyrm
        [1584] = true, -- Colossal Plaguespew Mawrat
        [1585] = true, -- Colossal Wraithbound Mawrat
        [1587] = true, -- Zereth Overseer
        [1597] = true, -- Grimhowl
        [1599] = true, -- Eternal Gladiator's Soul Eater
        [1600] = true, -- Elusive Emerald Hawkstrider
        [1602] = true, -- Tuskarr Shoreglider
        [1679] = true, -- Frostbrood Proto-Wyrm
    },

    [9] = { -- Dragonflight
        ["minID"] = 1577,
        ["maxID"] = 2115,
        [799] = true,  -- Flarecore Infernal
        [1266] = true, -- Alabaster Stormtalon
        [1267] = true, -- Alabaster Thunderwing
        [1468] = true, -- Amber Skitterfly
        [1469] = true, -- Magmashell
        [1478] = true, -- Skyskin Hornstrider
        [1545] = true, -- Divine Kiss of Ohn'ahra
        [1546] = true, -- Iskaara Trader's Ottuk
        [1553] = true, -- Liberated Slyvern
        [1556] = true, -- Tangled Dreamweaver
        [1563] = true, -- Highland Drake
        [1573] = true, -- Magenta Cloud Serpent
        [1574] = true, -- Crusty Crawler
        [1575] = true, -- Quawks
        [2118] = true, -- Amber Pterrordax
        [2142] = true, -- August Phoenix
        [2143] = true, -- Astral Emperor's Serpent
        [2152] = true, -- Pearlescent Goblin Wave Shredder
        [2140] = true, -- Charming Courier
        [2189] = true, -- Underlight Corrupted Behemoth
    },

    [10] = { -- The War Within
        ["minID"] = 2116,
        ["maxID"] = math.huge,
        [1550] = true, -- Depthstalker
        [1792] = true, -- Algarian Stormrider
        [1374] = true, -- Bonecleaver's Skullboar
        [1945] = true, -- Jeweled Sapphire Scarab
    }
}

function LM.MountDB.GetExpansionByID(id)
    local expansion

    for expansionID, mountIDTable in pairs(Expansion) do
        if mountIDTable[id] then
            expansion = expansionID
            break
        elseif id >= mountIDTable.minID and id <= mountIDTable.maxID then
            expansion = expansionID
        end
    end
    return expansion
end
