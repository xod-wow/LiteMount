--[[----------------------------------------------------------------------------

  LiteMount/_Compat.lua

  Copyright 2024 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--[[ C_Spell ]]-----------------------------------------------------------------

LM.C_Spell = CopyTable(C_Spell or {})

if not LM.C_Spell.GetSpellInfo then

    local GetSpellInfo = _G.GetSpellInfo

    function LM.C_Spell.GetSpellInfo(spellIdentifier)
        local name, _, iconID, castTime, minRange, maxRange, spellID, originalIconID = GetSpellInfo(spellIdentifier)
        if name then
            return {
                name = name,
                iconID = iconID,
                originalIconID = originalIconID,
                castTime = castTime,
                minRange = minRange,
                maxRange = maxRange,
                spellID = spellID,
            }
        end
    end
end

if not LM.C_Spell.GetSpellName then

    local GetSpellInfo = _G.GetSpellInfo

    function LM.C_Spell.GetSpellName(spellIdentifier)
        local name = GetSpellInfo(spellIdentifier)
        return name
    end
end

if not LM.C_Spell.GetSpellTexture then

    local GetSpellInfo = _G.GetSpellInfo

    function LM.C_Spell.GetSpellTexture(spellIdentifier)
        local _, _, iconID = GetSpellInfo(spellIdentifier)
        return iconID
    end
end

if not LM.C_Spell.GetSpellCooldown then

    local GetSpellCooldown = _G.GetSpellCooldown

    function LM.C_Spell.GetSpellCooldown(spellIdentifier)
        local startTime, duration, isEnabled, modRate = GetSpellCooldown(spellIdentifier)
        if startTime then
            return {
                startTime = startTime,
                duration = duration,
                isEnabled = isEnabled,
                modRate = modRate,
            }
        end
    end
end

if not LM.C_Spell.IsSpellUsable then

    local IsUsableSpell = _G.IsUsableSpell

    function LM.C_Spell.IsSpellUsable(spellIdentifier)
        return IsUsableSpell(spellIdentifier)
    end
end

if not LM.C_Spell.PickupSpell then
    LM.C_Spell.PickupSpell = _G.PickupSpell
end


--[[ C_Item ]]------------------------------------------------------------------

LM.C_Item = CopyTable(C_Item or {})

if not LM.C_Item.GetItemInfoInstant then
    LM.C_Item.GetItemInfoInstant = _G.GetItemInfoInstant
end

if not LM.C_Item.GetItemSpell then
    LM.C_Item.GetItemSpell = _G.GetItemSpell
end

if not LM.C_Item.PickupItem then
    LM.C_Item.PickupItem = _G.PickupItem
end


--[[ C_MountJournal ]]----------------------------------------------------------

LM.C_MountJournal = CopyTable(C_MountJournal or {})

if not LM.C_MountJournal.IsDragonridingUnlocked then

    local IsPlayerSpell = _G.IsPlayerSpell

    function LM.C_MountJournal.IsDragonridingUnlocked()
        return IsPlayerSpell(376777)
    end
end
