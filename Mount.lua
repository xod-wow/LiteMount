--[[----------------------------------------------------------------------------

----------------------------------------------------------------------------]]--

LM_Mount = { }
LM_Mount.__index = LM_Mount
function LM_Mount:new() return setmetatable({ }, LM_Mount) end

local FlagOverrideTable = {
    [SPELL_RIDING_TURTLE]       = bit.band(LM_FLAG_BIT_FLOAT, LM_FLAG_BIT_SWIM),
    [SPELL_SEA_TURTLE]          = bit.band(LM_FLAG_BIT_FLOAT, LM_FLAG_BIT_SWIM),
    [SPELL_FLIGHT_FORM]         = bit.band(LM_FLAG_BIT_FLY),
    [SPELL_SWIFT_FLIGHT_FORM]   = bit.band(LM_FLAG_BIT_FLY),
    [SPELL_RUNNING_WILD]        = bit.band(LM_FLAG_BIT_WALK),
}
for s in LM_AQ_MOUNT_SPELLS do
    FlagOverrideTable[s] = bit.band(LM_FLAG_BIT_AQ)
end
for s in LM_VASHJIR_MOUNT_SPELLS do
    FlagOverrideTable[s] = bit.band(LM_FLAG_BIT_VASHJIR)
end

function LM_Mount:FixupFlags()
    local flags = FlagOverrideTable[self.spell]
    if flags then
        self.flags = flags
    end
end

function LM_Mount:GetMountBySpell(spellId)
    local m = LM_Mount:new()
    local si = { GetSpellInfo(spellId) }
    m.name = si[1]
    m.spell = spellId
    m.icon = si[3]
    m.flags = 0
    m.casttime = si[7]
    m:FixupFlags()
    return m
end

function LM_Mount:GetMountByIndex(mountIndex)
    local m = LM_Mount:new()
    local ci = { GetCompanionInfo("MOUNT", i) }

    m.name = ci[2]
    m.spell = ci[3]
    m.icon = ci[4]
    m.flags = ci[6]

    if m.spell == SPELL_RIDING_TURTLE or m.spell == SPELL_SEA_TURTLE then
        m.flags = bit.band(m.flags, bit.bnot(FLAG_BIT_WALK))
    end

    local si = { GetSpellInfo(m.spell) }
    m.casttime = si[7]

    m:FixupFlags()
    return m
end

function LM_Mount:SpellId()
    return self.spell
end

function LM_Mount:Icon()
    return self.icon
end

function LM_Mount:Name()
    return self.name
end

function LM_Mount:CanFly()
    return bit.band(self.flags, FLAG_BIT_FLY)
end

function LM_Mount:CanWalk()
    return bit.band(self.flags, FLAG_BIT_WALK)
end

function LM_Mount:CanFloat()
    return bit.band(self.flags, FLAG_BIT_FLOAT)
end

function LM_Mount:CanSwim()
    return bit.band(self.flags, FLAG_BIT_SWIM)
end

function LM_Mount:CastTime()
    return self.casttime
end

function LM_Mount:Useable()
    return IsUsableSpell(self.spell)
end

function LM_Mount:Dump()
    LM_Print(string.format("%s %d %02x", self.name, self.spell, self.flags))
end
