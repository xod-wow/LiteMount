--[[----------------------------------------------------------------------------

  LiteMount/MountInfo/ExpansionInfo.lua

  Mostly copied from MountJournalEnhanced. Hey they took my rarity stuff
  so fair's fair right?

  Copyright 2024 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local MOUNTEXPANSION = {}

MOUNTEXPANSION[LE_EXPANSION_CLASSIC] = {
    ["minID"] = 0,
    ["maxID"] = 122,
}

MOUNTEXPANSION[LE_EXPANSION_BURNING_CRUSADE] = {
    ["minID"] = 123,
    ["maxID"] = 226,
    [241] = true, -- Brutal Nether Drake
    [243] = true, -- Big Blizzard Bear
}

MOUNTEXPANSION[LE_EXPANSION_WRATH_OF_THE_LICH_KING] = {
    ["minID"] = 227,
    ["maxID"] = 382,
    [211] = true, -- X-51 Nether-Rocket
    [212] = true, -- X-51 Nether-Rocket X-TREME
    [221] = true, -- Acherus Deathcharger
    [1679] = true, -- Frostbrood Proto-Wyrm (WotLK Classic)
}

MOUNTEXPANSION[LE_EXPANSION_CATACLYSM] = {
    ["minID"] = 383,
    ["maxID"] = 447,
    [358] = true, -- Wrathful Gladiator's Frost Wyrm
    [373] = true, -- Abyssal Seahorse
    [1812] = true, -- Runebound Firelord (Cataclysm Classic)
}

MOUNTEXPANSION[LE_EXPANSION_MISTS_OF_PANDARIA] = {
    ["minID"] = 448,
    ["maxID"] = 571,
}

MOUNTEXPANSION[LE_EXPANSION_WARLORDS_OF_DRAENOR] = {
    ["minID"] = 572,
    ["maxID"] = 772,
    [454] = true, -- Cindermane Charger
    [552] = true, -- Ironbound Wraithcharger
    [778] = true, -- Eclipse Dragonhawk
    [781] = true, -- Infinite Timereaver
}

MOUNTEXPANSION[LE_EXPANSION_LEGION] = {
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
}

MOUNTEXPANSION[LE_EXPANSION_BATTLE_FOR_AZEROTH] = {
    ["minID"] = 993,
    ["maxID"] = 1329,
    [926] = true, -- Alabaster Hyena
    [928] = true, -- Dune Scavenger
    [933] = true, -- Obsidian Krolusk
    [956] = true, -- Leaping Veinseeker
    [958] = true, -- Spectral Pterrorwing
    [963] = true, -- Bloodgorged Crawg
    [1346] = true, -- Steamscale Incinerator
}

MOUNTEXPANSION[LE_EXPANSION_SHADOWLANDS] = {
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
}

MOUNTEXPANSION[LE_EXPANSION_DRAGONFLIGHT] = {
    ["minID"] = 1577,
    ["maxID"] = 2115,
    [1469] = true, -- Magmashell
    [1478] = true, -- Skyskin Hornstrider
    [1545] = true, -- Divine Kiss of Ohn'ahra
    [1546] = true, -- Iskaara Trader's Ottuk
    [1553] = true, -- Liberated Slyvern
    [1556] = true, -- Tangled Dreamweaver
    [1563] = true, -- Highland Drake
    [2118] = true, -- Amber Pterrordax
    [2142] = true, -- August Phoenix
    [2143] = true, -- Astral Emperor's Serpent
    [2152] = true, -- Pearlescent Goblin Wave Shredder
    [2140] = true, -- Charming Courier
    [2189] = true, -- Underlight Corrupted Behemoth
}

MOUNTEXPANSION[LE_EXPANSION_WAR_WITHIN] = {
        ["minID"] = 2116,
        ["maxID"] = 9999999999,
        [1550] = true, -- Depthstalker
        [1715] = true, -- Armadillo Roller
        [1792] = true, -- Algarian Stormrider
}

function LM.MountInfo.GetMountExpansionBySpellID(spellID)
    local mountID = C_MountJournal.GetMountFromSpell(spellID)
    if mountID then
        return LM.MountInfo.GetMountExpansionByMountID(mountID)
    end
end

function LM.MountInfo.GetMountExpansionByMountID(mountID)
    local expansionID
    for id, expansionInfo in pairs(MOUNTEXPANSION) do
        if expansionInfo[mountID] then
            expansionID = id
            break
        elseif mountID >= expansionInfo.minID and mountID <= expansionInfo.maxID then
            expansionID = id
            break
        end
    end
    if expansionID then
        return expansionID, GetExpansionName(expansionID)
    end
end

function LM.MountInfo.GetMountExpansionNameByID(expansionID)
    return GetExpansionName(expansionID)
end

function LM.MountInfo.GetMountExpansionIDs()
    local expansionIDs = {}
    for i = 1, GetNumExpansions() do
        -- classic is 0
        local expansionID = i-1
        table.insert(expansionIDs, expansionID)
    end
    return expansionIDs
end

function LM.MountInfo.IsValidMountExpansionID(expansionID)
    return expansionID >= 0 and expansionID < GetNumExpansions()
end
