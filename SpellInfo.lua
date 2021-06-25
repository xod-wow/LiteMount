--[[----------------------------------------------------------------------------

  LiteMount/SpellInfo.lua

  Constants for mount spell information.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local L = LM.Localize

-- The values are sort order
LM.FLAG = { }
LM.FLAG.SWIM        = 1
LM.FLAG.FLY         = 2
LM.FLAG.RUN         = 3
LM.FLAG.WALK        = 4

LM.SPELL = { }
LM.SPELL.TRAVEL_FORM = 783
LM.SPELL.GHOST_WOLF = 2645
LM.SPELL.FLIGHT_FORM = 165962
LM.SPELL.FLYING_BROOM = 42667
LM.SPELL.MAGIC_BROOM = 47977
LM.SPELL.LOANED_GRYPHON = 64749
LM.SPELL.LOANED_WIND_RIDER = 64762
LM.SPELL.RUNNING_WILD = 87840
LM.SPELL.TARECGOSAS_VISAGE = 101641
LM.SPELL.GARRISON_ABILITY = 161691
LM.SPELL.FROSTWOLF_WAR_WOLF = 164222
LM.SPELL.TELAARI_TALBUK = 165803
LM.SPELL.MOONFANG = 145133
LM.SPELL.DUSTMANE_DIREWOLF = 171844
LM.SPELL.SOARING_SKYTERROR = 191633
LM.SPELL.MOUNT_FORM = 210053
LM.SPELL.RATSTALLION_HARNESS = 220123
LM.SPELL.BLUE_QIRAJI_WAR_TANK = 239766
LM.SPELL.RED_QIRAJI_WAR_TANK = 239767
LM.SPELL.SOULSHAPE = 310143
LM.SPELL.FLICKER = 324701
LM.SPELL.SPECTRAL_BRIDLE = 315315
LM.SPELL.MAWRAT_HARNESS = 342780
LM.SPELL.DEADSOUL_HOUND_HARNESS = 343635
LM.SPELL.MAW_SEEKER_HARNESS = 343632

LM.ITEM = { }
LM.ITEM.FLYING_BROOM = 33176
LM.ITEM.MAGIC_BROOM = 37011
LM.ITEM.LOANED_GRYPHON_REINS = 44221
LM.ITEM.LOANED_WIND_RIDER_REINS = 44229
LM.ITEM.DRAGONWRATH_TARECGOSAS_REST = 71086
LM.ITEM.SHIMMERING_MOONSTONE = 101675
LM.ITEM.RATSTALLION_HARNESS = 139421
LM.ITEM.RUBY_QIRAJI_RESONATING_CRYSTAL = 151625
LM.ITEM.SAPPHIRE_QIRAJI_RESONATING_CRYSTAL = 151626
LM.ITEM.MAWRAT_HARNESS = 168035
LM.ITEM.DEADSOUL_HOUND_HARNESS = 170498
LM.ITEM.SPECTRAL_BRIDLE = 174464
LM.ITEM.MAW_SEEKER_HARNESS = 170499

LM.MOUNT_TYPES = {
    [0]   = OTHER,
    [230] = L.LM_GROUND,
    [231] = GetSpellInfo(64731), -- Sea Turtle
    [232] = C_Map.GetMapInfo(203).name, -- Vashj'ir
    [241] = C_Map.GetMapInfo(319).name, -- Anh'Qiraj
    [242] = DEAD,
    [247] = C_MountJournal.GetMountInfoByID(509), -- Red Flying Cloud
    [248] = L.FLY,
    [254] = L.SWIM,
    [284] = HEIRLOOMS,
    [398] = C_MountJournal.GetMountInfoByID(1043), -- Kua'fon
}

function LM.UnitAura(unit, aura, filter)
    local i = 1
    while true do
        local name, _, _, _, _, _, _, _, _, id = UnitAura(unit, i, filter)
        if not name then
            return
        end
        if name == aura or id == tonumber(aura) then
            return UnitAura(unit, i, filter)
        end
        i = i + 1
    end
end
