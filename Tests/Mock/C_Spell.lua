C_Spell = {}

function C_Spell.GetSpellInfo(spellIdentifier)
    if type(spellIdentifier) == 'number' then
        return MockGetFromData(data.GetSpellInfo, spellIdentifier)
    elseif type(spellIdentifier) == 'string' then
        return MockGetFromData(data.GetSpellInfo, spellIdentifier, 1)
    end
    -- print("GetSpellInfo", tostring(id))
end

function C_Spell.GetSpellName(spellIdentifier)
    local info = C_Spell.GetSpellInfo(spellIdentifier)
    if info then
        return info.name
    end
end

function C_Spell.GetOverrideSpell(spellIdentifier)
    local info = C_Spell.GetSpellInfo(spellIdentifier)
    if info then
        return info.spellID
    end
end

function C_Spell.GetSpellName(spellIdentifier)
    local info = C_Spell.GetSpellInfo(spellIdentifier)
    if info then
        return info.name
    end
end

function C_Spell.GetSpellCooldown(id)
    return {
        isEnabled = true,
        startTime = 0,
        modRate = 1,
        duration = 0,
    }
end

function C_Spell.GetSpellIDForSpellIdentifier(spellIdentifier)
    local info = C_Spell.GetSpellInfo(spellIdentifier)
    return info.spellID
end

function C_Spell.GetSpellLink(spellIdentifier)
    local info = C_Spell.GetSpellInfo(spellIdentifier)
    return info.link
end

function C_Spell.GetSpellTexture(spellIdentifier)
    local info = C_Spell.GetSpellInfo(spellIdentifier)
    return info.iconID
end

function C_Spell.PickupSpell(spellIdentifier)
end

function C_Spell.IsSpellUsable(id)
    if MockState.moving then
        for _,info in pairs(data.GetMountInfoByID) do
            if info[2] == id then
                return false
            end
        end
    end
    return data.GetSpellInfo[id] ~= nil
end

--[[------------------------------------------------------------------------]]--

local SpellMixin = {
    ContinueOnSpellLoad =
        function (self, f)
            f()
        end,
    GetSpellName =
        function (self)
            return C_Spell.GetSpellName(self.id)
        end,
}

Spell = {}

function Spell:CreateFromSpellID(spellID)
    return Mixin({ id = spellID}, SpellMixin)
end
