--[[----------------------------------------------------------------------------

  LiteMount/Family.lua

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

LM.MOUNTFAMILY = {}

LM.MOUNTFAMILY["Alpaca"] = {
    [298367] = true, -- Mollie
    [316493] = true, -- Elusive Quickhoof
    [316802] = true, -- Springfur Alpaca

}

LM.MOUNTFAMILY["Anima Gorger"] = {
    [333027] = true, -- Loyal Gorger
    [344659] = true, -- Voracious Gorger
}

LM.MOUNTFAMILY["Aqir Flyer"] = {
    [316339] = true, -- Shadowbarb Drone
    [316337] = true, -- Malevolent Drone
    [316340] = true, -- Wicked Swarmer
}

LM.MOUNTFAMILY["Basilisk"] = {
    [230844] = true, -- Brawler's Burly Basilisk
    [261434] = true, -- Vicious War Basilisk
    [261433] = true, -- Vicious War Basilisk
    [289639] = true, -- Bruce
}

LM.MOUNTFAMILY["Bat"] = {
    [332882] = true, -- Horrid Dredwing
    [332903] = true, -- Rampart Screecher
    [312777] = true, -- Silvertip Dredwing
    [279868] = true, -- Witherbark Direwing
    [288714] = true, -- Bloodthirsty Dreadwing
    [139595] = true, -- Armored Bloodwing
    [288720] = true, -- Bloodgorged Hunter
}

LM.MOUNTFAMILY["Bear"] = {
    [288438] = true, -- Blackpaw
    [ 98204] = true, -- Amani Battle Bear
    [ 43688] = true, -- Amani War Bear
    [ 60116] = true, -- Armored Brown Bear
    [ 60114] = true, -- Armored Brown Bear
    [ 51412] = true, -- Big Battle Bear
    [ 58983] = true, -- Big Blizzard Bear
    [ 59572] = true, -- Black Polar Bear
    [ 60118] = true, -- Black War Bear
    [ 60119] = true, -- Black War Bear
    [103081] = true, -- Darkmoon Dancing Bear
    [229486] = true, -- Vicious War Bear
    [229487] = true, -- Vicious War Bear
    [ 54753] = true, -- White Polar Bear
}

LM.MOUNTFAMILY["Bee"] = {
    [259741] = true, -- Honeyback Harvester
}

LM.MOUNTFAMILY["Bird"] = {
    [266925] = true, -- Siltwing Albatross
    [183117] = true, -- Corrupted Dreadwing
    [155741] = true, -- Dread Raven
    [171828] = true, -- Solar Spirehawk
    [253639] = true, -- Violet Spellwing
    [254811] = true, -- Squawks
    [254813] = true, -- Sharkbait
    [231524] = true, -- Shadowblade's Baneful Omen
    [231525] = true, -- Shadowblade's Crimson Omen
    [231523] = true, -- Shadowblade's Lethal Omen
    [231434] = true, -- Shadowblade's Murderous Omen
    [316275] = true, -- Waste Marauder
    [316276] = true, -- Wastewander Skyterror
}

LM.MOUNTFAMILY["Boar"] = {
    [171633] = true, -- Wild Goretusk
    [171630] = true, -- Armored Razorback
    [171634] = true, -- Domesticated Razorback
    [171636] = true, -- Great Greytusk
    [171628] = true, -- Rocktusk Battleboar
    [171637] = true, -- Trained Rocktusk
    [171627] = true, -- Blacksteel Battleboar
    [171632] = true, -- Frostplains Battleboar
    [171629] = true, -- Armored Frostboar
    [190690] = true, -- Bristling Hellboar
    [190977] = true, -- Deathtusk Felboar
    [171635] = true, -- Giant Coldsnout
}

LM.MOUNTFAMILY["Bonehoof"] = {
    [332462] = true, -- Armored War-Bred Bonehoof
    [332455] = true, -- War-Bred Bonehoof
}

LM.MOUNTFAMILY["Broom"] = {
    [ 42667] = true, -- Flying Broom
    [ 47977] = true, -- Magic Broom
}

LM.MOUNTFAMILY["Brutosaur"] = {
    [264058] = true, -- Mighty Caravan Brutosaur
}

LM.MOUNTFAMILY["Camel"] = {
    [307263] = true, -- Explorer's Dunetrekker
    [ 88748] = true, -- Brown Riding Camel
    [ 88750] = true, -- Grey Riding Camel
    [ 88749] = true, -- Tan Riding Camel
    [102488] = true, -- White Riding Camel
}

LM.MOUNTFAMILY["Carpet"] = {
    [169952] = true, -- Creeping Carpet
    [ 61451] = true, -- Flying Carpet
    [ 75596] = true, -- Frosty Flying Carpet
    [233364] = true, -- Leywoven Flying Carpet
    [ 61309] = true, -- Magnificent Flying Carpet
}

LM.MOUNTFAMILY["Cat"] = {
    [232405] = true, -- Primal Flamesaber
    [ 16056] = true, -- Ancient Frostsaber
    [230987] = true, -- Arcanist's Manasaber
    [ 16055] = true, -- Black Nightsaber
    [ 63637] = true, -- Darnassian Nightsaber
    [200175] = true, -- Felsaber
    [288505] = true, -- Kaldorei Nightsaber
    [180545] = true, -- Mystic Runesaber
    [258845] = true, -- Nightborne Manasaber
    [288740] = true, -- Priestess' Moonsaber
    [288506] = true, -- Sandy Nightsaber
    [ 10789] = true, -- Spotted Frostsaber
    [ 66847] = true, -- Striped Dawnsaber
    [  8394] = true, -- Striped Frostsaber
    [ 10793] = true, -- Striped Nightsaber
    [ 23221] = true, -- Swift Frostsaber
    [ 23219] = true, -- Swift Mistsaber
    [ 65638] = true, -- Swift Moonsaber
    [ 23338] = true, -- Swift Stormsaber
    [288503] = true, -- Umber Nightsaber
    [281887] = true, -- Vicious Black Warsaber
    [146615] = true, -- Vicious Kaldorei Warsaber
    [281888] = true, -- Vicious White Warsaber
    [ 17229] = true, -- Winterspring Frostsaber
    [229385] = true, -- Ban-Lu, Grandmaster's Companion
    [ 22723] = true, -- Black War Tiger
    [129934] = true, -- Blue Shado-Pan Riding Tiger
    [129932] = true, -- Green Shado-Pan Riding Tiger
    [129935] = true, -- Red Shado-Pan Riding Tiger
    [ 42776] = true, -- Spectral Tiger
    [ 42777] = true, -- Swift Spectral Tiger
    [ 24252] = true, -- Swift Zulian Tiger
    [ 10790] = true, -- Tiger
    [229512] = true, -- Vicious War Lion
    [ 90621] = true, -- Golden King
    [ 96499] = true, -- Swift Zulian Panther
}

LM.MOUNTFAMILY["Charhound"] = {
    [253088] = true, -- Antoran Charhound
    [253087] = true, -- Antoran Gloomhound
}

LM.MOUNTFAMILY["Chimaera"] = {
    [336036] = true, -- Marrowfang
    [336038] = true, -- Callow Flayedwing
    [318052] = true, -- Deathbringer's Flayedwing
    [336039] = true, -- Gruesome Flayedwing
    [288495] = true, -- Ashenvale Chimaera
}

LM.MOUNTFAMILY["Clefthoof"] = {
    [270560] = true, -- Vicious War Clefthoof
    [171621] = true, -- Ironhoof Destroyer
    [171617] = true, -- Trained Icehoof
    [171619] = true, -- Tundra Icehoof
    [171620] = true, -- Bloodhoof Bull
    [171616] = true, -- Witherhide Cliffstomper
    [ 74918] = true, -- Wooly White Rhino
}

LM.MOUNTFAMILY["Cloud Serpent"] = {
    [127170] = true, -- Astral Cloud Serpent
    [123992] = true, -- Azure Cloud Serpent
    [127156] = true, -- Crimson Cloud Serpent
    [123993] = true, -- Golden Cloud Serpent
    [148619] = true, -- Grievous Gladiator's Cloud Serpent
    [127169] = true, -- Heavenly Azure Cloud Serpent
    [127161] = true, -- Heavenly Crimson Cloud Serpent
    [127164] = true, -- Heavenly Golden Cloud Serpent
    [127158] = true, -- Heavenly Onyx Cloud Serpent
    [315014] = true, -- Ivory Cloud Serpent
    [113199] = true, -- Jade Cloud Serpent
    [139407] = true, -- Malevolent Gladiator's Cloud Serpent
    [127154] = true, -- Onyx Cloud Serpent
    [148620] = true, -- Prideful Gladiator's Cloud Serpent
    [129918] = true, -- Thundering August Cloud Serpent
    [139442] = true, -- Thundering Cobalt Cloud Serpent
    [124408] = true, -- Thundering Jade Cloud Serpent
    [148476] = true, -- Thundering Onyx Cloud Serpent
    [132036] = true, -- Thundering Ruby Cloud Serpent
    [148618] = true, -- Tyrannical Gladiator's Cloud Serpent
    [315427] = true, -- Rajani Warserpent
    [127165] = true, -- Yu'lei, Daughter of Jade
    [110051] = true, -- Heart of the Aspects
}

LM.MOUNTFAMILY["Core Hound"] = {
    [170347] = true, -- Core Hound
    [271646] = true, -- Dark Iron Core Hound
    [213209] = true, -- Steelbound Devourer
    [341766] = true, -- Warstitched Darkhound
    [344228] = true, -- Battle-Bound Warhound
}

LM.MOUNTFAMILY["Courser"] = {
    [222240] = true, -- Prestigious Azure Courser
    [281044] = true, -- Prestigious Bloodforged Courser
    [222202] = true, -- Prestigious Bronze Courser
    [222237] = true, -- Prestigious Forest Courser
    [222238] = true, -- Prestigious Ivory Courser
    [222241] = true, -- Prestigious Midnight Courser
    [222236] = true, -- Prestigious Royal Courser
    [280730] = true, -- Pureheart Courser
    [332252] = true, -- Shimmermist Runner
    [336064] = true, -- Dauntless Duskrunner
    [342335] = true, -- Ascended Skymane
    [312767] = true, -- Swift Gloomhoof
    [312765] = true, -- Sundancer
    [242875] = true, -- Wild Dreamrunner
    [247402] = true, -- Lucid Nightmare
    [134573] = true, -- Swift Windsteed
}

LM.MOUNTFAMILY["Crab"] = {
    [294039] = true, -- Snapback Scuttler
}

LM.MOUNTFAMILY["Cradle"] = {
    [334352] = true, -- Wildseed Cradle
}

LM.MOUNTFAMILY["Crane"] = {
    [127174] = true, -- Azure Riding Crane
    [127176] = true, -- Golden Riding Crane
    [127177] = true, -- Regal Riding Crane
}

LM.MOUNTFAMILY["Crawg"] = {
    [250735] = true, -- Bloodgorged Crawg
    [273541] = true, -- Underrot Crawg
}

LM.MOUNTFAMILY["Deathroc"] = {
    [336042] = true, -- Hulking Deathroc
    [327405] = true, -- Colossal Slaughterclaw
    [336041] = true, -- Bonesewn Fleshroc
    [336045] = true, -- Predatory Plagueroc
}

LM.MOUNTFAMILY["Direhorn"] = {
    [290608] = true, -- Crusader's Direhorn
    [136471] = true, -- Spawn of Horridon
    [297560] = true, -- Child of Torcali
    [138424] = true, -- Amber Primordial Direhorn
    [138423] = true, -- Cobalt Primordial Direhorn
    [140250] = true, -- Crimson Primal Direhorn
    [140249] = true, -- Golden Primal Direhorn
    [138426] = true, -- Jade Primordial Direhorn
    [279474] = true, -- Palehide Direhorn
    [138425] = true, -- Slate Primordial Direhorn
    [263707] = true, -- Zandalari Direhorn
}

LM.MOUNTFAMILY["Disc"] = {
    [229376] = true, -- Archmage's Prismatic Disc
    [130092] = true, -- Red Flying Cloud
}

LM.MOUNTFAMILY["Donkey"] = {
    [279608] = true, -- Lil' Donkey
    [260174] = true, -- Terrified Pack Mule
}

LM.MOUNTFAMILY["Dragonhawk"] = {
    [ 96503] = true, -- Amani Dragonhawk
    [142478] = true, -- Armored Blue Dragonhawk
    [142266] = true, -- Armored Red Dragonhawk
    [ 62048] = true, -- Black Dragonhawk Mount
    [ 61996] = true, -- Blue Dragonhawk
    [194464] = true, -- Eclipse Dragonhawk
    [ 61997] = true, -- Red Dragonhawk
    [ 66088] = true, -- Sunreaver Dragonhawk
}

LM.MOUNTFAMILY["Drake"] = {
    [201098] = true, -- Infinite Timereaver
    [294197] = true, -- Obsidian Worldbreaker
    [290132] = true, -- Sylverian Dreamer
    [110039] = true, -- Experiment 12-B
    [ 59650] = true, -- Black Drake
    [ 60025] = true, -- Albino Drake
    [ 59567] = true, -- Azure Drake
    [107842] = true, -- Blazing Drake
    [ 59568] = true, -- Blue Drake
    [ 59569] = true, -- Bronze Drake
    [124550] = true, -- Cataclysmic Gladiator's Twilight Drake
    [175700] = true, -- Emerald Drake
    [ 93623] = true, -- Mottled Drake
    [ 59570] = true, -- Red Drake
    [ 69395] = true, -- Onyxian Drake
    [279466] = true, -- Twilight Avenger
    [ 59571] = true, -- Twilight Drake
    [107844] = true, -- Twilight Harbinger
    [107845] = true, -- Life-Binder's Handmaiden
    [101821] = true, -- Ruthless Gladiator's Twilight Drake
    [101282] = true, -- Vicious Gladiator's Twilight Drake
    [302143] = true, -- Uncorrupted Voidwing
    [101641] = true, -- Tarecgosa's Visage
    [113120] = true, -- Feldrake
    [229387] = true, -- Deathlord's Vilebrood Vanquisher
    [326390] = true, -- Steamscale Incinerator
}

LM.MOUNTFAMILY["Dreadsteed"] = {
    [ 23161] = true, -- Dreadsteed
    [  5784] = true, -- Felsteed
    [ 36702] = true, -- Fiery Warhorse
    [ 48778] = true, -- Acherus Deathcharger
    [ 73313] = true, -- Crimson Deathcharger
    [171847] = true, -- Cindermane Charger
    [ 48025] = true, -- Headless Horseman's Mount
    [238454] = true, -- Netherlord's Accursed Wrathsteed
    [238452] = true, -- Netherlord's Brimstone Wrathsteed
    [232412] = true, -- Netherlord's Chaotic Wrathsteed
}

LM.MOUNTFAMILY["Dreadwake"] = {
    [272770] = true, -- The Dreadwake
}

LM.MOUNTFAMILY["Elderhorn"] = {
    [213339] = true, -- Great Northern Elderhorn
    [242874] = true, -- Highmountain Elderhorn
    [288712] = true, -- Stonehide Elderhorn
    [189999] = true, -- Grove Warden
    [193007] = true, -- Grove Defiler
    [196681] = true, -- Spirit of Eche'ro
    [258060] = true, -- Highmountain Thunderhoof
}

LM.MOUNTFAMILY["Elekk"] = {
    [ 48027] = true, -- Black War Elekk
    [ 34406] = true, -- Brown Elekk
    [ 73629] = true, -- Exarch's Elekk
    [ 63639] = true, -- Exodar Elekk
    [ 35710] = true, -- Gray Elekk
    [ 35713] = true, -- Great Blue Elekk
    [ 73630] = true, -- Great Exarch's Elekk
    [ 35712] = true, -- Great Green Elekk
    [ 35714] = true, -- Great Purple Elekk
    [ 65637] = true, -- Great Red Elekk
    [ 35711] = true, -- Purple Elekk
    [223578] = true, -- Vicious War Elekk
    [171622] = true, -- Mottled Meadowstomper
    [171623] = true, -- Trained Meadowstomper
    [171624] = true, -- Shadowhide Pearltusk
    [171625] = true, -- Dusty Rockhide
    [171626] = true, -- Armored Irontusk
    [254259] = true, -- Avenging Felcrusher
    [254258] = true, -- Blessed Felcrusher
    [254069] = true, -- Glorious Felcrusher
    [258022] = true, -- Lightforged Felcrusher
    [294568] = true, -- Beastlord's Irontusk
}

LM.MOUNTFAMILY["Elemental"] = {
    [231442] = true, -- Farseer's Raging Tempest
    [213134] = true, -- Felblaze Infernal
    [213350] = true, -- Frostshard Infernal
    [289555] = true, -- Glacial Tidestorm
    [171827] = true, -- Hellfire Infernal
    [340068] = true, -- Sintouched Deathwalker
}

LM.MOUNTFAMILY["Fathom Dweller"] = {
    [308814] = true, -- Ny'alotha Allseer
    [223018] = true, -- Fathom Dweller
    [253711] = true, -- Pond Nettle
    [278979] = true, -- Surf Jelly
}

LM.MOUNTFAMILY["Fathom Ray"] = {
    [300149] = true, -- Silent Glider
    [292407] = true, -- Ankoan Waveray
    [291538] = true, -- Unshackled Waveray
    [292419] = true, -- Azshari Bloatray
    [302794] = true, -- Swift Spectral Fathom Ray
}

LM.MOUNTFAMILY["Felbat"] = {
    [229417] = true, -- Slayer's Felbroken Shrieker
    [272472] = true, -- Undercity Plaguebat
}

LM.MOUNTFAMILY["Fey Dragon"] = {
    [142878] = true, -- Enchanted Fey Dragon
}

LM.MOUNTFAMILY["Fire Hawk"] = {
    [ 97501] = true, -- Felfire Hawk
    [ 97493] = true, -- Pureblood Fire Hawk
    [ 97560] = true, -- Corrupted Fire Hawk
}

LM.MOUNTFAMILY["Fish"] = {
    [214791] = true, -- Brinedeep Bottom-Feeder
}

LM.MOUNTFAMILY["Fox"] = {
    [290133] = true, -- Vulpine Familiar
    [334366] = true, -- Wild Glimmerfur Prowler
    [242897] = true, -- Vicious War Fox
    [242896] = true, -- Vicious War Fox
    [171850] = true, -- Llothien Prowler
}

LM.MOUNTFAMILY["Gargon"] = {
    [332932] = true, -- Crypt Guardian
    [333021] = true, -- Gravestone Battle Gargon
    [312753] = true, -- Harnessed Hopecrusher
    [332923] = true, -- Inquisition Intimidator
    [332927] = true, -- Sinfall Gargon
    [333023] = true, -- Silessa
    [312754] = true, -- Vrednic
    [332949] = true, -- Desire's Loyal Hound
}

LM.MOUNTFAMILY["Goat"] = {
    [130138] = true, -- Black Riding Goat
    [130086] = true, -- Brown Riding Goat
    [130137] = true, -- White Riding Goat
}

LM.MOUNTFAMILY["Gorm"] = {
    [312763] = true, -- Darkwarren Hardshell
    [340503] = true, -- Umbral Scythehorn
    [334364] = true, -- Spinemaw Gladechewer
    [334365] = true, -- Pale Acidmaw
}

LM.MOUNTFAMILY["Gronnling"] = {
    [189364] = true, -- Coalfist Gronnling
    [171436] = true, -- Gorestrider Gronnling
    [186828] = true, -- Primal Gladiator's Felblood Gronnling
    [171849] = true, -- Sunhide Gronnling
    [189044] = true, -- Warmongering Gladiator's Felblood Gronnling
    [189043] = true, -- Wild Gladiator's Felblood Gronnling
}

LM.MOUNTFAMILY["Gryphon"] = {
    [229377] = true, -- High Priest's Lightsworn Seeker
    [302361] = true, -- Alabaster Stormtalon
    [ 61229] = true, -- Armored Snowy Gryphon
    [275859] = true, -- Dusky Waycrest Gryphon
    [ 32239] = true, -- Ebon Gryphon
    [ 32235] = true, -- Golden Gryphon
    [135416] = true, -- Grand Armored Gryphon
    [136163] = true, -- Grand Gryphon
    [ 64749] = true, -- Loaned Gryphon
    [ 32240] = true, -- Snowy Gryphon
    [107516] = true, -- Spectral Gryphon
    [ 32242] = true, -- Swift Blue Gryphon
    [ 32290] = true, -- Swift Green Gryphon
    [ 32292] = true, -- Swift Purple Gryphon
    [ 32289] = true, -- Swift Red Gryphon
    [302796] = true, -- Swift Spectral Armored Gryphon
    [ 55164] = true, -- Swift Spectral Gryphon
    [275868] = true, -- Proudmoore Sea Scout
    [275866] = true, -- Stormsong Coastwatcher
    [ 54729] = true, -- Winged Steed of the Ebon Blade
}

LM.MOUNTFAMILY["Hawkstrider"] = {
    [223363] = true, -- Vicious Warstrider
    [259202] = true, -- Starcursed Voidstrider
    [ 35022] = true, -- Black Hawkstrider
    [ 35020] = true, -- Blue Hawkstrider
    [230401] = true, -- Ivory Hawkstrider
    [ 35018] = true, -- Purple Hawkstrider
    [ 34795] = true, -- Red Hawkstrider
    [ 63642] = true, -- Silvermoon Hawkstrider
    [ 66091] = true, -- Sunreaver Hawkstrider
    [ 35025] = true, -- Swift Green Hawkstrider
    [ 33660] = true, -- Swift Pink Hawkstrider
    [ 35027] = true, -- Swift Purple Hawkstrider
    [ 65639] = true, -- Swift Red Hawkstrider
    [ 46628] = true, -- Swift White Hawkstrider
    [ 35028] = true, -- Swift Warstrider
}

LM.MOUNTFAMILY["Hippogryph"] = {
    [ 63844] = true, -- Argent Hippogryph
    [ 74856] = true, -- Blazing Hippogryph
    [ 43927] = true, -- Cenarion War Hippogryph
    [242881] = true, -- Cloudwing Hippogryph
    [102514] = true, -- Corrupted Hippogryph
    [149801] = true, -- Emerald Hippogryph
    [ 97359] = true, -- Flameward Hippogryph
    [225765] = true, -- Leyfeather Hippogryph
    [215159] = true, -- Long-Forgotten Hippogryph
    [ 66087] = true, -- Silver Covenant Hippogryph
    [239363] = true, -- Swift Spectral Hippogryph
    [274610] = true, -- Teldrassil Hippogryph
}

LM.MOUNTFAMILY["Hivemind"] = {
    [261395] = true, -- The Hivemind
}

LM.MOUNTFAMILY["Horse"] = {
    [103196] = true, -- Swift Mountain Horse
    [259213] = true, -- Admiralty Stallion
    [295387] = true, -- Bloodflank Charger
    [279457] = true, -- Broken Highland Mustang
    [255695] = true, -- Seabraid Stallion
    [341639] = true, -- Court Sinrunner
    [260175] = true, -- Goldenmane
    [279456] = true, -- Highland Mustang
    [ 66906] = true, -- Argent Charger
    [ 23214] = true, -- Charger
    [231435] = true, -- Highlord's Golden Charger
    [231589] = true, -- Highlord's Valorous Charger
    [231587] = true, -- Highlord's Vengeful Charger
    [231588] = true, -- Highlord's Vigilant Charger
    [282682] = true, -- Kul Tiran Charger
    [260173] = true, -- Smoky Charger
    [ 34767] = true, -- Thalassian Charger
    [  6648] = true, -- Chestnut Mare
    [   468] = true, -- White Stallion
    [ 16083] = true, -- White Stallion
    [   470] = true, -- Black Stallion
    [ 16082] = true, -- Palomino
    [ 23227] = true, -- Swift Palomino
    [   472] = true, -- Pinto
    [ 67466] = true, -- Argent Warhorse
    [ 68188] = true, -- Crusader's Black Warhorse
    [ 68187] = true, -- Crusader's White Warhorse
    [ 34769] = true, -- Thalassian Warhorse
    [   458] = true, -- Brown Horse
    [103195] = true, -- Mountain Horse
    [ 22717] = true, -- Black War Steed
    [193695] = true, -- Prestigious War Steed
    [ 63232] = true, -- Stormwind Steed
    [ 68057] = true, -- Swift Alliance Steed
    [ 23229] = true, -- Swift Brown Steed
    [ 65640] = true, -- Swift Gray Steed
    [ 23228] = true, -- Swift White Steed
    [100332] = true, -- Vicious War Steed
    [ 13819] = true, -- Warhorse
    [223341] = true, -- Vicious Gilnean Warhorse
    [339588] = true, -- Sinrunner Blanchy
    [107203] = true, -- Tyrael's Charger
    [ 72286] = true, -- Invincible
    [142073] = true, -- Hearthsteed
    [ 75614] = true, -- Celestial Steed
    [136505] = true, -- Ghastly Charger
    [260172] = true, -- Dapple Gray
    [ 48954] = true, -- Swift Zhevra
    [ 49322] = true, -- Swift Zhevra
    [ 66090] = true, -- Quel'dorei Steed
    [ 92231] = true, -- Spectral Steed
}

LM.MOUNTFAMILY["Hound"] = {
    [344578] = true, -- Corridor Creeper
    [312762] = true, -- Mawsworn Soulhunter
    [189998] = true, -- Illidari Felstalker
}

LM.MOUNTFAMILY["Hyena"] = {
    [237287] = true, -- Alabaster Hyena
    [306423] = true, -- Caravan Hyena
    [237286] = true, -- Dune Scavenger
}

LM.MOUNTFAMILY["Kodo"] = {
    [ 22718] = true, -- Black War Kodo
    [ 49378] = true, -- Brewfest Riding Kodo
    [ 18990] = true, -- Brown Kodo
    [288499] = true, -- Frightened Kodo
    [ 18989] = true, -- Gray Kodo
    [ 49379] = true, -- Great Brewfest Kodo
    [ 23249] = true, -- Great Brown Kodo
    [ 65641] = true, -- Great Golden Kodo
    [ 23248] = true, -- Great Gray Kodo
    [ 69826] = true, -- Great Sunwalker Kodo
    [ 23247] = true, -- Great White Kodo
    [ 18991] = true, -- Green Kodo
    [ 18363] = true, -- Riding Kodo
    [ 69820] = true, -- Sunwalker Kodo
    [ 18992] = true, -- Teal Kodo
    [ 63641] = true, -- Thunder Bluff Kodo
    [185052] = true, -- Vicious War Kodo
    [ 64657] = true, -- White Kodo
}

LM.MOUNTFAMILY["Krolusk"] = {
    [288736] = true, -- Azureshell Krolusk
    [279454] = true, -- Conqueror's Scythemaw
    [239049] = true, -- Obsidian Krolusk
    [288735] = true, -- Rubyshell Krolusk
}

LM.MOUNTFAMILY["Larion"] = {
    [342334] = true, -- Gilded Prowler
    [334433] = true, -- Silverwind Larion
    [341776] = true, -- Highwind Darkmane
}

LM.MOUNTFAMILY["Mammoth"] = {
    [ 59785] = true, -- Black War Mammoth
    [ 59788] = true, -- Black War Mammoth
    [ 61465] = true, -- Grand Black War Mammoth
    [ 61467] = true, -- Grand Black War Mammoth
    [ 60140] = true, -- Grand Caravan Mammoth
    [ 60136] = true, -- Grand Caravan Mammoth
    [ 61469] = true, -- Grand Ice Mammoth
    [ 61470] = true, -- Grand Ice Mammoth
    [ 59797] = true, -- Ice Mammoth
    [ 59799] = true, -- Ice Mammoth
    [ 61447] = true, -- Traveler's Tundra Mammoth
    [ 61425] = true, -- Traveler's Tundra Mammoth
    [ 59791] = true, -- Wooly Mammoth
    [ 59793] = true, -- Wooly Mammoth
}

LM.MOUNTFAMILY["Mana Ray"] = {
    [235764] = true, -- Darkspore Mana Ray
    [253108] = true, -- Felglow Mana Ray
    [253107] = true, -- Lambent Mana Ray
    [253109] = true, -- Scintillating Mana Ray
    [253106] = true, -- Vibrant Mana Ray
    [344574] = true, -- Bulbous Necroray
    [344576] = true, -- Infested Necroray
    [344575] = true, -- Pestilent Necroray
}

LM.MOUNTFAMILY["Marsh Hopper"] = {
    [339632] = true, -- Arboreal Gulper
    [288587] = true, -- Blue Marsh Hopper
    [259740] = true, -- Green Marsh Hopper
    [288589] = true, -- Yellow Marsh Hopper
}

LM.MOUNTFAMILY["Meat Wagon"] = {
    [281554] = true, -- Meat Wagon
}

LM.MOUNTFAMILY["Mechacycle"] = {
    [296788] = true, -- Mechacycle Model W
    [297157] = true, -- Junkheap Drifter
}

LM.MOUNTFAMILY["Mechanocat"] = {
    [294143] = true, -- X-995 Mechanocat
}

LM.MOUNTFAMILY["Mechanocrawler"] = {
    [299158] = true, -- Mechagon Peacekeeper
    [291492] = true, -- Rusty Mechanocrawler
    [299159] = true, -- Scrapforged Mechaspider
}

LM.MOUNTFAMILY["Mechanoflier"] = {
    [307256] = true, -- Explorer's Jungle Hopper
    [256123] = true, -- Xiwyllag ATV
    [290718] = true, -- Aerial Unit R-21/X
    [290328] = true, -- Wonderwing 2.0
    [299170] = true, -- Rustbolt Resistor
    [245723] = true, -- Stormwind Skychaser
    [245725] = true, -- Orgrimmar Interceptor
    [ 44153] = true, -- Flying Machine
    [ 44151] = true, -- Turbo-Charged Flying Machine
    [ 63796] = true, -- Mimiron's Head
    [261437] = true, -- Mecha-Mogul Mk2
    [302795] = true, -- Swift Spectral Magnetocraft
    [247448] = true, -- Darkmoon Dirigible
}

LM.MOUNTFAMILY["Mechanosteed"] = {
    [163024] = true, -- Warforged Nightmare
    [142910] = true, -- Ironbound Wraithcharger
}

LM.MOUNTFAMILY["Mechanostrider"] = {
    [ 33630] = true, -- Blue Mechanostrider
    [ 10969] = true, -- Blue Mechanostrider
    [ 63638] = true, -- Gnomeregan Mechanostrider
    [ 15780] = true, -- Green Mechanostrider
    [ 17453] = true, -- Green Mechanostrider
    [ 17459] = true, -- Icy Blue Mechanostrider Mod A
    [305592] = true, -- Mechagon Mechanostrider
    [ 10873] = true, -- Red Mechanostrider
    [ 23225] = true, -- Swift Green Mechanostrider
    [ 23223] = true, -- Swift White Mechanostrider
    [ 23222] = true, -- Swift Yellow Mechanostrider
    [ 17454] = true, -- Unpainted Mechanostrider
    [183889] = true, -- Vicious War Mechanostrider
    [ 15779] = true, -- White Mechanostrider Mod B
    [ 65642] = true, -- Turbostrider
    [ 22719] = true, -- Black Battlestrider
}

LM.MOUNTFAMILY["Moth"] = {
    [342666] = true, -- Amber Ardenmoth
    [332256] = true, -- Duskflutter Ardenmoth
    [318051] = true, -- Silky Shimmermoth
    [342667] = true, -- Vibrant Flutterwing
}

LM.MOUNTFAMILY["Motorcycle"] = {
    [179245] = true, -- Chauffeured Mekgineer's Chopper
    [ 60424] = true, -- Mekgineer's Chopper
    [179244] = true, -- Chauffeured Mechano-Hog
    [ 55531] = true, -- Mechano-Hog
    [ 87090] = true, -- Goblin Trike
    [ 87091] = true, -- Goblin Turbo-Trike
    [223354] = true, -- Vicious War Trike
    [171845] = true, -- Warlord's Deathwheel
    [171846] = true, -- Champion's Treadblade
}

LM.MOUNTFAMILY["Mushan Beast"] = {
    [148428] = true, -- Ashhide Mushan Beast
    [142641] = true, -- Brawler's Burly Mushan Beast
    [130965] = true, -- Son of Galleon
}

LM.MOUNTFAMILY["Nether Drake"] = {
    [ 58615] = true, -- Brutal Nether Drake
    [ 44317] = true, -- Merciless Nether Drake
    [ 44744] = true, -- Merciless Nether Drake
    [ 28828] = true, -- Nether Drake
    [ 37015] = true, -- Swift Nether Drake
    [ 49193] = true, -- Vengeful Nether Drake
    [ 41514] = true, -- Azure Netherwing Drake
    [ 41515] = true, -- Cobalt Netherwing Drake
    [ 41513] = true, -- Onyx Netherwing Drake
    [ 41516] = true, -- Purple Netherwing Drake
    [ 41517] = true, -- Veridian Netherwing Drake
    [ 41518] = true, -- Violet Netherwing Drake
}

LM.MOUNTFAMILY["Nether Ray"] = {
    [ 39803] = true, -- Blue Riding Nether Ray
    [ 39798] = true, -- Green Riding Nether Ray
    [ 39801] = true, -- Purple Riding Nether Ray
    [ 39800] = true, -- Red Riding Nether Ray
    [ 39802] = true, -- Silver Riding Nether Ray
}

LM.MOUNTFAMILY["Pandaren Kite"] = {
    [133023] = true, -- Jade Pandaren Kite
    [130985] = true, -- Pandaren Kite
    [118737] = true, -- Pandaren Kite
}

LM.MOUNTFAMILY["Panthara"] = {
    [243512] = true, -- Luminous Starseeker
}

LM.MOUNTFAMILY["Phoenix"] = {
    [132117] = true, -- Ashen Pandaren Phoenix
    [129552] = true, -- Crimson Pandaren Phoenix
    [132118] = true, -- Emerald Pandaren Phoenix
    [132119] = true, -- Violet Pandaren Phoenix
    [ 40192] = true, -- Ashes of Al'ar
    [ 88990] = true, -- Dark Phoenix
    [312751] = true, -- Clutch of Ha-Li
    [139448] = true, -- Clutch of Ji-Kun
}

LM.MOUNTFAMILY["Proto-Drake"] = {
    [229388] = true, -- Battlelord's Bloodthirsty War Wyrm
    [ 59976] = true, -- Black Proto-Drake
    [ 59996] = true, -- Blue Proto-Drake
    [262027] = true, -- Corrupted Gladiator's Proto-Drake
    [262022] = true, -- Dread Gladiator's Proto-Drake
    [ 61294] = true, -- Green Proto-Drake
    [ 63956] = true, -- Ironbound Proto-Drake
    [262024] = true, -- Notorious Gladiator's Proto-Drake
    [ 60021] = true, -- Plagued Proto-Drake
    [ 59961] = true, -- Red Proto-Drake
    [ 63963] = true, -- Rusted Proto-Drake
    [262023] = true, -- Sinister Gladiator's Proto-Drake
    [ 60002] = true, -- Time-Lost Proto-Drake
    [ 60024] = true, -- Violet Proto-Drake
    [148392] = true, -- Spawn of Galakras
}

LM.MOUNTFAMILY["Pterrordax"] = {
    [275837] = true, -- Cobalt Pterrordax
    [244712] = true, -- Spectral Pterrorwing
    [302797] = true, -- Swift Spectral Pterrordax
    [289101] = true, -- Dazar'alor Windreaver
    [267270] = true, -- Kua'fon
    [275838] = true, -- Captured Swampstalker
    [275840] = true, -- Voldunai Dunescraper
    [136400] = true, -- Armored Skyscreamer
}

LM.MOUNTFAMILY["Quilen"] = {
    [124659] = true, -- Imperial Quilen
    [279469] = true, -- Qinsho's Eternal Hound
    [316722] = true, -- Ren's Stalwart Hound
    [316723] = true, -- Xinlao
}

LM.MOUNTFAMILY["Ram"] = {
    [  6896] = true, -- Black Ram
    [ 17461] = true, -- Black Ram
    [ 22720] = true, -- Black War Ram
    [ 43899] = true, -- Brewfest Ram
    [  6899] = true, -- Brown Ram
    [270562] = true, -- Darkforge Ram
    [270564] = true, -- Dawnforge Ram
    [ 17460] = true, -- Frost Ram
    [  6777] = true, -- Gray Ram
    [ 63636] = true, -- Ironforge Ram
    [308250] = true, -- Stormpike Battle Ram
    [ 43900] = true, -- Swift Brewfest Ram
    [ 23238] = true, -- Swift Brown Ram
    [ 23239] = true, -- Swift Gray Ram
    [ 65643] = true, -- Swift Violet Ram
    [ 23240] = true, -- Swift White Ram
    [171834] = true, -- Vicious War Ram
    [  6898] = true, -- White Ram
    [ 23510] = true, -- Stormpike Battle Charger
}

LM.MOUNTFAMILY["Raptor"] = {
    [279611] = true, -- Skullripper
    [255696] = true, -- Gilded Ravasaur
    [266058] = true, -- Tomb Stalker
    [  8395] = true, -- Emerald Raptor
    [ 64659] = true, -- Venomhide Ravasaur
    [ 96491] = true, -- Armored Razzashi Raptor
    [138642] = true, -- Black Primal Raptor
    [ 22721] = true, -- Black War Raptor
    [138640] = true, -- Bone-White Primal Raptor
    [ 63635] = true, -- Darkspear Raptor
    [ 84751] = true, -- Fossilized Raptor
    [138643] = true, -- Green Primal Raptor
    [ 10795] = true, -- Ivory Raptor
    [ 17450] = true, -- Ivory Raptor
    [ 16084] = true, -- Mottled Red Raptor
    [138641] = true, -- Red Primal Raptor
    [ 97581] = true, -- Savage Raptor
    [279569] = true, -- Swift Albino Raptor
    [ 23241] = true, -- Swift Blue Raptor
    [ 23242] = true, -- Swift Olive Raptor
    [ 23243] = true, -- Swift Orange Raptor
    [ 65644] = true, -- Swift Purple Raptor
    [ 24242] = true, -- Swift Razzashi Raptor
    [ 10796] = true, -- Turquoise Raptor
    [171835] = true, -- Vicious War Raptor
    [ 10799] = true, -- Violet Raptor
    [213163] = true, -- Snowfeather Hunter
    [213165] = true, -- Viridian Sharptalon
    [213164] = true, -- Brilliant Direbeak
    [213158] = true, -- Predatory Bloodgazer
}

LM.MOUNTFAMILY["Rat"] = {
    [215558] = true, -- Ratstallion
    [220123] = true, -- Ratstallion Harness
}

LM.MOUNTFAMILY["Ravager"] = {
    [163025] = true, -- Grinning Reaver
}

LM.MOUNTFAMILY["Riverbeast"] = {
    [171826] = true, -- Mudback Riverbeast
    [171824] = true, -- Sapphire Riverbeast
    [272481] = true, -- Vicious War Riverbeast
    [171825] = true, -- Mosshide Riverwallow
    [171638] = true, -- Trained Riverwallow
}

LM.MOUNTFAMILY["Rocket"] = {
    [ 46197] = true, -- X-51 Nether-Rocket
    [ 46199] = true, -- X-51 Nether-Rocket X-TREME
    [ 75973] = true, -- X-53 Touring Rocket
    [126507] = true, -- Depleted-Kyparium Rocket
    [126508] = true, -- Geosynchronous World Spinner
    [ 71342] = true, -- Big Love Rocket
}

LM.MOUNTFAMILY["Rooster"] = {
    [ 66124] = true, -- Magic Rooster
    [ 66123] = true, -- Magic Rooster
    [ 66122] = true, -- Magic Rooster
    [ 65917] = true, -- Magic Rooster
}

LM.MOUNTFAMILY["Runedeer"] = {
    [312759] = true, -- Dreamlight Runedeer
    [332243] = true, -- Umbral Runedeer
    [332244] = true, -- Wakener's Runedeer
    [332245] = true, -- Winterborn Runedeer
    [312761] = true, -- Dreamlight Runestag
    [332246] = true, -- Umbral Runestag
    [332247] = true, -- Wakener's Runestag
}

LM.MOUNTFAMILY["Rylak"] = {
    [153489] = true, -- Iron Skyreaver
    [191633] = true, -- Soaring Skyterror
    [194046] = true, -- Swift Spectral Rylak
}

LM.MOUNTFAMILY["Scorpion"] = {
    [123886] = true, -- Amber Scorpion
    [ 93644] = true, -- Kor'kron Annihilator
    [148417] = true, -- Kor'kron Juggernaut
    [230988] = true, -- Vicious War Scorpion
}

LM.MOUNTFAMILY["Sea Ray"] = {
    [228919] = true, -- Darkwater Skate
    [278803] = true, -- Great Sea Ray
}

LM.MOUNTFAMILY["Sea Turtle"] = {
    [ 30174] = true, -- Riding Turtle
    [ 64731] = true, -- Sea Turtle
}

LM.MOUNTFAMILY["Seahorse"] = {
    [288711] = true, -- Saltwater Seahorse
    [ 98718] = true, -- Subdued Seahorse
    [ 75207] = true, -- Vashj'ir Seahorse
    [300151] = true, -- Inkscale Deepseeker
    [300150] = true, -- Fabious
    [300153] = true, -- Crimson Tidestallion

}

LM.MOUNTFAMILY["Serpent"] = {
    [232519] = true, -- Abyss Worm
    [243025] = true, -- Riddler's Mind-Worm
    [275623] = true, -- Nazjatar Blood Serpent
    [307932] = true, -- Ensorcelled Everwyrm
    [315987] = true, -- Mail Muncher
    [346141] = true, -- Slime Serpent
    [316343] = true, -- Wriggling Parasite
    [316637] = true, -- Awakened Mindborer
    [305182] = true, -- Black Serpent of N'Zoth
}

LM.MOUNTFAMILY["Shapeshift"] = {
    [165962] = true, -- Flight Form
    [210053] = true, -- Mount Form
    [ 87840] = true, -- Running Wild
    [   783] = true, -- Travel Form
    [310143] = true, -- Soulshape
    [  2645] = true, -- Ghost Wolf
}

LM.MOUNTFAMILY["Silithid"] = {
    [ 25863] = true, -- Black Qiraji Battle Tank
    [ 26655] = true, -- Black Qiraji Battle Tank
    [ 26656] = true, -- Black Qiraji Battle Tank
    [239770] = true, -- Black Qiraji War Tank
    [ 25953] = true, -- Blue Qiraji Battle Tank
    [239766] = true, -- Blue Qiraji War Tank
    [ 26056] = true, -- Green Qiraji Battle Tank
    [ 26054] = true, -- Red Qiraji Battle Tank
    [239767] = true, -- Red Qiraji War Tank
    [ 92155] = true, -- Ultramarine Qiraji Battle Tank
    [ 26055] = true, -- Yellow Qiraji Battle Tank
}

LM.MOUNTFAMILY["Skeletal Horse"] = {
    [ 64977] = true, -- Black Skeletal Horse
    [ 17463] = true, -- Blue Skeletal Horse
    [ 17464] = true, -- Brown Skeletal Horse
    [ 17462] = true, -- Red Skeletal Horse
    [  8980] = true, -- Skeletal Horse
    [ 64656] = true, -- Blue Skeletal Warhorse
    [ 17465] = true, -- Green Skeletal Warhorse
    [ 66846] = true, -- Ochre Skeletal Warhorse
    [ 23246] = true, -- Purple Skeletal Warhorse
    [ 22722] = true, -- Red Skeletal Warhorse
    [146622] = true, -- Vicious Skeletal Warhorse
    [ 65645] = true, -- White Skeletal Warhorse
    [ 17481] = true, -- Rivendare's Deathcharger
    [229499] = true, -- Midnight
    [288722] = true, -- Risen Mare
    [ 63643] = true, -- Forsaken Warhorse
    [281890] = true, -- Vicious Black Bonesteed
    [281889] = true, -- Vicious White Bonesteed
}

LM.MOUNTFAMILY["Skullboar"] = {
    [332484] = true, -- Lurid Bloodtusk
    [332478] = true, -- Umbral Bloodtusk
    [332480] = true, -- Gorespine
    [332482] = true, -- Bonecleaver's Skullboar
}

LM.MOUNTFAMILY["Snapdragon"] = {
    [300147] = true, -- Deepcoral Snapdragon
    [294038] = true, -- Royal Snapdragon
    [300146] = true, -- Snapdragon Kelpstalker
}

LM.MOUNTFAMILY["Soul Eater"] = {
    [332400] = true, -- Sinful Gladiator's Soul Eater
}

LM.MOUNTFAMILY["Spider"] = {
    [213115] = true, -- Bloodfang Widow
    [327408] = true, -- Vicious War Spider
    [327407] = true, -- Vicious War Spider
}

LM.MOUNTFAMILY["Stone Cat"] = {
    [121837] = true, -- Jade Panther
    [120043] = true, -- Jeweled Onyx Panther
    [121838] = true, -- Ruby Panther
    [121836] = true, -- Sapphire Panther
    [121839] = true, -- Sunstone Panther
    [121820] = true, -- Obsidian Nightwing
    [ 98727] = true, -- Winged Guardian
}

LM.MOUNTFAMILY["Stone Drake"] = {
    [ 88718] = true, -- Phosphorescent Stone Drake
    [ 93326] = true, -- Sandstone Drake
    [ 88746] = true, -- Vitreous Stone Drake
    [ 88331] = true, -- Volcanic Stone Drake
}

LM.MOUNTFAMILY["Storm Dragon"] = {
    [227989] = true, -- Cruel Gladiator's Storm Dragon
    [243201] = true, -- Demonic Gladiator's Storm Dragon
    [227995] = true, -- Dominant Gladiator's Storm Dragon
    [227988] = true, -- Fearless Gladiator's Storm Dragon
    [227991] = true, -- Ferocious Gladiator's Storm Dragon
    [227994] = true, -- Fierce Gladiator's Storm Dragon
    [227986] = true, -- Vindictive Gladiator's Storm Dragon
    [288721] = true, -- Island Thunderscale
    [242882] = true, -- Valarjar Stormwing
}

LM.MOUNTFAMILY["Talbuk"] = {
    [253058] = true, -- Maddened Chaosrunner
    [253004] = true, -- Amethyst Ruinstrider
    [253005] = true, -- Beryl Ruinstrider
    [254260] = true, -- Bleakhoof Ruinstrider
    [253007] = true, -- Cerulean Ruinstrider
    [253006] = true, -- Russet Ruinstrider
    [242305] = true, -- Sable Ruinstrider
    [253008] = true, -- Umber Ruinstrider
    [171830] = true, -- Swift Breezestrider
    [171829] = true, -- Shadowmane Charger
    [171831] = true, -- Trained Silverpelt
    [171833] = true, -- Pale Thorngrazer
    [171832] = true, -- Breezestrider Stallion
    [ 39315] = true, -- Cobalt Riding Talbuk
    [ 34896] = true, -- Cobalt War Talbuk
    [ 39316] = true, -- Dark Riding Talbuk
    [ 34790] = true, -- Dark War Talbuk
    [ 39317] = true, -- Silver Riding Talbuk
    [ 34898] = true, -- Silver War Talbuk
    [ 39318] = true, -- Tan Riding Talbuk
    [ 34899] = true, -- Tan War Talbuk
    [165803] = true, -- Telaari Talbuk
    [ 39319] = true, -- White Riding Talbuk
    [ 34897] = true, -- White War Talbuk
}

LM.MOUNTFAMILY["Tallstrider"] = {
    [102349] = true, -- Swift Springstrider
    [102350] = true, -- Swift Lovebird
    [102346] = true, -- Swift Forest Strider
    [101573] = true, -- Swift Shorestrider
}

LM.MOUNTFAMILY["Talonbird"] = {
    [ 41252] = true, -- Raven Lord
    [101542] = true, -- Flametalon of Alysrazor
    [280729] = true, -- Frenzied Feltalon
    [179478] = true, -- Voidtalon of the Dark Star
}

LM.MOUNTFAMILY["Tick"] = {
    [275841] = true, -- Expedition Bloodswarmer
    [243795] = true, -- Leaping Veinseeker
    [312776] = true, -- Chittering Animite
    [332905] = true, -- Endmire Flyer
}

LM.MOUNTFAMILY["Turtle"] = {
    [227956] = true, -- Arcadian War Turtle
    [232525] = true, -- Vicious War Turtle
    [232523] = true, -- Vicious War Turtle
    [127286] = true, -- Black Dragon Turtle
    [127287] = true, -- Blue Dragon Turtle
    [127288] = true, -- Brown Dragon Turtle
    [127295] = true, -- Great Black Dragon Turtle
    [127302] = true, -- Great Blue Dragon Turtle
    [127308] = true, -- Great Brown Dragon Turtle
    [127293] = true, -- Great Green Dragon Turtle
    [127310] = true, -- Great Purple Dragon Turtle
    [120822] = true, -- Great Red Dragon Turtle
    [120395] = true, -- Green Dragon Turtle
    [127289] = true, -- Purple Dragon Turtle
    [127290] = true, -- Red Dragon Turtle
}

LM.MOUNTFAMILY["Undead Wyrm"] = {
    [ 65439] = true, -- Furious Gladiator's Frost Wyrm
    [ 67336] = true, -- Relentless Gladiator's Frost Wyrm
    [ 71810] = true, -- Wrathful Gladiator's Frost Wyrm
    [ 64927] = true, -- Deadly Gladiator's Frost Wyrm
    [231428] = true, -- Smoldering Ember Wyrm
    [ 72808] = true, -- Bloodbathed Frostbrood Vanquisher
    [ 72807] = true, -- Icebound Frostbrood Vanquisher
}

LM.MOUNTFAMILY["Ur'zul"] = {
    [243651] = true, -- Shackled Ur'zul
}

LM.MOUNTFAMILY["Vile Fiend"] = {
    [243652] = true, -- Vile Fiend
    [253660] = true, -- Biletooth Gnasher
    [253662] = true, -- Acid Belcher
    [253661] = true, -- Crimson Slavermaw
}

LM.MOUNTFAMILY["Warframe"] = {
    [182912] = true, -- Felsteel Annihilator
    [289083] = true, -- G.M.O.D.
    [239013] = true, -- Lightforged Warframe
    [134359] = true, -- Sky Golem
    [223814] = true, -- Mechanized Lumber Extractor
}

LM.MOUNTFAMILY["Water Strider"] = {
    [118089] = true, -- Azure Water Strider
    [127271] = true, -- Crimson Water Strider
}

LM.MOUNTFAMILY["Wind Drake"] = {
    [ 88335] = true, -- Drake of the East Wind
    [315847] = true, -- Drake of the Four Winds
    [ 88742] = true, -- Drake of the North Wind
    [ 88744] = true, -- Drake of the South Wind
    [ 88741] = true, -- Drake of the West Wind
}

LM.MOUNTFAMILY["Wind Rider"] = {
    [ 61230] = true, -- Armored Blue Wind Rider
    [ 32244] = true, -- Blue Wind Rider
    [ 32245] = true, -- Green Wind Rider
    [ 64762] = true, -- Loaned Wind Rider
    [107517] = true, -- Spectral Wind Rider
    [ 32295] = true, -- Swift Green Wind Rider
    [ 32297] = true, -- Swift Purple Wind Rider
    [ 32246] = true, -- Swift Red Wind Rider
    [ 32296] = true, -- Swift Yellow Wind Rider
    [ 32243] = true, -- Tawny Wind Rider
    [302362] = true, -- Alabaster Thunderwing
    [135418] = true, -- Grand Armored Wyvern
    [136164] = true, -- Grand Wyvern
}

LM.MOUNTFAMILY["Wolf"] = {
    [295386] = true, -- Ironclad Frostclaw
    [306421] = true, -- Frostwolf Snarler
    [171841] = true, -- Trained Snarler
    [267274] = true, -- Mag'har Direwolf
    [171844] = true, -- Dustmane Direwolf
    [186305] = true, -- Infernal Direwolf
    [171843] = true, -- Smoky Direwolf
    [ 16081] = true, -- Arctic Wolf
    [ 22724] = true, -- Black War Wolf
    [   578] = true, -- Black Wolf
    [ 64658] = true, -- Black Wolf
    [  6654] = true, -- Brown Wolf
    [  6653] = true, -- Dire Wolf
    [164222] = true, -- Frostwolf War Wolf
    [   459] = true, -- Gray Wolf
    [148396] = true, -- Kor'kron War Wolf
    [ 63640] = true, -- Orgrimmar Wolf
    [204166] = true, -- Prestigious War Wolf
    [   579] = true, -- Red Wolf
    [ 16080] = true, -- Red Wolf
    [ 92232] = true, -- Spectral Wolf
    [ 23250] = true, -- Swift Brown Wolf
    [ 65646] = true, -- Swift Burgundy Wolf
    [ 23252] = true, -- Swift Gray Wolf
    [ 68056] = true, -- Swift Horde Wolf
    [ 23251] = true, -- Swift Timber Wolf
    [   580] = true, -- Timber Wolf
    [100333] = true, -- Vicious War Wolf
    [   581] = true, -- Winter Wolf
    [294569] = true, -- Beastlord's Warwolf
    [171838] = true, -- Armored Frostwolf
    [ 23509] = true, -- Frostwolf Howler
    [171839] = true, -- Ironside Warwolf
    [171842] = true, -- Swift Frostwolf
    [171851] = true, -- Garn Nighthowl
    [171836] = true, -- Garn Steelmaw
    [171837] = true, -- Warsong Direfang
    [145133] = true, -- Moonfang
}

LM.MOUNTFAMILY["Wolfhawk"] = {
    [229439] = true, -- Huntmaster's Dire Wolfhawk
    [229438] = true, -- Huntmaster's Fierce Wolfhawk
    [229386] = true, -- Huntmaster's Loyal Wolfhawk
}

LM.MOUNTFAMILY["Yak"] = {
    [127209] = true, -- Black Riding Yak
    [127220] = true, -- Blonde Riding Yak
    [127213] = true, -- Brown Riding Yak
    [122708] = true, -- Grand Expedition Yak
    [127216] = true, -- Grey Riding Yak
    [123182] = true, -- White Riding Yak
}

LM.MOUNTFAMILY["Yeti"] = {
    [191314] = true, -- Minion of Grumpus
    [279467] = true, -- Craghorn Chasm-Leaper
    [171848] = true, -- Challenger's War Yeti
}

LM.MOUNTFAMILY["Zodiac"] = {
    [290134] = true, -- Hogrus, Swine of Good Fortune
    [308078] = true, -- Squeakers, the Trickster
    [259395] = true, -- Shu-Zen, the Divine Sentinel
}
