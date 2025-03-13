--[[----------------------------------------------------------------------------

  LiteMount/Blizzard_Compat.lua

  Copyright 2024 Mike Battersby

  For better or worse, try to back-port a functioning amount of compatibility
  for the 11.0 deprecations into classic, on the assumption that it will
  eventually go in there properly and this is the right approach rather than
  making the new way look like the old.

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
    LM.C_Spell.IsSpellUsable = _G.IsUsableSpell
end

if not LM.C_Spell.PickupSpell then
    LM.C_Spell.PickupSpell = _G.PickupSpell
end

if not LM.C_Spell.GetSpellSubtext then
    LM.C_Spell.GetSpellSubtext = _G.GetSpellSubtext
end

if not LM.C_Spell.GetOverrideSpell then
    function LM.C_Spell.GetOverrideSpell(spellIdentifier)
        local info = LM.C_Spell.GetSpellInfo(spellIdentifier)
        return info and FindSpellOverrideByID(info.spellID)
    end
end


--[[ C_MountJournal ]]----------------------------------------------------------

LM.C_MountJournal = CopyTable(C_MountJournal or {})

if not LM.C_MountJournal.IsDragonridingUnlocked then

    local IsPlayerSpell = _G.IsPlayerSpell

    function LM.C_MountJournal.IsDragonridingUnlocked()
        return IsPlayerSpell(376777)
    end
end

if not LM.C_MountJournal.GetDynamicFlightModeSpellID then

    function LM.C_MountJournal.GetDynamicFlightModeSpellID()
        return 436854
    end

end
