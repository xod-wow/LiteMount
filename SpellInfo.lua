--[[----------------------------------------------------------------------------

  LiteMount/SpellInfo.lua

  Constants for mount spell information.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

-- The values are sort order
LM.FLAG = { }
LM.FLAG.SWIM        = 1
LM.FLAG.FLY         = 3
LM.FLAG.RUN         = 4
LM.FLAG.WALK        = 5
LM.FLAG.FAVORITES   = 6

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
LM.SPELL.STAG_FORM = 210053
LM.SPELL.RATSTALLION_HARNESS = 220123
LM.SPELL.BLUE_QIRAJI_WAR_TANK = 239766
LM.SPELL.RED_QIRAJI_WAR_TANK = 239767
LM.SPELL.SOULSHAPE = 310143

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

function LM.UnitAura(unit, aura, filter)
    local i = 1
    while true do
        local name, _, _, _, _, _, _, _, _, id = UnitAura('player', i, filter)
        if not name then
            return
        end
        if name == aura or id == tonumber(aura) then
            return UnitAura('player', i, filter)
        end
        i = i + 1
    end
end
