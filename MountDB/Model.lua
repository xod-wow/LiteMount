--[[----------------------------------------------------------------------------

  LiteMount/MountDB/Model.lua

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

LM.MountDB = LM.MountDB or {}

local Model = {
    [NONE] = {}
}

Model._AUTO_ = {
    [302361] = true, -- Alabaster Stormtalon
    [417888] = true, -- Algarian Stormrider
    [369476] = true, -- Amalgam of Rage
    [367875] = true, -- Armored Siege Kodo
   [1242904] = true, -- Ashes of Belo'ren (2607) - reskin Coldflame Tempest?
    [294569] = true, -- Beastlord's Warwolf
    [288438] = true, -- Blackpaw
    [358072] = true, -- Bound Blizzard
   [1247662] = true, -- Barrel Bomber
    [359545] = true, -- Carcinized Zerethsteed
    [ 75614] = true, -- Celestial Steed
    [171846] = true, -- Champion's Treadblade
   [1226144] = true, -- Chrono Corsair
    [171847] = true, -- Cindermane Charger
    [463133] = true, -- Coldflame Tempest
    [347812] = true, -- Sapphire Skyblazer (+ Coldflame Tempest)
    [431992] = true, -- Compass Rose
    [271646] = true, -- Dark Iron Core Hound
    [247448] = true, -- Darkmoon Dirigible
    [ 23161] = true, -- Dreadsteed
    [307932] = true, -- Ensorcelled Everwyrm
    [307256] = true, -- Explorer's Jungle Hopper
    [  5784] = true, -- Felsteed
    [182912] = true, -- Felsteel Annihilator
    [ 84751] = true, -- Fossilized Raptor
    [289083] = true, -- G.M.O.D.
    [126508] = true, -- Geosynchronous World Spinner
    [136505] = true, -- Ghastly Charger
    [289555] = true, -- Glacial Tidestorm
    [122708] = true, -- Grand Expedition Yak
    [457485] = true, -- Grizzly Hills Packmaster
   [1227192] = true, -- Herald of Sa'bak
    [360954] = true, -- Highland Drake [Swift Spectral Drake]
    [201098] = true, -- Infinite Timereaver
    [ 72286] = true, -- Invincible
    [142910] = true, -- Ironbound Wraithcharger
    [473472] = true, -- Jani's Trashpile
    [366791] = true, -- Jigglesworth Sr.
   [1233925] = true, -- Lana'thel's Crimson Cascade
    [363613] = true, -- Lightforged Ruinstrider
    [239013] = true, -- Lightforged Warframe
    [472253] = true, -- Lunar Launcher
    [267274] = true, -- Mag'har Direwolf
    [305592] = true, -- Mechagon Mechanostrider
    [367676] = true, -- Nether-Gorged Greatwyrm
    [308814] = true, -- Ny'alotha Allseer
    [245725] = true, -- Orgrimmar Interceptor
   [1221155] = true, -- Prototype A.S.M.R.
   [1261391] = true, -- Relinquished Scarlet Charger (2785)
    [400733] = true, -- Rocket Shredder 9001
    [424009] = true, -- Runebound Firelord
   [1247422] = true, -- Scorching Valor (2634)
   [1216430] = true, -- Sha-Warped Riding Tiger
    [279611] = true, -- Skullripper
    [341821] = true, -- Snowstorm
    [259202] = true, -- Starcursed Voidstrider
   [1255246] = true, -- Starspark Netherdrake
    [454682] = true, -- Startouched Furline
    [308250] = true, -- Stormpike Battle Ram
    [245723] = true, -- Stormwind Skychaser
    [317177] = true, -- Sunwarmed Furline
    [290132] = true, -- Sylverian Dreamer
    [359843] = true, -- Tangled Dreamweaver
   [1217760] = true, -- The Big G
    [370770] = true, -- Tuskarr Shoreglider
   [1234573] = true, -- Unbound Star-Eater
    [223341] = true, -- Vicious Gilnean Warhorse
    [424534] = true, -- Vicious Moonbeast (Alliance)
    [424535] = true, -- Vicious Moonbeast (Horde)
    [449325] = true, -- Vicious Skyflayer (Alliance)
    [447405] = true, -- Vicious Skyflayer (Horde)
    [229486] = true, -- Vicious War Bear
    [229487] = true, -- Vicious War Bear
    [242896] = true, -- Vicious War Fox
    [242897] = true, -- Vicious War Fox
    [348769] = true, -- Vicious War Gorm
    [348770] = true, -- Vicious War Gorm
    [185052] = true, -- Vicious War Kodo
    [183889] = true, -- Vicious War Mechanostrider
    [171834] = true, -- Vicious War Ram
    [171835] = true, -- Vicious War Raptor
    [272481] = true, -- Vicious War Riverbeast
    [409032] = true, -- Vicious War Snail
    [409034] = true, -- Vicious War Snail
    [327407] = true, -- Vicious War Spider
    [327408] = true, -- Vicious War Spider
    [232523] = true, -- Vicious War Turtle
    [232525] = true, -- Vicious War Turtle
    [349823] = true, -- Vicious Warstalker (Alliance)
    [349824] = true, -- Vicious Warstalker (Horde)
    [223363] = true, -- Vicious Warstrider
    [348162] = true, -- Wandering Ancient
    [163024] = true, -- Warforged Nightmare
    [171845] = true, -- Warlord's Deathwheel
    [368899] = true, -- Windborn Velocidrake
    [ 98727] = true, -- Winged Guardian
    [ 54729] = true, -- Winged Steed of the Ebon Blade
    [ 75973] = true, -- X-53 Touring Rocket
    [256123] = true, -- Xiwyllag ATV
}

Model["Abyss Worm"] = {
    [232519] = true, -- Abyss Worm
    [275623] = true, -- Nazjatar Blood Serpent
   [1218314] = true, -- Ny'alothan Shadow Worm
    [243025] = true, -- Riddler's Mind-Worm
}

Model["Aerial Unit"] = {
    [290718] = true, -- Aerial Unit R-21/X
    [424082] = true, -- Mimiron's Jumpjets
    [299170] = true, -- Rustbolt Resistor
    [302795] = true, -- Swift Spectral Magnetocraft
}

-- Merged into vulture after DB2 showed they are the same
-- Model["Albatross"] = {
-- }

Model["Alpaca"] = {
    [316493] = true, -- Elusive Quickhoof
    [298367] = true, -- Mollie
    [418078] = true, -- Pattie
    [316802] = true, -- Springfur Alpaca
}

Model["Amani Bear"] = {
    [ 98204] = true, -- Amani Battle Bear
    [452645] = true, -- Amani Hunting Bear
    [ 43688] = true, -- Amani War Bear
}

Model["Amani Eagle"] = {
   [1261316] = true, --  2760 Amani Sharptalon
   [1251433] = true, --  2693 Amani Sunfeather
   [1261576] = true, --  2786 Hexed Vilefeather Eagle
   [1251630] = true, --  2694 Amani Windcaller
}

Model["Amani Pango"] = {
   [1261348] = true, --  2772 Blessed Amani Burrower
   [1261351] = true, --  2775 Witherbark Pango
}

Model["Amani War Bear"] = {
   [1261357] = true, --  2776 Amani Blessed Bear
   [1261360] = true, --  2778 Ancestral War Bear
}

-- Devourer Animite
Model["Animite"] = {
    [312776] = true, -- Chittering Animite
    [332905] = true, -- Endmire Flyer
}

Model["Antoran Hound"] = {
    [253088] = true, -- Antoran Charhound
    [253087] = true, -- Antoran Gloomhound
}

Model["Aqir Drone"] = {
    [316337] = true, -- Malevolent Drone
    [316339] = true, -- Shadowbarb Drone
    [414986] = true, -- Royal Swarmer
    [316340] = true, -- Wicked Swarmer
}

Model["Aquilon"] = {
    [353880] = true, -- Ascendant's Aquilon
    [343550] = true, -- Battle-Hardened Aquilon
   [1261671] = true, -- Bronze Aquilon
    [353875] = true, -- Elysian Aquilon
    [353877] = true, -- Foresworn Aquilon
}

-- Model file is Arcane Golem
Model["Arcane Guardian"] = {
   [1268949] = true, --  2842 Arcanovoid Construct
   [1268926] = true, --  2841 Elven Arcane Guardian
   [1268924] = true, --  2840 Silvermoon's Arcane Defender
}

Model["Armored Bear"] = {
    [ 60116] = true, -- Armored Brown Bear
    [ 60114] = true, -- Armored Brown Bear
    [ 59572] = true, -- Black Polar Bear
    [ 60118] = true, -- Black War Bear
    [ 60119] = true, -- Black War Bear
    [ 54753] = true, -- White Polar Bear
}

-- These are the same model as Pterrordax in the db2
-- Model["Armored Pterrordax"] = {
-- }

Model["Armored Ram"] = {
    [270562] = true, -- Darkforge Ram
    [270564] = true, -- Dawnforge Ram
}

Model["Armored Tauralus"] = {
    [332466] = true, -- Armored Bonehoof Tauralus
    [332467] = true, -- Armored Chosen Tauralus
    [332464] = true, -- Armored Plaguerot Tauralus
    [332462] = true, -- Armored War-Bred Tauralus
}

Model["Armored Vorquin"] = {
    [385131] = true, -- Armored Vorquin Leystrider
    [384963] = true, -- Guardian Vorquin
    [385115] = true, -- Majestic Armored Vorquin
    [385134] = true, -- Swift Armored Vorquin
}

Model["Armoredon"] = {
    [387231] = true, -- Hailstorm Armoredon
    [406637] = true, -- Inferno Armoredon
    [434462] = true, -- Infinite Armoredon
    [422486] = true, -- Verdant Armoredon
}

Model["Astral Cloud Serpent"] = {
    [127170] = true, -- Astral Cloud Serpent
    [446022] = true, -- Astral Emperor's Serpent
   [1236262] = true, -- Shaohao's Sage Serpent
}

Model["Aurelid"] = {
    [359381] = true, -- Cryptic Aurelid
    [342680] = true, -- Deepstar Aurelid
    [359380] = true, -- Depthstalker
    [359379] = true, -- Shimmering Aurelid
}

Model["Aurochs"] = {
   [1245604] = true, -- 2632 Astral Aurochs
}

Model["Bakar"] = {
    [424601] = true, -- Brown-Furred Spiky Bakar
    [424607] = true, -- Taivan
}

-- Split?
Model["Basilisk"] = {
   [1250881] = true, -- Aquamarine Basilisk
    [230844] = true, -- Brawler's Burly Basilisk
   [1264621] = true, -- Brawlin' Bruno
    [289639] = true, -- Bruce
   [1250880] = true, -- Felslate Basilisk
   [1250879] = true, -- Leystone Basilisk
   [1238729] = true, -- Slag Basilisk
    [261433] = true, -- Vicious War Basilisk
    [261434] = true, -- Vicious War Basilisk
}

Model["Battle Bear"] = {
    [ 51412] = true, -- Big Battle Bear
    [103081] = true, -- Darkmoon Dancing Bear
}

Model["Battle Gargon"] = {
    [333023] = true, -- Battle Gargon Silessa
    [312754] = true, -- Battle Gargon Vrednic
    [332949] = true, -- Desire's Battle Gargon
    [333021] = true, -- Gravestone Battle Gargon
}

Model["Battleboar"] = {
    [171629] = true, -- Armored Frostboar
    [171630] = true, -- Armored Razorback
    [171627] = true, -- Blacksteel Battleboar
    [190690] = true, -- Bristling Hellboar
    [190977] = true, -- Deathtusk Felboar
    [171632] = true, -- Frostplains Battleboar
    [171628] = true, -- Rocktusk Battleboar
}

Model["Bear"] = {
    [ 58983] = true, -- Big Blizzard Bear
    [464443] = true, -- Harmonious Salutations Bear
}

Model["Bee"] = {
    [259741] = true, -- Honeyback Harvester
    [303767] = true, -- Honeyback Hivemother
    [471538] = true, -- Timely Buzzbee
}

-- Delete?
Model["Beetle"] = {
    [381529] = true, -- Telix the Stormhorn
    [452779] = true, -- Ivory Goliathus
}

Model["Blazecycle"] = {
    [428067] = true, -- Hatefored Blazecycle
    [428013] = true, -- Incognitro, the Indecipherable Felcycle
    [428068] = true, -- Voidfire Deathcycle
}

Model["Bloodswarmer"] = {
    [275841] = true, -- Expedition Bloodswarmer
    [243795] = true, -- Leaping Veinseeker
}

Model["Bloodwing"] = {
    [139595] = true, -- Armored Bloodwing
    [288720] = true, -- Bloodgorged Hunter
}

Model["Boar"] = {
    [171634] = true, -- Domesticated Razorback
    [171635] = true, -- Giant Coldsnout
    [171636] = true, -- Great Greytusk
    [171637] = true, -- Trained Rocktusk
   [1240003] = true, -- Unarmored Deathtusk Felboar
    [171633] = true, -- Wild Goretusk
}

Model["Bonesteed"] = {
   [1251307] = true, -- Bonesteed of Bloodshed
   [1251311] = true, -- Bonesteed of Oblivion
   [1251309] = true, -- Bonesteed of Plague
   [1251305] = true, -- Bonesteed of Triumph
    [229499] = true, -- Midnight
}

Model["Bottom-Feeder"] = {
    [214791] = true, -- Brinedeep Bottom-Feeder
}

Model["Breezestrider"] = {
    [171832] = true, -- Breezestrider Stallion
    [171833] = true, -- Pale Thorngrazer
    [171829] = true, -- Shadowmane Charger
    [171830] = true, -- Swift Breezestrider
    [171831] = true, -- Trained Silverpelt
}

Model["Bruffalon"] = {
    [349935] = true, -- Noble Bruffalon
    [373967] = true, -- Stormtouched Bruffalon
}

Model["Brutosaur"] = {
    [264058] = true, -- Mighty Caravan Brutosaur
    [465235] = true, -- Trader's Gilded Brutosaur
}

Model["Bufonid"] = {
    [359413] = true, -- Goldplate Bufonid
    [363701] = true, -- Patient Bufonid
    [363703] = true, -- Prototype Leaper
    [363706] = true, -- Russet Bufonid
}

Model["Butterfly"] = {
   [1218014] = true, -- Midnight Butterfly
   [1217994] = true, -- Pearlescent Butterfly
   [1218012] = true, -- Ruby Butterfly
   [1218013] = true, -- Spring Butterfly
}

Model["Camel"] = {
    [ 88748] = true, -- Brown Riding Camel
    [307263] = true, -- Explorer's Dunetrekker [diff model]
    [ 88750] = true, -- Grey Riding Camel
    [ 88749] = true, -- Tan Riding Camel
    [102488] = true, -- White Riding Camel
}

Model["Carrion"] = {
   [1257058] = true, --  2733 Calamitous Carrion
   [1257081] = true, --  2734 Convalescent Carrion
}

Model["Charger"] = {
    [ 66906] = true, -- Argent Charger
    [ 23214] = true, -- Charger
    [ 34767] = true, -- Thalassian Charger
}

Model["Chloroceros"] = {
   [1270675] = true, --  2913 Vivid Chloroceros
}

Model["Chopper"] = {
    [179244] = true, -- Chauffeured Mechano-Hog
    [179245] = true, -- Chauffeured Mekgineer's Chopper
    [ 60424] = true, -- Mekgineer's Chopper
    [ 55531] = true, -- Mechano-Hog
}

Model["Cinderbee"] = {
    [447160] = true, -- Raging Cinderbee
    [447057] = true, -- Smoldering Cinderbee
    [447151] = true, -- Soaring Meaderbee
}

Model["Clefthoof"] = {
    [417245] = true, -- Ancestral Clefthoof
    [171620] = true, -- Bloodhoof Bull
    [171621] = true, -- Ironhoof Destroyer
    [171617] = true, -- Trained Icehoof
    [171619] = true, -- Tundra Icehoof
    [270560] = true, -- Vicious War Clefthoof [diff model]
    [171616] = true, -- Witherhide Cliffstomper
}

Model["Cloud Serpent"] = {
    [123992] = true, -- Azure Cloud Serpent
    [127156] = true, -- Crimson Cloud Serpent
   [1260356] = true, -- Echo of Aln'sharan (2749)
    [123993] = true, -- Golden Cloud Serpent
    [315014] = true, -- Ivory Cloud Serpent
    [113199] = true, -- Jade Cloud Serpent
    [366647] = true, -- Magenta Cloud Serpent
    [127154] = true, -- Onyx Cloud Serpent
   [1216422] = true, -- Sha-Warped Cloud Serpent
}

Model["Cloudrook"] = {
    [447213] = true, -- Alunira
}

Model["Cloudwing Hippogryph"] = {
    [242881] = true, -- Cloudwing Hippogryph
    [149801] = true, -- Emerald Hippogryph
    [225765] = true, -- Leyfeather Hippogryph
    [239363] = true, -- Swift Spectral Hippogryph
    [359013] = true, -- Val'sharah Hippogryph
}

Model["Comfy Flying Quilt"] = {
   [1270520] = true, --  2850 Fluffy Comfy Flying Quilt
   [1270521] = true, --  2851 Gruffy Comfy Flying Quilt
   [1270522] = true, --  2852 Comfy Bel'ameth Flying Quilt
   [1270523] = true, --  2853 Comfy Silvermoon Flying Quilt
}

Model["Core Hound"] = {
    [170347] = true, -- Core Hound
    [213209] = true, -- Steelbound Devourer
    [414327] = true, -- Sulfur Hound
}

Model["Cormaera"] = {
   [1226740] = true, -- Coldflame Cormaera
   [1226851] = true, -- Felborn Cormaera
   [1226856] = true, -- Lavaborn Cormaera
   [1226855] = true, -- Molten Cormaera
}

Model["Corpsefly"] = {
    [353885] = true, -- Battlefield Swarmer
   [1261677] = true, -- Bronze Corpsefly
    [347250] = true, -- Lord of the Corpseflies
    [353883] = true, -- Maldraxxian Corpsefly
    [353884] = true, -- Regal Corpsefly
}

Model["Courser"] = {
    [336064] = true, -- Dauntless Duskrunner
    [332252] = true, -- Shimmermist Runner
    [312765] = true, -- Sundancer
    [312767] = true, -- Swift Gloomhoof
}

Model["Crab"] = {
    [366789] = true, -- Crusty Crawler
    [294039] = true, -- Snapback Scuttler
}

Model["Crane"] = {
    [127174] = true, -- Azure Riding Crane
    [435123] = true, -- Gilded Riding Crane
    [127176] = true, -- Golden Riding Crane
    [127178] = true, -- Jungle Riding Crane
    [435124] = true, -- Luxurious Riding Crane
    [435128] = true, -- Pale Riding Crane
    [127177] = true, -- Regal Riding Crane
    [435127] = true, -- Rose Riding Crane
    [435126] = true, -- Silver Riding Crane
    [435125] = true, -- Tropical Riding Crane
}

Model["Crawg"] = {
    [250735] = true, -- Bloodgorged Crawg
    [273541] = true, -- Underrot Crawg
}

Model["Crest-Horn"] = {
   [1248309] = true, -- Kalu'ak Crest-Horn
   [1250285] = true, -- Sharktested Crest-Horn
   [1250287] = true, -- Floestrider Crest-Horn
   [1250288] = true, -- Cragstepper Crest-Horn
}

Model["Crocolisk"] = {
    [457654] = true, -- Keg Leg's Radiant Crocolisk
    [457650] = true, -- Plunderlord's Golden Crocolisk
    [457656] = true, -- Plunderlord's Midnight Crocolisk
    [457659] = true, -- Plunderlord's Weathered Crocolisk
}

Model["Crow"] = {
    [231524] = true, -- Shadowblade's Baneful Omen
    [231525] = true, -- Shadowblade's Crimson Omen
   [1255477] = true, -- Shadowblade's Felscorned Omen
    [231523] = true, -- Shadowblade's Lethal Omen
    [231434] = true, -- Shadowblade's Murderous Omen
}

-- Unused models are Amethyst and Citrine Mechsuit
Model["Crystal Mechsuit"] = {
    [458335] = true, -- Diamond Mechsuit
   [1243003] = true, -- Light-Forged Mechsuit
   [1241263] = true, -- OC91 Chariot
}

Model["Darkhound"] = {
    [344228] = true, -- Battle-Bound Warhound
    [369666] = true, -- Grimhowl
    [352742] = true, -- Undying Darkhound
    [341766] = true, -- Warstitched Darkhound
}

Model["Darkmoon Charger"] = {
   [1217341] = true, -- Lively Darkmoon Charger
   [1217340] = true, -- Midnight Darkmoon Charger
   [1217343] = true, -- Snowy Darkmoon Charger
   [1217342] = true, -- Violet Darkmoon Charger
}

Model["Deathcharger"] = {
    [ 48778] = true, -- Acherus Deathcharger
    [ 73313] = true, -- Crimson Deathcharger
}

Model["Deathroc"] = {
    [336041] = true, -- Bonesewn Fleshroc
    [327405] = true, -- Colossal Slaughterclaw
    [336042] = true, -- Hulking Deathroc
    [336045] = true, -- Predatory Plagueroc
}

Model["Deathwalker"] = {
    [334482] = true, -- Restoration Deathwalker
    [340068] = true, -- Sintouched Deathwalker
    [358319] = true, -- Soultwisted Deathwalker
    [359407] = true, -- Wastewarped Deathwalker
}

-- Worldbreaker Drake
Model["Deathwing Drake"] = {
    [420097] = true, -- Azure Worldchiller
    [294197] = true, -- Obsidian Worldbreaker
}

Model["Delver's Dirigible"] = {
    [446052] = true, -- Delver's Dirigible
    [466133] = true, -- Delver's Gob-Trotter
   [1224048] = true, -- Delver's Mana-Skimmer
}

-- This is a very unsexy name. Archangel Charger?
Model["Diablo Charger"] = {
   [1241429] = true, -- Inarius' Charger
    [107203] = true, -- Tyrael's Charger
}

Model["Direbeak"] = {
    [213164] = true, -- Brilliant Direbeak
    [213158] = true, -- Predatory Bloodgazer
    [213163] = true, -- Snowfeather Hunter
    [213165] = true, -- Viridian Sharptalon
}

Model["Direhorn"] = {
    [138424] = true, -- Amber Primordial Direhorn
    [297560] = true, -- Child of Torcali
    [138423] = true, -- Cobalt Primordial Direhorn
    [140250] = true, -- Crimson Primal Direhorn
    [290608] = true, -- Crusader's Direhorn
    [140249] = true, -- Golden Primal Direhorn
    [138426] = true, -- Jade Primordial Direhorn
    [279474] = true, -- Palehide Direhorn
    [138425] = true, -- Slate Primordial Direhorn
    [136471] = true, -- Spawn of Horridon
    [263707] = true, -- Zandalari Direhorn
}

-- Split?
Model["Direwolf"] = {
    [171838] = true, -- Armored Frostwolf wolfdraenormountarmored.m2
    [171844] = true, -- Dustmane Direwolf wolfdraenormount.m2
    [306421] = true, -- Frostwolf Snarler frostwolfhowler.m2
    [171851] = true, -- Garn Nighthowl wolfdraenormount.m2
    [171836] = true, -- Garn Steelmaw wolfdraenormountarmored.m2
    [186305] = true, -- Infernal Direwolf wolfdraenor_felmount.m2
    [295386] = true, -- Ironclad Frostclaw alliancewolfmount.m2
    [171839] = true, -- Ironside Warwolf wolfdraenormountarmored.m2
    [148396] = true, -- Kor'kron War Wolf korkronelitewolf.m2
    [171843] = true, -- Smoky Direwolf wolfdraenormount.m2
    [171842] = true, -- Swift Frostwolf wolfdraenormount.m2
    [171841] = true, -- Trained Snarler wolfdraenormount.m2
   [1218306] = true, -- Void-Scarred Pack Mother wolfdraenormount.m2
    [171837] = true, -- Warsong Direfang wolfdraenormountarmored.m2
}

Model["Discus"] = {
    [435044] = true, -- Golden Discus
    [435082] = true, -- Mogu Hazeblazer
    [130092] = true, -- Red Flying Cloud
    [435084] = true, -- Sky Surfer
}

Model["Dragon Turtle"] = {
    [127286] = true, -- Black Dragon Turtle
    [127287] = true, -- Blue Dragon Turtle
    [127288] = true, -- Brown Dragon Turtle
    [120395] = true, -- Green Dragon Turtle
    [127289] = true, -- Purple Dragon Turtle
    [127290] = true, -- Red Dragon Turtle
}

-- This could be split into two/three
Model["Dragonhawk"] = {
    [ 96503] = true, -- Amani Dragonhawk
    [142478] = true, -- Armored Blue Dragonhawk
    [142266] = true, -- Armored Red Dragonhawk
    [ 61996] = true, -- Blue Dragonhawk
   [1253929] = true, -- 2710 Cerulean Sporeglider
   [1261298] = true, -- 2756 Crimson Dragonhawk
   [1261302] = true, -- 2758 Cobalt Dragonhawk
    [194464] = true, -- Eclipse Dragonhawk
   [1261291] = true, -- 2753 Fiery Dragonhawk
    [ 62048] = true, -- Illidari Doomhawk
   [1234305] = true, -- Lightwing Dragonhawk
    [ 61997] = true, -- Red Dragonhawk
   [1253938] = true, -- 2713 Ruddy Sporeglider
    [ 66088] = true, -- Sunreaver Dragonhawk
    [351195] = true, -- Vengeance
   [1239138] = true, -- Voidlight Surger
   [1234303] = true, -- Voidwing Dragonhawk
}

Model["Drake"] = {
    [ 60025] = true, -- Albino Drake
    [ 59567] = true, -- Azure Drake
    [ 59650] = true, -- Black Drake
    [ 59568] = true, -- Blue Drake
    [ 59569] = true, -- Bronze Drake
   [1214946] = true, -- Broodling of Sinestra
    [175700] = true, -- Emerald Drake
    [110039] = true, -- Experiment 12-B
    [113120] = true, -- Feldrake
    [ 93623] = true, -- Mottled Drake
    [ 69395] = true, -- Onyxian Drake
    [ 59570] = true, -- Red Drake
    [326390] = true, -- Steamscale Incinerator
    [279466] = true, -- Twilight Avenger
    [ 59571] = true, -- Twilight Drake
}

Model["Dread Raven"] = {
    [183117] = true, -- Corrupted Dreadwing
    [155741] = true, -- Dread Raven
}

-- Yes there are Dreadwing and Dredwing, it's not my fault blame Blizzard.
-- Can't call this Dredwing because nearly all the localizations translate
-- Dreadwing and Dredwing into the same word.

Model["Dreadbat"] = {
    [332904] = true, -- Harvester's Dredwing
    [332882] = true, -- Horrid Dredwing
    [332903] = true, -- Rampart Screecher
    [312777] = true, -- Silvertip Dredwing
}

Model["Dreadwing"] = {
    [288714] = true, -- Bloodthirsty Dreadwing
    [279868] = true, -- Witherbark Direwing
    [466838] = true, -- Chaos-Forged Dreadwing
}

Model["Dreamsaber"] = {
    [424479] = true, -- Evening Sun Dreamsaber
    [424482] = true, -- Mourning Flourish Dreamsaber
    [424474] = true, -- Shadow Dusk Dreamsaber
    [424476] = true, -- Winter Night Dreamsaber
}

Model["Dreamstag"] = {
    [423871] = true, -- Blossoming Dreamstag
    [423891] = true, -- Lunar Dreamstag
    [423877] = true, -- Rekindled Dreamstag
    [427226] = true, -- Stargrazer
    [423873] = true, -- Suntouched Dreamstag
}

Model["Dreamtalon"] = {
    [427041] = true, -- Ochre Dreamtalon
    [427043] = true, -- Snowfluff Dreamtalon
    [426955] = true, -- Springtide Dreamtalon
    [427224] = true, -- Talont
    [434470] = true, -- Vicious Dreamtalon (Alliance)
    [434477] = true, -- Vicious Dreamtalon (Horde)
}

Model["Eagle"] = {
    [385260] = true, -- Bestowed Ohuna Spotter
    [385262] = true, -- Duskwing Ohuna
    [395644] = true, -- Divine Kiss of Ohn'ahra
    [385266] = true, -- Zenet Hatchling
}

Model["Earthen Mechsuit"] = {
    [448186] = true, -- Crowd Pummeler 2-30
    [448188] = true, -- Machine Defense Unit 1-11
    [442358] = true, -- Stonevault Mechsuit
}

Model["Eel"] = {
    [466145] = true, -- Vicious Electro Eel (Horde)
    [466146] = true, -- Vicious Electro Eel (Alliance)
}

Model["Elderhorn"] = {
    [213339] = true, -- Great Northern Elderhorn
   [1250886] = true, -- Highland Elderhorn
    [242874] = true, -- Highmountain Elderhorn
    [258060] = true, -- Highmountain Thunderhoof
    [196681] = true, -- Spirit of Eche'ro
    [288712] = true, -- Stonehide Elderhorn
}

Model["Elekk"] = {
    [ 34406] = true, -- Brown Elekk
    [ 73629] = true, -- Exarch's Elekk
    [ 35710] = true, -- Gray Elekk
    [ 35711] = true, -- Purple Elekk
}

Model["Elemental"] = {
   [1255478] = true, -- Farseer's Felscorned Tempest
    [231442] = true, -- Farseer's Raging Tempest
}

Model["Enchanted Runestag"] = {
    [312761] = true, -- Enchanted Dreamlight Runestag
    [332246] = true, -- Enchanted Umbral Runestag
    [332247] = true, -- Enchanted Wakener's Runestag
    [332248] = true, -- Enchanted Winterborn Runestag
}

Model["Eternal Phalynx"] = {
    [334406] = true, -- Eternal Phalynx of Courage
    [334409] = true, -- Eternal Phalynx of Humility
    [334408] = true, -- Eternal Phalynx of Loyalty
    [334403] = true, -- Eternal Phalynx of Purity
}

Model["Fathom Dweller"] = {
    [223018] = true, -- Fathom Dweller
    [253711] = true, -- Pond Nettle
    [278979] = true, -- Surf Jelly
}

Model["Fathom Ray"] = {
    [292407] = true, -- Ankoan Waveray
    [292419] = true, -- Azshari Bloatray
    [367620] = true, -- Coral-Stalker Waveray
    [300149] = true, -- Silent Glider
    [302794] = true, -- Swift Spectral Fathom Ray
    [291538] = true, -- Unshackled Waveray
}

Model["Fel Elekk"] = {
   [1244259] = true, -- Cinder-seared Elekk
   [1244261] = true, -- Legion Forged Elekk
   [1244247] = true, -- Thunder-ridged Elekk
   [1244260] = true, -- Void-Razed Elekk
}

-- Could split Glad
Model["Felbat"] = {
    [472157] = true, -- Astral Gladiator's Fel Bat
   [1229276] = true, -- Bloodhunter Fel Bat
   [1229283] = true, -- Ashplague Fel Bat
   [1229288] = true, -- Wretched Fel Bat
    [449466] = true, -- Forged Gladiator's Fel Bat
    [466144] = true, -- Prized Gladiator's Fel Bat
    [229417] = true, -- Slayer's Felbroken Shrieker
   [1255431] = true, -- Slayer's Felscorned Shrieker
    [272472] = true, -- Undercity Plaguebat
}

Model["Felblood Gronnling"] = {
    [186828] = true, -- Primal Gladiator's Felblood Gronnling
    [189044] = true, -- Warmongering Gladiator's Felblood Gronnling
    [189043] = true, -- Wild Gladiator's Felblood Gronnling
}

Model["Felcrusher"] = {
    [254259] = true, -- Avenging Felcrusher
    [254258] = true, -- Blessed Felcrusher
    [254069] = true, -- Glorious Felcrusher
    [258022] = true, -- Lightforged Felcrusher
}

Model["Felsaber"] = {
    [200175] = true, -- Felsaber
}

Model["Felstalker"] = {
   [1250884] = true, -- Illidari Blightstalker
   [1250882] = true, -- Illidari Dreadstalker
    [189998] = true, -- Illidari Felstalker
}

Model["Fey Dragon"] = {
    [142878] = true, -- Enchanted Fey Dragon
}

Model["Fiery Warhorse"] = {
    [ 36702] = true, -- Fiery Warhorse
    [ 48025] = true, -- Headless Horseman's Mount
}

Model["Fire Hawk"] = {
   [1216542] = true, -- Blazing Royal Fire Hawk
    [ 97560] = true, -- Corrupted Fire Hawk
    [ 97501] = true, -- Felfire Hawk
    [ 97493] = true, -- Pureblood Fire Hawk
}

Model["Flamesaber"] = {
    [232405] = true, -- Primal Flamesaber
}

Model["Flayedwing"] = {
    [336038] = true, -- Callow Flayedwing
--  [318052] = true, -- Deathbringer's Flayedwing (removed)
    [336039] = true, -- Gruesome Flayedwing
    [336036] = true, -- Marrowfang
}

Model["Flying Carpet"] = {
    [169952] = true, -- Creeping Carpet
    [468353] = true, -- Enchanted Spellweave Carpet
    [ 61451] = true, -- Flying Carpet
    [ 75596] = true, -- Frosty Flying Carpet
    [233364] = true, -- Leywoven Flying Carpet
    [432455] = true, -- Noble Flying Carpet
    [ 61309] = true, -- Magnificent Flying Carpet
}

Model["Flying Machine"] = {
    [ 44153] = true, -- Flying Machine
    [ 44151] = true, -- Turbo-Charged Flying Machine
}

Model["Forsaken Charger"] = {
   [1234859] = true, -- Banshee's Chilling Charger
   [1235820] = true, -- Banshee's Sickening Charger
   [1235817] = true, -- Forsaken's Grotesque Charger
   [1235819] = true, -- Wailing Banshee's Charger
}

Model["Fox"] = {
    [430225] = true, -- Gilnean Prowler
    [171850] = true, -- Llothien Prowler
}

Model["Gargon"] = {
    [332932] = true, -- Crypt Gargon
    [312753] = true, -- Hopecrusher Gargon
    [332923] = true, -- Inquisition Gargon
    [332927] = true, -- Sinfall Gargon
}

Model["Gearglider"] = {
    [353263] = true, -- Cartel Master's Gearglider
    [346554] = true, -- Tazavesh Gearglider
    [353265] = true, -- Vandal's Gearglider
    [353264] = true, -- Xy Trustee's Gearglider
}

Model["Gladiator's Cloud Serpent"] = {
    [148619] = true, -- Grievous Gladiator's Cloud Serpent
    [139407] = true, -- Malevolent Gladiator's Cloud Serpent
    [148620] = true, -- Prideful Gladiator's Cloud Serpent
    [148618] = true, -- Tyrannical Gladiator's Cloud Serpent
}

Model["Gladiator's Drake"] = {
    [377071] = true, -- Crimson Gladiator's Drake
    [424539] = true, -- Draconic Gladiator's Drake
}

Model["Gladiator's Proto-Drake"] = {
    [262027] = true, -- Corrupted Gladiator's Proto-Drake
    [262022] = true, -- Dread Gladiator's Proto-Drake
    [262024] = true, -- Notorious Gladiator's Proto-Drake
    [262023] = true, -- Sinister Gladiator's Proto-Drake
}

Model["Gladiator's Slitherdrake"] = {
    [408977] = true, -- Obsidian Gladiator's Slitherdrake
    [425416] = true, -- Verdant Gladiator's Slitherdrake
}

Model["Gladiator's Twilight Drake"] = {
    [124550] = true, -- Cataclysmic Gladiator's Twilight Drake
    [101821] = true, -- Ruthless Gladiator's Twilight Drake
    [101282] = true, -- Vicious Gladiator's Twilight Drake
}

Model["Glimmerfur Vulpin"] = {
    [427435] = true, -- Crimson Glimmerfur
   [1263369] = true, -- Skypaw Glimmerfur
   [1264988] = true, -- Snowpaw Glimmerfur Prowler
    [290133] = true, -- Vulpine Familiar
    [334366] = true, -- Wild Glimmerfur Prowler
}

Model["Glowmite"] = {
    [447176] = true, -- Cyan Glowmite
    [447173] = true, -- 2161 Elder Glowmite
}

Model["Goat"] = {
    [130138] = true, -- Black Riding Goat
    [130086] = true, -- Brown Riding Goat
    [435133] = true, -- Little Red Riding Goat
    [435131] = true, -- Snowy Riding Goat
   [1219705] = true, -- Spotted Black Riding Goat
    [130137] = true, -- White Riding Goat
}

Model["Goblin Aerial Unit"] = {
    [466024] = true, -- Bilgewater Bombardier
    [466027] = true, -- Darkfuse Spy-Eye
    [466025] = true, -- Margin Manipulator
    [466028] = true, -- Mean Green Flying Machine
    [466026] = true, -- Salvaged Goblin Gazillionaire's Flying Machine
}

Model["Goblin Hyena"] = {
    [466001] = true, -- Blackwater Bonecrusher
    [465999] = true, -- Crimson Armored Growler
    [466000] = true, -- Darkfuse Chompactor
    [466002] = true, -- Violet Armored Growler
}

Model["Goblin Rocket"] = {
   [1264643] = true, -- Ballistic Bronco
    [126507] = true, -- Depleted-Kyparium Rocket
}

Model["Goblin Shredder"] = {
    [466023] = true, -- Asset Advocator
    [466019] = true, -- Blackwater Shredder Deluxe Mk 2
    [466018] = true, -- Darkfuse Demolisher
    [468068] = true, -- Junkmaestro's Magnetomech
    [466020] = true, -- Personalized Goblin S.C.R.A.Per
    [466022] = true, -- Venture Coordinator
    [466021] = true, -- Violet Goblin Shredder
}

Model["Goblin Trike"] = {
    [ 87090] = true, -- Goblin Trike
    [ 87091] = true, -- Goblin Turbo-Trike
    [223354] = true, -- Vicious War Trike
}

Model["Goblin Waveshredder"] = {
    [473188] = true, -- Bronze Goblin Waveshredder
    [446352] = true, -- Kickin' Kezan Wave Shredder
    [447413] = true, -- Pearlescent Goblin Wave Shredder
    [473137] = true, -- Soweezi's Vintage Waveshredder
}

-- Devourer Gorger
Model["Gorger"] = {
    [333027] = true, -- Loyal Gorger
   [1241070] = true, -- Translocated Gorger
    [344659] = true, -- Voracious Gorger
}

Model["Gorm"] = {
    [312763] = true, -- Darkwarren Hardshell
    [334365] = true, -- Pale Acidmaw
    [334364] = true, -- Spinemaw Gladechewer
    [340503] = true, -- Umbral Scythehorn
    [352441] = true, -- Wild Hunt Legsplitter
}

Model["Grand Gryphon"] = {
    [136163] = true, -- Grand Gryphon
    [414323] = true, -- Ravenous Black Gryphon
   [1218229] = true, -- Void-Scarred Gryphon
}

Model["Grand Wyvern"] = {
    [135418] = true, -- Grand Armored Wyvern
    [136164] = true, -- Grand Wyvern
   [1218307] = true, -- Void-Scarred Windrider
}

Model["Grandmaster's Board"] = {
   [1235756] = true, -- Grandmaster's Prophetic Board
   [1235763] = true, -- Grandmaster's Deep Board
   [1235803] = true, -- Grandmaster's Royal Board
      [1235806] = true, -- Grandmaster's Smokey Board
}

Model["Grandmaster's Companion"] = {
    [229385] = true, -- Ban-Lu, Grandmaster's Companion
   [1255467] = true, -- Felscorned Grandmaster's Companion
}

Model["Gravewing"] = {
   [1261681] = true, -- Bronze Gravewing
    [215545] = true, -- Mastercraft Gravewing
    [353866] = true, -- Obsidian Gravewing
    [353873] = true, -- Pale Gravewing
    [353872] = true, -- Sinfall Gravewing
}

Model["Great Dragon Turtle"] = {
    [127295] = true, -- Great Black Dragon Turtle
    [127302] = true, -- Great Blue Dragon Turtle
    [127308] = true, -- Great Brown Dragon Turtle
    [127293] = true, -- Great Green Dragon Turtle
    [127310] = true, -- Great Purple Dragon Turtle
    [120822] = true, -- Great Red Dragon Turtle
}

Model["Great Elekk"] = {
    [ 48027] = true, -- Black War Elekk
    [ 63639] = true, -- Exodar Elekk
    [ 35713] = true, -- Great Blue Elekk
    [ 35712] = true, -- Great Green Elekk
    [ 35714] = true, -- Great Purple Elekk
    [ 65637] = true, -- Great Red Elekk
}

Model["Great Kodo"] = {
    [ 22718] = true, -- Black War Kodo
    [ 49379] = true, -- Great Brewfest Kodo
    [ 23249] = true, -- Great Brown Kodo
    [ 65641] = true, -- Great Golden Kodo
    [ 23248] = true, -- Great Gray Kodo
    [ 23247] = true, -- Great White Kodo
    [ 63641] = true, -- Thunder Bluff Kodo
}

Model["Great Raven"] = {
   [1226983] = true, -- Archmage's Great Raven
   [1226760] = true, -- Prophet's Great Raven
}

-- Harronir Cat
Model["Grimlynx"] = {
   [1243593] = true, --  2614 Fierce Grimlynx
   [1243597] = true, --  2615 Rootstalker Grimlynx
}

Model["Gronnling"] = {
    [189364] = true, -- Coalfist Gronnling
    [171436] = true, -- Gorestrider Gronnling
    [171849] = true, -- Sunhide Gronnling
}

Model["Grove Crawler"]  = {
   [1260354] = true, -- 2747 Untained Grove Crawler
}

Model["Grove Warden"] = {
    [193007] = true, -- Grove Defiler
    [189999] = true, -- Grove Warden
}

Model["Grrloc"] = {
    [315132] = true, -- Gargantuan Grrloc
    [463025] = true, -- Gigantic Grrloc
    [419567] = true, -- Ginormous Grrloc
   [1234971] = true, -- Grandiose Grrloc
}

Model["Gryphon"] = {
    [ 32239] = true, -- Ebon Gryphon
    [ 32235] = true, -- Golden Gryphon
    [441324] = true, -- Remembered Golden Gryphon
    [ 32240] = true, -- Snowy Gryphon
    [107516] = true, -- Spectral Gryphon
}

Model["Hand"] = {
    [352309] = true, -- Hand of Bahmethra
    [339957] = true, -- Hand of Hrestimorak
    [354354] = true, -- Hand of Nilganihmaht
    [459193] = true, -- Hand of Reshkigaal
    [354355] = true, -- Hand of Salaranga
}

Model["Harbor Gryphon"] = {
    [466811] = true, -- Chaos-Forged Gryphon
    [275859] = true, -- Dusky Waycrest Gryphon
    [135416] = true, -- Grand Armored Gryphon
    [413827] = true, -- Harbor Gryphon
    [275868] = true, -- Proudmoore Sea Scout
    [275866] = true, -- Stormsong Coastwatcher
}

-- This is a cheap reskin of Skyrazor is lore-wise unrelated.
Model["Harrower"] = {
   [1261332] = true, --  2764 Duskbrute Harrower
   [1266700] = true, --  2827 Sanguine Harrower
   [1266980] = true, --  2831 Tenebrous Harrower
}

Model["Harvesthog"] = {
   [1226511] = true, -- Spring Harvesthog
   [1226531] = true, -- Summer Harvesthog
   [1226532] = true, -- Winter Harvesthog
   [1226533] = true, -- Autumn Harvesthog
}

Model["Hawkstrider"] = {
    [ 35022] = true, -- Black Hawkstrider
    [ 35020] = true, -- Blue Hawkstrider
    [370620] = true, -- Elusive Emerald Hawkstrider
    [230401] = true, -- Ivory Hawkstrider
    [ 35018] = true, -- Purple Hawkstrider
    [ 34795] = true, -- Red Hawkstrider
}

Model["Headless Horseman's Charger"] = {
   [1245202] = true, -- The Headless Horseman's Burning Charger
   [1245197] = true, -- The Headless Horseman's Chilling Charger
   [1245205] = true, -- The Headless Horseman's Ghostly Charger
   [1245198] = true, -- The Headless Horseman's Ghoulish Charger
}

Model["Hearthsteed"] = {
    [278966] = true, -- Fiery Hearthsteed
    [142073] = true, -- Hearthsteed
}

Model["Heavenly Cloud Serpent"] = {
    [127169] = true, -- Heavenly Azure Cloud Serpent
    [127161] = true, -- Heavenly Crimson Cloud Serpent
    [127164] = true, -- Heavenly Golden Cloud Serpent
    [127158] = true, -- Heavenly Onyx Cloud Serpent
    [127165] = true, -- Yu'lei, Daughter of Jade
}

Model["Helicid"] = {
    [359376] = true, -- Bronze Helicid
    [359378] = true, -- Scarlet Helicid
    [346719] = true, -- Serenade
    [359377] = true, -- Unsuccessful Prototype Fleetpod
}

Model["High Priest's Seeker"] = {
   [1255475] = true, -- High Priest's Felscorned Seeker
    [229377] = true, -- High Priest's Lightsworn Seeker
}

Model["Highlord's Charger"] = {
   [1255471] = true, -- Felscorned Highlord's Charger
    [231435] = true, -- Highlord's Golden Charger
    [231589] = true, -- Highlord's Valorous Charger
    [231587] = true, -- Highlord's Vengeful Charger
    [231588] = true, -- Highlord's Vigilant Charger
}

Model["Highmountain Eagle"] = {
   [1235513] = true, -- Snowy Highmountain Eagle
   [1251255] = true, -- Treetop Highmountain Eagle
}

-- Split
Model["Hippogryph"] = {
    [ 63844] = true, -- Argent Hippogryph
    [ 74856] = true, -- Blazing Hippogryph
    [ 43927] = true, -- Cenarion War Hippogryph
    [466812] = true, -- Chaos-Forged Hippogryph
    [102514] = true, -- Corrupted Hippogryph
    [ 97359] = true, -- Flameward Hippogryph
    [452643] = true, -- Frayfeather Hippogryph
    [215159] = true, -- Long-Forgotten Hippogryph
    [ 66087] = true, -- Silver Covenant Hippogryph
    [274610] = true, -- Teldrassil Hippogryph
}

Model["Hivemind"] = {
    [261395] = true, -- The Hivemind
}

Model["Hornstrider"] = {
    [432610] = true, -- Clayscale Hornstrider
    [352926] = true, -- Skyskin Hornstrider
}

Model["Horse"] = {
    [   470] = true, -- Black Stallion
    [   458] = true, -- Brown Horse
    [  6648] = true, -- Chestnut Mare
    [ 16082] = true, -- Palomino
    [   472] = true, -- Pinto
    [   468] = true, -- White Stallion
    [ 16083] = true, -- White Stallion
}

Model["Hyena"] = {
    [237287] = true, -- Alabaster Hyena
    [306423] = true, -- Caravan Hyena
    [237286] = true, -- Dune Scavenger
}

Model["Infernal"] = {
    [171840] = true, -- Coldflame Infernal
    [213134] = true, -- Felblaze Infernal
    [213349] = true, -- Flarecore Infernal
    [213350] = true, -- Frostshard Infernal
    [171827] = true, -- Hellfire Infernal
}

Model["Jawcrawler"] = {
    [447957] = true, -- Ferocious Jawcrawler
}

Model["K'aresh Slateback"] = {
   [1233559] = true, -- Blue Barry
   [1233561] = true, -- Curious Slateback
   [1250578] = true, -- Phase-Lost Slateback
}

Model["K'arroc"] = {
   [1233516] = true, -- K'arroc Swiftwing
   [1221132] = true, -- Resplendent K'arroc
   [1233511] = true, -- Umbral K'arroc
   [1233518] = true, -- Lavender K'arroc
}

Model["Kaldorei Nightsaber"] = {
    [288505] = true, -- Kaldorei Nightsaber
   [1237631] = true, -- Moonlit Nightsaber
    [288506] = true, -- Sandy Nightsaber
    [288503] = true, -- Umber Nightsaber
}

Model["Kaldorei War Wolf"] = {
    [449142] = true, -- Kaldorei War Wolf
    [449140] = true, -- Sentinel War Wolf
}

Model["Kodo"] = {
    [ 49378] = true, -- Brewfest Riding Kodo
    [ 18990] = true, -- Brown Kodo
    [288499] = true, -- Frightened Kodo
    [ 18989] = true, -- Gray Kodo
    [ 18991] = true, -- Green Kodo
    [ 18363] = true, -- Riding Kodo
    [ 18992] = true, -- Teal Kodo
    [ 64657] = true, -- White Kodo
}

Model["Krolusk"] = {
    [288736] = true, -- Azureshell Krolusk
    [279454] = true, -- Conqueror's Scythemaw
    [239049] = true, -- Obsidian Krolusk
   [1240632] = true, -- Pearlescent Krolusk
    [288735] = true, -- Rubyshell Krolusk
}

Model["Larion"] = {
    [342334] = true, -- Gilded Prowler
    [341776] = true, -- Highwind Darkmane
    [334433] = true, -- Silverwind Larion
}

Model["Lion"] = {
    [ 90621] = true, -- Golden King
    [229512] = true, -- Vicious War Lion
}

Model["Longhorned Talbuk"] = {
   [1251396] = true, -- Longhorned Sable Talbuk
   [1251398] = true, -- Longhorned Bleakhoof Talbuk
   [1251399] = true, -- Longhorned Argussian Talbuk
   [1251400] = true, -- Longhorned Beryl Talbuk
}

-- Proto-wolf?
Model["Lupine"] = {
   [1263387] = true, -- Crimson Lupine
    [367673] = true, -- Heartbond Lupine
}

Model["Lynx"] = {
    [448979] = true, -- Dauntless Imperial Lynx
   [1226421] = true, -- Radiant Imperial Lynx
    [448978] = true, -- Vermillion Imperial Lynx
   [1228865] = true, -- Void-Scarred Lynx
}

Model["Magic Broom"] = {
    [419345] = true, -- Eve's Ghastly Rider
}

Model["Magmammoth"] = {
    [373859] = true, -- Loyal Magmammoth
    [427546] = true, -- Mammyth
    [374275] = true, -- Raging Magmammoth
    [374278] = true, -- Renewed Magmammoth
    [371176] = true, -- Subterranean Magmammoth
}

Model["Mammoth"] = {
    [374172] = true, -- Bestowed Trawling Mammoth mammoth2mount.m2
    [ 59785] = true, -- Black War Mammoth mammothmount_1seat.m2
    [ 59788] = true, -- Black War Mammoth mammothmount_1seat.m2
    [ 61465] = true, -- Grand Black War Mammoth mammothmount_3seat.m2
    [ 61467] = true, -- Grand Black War Mammoth mammothmount_3seat.m2
    [ 60140] = true, -- Grand Caravan Mammoth mammothmount_3seat.m2
    [ 60136] = true, -- Grand Caravan Mammoth mammothmount_3seat.m2
    [ 61469] = true, -- Grand Ice Mammoth mammothmount_3seat.m2
    [ 61470] = true, -- Grand Ice Mammoth mammothmount_3seat.m2
    [ 59797] = true, -- Ice Mammoth mammothmount_1seat.m2
    [ 59799] = true, -- Ice Mammoth mammothmount_1seat.m2
    [374194] = true, -- Mossy Mammoth mammoth2mount.m2
    [374196] = true, -- Plainswalker Bearer mammoth2mount.m2
    [ 61447] = true, -- Traveler's Tundra Mammoth mammothmount_3seat.m2
    [ 61425] = true, -- Traveler's Tundra Mammoth mammothmount_3seat.m2
    [ 59791] = true, -- Wooly Mammoth mammothmount_1seat.m2
    [ 59793] = true, -- Wooly Mammoth mammothmount_1seat.m2
}

Model["Mana Ray"] = {
   [1251283] = true, -- Albino Mana Ray
   [1251281] = true, -- Bloodtooth Mana Ray
    [344574] = true, -- Bulbous Necroray
    [235764] = true, -- Darkspore Mana Ray
   [1251279] = true, -- Fel-Scarred Mana Ray
    [253108] = true, -- Felglow Mana Ray
    [427777] = true, -- Heartseeker Mana Ray
    [344576] = true, -- Infested Necroray
    [253107] = true, -- Lambent Mana Ray
   [1251284] = true, -- Luminous Mana Ray
    [344575] = true, -- Pestilent Necroray
    [253109] = true, -- Scintillating Mana Ray
    [253106] = true, -- Vibrant Mana Ray
}

Model["Mana Wyrm"] = {
   [1261336] = true, --  2769 Preyseeker's Hubris
   [1261338] = true, --  2771 Preyseeker's Nightmare
   [1261337] = true, --  2770 Preyseeker's Wrath
}

Model["Manasaber"] = {
    [230987] = true, -- Arcanist's Manasaber
    [180545] = true, -- Mystic Runesaber
    [258845] = true, -- Nightborne Manasaber
}

Model["Marsh Hopper"] = {
    [288587] = true, -- Blue Marsh Hopper
    [369480] = true, -- Cerulean Marsh Hopper
    [259740] = true, -- Green Marsh Hopper
    [288589] = true, -- Yellow Marsh Hopper
}

-- Devourer Mauler
Model["Mauler"] = {
    [356501] = true, -- Rampaging Mauler
   [1241076] = true, -- Sthaarbs's Last Lunch
    [347536] = true, -- Tamed Mauler
}

Model["Mawrat"] = {
    [363136] = true, -- Colossal Ebonclaw Mawrat
    [368105] = true, -- Colossal Plaguespew Mawrat
    [363297] = true, -- Colossal Soulshredder Mawrat
    [363178] = true, -- Colossal Umbrahide Mawrat
    [368128] = true, -- Colossal Wraithbound Mawrat
}

Model["Mawsworn Charger"] = {
    [354353] = true, -- Fallen Charger
    [339956] = true, -- Mawsworn Charger
    [354351] = true, -- Sanctum Gloomcharger
    [354352] = true, -- Soulbound Gloomcharger
}

Model["Meadowstomper"] = {
    [171626] = true, -- Armored Irontusk
    [294568] = true, -- Beastlord's Irontusk
    [171625] = true, -- Dusty Rockhide
    [171622] = true, -- Mottled Meadowstomper
    [171624] = true, -- Shadowhide Pearltusk
    [171623] = true, -- Trained Meadowstomper
}

Model["Meat Wagon"] = {
   [1262886] = true, -- Geargrinder Mk. 11
    [281554] = true, -- Meat Wagon
}

Model["Mechacycle"] = {
    [296788] = true, -- Mechacycle Model W
    [297157] = true, -- Junkheap Drifter
}

Model["Mechanocat"] = {
    [294143] = true, -- X-995 Mechanocat
}

Model["Mechanostrider"] = {
    [ 33630] = true, -- Blue Mechanostrider
    [ 10969] = true, -- Blue Mechanostrider
    [ 15780] = true, -- Green Mechanostrider
    [ 17453] = true, -- Green Mechanostrider
    [ 17459] = true, -- Icy Blue Mechanostrider Mod A
    [ 10873] = true, -- Red Mechanostrider
    [ 17454] = true, -- Unpainted Mechanostrider
    [ 15779] = true, -- White Mechanostrider Mod B
}

Model["Mechasaur"] = {
    [466011] = true, -- Flarendo the Furious
}

Model["Mechaspider"] = {
    [299158] = true, -- Mechagon Peacekeeper
    [299159] = true, -- Scrapforged Mechaspider
    [291492] = true, -- Rusty Mechanocrawler
}

Model["Meeksi"] = {
    [473745] = true, -- Meeksi Brewthief
    [473743] = true, -- Meeksi Rollingpaw
    [473739] = true, -- Meeksi Rufflefur
    [473741] = true, -- Meeksi Softpaw
    [473744] = true, -- Meeksi Teatuft
}

Model["Mimiron's Head"] = {
    [261437] = true, -- Mecha-Mogul Mk2
    [ 63796] = true, -- Mimiron's Head
}

Model["Mole"] = {
    [449269] = true, -- Crimson Mudnose
    [449258] = true, -- Ol' Mole Rufus
    [449264] = true, -- Wick
}

Model["Moonbeast"] = {
    [400976] = true, -- Gleaming Moonbeast
}

Model["Moth"] = {
    [342666] = true, -- Amber Ardenmoth
    [332256] = true, -- Duskflutter Ardenmoth
    [318051] = true, -- Silky Shimmermoth
    [342667] = true, -- Vibrant Flutterwing
}

-- There's a fair bit of variation here, armors and mane and hoofguards,
-- but they are all the same Kul Tiran Horse model with pointy ears and
-- fluffy feet. X here have a different model from the rest.

Model["Mountain Horse"] = {
    [259213] = true, -- Admiralty Stallion
    [295387] = true, -- Bloodflank Charger X1
    [279457] = true, -- Broken Highland Mustang
    [341639] = true, -- Court Sinrunner
    [260172] = true, -- Dapple Gray
    [260175] = true, -- Goldenmane
    [279456] = true, -- Highland Mustang
    [282682] = true, -- Kul Tiran Charger X2
    [279608] = true, -- Lil' Donkey
    [103195] = true, -- Mountain Horse X3
    [255695] = true, -- Seabraid Stallion X4
    [339588] = true, -- Sinrunner Blanchy
    [260173] = true, -- Smoky Charger
    [103196] = true, -- Swift Mountain Horse X3
    [260174] = true, -- Terrified Pack Mule
   [1218305] = true, -- Void-Forged Stallion
}

Model["Mouse"] = {
    [356488] = true, -- Sarge's Tale
}

Model["Mushan Beast"] = {
    [148428] = true, -- Ashhide Mushan Beast
    [142641] = true, -- Brawler's Burly Mushan Beast
    [435161] = true, -- Palehide Mushan Beast
    [435160] = true, -- Riverwalker Mushan
    [130965] = true, -- Son of Galleon
}

Model["Nether Drake"] = {
    [ 41514] = true, -- Azure Netherwing Drake
    [ 41515] = true, -- Cobalt Netherwing Drake
    [412088] = true, -- Grotto Netherwing Drake
      [3363] = true, -- Lost Nether Drake (16)
    [ 28828] = true, -- Nether Drake
    [ 41513] = true, -- Onyx Netherwing Drake
    [ 41516] = true, -- Purple Netherwing Drake
    [ 41517] = true, -- Veridian Netherwing Drake
    [ 41518] = true, -- Violet Netherwing Drake
}

Model["Nether Ray"] = {
   [1261155] = true, -- 2751 Augmented Stormray
    [ 39803] = true, -- Blue Riding Nether Ray
    [ 39798] = true, -- Green Riding Nether Ray
    [ 39801] = true, -- Purple Riding Nether Ray
    [ 39800] = true, -- Red Riding Nether Ray
    [ 39802] = true, -- Silver Riding Nether Ray
}

Model["Nightsaber"] = {
    [ 16056] = true, -- Ancient Frostsaber
    [ 16055] = true, -- Black Nightsaber
    [ 10789] = true, -- Spotted Frostsaber
    [ 66847] = true, -- Striped Dawnsaber
    [  8394] = true, -- Striped Frostsaber
    [ 10793] = true, -- Striped Nightsaber
    [ 96499] = true, -- Swift Zulian Panther
    [ 10790] = true, -- Tiger
    [ 17229] = true, -- Winterspring Frostsaber
}

Model["Ottuk"] = {
    [376875] = true, -- Brown Scouting Ottuk
    [427222] = true, -- Delugen
    [359409] = true, -- Iskaara Trader's Ottuk
    [376879] = true, -- Ivory Trader's Ottuk
    [376873] = true, -- Otto
    [376880] = true, -- Yellow Scouting Ottuk
}

Model["Owl"] = {
    [424484] = true, -- Anu'relos, Flame's Guidance
   [1276650] = true, --  2917 Anu'shalla, Shadow's Guidance
    [443660] = true, -- Charming Courier
}

Model["Pandaren Kite"] = {
    [133023] = true, -- Jade Pandaren Kite
    [435109] = true, -- Feathered Windsurfer
    [130985] = true, -- Pandaren Kite
    [118737] = true, -- Pandaren Kite
}

Model["Pandaren Phoenix"] = {
    [132117] = true, -- Ashen Pandaren Phoenix
    [446017] = true, -- August Phoenix
    [129552] = true, -- Crimson Pandaren Phoenix
    [132118] = true, -- Emerald Pandaren Phoenix
    [132119] = true, -- Violet Pandaren Phoenix
}

Model["Panthara"] = {
    [243512] = true, -- Luminous Starseeker
}

Model["Parrot"] = {
    [471696] = true, -- Hooktalon
    [437162] = true, -- Polly Roger
    [366790] = true, -- Quawks
    [254812] = true, -- Royal Seafeather
    [254813] = true, -- Sharkbait
    [254811] = true, -- Squawks
    [290328] = true, -- Wonderwing 2.0
}

Model["Peafowl"] = {
    [432562] = true, -- Brilliant Sunburst Peafowl
    [432558] = true, -- Majestic Azure Peafowl
}

Model["Petalwing"] = {
   [1253927] = true, --  2708 Vibrant Petalwing
}

Model["Phalynx"] = {
    [334391] = true, -- Phalynx of Courage
    [334386] = true, -- Phalynx of Humility
    [334382] = true, -- Phalynx of Loyalty
    [334398] = true, -- Phalynx of Purity
}

Model["Phoenix"] = {
    [ 40192] = true, -- Ashes of Al'ar
    [312751] = true, -- Clutch of Ha-Li
    [139448] = true, -- Clutch of Ji-Kun
    [ 88990] = true, -- Dark Phoenix
--  [347813] = true, -- Fireplume Phoenix (NYI)
    [459784] = true, -- Golden Ashes of Al'ar
}

Model["Pirate Ship"] = {
    [472752] = true, -- The Breaker's Song
    [272770] = true, -- The Dreadwake
}

Model["Prestigious Courser"] = {
    [222240] = true, -- Prestigious Azure Courser
    [281044] = true, -- Prestigious Bloodforged Courser
    [222202] = true, -- Prestigious Bronze Courser
    [222237] = true, -- Prestigious Forest Courser
    [222238] = true, -- Prestigious Ivory Courser
    [222241] = true, -- Prestigious Midnight Courser
    [222236] = true, -- Prestigious Royal Courser
}

Model["Prismatic Disc"] = {
   [1255463] = true, -- Archmage's Felscorned Disc
    [229376] = true, -- Archmage's Prismatic Disc
}

Model["Proto-Drake"] = {
    [229388] = true, -- Battlelord's Bloodthirsty War Wyrm
    [ 59976] = true, -- Black Proto-Drake
    [ 59996] = true, -- Blue Proto-Drake
   [1255482] = true, -- Felscorned War Wyrm
    [386452] = true, -- Frostbrood Proto-Wyrm
   [1262840] = true, -- Galactic Gladiator's Goredrake (2801)
    [ 61294] = true, -- Green Proto-Drake
    [ 63956] = true, -- Ironbound Proto-Drake
    [ 60021] = true, -- Plagued Proto-Drake
    [ 59961] = true, -- Red Proto-Drake
    [368896] = true, -- Renewed Proto-Drake
    [ 63963] = true, -- Rusted Proto-Drake
    [148392] = true, -- Spawn of Galakras
    [ 60002] = true, -- Time-Lost Proto-Drake
    [ 60024] = true, -- Violet Proto-Drake
}

-- I think you could make a case this should be called Cervid to align
-- with calling the protosnails Helecid
Model["Protostag"] = {
    [359276] = true, -- Anointed Protostag (sic)
    [359278] = true, -- Deathrunner
    [342671] = true, -- Pale Regak Cervid
    [359277] = true, -- Sundered Zerethsteed
}

Model["Pseudoshell"] = {
   [1267004] = true, --  2836 Accented Pseudoshell
   [1266993] = true, --  2833 Arboreal Pseudoshell
   [1266997] = true, --  2834 Cabbage Pseudoshell
   [1267002] = true, --  2835 Lavender Pseudoshell
}

Model["Pterrordax Skyscreamer"] = {
    [441794] = true, -- Amber Pterrordax
    [136400] = true, -- Armored Skyscreamer
    [435145] = true, -- Bloody Skyscreamer
    [435147] = true, -- Jade Pterrordax
    [435146] = true, -- Night Pterrorwing
}

Model["Pterrordax"] = {
    [368126] = true, -- Armored Golden Pterrordax
    [275838] = true, -- Captured Swampstalker
    [275837] = true, -- Cobalt Pterrordax
    [289101] = true, -- Dazar'alor Windreaver
    [267270] = true, -- Kua'fon
    [413825] = true, -- Scarlet Pterrordax
    [244712] = true, -- Spectral Pterrorwing
    [302797] = true, -- Swift Spectral Pterrordax
    [275840] = true, -- Voldunai Dunescraper
}

Model["Qiraji Battle Tank"] = {
    [ 25863] = true, -- Black Qiraji Battle Tank
    [ 26655] = true, -- Black Qiraji Battle Tank
    [ 26656] = true, -- Black Qiraji Battle Tank
    [ 25953] = true, -- Blue Qiraji Battle Tank
    [ 26056] = true, -- Green Qiraji Battle Tank
    [ 26054] = true, -- Red Qiraji Battle Tank
    [ 92155] = true, -- Ultramarine Qiraji Battle Tank
    [ 26055] = true, -- Yellow Qiraji Battle Tank
}

Model["Qiraji War Tank"] = {
    [239770] = true, -- Black Qiraji War Tank
    [239766] = true, -- Blue Qiraji War Tank
    [239767] = true, -- Red Qiraji War Tank
}

Model["Ram"] = {
    [  6896] = true, -- Black Ram
    [ 17461] = true, -- Black Ram
    [ 43899] = true, -- Brewfest Ram
    [  6899] = true, -- Brown Ram
    [ 17460] = true, -- Frost Ram
    [  6777] = true, -- Gray Ram
    [  6898] = true, -- White Ram
}

Model["Ramolith"] = {
    [453785] = true, -- Earthen Ordinant's Ramolith
    [449418] = true, -- Shale Ramolith
    [449415] = true, -- Slatestone Ramolith
}

Model["Raptor"] = {
    [138642] = true, -- Black Primal Raptor
    [138640] = true, -- Bone-White Primal Raptor
    [  8395] = true, -- Emerald Raptor
    [138643] = true, -- Green Primal Raptor
    [ 10795] = true, -- Ivory Raptor
    [ 17450] = true, -- Ivory Raptor
    [ 16084] = true, -- Mottled Red Raptor
    [138641] = true, -- Red Primal Raptor
    [ 97581] = true, -- Savage Raptor
    [ 10796] = true, -- Turquoise Raptor
    [ 64659] = true, -- Venomhide Ravasaur
    [ 10799] = true, -- Violet Raptor
}

Model["Raptora"] = {
    [342668] = true, -- Desertwing Hunter
    [359372] = true, -- Mawdapted Raptora
    [359373] = true, -- Raptora Swooper
}

Model["Ratstallion"] = {
    [215558] = true, -- Ratstallion
}

Model["Ravager"] = {
    [163025] = true, -- Grinning Reaver
}

Model["Ravasaur"] = {
    [255696] = true, -- Gilded Ravasaur
    [266058] = true, -- Tomb Stalker
}

Model["Raven"] = {
    [101542] = true, -- Flametalon of Alysrazor
    [280729] = true, -- Frenzied Feltalon
    [ 41252] = true, -- Raven Lord
    [179478] = true, -- Voidtalon of the Dark Star
}

Model["Ray"] = {
    [228919] = true, -- Darkwater Skate
    [278803] = true, -- Great Sea Ray
}

Model["Razorwing"] = {
   [1266579] = true, -- Cloudborn Razorwing
    [354361] = true, -- Dusklight Razorwing
    [354359] = true, -- Fierce Razorwing
    [354360] = true, -- Garnet Razorwing
    [347251] = true, -- Soaring Razorwing
}

Model["Rhino"] = {
    [ 74918] = true, -- Wooly White Rhino
}

Model["Riverbeast"] = {
    [171825] = true, -- Mosshide Riverwallow
    [171826] = true, -- Mudback Riverbeast
    [171824] = true, -- Sapphire Riverbeast
    [171638] = true, -- Trained Riverwallow
}

Model["Rocket"] = {
    [466017] = true, -- Innovation Investigator
    [466013] = true, -- Ochre Delivery Rocket
    [466014] = true, -- Steamwheedle Supplier
    [466016] = true, -- The Topskimmer Special
    [466012] = true, -- Thunderdrum Misfire
    [ 71342] = true, -- X-45 Heartbreaker (Big Love Rocket)
    [ 46197] = true, -- X-51 Nether-Rocket
    [ 46199] = true, -- X-51 Nether-Rocket X-TREME
}

Model["Rooster"] = {
    [ 66124] = true, -- Magic Rooster
    [ 66123] = true, -- Magic Rooster
    [ 66122] = true, -- Magic Rooster
    [ 65917] = true, -- Magic Rooster
}

Model["Ruinstrider"] = {
    [253004] = true, -- Amethyst Ruinstrider
    [253005] = true, -- Beryl Ruinstrider
    [254260] = true, -- Bleakhoof Ruinstrider
    [253007] = true, -- Cerulean Ruinstrider
   [1251397] = true, -- Garnet Ruinstrider
    [253058] = true, -- Maddened Chaosrunner
   [1245370] = true, -- Ornery Breezestrider
    [253006] = true, -- Russet Ruinstrider
    [242305] = true, -- Sable Ruinstrider
    [253008] = true, -- Umber Ruinstrider
}

Model["Runestag"] = {
    [312759] = true, -- Dreamlight Runestag
    [332243] = true, -- Umbral Runestag
    [332244] = true, -- Wakener's Runestag
    [332245] = true, -- Winterborn Runestag
}

Model["Rylak"] = {
    [288495] = true, -- Ashenvale Chimaera
    [153489] = true, -- Iron Skyreaver
   [1214920] = true, -- Nightfall Skyreaver
    [191633] = true, -- Soaring Skyterror
    [194046] = true, -- Swift Spectral Rylak
}

Model["Sabertooth"] = {
    [394737] = true, -- Vicious Sabertooth
    [394738] = true, -- Vicious Sabertooth
}

Model["Salamanther"] = {
    [374090] = true, -- Ancient Salamanther
    [374097] = true, -- Coralscale Salamanther
    [427724] = true, -- Salatrancer
    [374098] = true, -- Stormhide Salamanther
}

Model["Savage Battle Turtle"] = {
    [473861] = true, -- Savage Alabaster Battle Turtle
    [433281] = true, -- Savage Blue Battle Turtle
   [1266248] = true, -- Savage Crimson Battle Turtle
    [453255] = true, -- Savage Ebony Battle Turtle
    [367826] = true, -- Savage Green Battle Turtle
}

Model["Savagemane Ravasaur"] = {
   [1237703] = true, -- Ivory Savagemane
}

Model["Scarab"] = {
    [428060] = true, -- Golden Regal Scarab
    [428005] = true, -- Jeweled Copper Scarab
    [428065] = true, -- Jeweled Jade Scarab (1946)
    [428062] = true, -- Jeweled Sapphire Scarab
}

-- Could split the Iron Juggernauts
Model["Scorpid"] = {
    [123886] = true, -- Amber Scorpion
    [435149] = true, -- Cobalt Juggernaut
    [435150] = true, -- Fel Iron Juggernaut
    [411565] = true, -- Felcrystal Scorpion
    [ 93644] = true, -- Kor'kron Annihilator
    [148417] = true, -- Kor'kron Juggernaut
    [414328] = true, -- Perfected Juggernaut
    [230988] = true, -- Vicious War Scorpion
}

Model["Seahorse"] = {
    [288711] = true, -- Saltwater Seahorse
    [ 98718] = true, -- Subdued Seahorse
    [ 75207] = true, -- Vashj'ir Seahorse
}

Model["Serpent"] = {
    [316637] = true, -- Awakened Mindborer
    [305182] = true, -- Black Serpent of N'Zoth
    [315987] = true, -- Mail Muncher
    [346141] = true, -- Slime Serpent
    [316343] = true, -- Wriggling Parasite
}

Model["Shackled Shadow"] = {
    [448941] = true, -- Beledar's Spawn
    [448939] = true, -- Shackled Shadow
    [448934] = true, -- Shadow of Doubt
}

Model["Shadehound"] = {
    [344577] = true, -- Bound Shadehound
    [344578] = true, -- Corridor Creeper
    [312762] = true, -- Mawsworn Soulhunter
}

Model["Shado-Pan Riding Tiger"] = {
    [129934] = true, -- Blue Shado-Pan Riding Tiger
    [129932] = true, -- Green Shado-Pan Riding Tiger
    [435153] = true, -- Purple Shado-Pan Riding Tiger
    [129935] = true, -- Red Shado-Pan Riding Tiger
}

Model["Shalewing"] = {
    [408653] = true, -- Boulder Hauler
    [408648] = true, -- Calescent Shalewing
    [408651] = true, -- Catalogued Shalewing
    [408647] = true, -- Cobalt Shalewing
    [408627] = true, -- Igneous Shalewing
    [427549] = true, -- Imagiwing
    [408655] = true, -- Morsel Sniffer
    [408654] = true, -- Sandy Shalewing
    [408649] = true, -- Shadowflame Shalewing
}

Model["Shardhide"] = {
    [354356] = true, -- Amber Shardhide
    [347810] = true, -- Crimson Shardhide
    [354357] = true, -- Beryl Shardhide
    [354358] = true, -- Darkmaul
}

Model["Shredclaw"] = {
   [1261585] = true, -- Frenzied Shredclaw (2792)
   [1261584] = true, -- Prowling Shredclaw (2791)
}

Model["Shredder"] = {
    [223814] = true, -- Mechanized Lumber Extractor
    [134359] = true, -- Sky Golem
}

Model["Shreddertank"] = {
   [1217235] = true, -- Crimson Shreddertank
   [1221694] = true, -- Enterprising Shreddertank
}

-- This is annoying because there is a mount "Silvermoon Hawkstrider" which
-- is not one of these but a Swift Hawkstrider, but this is clearly the
-- right name from the flavor text.
Model["Silvermoon Hawkstrider"]= {
   [1261323] = true, --  2762 Cerulean Hawkstrider
   [1261322] = true, --  2761 Crimson Silvermoon Hawkstrider
   [1265784] = true, --  2817 Lucent Hawkstrider
}

-- Merged into Mountain Horse
-- Model["Sinrunner"] = { }

Model["Skeletal Horse"] = {
    [ 64977] = true, -- Black Skeletal Horse
    [ 17463] = true, -- Blue Skeletal Horse
    [ 17464] = true, -- Brown Skeletal Horse
    [ 17462] = true, -- Red Skeletal Horse
    [288722] = true, -- Risen Mare
    [  8980] = true, -- Skeletal Horse
}

Model["Skeletal Warhorse"] = {
    [ 64656] = true, -- Blue Skeletal Warhorse
    [ 63643] = true, -- Forsaken Warhorse
    [ 17465] = true, -- Green Skeletal Warhorse
    [ 66846] = true, -- Ochre Skeletal Warhorse
    [ 23246] = true, -- Purple Skeletal Warhorse
    [ 22722] = true, -- Red Skeletal Warhorse
    [ 17481] = true, -- Rivendare's Deathcharger
    [413922] = true, -- Valiance
    [ 65645] = true, -- White Skeletal Warhorse
}

Model["Skitterfly"] = {
    [349943] = true, -- Amber Skitterfly
    [374034] = true, -- Azure Skitterfly
    [374071] = true, -- Bestowed Sandskimmer
    [374032] = true, -- Tamed Skitterfly
    [374048] = true, -- Verdant Skitterfly
}

Model["Skullboar"] = {
    [332482] = true, -- Bonecleaver's Skullboar
    [332478] = true, -- Blisterback Bloodtusk
    [332480] = true, -- Gorespine
    [332484] = true, -- Lurid Bloodtusk
}

Model["Sky Fox"] = {
    [431357] = true, -- Fur-endship Fox
    [431359] = true, -- Soaring Sky Fox
    [431360] = true, -- Twilight Sky Prowler
}

Model["Skyrazor"] = {
    [451491] = true, -- Ascendant Skyrazor
    [451487] = true, -- 2220 Retrained Skyrazor
    [451489] = true, -- Siesbarg
    [451486] = true, -- Sureki Skyrazor
}

Model["Slitherdrake"] = {
    [418286] = true, -- Auspicious Arborwyrm
   [1218316] = true, -- Corruption of the Aspects
    [110051] = true, -- Heart of the Aspects
    [368893] = true, -- Winding Slitherdrake
}

Model["Slug"] = {
    [374138] = true, -- Seething Slug
}

Model["Slyvern"] = {
    [359622] = true, -- Liberated Slyvern
    [385738] = true, -- Temperamental Skyclaw
}

Model["Snail"] = {
    [408313] = true, -- Big Slick in the City
   [1218069] = true, -- Emerald Snail
}

Model["Snailemental"] = {
    [374157] = true, -- Gooey Snailemental
    [350219] = true, -- Magmashell
    [374162] = true, -- Scrappy Worldsnail
    [374155] = true, -- Shellack
}

Model["Snapdragon"] = {
    [300147] = true, -- Deepcoral Snapdragon
    [474086] = true, -- Prismatic Snapdragon
    [294038] = true, -- Royal Snapdragon
    [300146] = true, -- Snapdragon Kelpstalker
}

Model["Snaplizard"] = {
   [1261629] = true, --  2793 Vicious Snaplizard
   [1261648] = true, --  2794 Vicious Snaplizard
}

Model["Snapvine"] = {
   [1269279] = true, --  2847 Blooded Snapvine
   [1269277] = true, --  2846 Ferocious Snapvine
   [1269280] = true, --  2848 Savage Snapvine
   [1269273] = true, --  2845 Vicious Snapvine
}

Model["Soul Eater"] = {
    [365559] = true, -- Cosmic Gladiator's Soul Eater
    [370346] = true, -- Eternal Gladiator's Soul Eater
    [332400] = true, -- Sinful Gladiator's Soul Eater
    [353036] = true, -- Unchained Gladiator's Soul Eater
    [440444] = true, -- Zovaal's Soul Eater
}

Model["Spelltome"] = {
    [359318] = true, -- Soaring Spelltome
}

Model["Spider"] = {
    [213115] = true, -- Bloodfang Widow
}

Model["Stone Drake"] = {
    [ 88718] = true, -- Phosphorescent Stone Drake
    [ 93326] = true, -- Sandstone Drake
    [ 88746] = true, -- Vitreous Stone Drake
    [ 88331] = true, -- Volcanic Stone Drake
}

Model["Stone Hound"] = {
   [1214974] = true, -- Copper-Maned Quilen
    [435115] = true, -- Guardian Quilen
    [124659] = true, -- Imperial Quilen
    [435118] = true, -- Marble Quilen
    [279469] = true, -- Qinsho's Eternal Hound
    [316722] = true, -- Ren's Stalwart Hound
    [316723] = true, -- Xinlao
}

Model["Stone Panther"] = {
    [121837] = true, -- Jade Panther
    [120043] = true, -- Jeweled Onyx Panther
    [121820] = true, -- Obsidian Nightwing
    [121838] = true, -- Ruby Panther
    [121836] = true, -- Sapphire Panther
    [121839] = true, -- Sunstone Panther
   [1218317] = true, -- Void-Crystal Panther
}

Model["Storm Dragon"] = {
    [227989] = true, -- Cruel Gladiator's Storm Dragon
    [243201] = true, -- Demonic Gladiator's Storm Dragon
    [227995] = true, -- Dominant Gladiator's Storm Dragon
    [227988] = true, -- Fearless Gladiator's Storm Dragon
    [414326] = true, -- Felstorm Dragon
    [227991] = true, -- Ferocious Gladiator's Storm Dragon
    [227994] = true, -- Fierce Gladiator's Storm Dragon
    [288721] = true, -- Island Thunderscale
    [242882] = true, -- Valarjar Stormwing
    [227986] = true, -- Vindictive Gladiator's Storm Dragon
}

Model["Stormcrow"] = {
    [171828] = true, -- Solar Spirehawk
    [471562] = true, -- Thrayir, Eyes of the Siren
    [253639] = true, -- Violet Spellwing
}

Model["Sunwalker Kodo"] = {
    [ 69820] = true, -- Sunwalker Kodo
    [ 69826] = true, -- Great Sunwalker Kodo
}

Model["Swarmite"] = {
    [447185] = true, -- Aquamarine Swarmite
    [447189] = true, -- Nesting Swarmite
    [447190] = true, -- Shadowed Swarmite
    [447195] = true, -- Swarmite Skyhunter
}

-- "Love Broom"
Model["Sweeper"] = {
    [472479] = true, -- Love Witch's Sweeper
    [472487] = true, -- Silvermoon Sweeper
    [472489] = true, -- Sky Witch's Sweeper
    [472488] = true, -- Twilight Witch's Sweeper
}

Model["Swift Gryphon"] = {
    [ 61229] = true, -- Armored Snowy Gryphon
    [ 32242] = true, -- Swift Blue Gryphon
    [ 32290] = true, -- Swift Green Gryphon
    [ 32292] = true, -- Swift Purple Gryphon
    [ 32289] = true, -- Swift Red Gryphon
}

Model["Swift Hawkstrider"] = {
    [ 63642] = true, -- Silvermoon Hawkstrider
    [ 66091] = true, -- Sunreaver Hawkstrider
    [ 35025] = true, -- Swift Green Hawkstrider
    [ 33660] = true, -- Swift Pink Hawkstrider
    [ 35027] = true, -- Swift Purple Hawkstrider
    [ 65639] = true, -- Swift Red Hawkstrider
    [ 35028] = true, -- Swift Warstrider
    [ 46628] = true, -- Swift White Hawkstrider
}

Model["Swift Horse"] = {
    [ 22717] = true, -- Black War Steed
    [ 63232] = true, -- Stormwind Steed
    [ 92231] = true, -- Spectral Steed
    [ 68057] = true, -- Swift Alliance Steed
    [ 23229] = true, -- Swift Brown Steed
    [ 65640] = true, -- Swift Gray Steed
    [ 23227] = true, -- Swift Palomino
    [ 23228] = true, -- Swift White Steed
}

Model["Swift Mechanostrider"] = {
    [ 22719] = true, -- Black Battlestrider
    [ 63638] = true, -- Gnomeregan Mechanostrider
    [ 23225] = true, -- Swift Green Mechanostrider
    [ 23223] = true, -- Swift White Mechanostrider
    [ 23222] = true, -- Swift Yellow Mechanostrider
    [ 65642] = true, -- Turbostrider
}

Model["Swift Nether Drake"] = {
    [ 58615] = true, -- Brutal Nether Drake
    [ 44317] = true, -- Merciless Nether Drake
    [ 44744] = true, -- Merciless Nether Drake
    [372995] = true, -- Swift Spectral Drake
    [ 37015] = true, -- Swift Nether Drake
    [ 49193] = true, -- Vengeful Nether Drake
}

Model["Swift Nightsaber"] = {
    [ 22723] = true, -- Black War Tiger
    [ 63637] = true, -- Darnassian Nightsaber
    [ 42776] = true, -- Spectral Tiger
    [ 23221] = true, -- Swift Frostsaber
    [ 23219] = true, -- Swift Mistsaber
    [ 65638] = true, -- Swift Moonsaber
    [ 42777] = true, -- Swift Spectral Tiger
    [ 23338] = true, -- Swift Stormsaber
    [ 24252] = true, -- Swift Zulian Tiger
}

Model["Swift Ram"] = {
    [ 22720] = true, -- Black War Ram
    [ 63636] = true, -- Ironforge Ram
    [ 23510] = true, -- Stormpike Battle Charger
    [ 43900] = true, -- Swift Brewfest Ram
    [ 23238] = true, -- Swift Brown Ram
    [ 23239] = true, -- Swift Gray Ram
    [ 65643] = true, -- Swift Violet Ram
    [ 23240] = true, -- Swift White Ram
}

Model["Swift Raptor"] = {
    [ 96491] = true, -- Armored Razzashi Raptor
    [ 22721] = true, -- Black War Raptor
    [ 63635] = true, -- Darkspear Raptor
    [279569] = true, -- Swift Albino Raptor
    [ 23241] = true, -- Swift Blue Raptor
    [ 23242] = true, -- Swift Olive Raptor
    [ 23243] = true, -- Swift Orange Raptor
    [ 65644] = true, -- Swift Purple Raptor
    [ 24242] = true, -- Swift Razzashi Raptor
}

Model["Swift Wind Rider"] = {
    [ 61230] = true, -- Armored Blue Wind Rider
    [466845] = true, -- Chaos-Forged Wind Rider
    [ 32295] = true, -- Swift Green Wind Rider
    [ 32297] = true, -- Swift Purple Wind Rider
    [ 32246] = true, -- Swift Red Wind Rider
    [ 32296] = true, -- Swift Yellow Wind Rider
}

Model["Swift Wolf"] = {
    [ 22724] = true, -- Black War Wolf
    [ 23509] = true, -- Frostwolf Howler
    [ 63640] = true, -- Orgrimmar Wolf
    [ 92232] = true, -- Spectral Wolf
    [ 23250] = true, -- Swift Brown Wolf
    [ 65646] = true, -- Swift Burgundy Wolf
    [ 23252] = true, -- Swift Gray Wolf
    [ 68056] = true, -- Swift Horde Wolf
    [ 23251] = true, -- Swift Timber Wolf
    [414316] = true, -- White War Wolf
}

Model["Talbuk"] = {
    [ 39315] = true, -- Cobalt Riding Talbuk
    [ 39316] = true, -- Dark Riding Talbuk
    [ 39317] = true, -- Silver Riding Talbuk
    [ 39318] = true, -- Tan Riding Talbuk
    [ 39319] = true, -- White Riding Talbuk
}

Model["Tallstrider"] = {
    [102346] = true, -- Swift Forest Strider
    [102350] = true, -- Swift Lovebird
    [101573] = true, -- Swift Shorestrider
    [102349] = true, -- Swift Springstrider
}

Model["Tarachnid"] = {
    [359401] = true, -- Genesis Crawler
    [359403] = true, -- Ineffable Skitterer
    [359402] = true, -- Tarachnid Creeper
}

-- Life-Binder Drake? Tarecgosa's Visage an outlier
Model["Tarecgosa Drake"] = {
    [107842] = true, -- Blazing Drake
    [107845] = true, -- Life-Binder's Handmaiden
    [407555] = true, -- Tarecgosa's Visage (Mount)
    [107844] = true, -- Twilight Harbinger
}

Model["Tauralus"] = {
    [332457] = true, -- Bonehoof Tauralus
    [332460] = true, -- Chosen Tauralus
    [332456] = true, -- Plaguerot Tauralus
    [332455] = true, -- War-Bred Tauralus
}

Model["Thundering Cloud Serpent"] = {
    [315427] = true, -- Rajani Warserpent
    [129918] = true, -- Thundering August Cloud Serpent
    [139442] = true, -- Thundering Cobalt Cloud Serpent
    [124408] = true, -- Thundering Jade Cloud Serpent
    [148476] = true, -- Thundering Onyx Cloud Serpent
    [132036] = true, -- Thundering Ruby Cloud Serpent
}

Model["Thunderspine"] = {
    [351408] = true, -- Bestowed Thunderspine Packleader
    [374204] = true, -- Explorer's Stonehide Packbeast
    [374247] = true, -- Lizi, Thunderspine Tramper
}

Model["Tidestallion"] = {
    [300153] = true, -- Crimson Tidestallion
    [300150] = true, -- Fabious
    [300151] = true, -- Inkscale Deepseeker
    [300154] = true, -- Silver Tidestallion
}

Model["Toad"] = {
    [339632] = true, -- Arboreal Gulper
    [347255] = true, -- Vicious War Croaker (Horde)
    [347256] = true, -- Vicious War Croaker (Alliance)
}

Model["Turkey"] = {
   [1251680] = true, -- Highlands Gobbler
   [1251685] = true, -- Quirky Turkey
   [1251689] = true, -- Murky Turkey
   [1251690] = true, -- Prized Turkey
}

Model["Turtle"] = {
    [ 30174] = true, -- Riding Turtle
    [ 64731] = true, -- Sea Turtle
}

Model["Undercrawler"] = {
    [448685] = true, -- Heritage Undercrawler
    [448689] = true, -- Royal Court Undercrawler
    [448680] = true, -- Widow's Undercrawler
}

Model["Underlight Behemoth"] = {
    [448845] = true, -- Blue Old God Fish Mount
    [448850] = true, -- Kah, Legend of the Deep
    [448851] = true, -- Underlight Corrupted Behemoth
    [448849] = true, -- Underlight Shorestalker
}

Model["Unknown"] = {
}

Model["Ur'zul"] = {
   [1250482] = true, -- Ghastly Ur'zul
    [243651] = true, -- Shackled Ur'zul
   [1214940] = true, -- Ur'zul Fleshripper
}

Model["Vespoid"] = {
    [359364] = true, -- Bronzewing Vespoid
    [359366] = true, -- Buzz
    [359367] = true, -- Forged Spiteflyer
    [342678] = true, -- Vespoid Flutterer
}

-- Voidwing Drake?
Model["Vexiona Drake"] = {
   [1242272] = true, -- Royal Voidwing
    [302143] = true, -- Uncorrupted Voidwing
}

Model["Vicious Bonesteed"] = {
    [281890] = true, -- Vicious Black Bonesteed
    [146622] = true, -- Vicious Skeletal Warhorse
    [281889] = true, -- Vicious White Bonesteed
}

Model["Vicious War Steed"] = {
    [193695] = true, -- Prestigious War Steed
    [100332] = true, -- Vicious War Steed
}

Model["Vicious War Wolf"] = {
    [204166] = true, -- Prestigious War Wolf
    [100333] = true, -- Vicious War Wolf
}

Model["Vile Fiend"] = {
    [253662] = true, -- Acid Belcher
    [253660] = true, -- Biletooth Gnasher
    [253661] = true, -- Crimson Slavermaw
    [243652] = true, -- Vile Fiend
}

Model["Vilebrood Vanquisher"] = {
    [229387] = true, -- Deathlord's Vilebrood Vanquisher
   [1255264] = true, -- Felscorned Vilebrood Vanquisher
}

Model["Void Creeper"] = {
   [1233547] = true, -- Acidic Void Creeper
   [1233546] = true, -- Ruby Void Creeper
   [1233542] = true, -- The Bone Freezer
   [1234820] = true, -- Vicious Void Creeper
   [1234821] = true, -- Vicious Void Creeper
}

Model["Void Flyer"] = {
   [1246781] = true, -- Azure Void Flyer
   [1245517] = true, -- Scarlet Void Flyer
   [1223191] = true, -- Terror of the Night
   [1223187] = true, -- Terror of the Wastes
}

Model["Vombata"] = {
    [359232] = true, -- Adorned Vombata
    [359230] = true, -- Curious Crystalsniffer
    [359231] = true, -- Darkened Vombata
    [359229] = true, -- Heartlight Vombata
}

Model["Vorquin"] = {
    [394219] = true, -- Bronze Vorquin
    [394216] = true, -- Crimson Vorquin
    [394220] = true, -- Obsidian Vorquin
    [394218] = true, -- Sapphire Vorquin
}

Model["Vulture"] = {
    [414324] = true, -- Gold-Toed Albatross
    [266925] = true, -- Siltwing Albatross
    [316275] = true, -- Waste Marauder
    [316276] = true, -- Wastewander Skyterror
}

Model["War Elekk"] = {
    [ 73630] = true, -- Great Exarch's Elekk
    [223578] = true, -- Vicious War Elekk
}

Model["War Ottuk"] = {
    [376898] = true, -- Bestowed Ottuk Vanguard
    [376910] = true, -- Brown War Ottuk
    [376912] = true, -- Otherworldly Ottuk Carrier
    [376913] = true, -- Yellow War Ottuk
}

Model["War Talbuk"] = {
    [ 34896] = true, -- Cobalt War Talbuk
    [ 34790] = true, -- Dark War Talbuk
    [ 34898] = true, -- Silver War Talbuk
    [ 34899] = true, -- Tan War Talbuk
    [ 34897] = true, -- White War Talbuk
}

Model["War Turtle"] = {
    [227956] = true, -- Arcadian War Turtle
   [1227076] = true, -- Tyrannotort
}

-- Deleted
-- Model["Warframe"] = {
-- }

Model["Warhorse"] = {
    [ 67466] = true, -- Argent Warhorse
    [ 68188] = true, -- Crusader's Black Warhorse
    [ 68187] = true, -- Crusader's White Warhorse
    [ 34769] = true, -- Thalassian Warhorse
    [ 13819] = true, -- Warhorse
}

Model["Warp Stalker"] = {
   [1256677] = true, -- Cerulean Phase-Hunter
    [346136] = true, -- Viridian Phase-Hunter
}

-- Check
Model["Warsaber"] = {
    [366962] = true, -- Ash'adar, Harbinger of Dawn nightsaber2mountsunmoon.m2
    [449132] = true, -- Blackrock Warsaber nightsaberhordemount.m2
    [449126] = true, -- Kor'kron Warsaber nightsaberhordemount.m2
    [288740] = true, -- Priestess' Moonsaber saber3mount.m2
    [281887] = true, -- Vicious Black Warsaber warnightsabermount.m2
    [146615] = true, -- Vicious Kaldorei Warsaber warnightsabermount.m2
    [281888] = true, -- Vicious White Warsaber warnightsabermount.m2
}

Model["Water Strider"] = {
    [118089] = true, -- Azure Water Strider
    [127271] = true, -- Crimson Water Strider
}

Model["Wavewhisker"] = {
    [397406] = true, -- Wondrous Wavewhisker
}

Model["Whimsydrake"] = {
    [425338] = true, -- Flourishing Whimsydrake
}

-- No saddle
Model["Wild Courser"] = {
    [342335] = true, -- Ascended Skymane horse2bastion.m2
   [1253130] = true, -- Brimstone Courser
   [1253129] = true, -- Chestnut Courser
   [1251300] = true, -- Gloomdark Nightmare
   [1251297] = true, -- Golden Sunrunner
    [247402] = true, -- Lucid Nightmare horse2.m2
    [354362] = true, -- Maelie, the Wanderer horse2ardenweald.m2
    [280730] = true, -- Pureheart Courser horse2.m2
   [1217965] = true, -- Shimmermist Free Runner horse2ardenweald.m2
   [1251298] = true, -- Turquoise Courser
   [1251295] = true, -- Twilight Courser
    [242875] = true, -- Wild Dreamrunner horse2.m2
}

-- No saddle
Model["Wild Manasaber"] = {
   [1251265] = true, -- Arcberry Manasaber
}

Model["Wilderling"] = {
    [353856] = true, -- Ardenweald Wilderling
    [353857] = true, -- Autumnal Wilderling
   [1261668] = true, -- Bronze Wilderling
    [353859] = true, -- Summer Wilderling
    [439138] = true, -- Voyaging Wilderling
    [353858] = true, -- Winder Wilderling
}

Model["Wildhammer Gryphon"] = {
   [1245358] = true, -- High Shaman's Aerie Gryphon
   [1245361] = true, -- Emberwing Sky Guide
   [1245359] = true, -- Cinder-Plumed HIghland Gryphon
   [1245357] = true, -- Adorned Northeron Gryphon
}

Model["Wildseed Cradle"] = {
    [334352] = true, -- Wildseed Cradle
}

Model["Wind Drake"] = {
    [ 88335] = true, -- Drake of the East Wind
    [315847] = true, -- Drake of the Four Winds
    [ 88742] = true, -- Drake of the North Wind
    [ 88744] = true, -- Drake of the South Wind
    [ 88741] = true, -- Drake of the West Wind
}

Model["Wind Rider"] = {
    [302362] = true, -- Alabaster Thunderwing
    [ 32244] = true, -- Blue Wind Rider
    [ 32245] = true, -- Green Wind Rider
    [441325] = true, -- Remembered Wind Rider
    [107517] = true, -- Spectral Wind Rider
    [ 32243] = true, -- Tawny Wind Rider
}

Model["Windsteed"] = {
    [435103] = true, -- Dashing Windsteed
    [435108] = true, -- Daystorm Windsteed
    [435107] = true, -- Forest Windsteed
    [134573] = true, -- Swift Windsteed
}

Model["Wolf"] = {
    [ 16081] = true, -- Arctic Wolf
    [   578] = true, -- Black Wolf
    [ 64658] = true, -- Black Wolf
    [  6654] = true, -- Brown Wolf
    [  6653] = true, -- Dire Wolf
    [   459] = true, -- Gray Wolf
    [   579] = true, -- Red Wolf
    [ 16080] = true, -- Red Wolf
    [   580] = true, -- Timber Wolf
    [   581] = true, -- Winter Wolf
}

Model["Wolfhawk"] = {
   [1255456] = true, -- Felscorned Wolfhawk
    [229439] = true, -- Huntmaster's Dire Wolfhawk
    [229438] = true, -- Huntmaster's Fierce Wolfhawk
    [229386] = true, -- Huntmaster's Loyal Wolfhawk
}

Model["Wrathsteed"] = {
   [1255480] = true, -- Felscorned Netherlord's Dreadsteed
    [238454] = true, -- Netherlord's Accursed Wrathsteed
    [238452] = true, -- Netherlord's Brimstone Wrathsteed
    [232412] = true, -- Netherlord's Chaotic Wrathsteed
}

Model["Wylderdrake"] = {
    [368901] = true, -- Cliffside Wylderdrake
}

Model["Wyrm"] = {
    [ 72808] = true, -- Bloodbathed Frostbrood Vanquisher armoredridingundeaddrake.m2
    [ 64927] = true, -- Deadly Gladiator's Frost Wyrm ridingundeaddrake.m2
    [ 65439] = true, -- Furious Gladiator's Frost Wyrm ridingundeaddrake.m2
    [ 72807] = true, -- Icebound Frostbrood Vanquisher armoredridingundeaddrake.m2
    [ 67336] = true, -- Relentless Gladiator's Frost Wyrm ridingundeaddrake.m2
    [414334] = true, -- Scourgebound Vanquisher armoredridingundeaddrake.m2
    [231428] = true, -- Smoldering Ember Wyrm nightbane2mount.m2
    [ 71810] = true, -- Wrathful Gladiator's Frost Wyrm ridingundeaddrake.m2
}

Model["Yak"] = {
    [127209] = true, -- Black Riding Yak
    [127220] = true, -- Blonde Riding Yak
    [127213] = true, -- Brown Riding Yak
    [127216] = true, -- Grey Riding Yak
    [123182] = true, -- White Riding Yak
}

Model["Yeti"] = {
    [171848] = true, -- Challenger's War Yeti
    [279467] = true, -- Craghorn Chasm-Leaper
    [191314] = true, -- Minion of Grumpus
}

Model["Zereth Overseer"] = {
    [368158] = true, -- Zereth Overseer
   [1243589] = true, -- Void-Forged Overseer
}

Model["Zhevra"] = {
    [ 48954] = true, -- Swift Zhevra
    [ 49322] = true, -- Swift Zhevra
    [ 66090] = true, -- Quel'dorei Steed
}

-- What on earth to do with this
Model["Zodiac"] = {
    doNotCombine = true,
    [290134] = true, -- Hogrus, Swine of Good Fortune
    [369451] = true, -- Jade, Bright Foreseer
    [308087] = true, -- Lucky Yun
    [259395] = true, -- Shu-Zen, the Divine Sentinel
    [308078] = true, -- Squeakers, the Trickster
    [468205] = true, -- Timbered Sky Snake
    [359317] = true, -- Wen Lo, the River's Edge
}

local ModelBySpellID = {}
local ModelList = {}

do
    for spellID in pairs(Model._AUTO_) do
        local mountID = C_MountJournal.GetMountFromSpell(spellID)
        if mountID then
            local name = C_MountJournal.GetMountInfoByID(mountID)
            Model[name] = Model[name] or {}
            Model[name][spellID] = true
        end
    end
    Model._AUTO_ = nil

    for modelName, mounts in pairs(Model) do
        table.insert(ModelList, modelName)
        for spellID in pairs(mounts) do
            if type(spellID) == 'number' then
                ModelBySpellID[spellID] = modelName
            end
        end
    end
    table.sort(ModelList, function (a, b) return L[a] < L[b] end)
end

function LM.MountDB.GetModelByID(mountID)
    local _, spellID = C_MountJournal.GetMountInfoByID(mountID)
    return ModelBySpellID[spellID]
end

function LM.MountDB.GetModelBySpellID(spellID)
    return ModelBySpellID[spellID]
end

function LM.MountDB.GetModelList()
    return ModelList
end

function LM.MountDB.IsValidModel(modelName)
    return Model[modelName] ~= nil
end

--@debug@

-- This is an approximation to try to find wrong stuff. It will misflag things
-- from anything but the curent client (classic, ptr, etc).

function LM.MountDB.AuditModelData()
    local mountSpells = {}
    for _, mountID in ipairs(C_MountJournal.GetMountIDs()) do
        local name, spellID = C_MountJournal.GetMountInfoByID(mountID)
        local typeID = select(5, C_MountJournal.GetMountInfoExtraByID(mountID))
        local typeInfo = LM.MOUNT_TYPE_INFO[typeID]
        if (not typeInfo or not typeInfo.skip) and not ModelBySpellID[spellID] then
            print('MISSING MOUNT', spellID, name)
        end
       mountSpells[spellID] = name
    end

    for spellID, family in pairs(ModelBySpellID) do
       if not mountSpells[spellID] then
          local name = C_Spell.GetSpellName(spellID)
          if not name then
             -- print('NO SPELL', spellID, family)
          else
             print('EXTRA SPELL', spellID, C_Spell.GetSpellName(spellID))
          end
       end
    end
end

--@end-debug@
