--[[----------------------------------------------------------------------------

  LiteMount/Options.lua

  User-settable options.  Theses are queried by different places.

----------------------------------------------------------------------------]]--

local Default_LM_OptionsDB = {
    ["excludedspells"] = { },
    ["flagoverrides"]  = { },
}

LM_Options = { }

function LM_Options:Initialize()

    if not LM_OptionsDB then
        LM_OptionsDB = Default_LM_OptionsDB
    end

    -- Compatibility fixups
    if not LM_OptionsDB.excludedspells then
        local orig = LM_OptionsDB
        LM_OptionsDB = Default_LM_OptionsDB
        LM_OptionsDB.excludedspells = orig
    end

    self.excludedspells = LM_OptionsDB.excludedspells
    self.flagoverrides = LM_OptionsDB.flagoverrides

end

--[[----------------------------------------------------------------------------
   Excluded Spell stuff.
----------------------------------------------------------------------------]]--

function LM_Options:IsExcludedSpell(id)
    for _,s in ipairs(self.excludedspells) do
        if s == id then return true end
    end
end

function LM_Options:AddExcludedSpell(id)
    LM_Debug(string.format("Disabling mount %s (%d).", GetSpellInfo(id), id))
    if not self:IsExcludedSpell(id) then
        table.insert(self.excludedspells, id)
        table.sort(self.excludedspells)
    end
end

function LM_Options:RemoveExcludedSpell(id)
    LM_Debug(string.format("Enabling mount %s (%d).", GetSpellInfo(id), id))
    for i = 1, #self.excludedspells do
        if self.excludedspells[i] == id then
            table.remove(self.excludedspells, i)
            return
        end
    end
end

function LM_Options:SetExcludedSpells(idlist)
    LM_Debug("Setting complete list of disabled mounts.")
    table.wipe(self.excludedspells)
    for _,id in ipairs(idlist) do
        table.insert(self.excludedspells, id)
    end
    table.sort(self.excludedspells)
end

--[[----------------------------------------------------------------------------
   Mount flag overrides stuff
----------------------------------------------------------------------------]]--

function LM_Options:SaveMountFlags(mount, flags)
    local id = mount:SpellId()

    if not self.flagoverrides[id] then
        self.flagoverrides[id] = { 0, 0 }
    end

    local def = mount:GetDefaultFlags()
    local cur = mount:GetFlags()

    local toset = bit.band(bit.bxor(def, cur), cur)
    local toclear = bit.band(bit.bxor(def, cur), bit.bnot(cur))

    self.flagoverrides[id][1] = toset
    self.flagoverrides[id][2] = toclear
end

function LM_Options:ModFlags(mount)
    local id = mount:SpellId()
    local flags = mount:DefaultFlags()

    local ov = self.flagoverrides[id]


    if not ov then return flags end

    flags = bit.bor(flags, ov[1])
    flags = bit.band(flags, bit.bnot(ov[1]))

    return flags
end

function LM_Options:SetMountFlagBit(mount, flag)
    LM_Debug(string.format("Setting flag bit %d for spell %s (%d).",
                           flag, GetSpellInfo(id), id))

    local newflags = bit.bor(mount:Flags(), flag)
    LM_Options:SaveMountFlags(mount, newflags)
end

function LM_Options:ClearMountFlagBit(mount, flag)
    LM_Debug(string.format("Clearing flag bit %d for spell %s (%d).",
                           flag, GetSpellInfo(id), id))

    local newflags = bit.band(mount:Flags(), bit.bnot(flag))
    LM_Options:SaveMountFlags(mount, newflags)
end

function LM_Options:ResetMountFlags(mount)
    LM_Debug(string.format("Defaulting flag bit %d for spell %s (%d).",
                           flag, GetSpellInfo(id), id))

    local newflags = mount:DefaultFlags()
    LM_Options:SaveMountFlags(mount, newflags)
end

