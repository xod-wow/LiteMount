--[[----------------------------------------------------------------------------

  LiteMount/OptionsDB.lua

  User-settable options, Ace-3.0 version.
  Theses are queried by different places.

  Copyright 2011-2016 Mike Battersby

----------------------------------------------------------------------------]]--

local defaults = {
    global = {
        actionLists = { },
        seenSpells = { },
    },
    profile = {
        excludedSpells = { },
        flagoverrides = { },
        unavailableMacro = {
	    enabled = false,
            macroText = nil
        },
        combatMacro = {
            enabled = false,
            macroText = nil
        },
        excludeNewMounts = false,
        copyTargetsMount = true,
        actionListBindings = {
                [*] = "Default",
            },
    },
}

LM_Options = { }

function LM_Options:Initialize()
    self.db = LibStub("AceDB-3.0"):New("LM_GlobalOptionsDB", defaults, true)
    -- self.db.RegisterCallback(self, "OnProfileChanged", "RefreshConfig")
    -- self.db.RegisterCallback(self, "OnProfileCopied", "RefreshConfig")
    -- self.db.RegisterCallback(self, "OnProfileReset", "RefreshConfig")
end


local function VersionUpgradeOptions(db)

    -- XXX FIXME XXX

end


--[[----------------------------------------------------------------------------
    Excluded Mount stuff.
----------------------------------------------------------------------------]]--

function LM_Options:IsExcludedMount(m)
    if tContains(self.db.profile.excludedSpells, m:SpellID()) then
        return true
    end
    return false
end

function LM_Options:AddExcludedMount(m)
    LM_Debug(format("Disabling mount %s (%d).", m:SpellName(), m:SpellID()))
    if not tContains(self.db.profile.excludedSpells, m:SpellID()) then
        tinsert(self.db.excludedspells, m:SpellID())
    end
end

function LM_Options:RemoveExcludedMount(m)
    LM_Debug(format("Enabling mount %s (%d).", m:SpellName(), m:SpellID()))
    tDeleteItem(self.db.profile.excludedSpells, m:SpellID())
end

function LM_Options:ToggleExcludedMount(m)
    LM_Debug(format("Toggling mount %s (%d).", m:SpellName(), m:SpellID()))
    if self:IsExcludedMount(m) then
        self:RemoveExcludedMount(m)
    else
        self:AddExcludedMount(m)
    end
end

function LM_Options:SetExcludedMounts(mountlist)
    LM_Debug("Setting complete list of disabled mounts.")
    wipe(self.db.profile.excludedspells)
    for _,m in ipairs(mountlist) do
        tinsert(self.db.profile.excludedspells, m:SpellID())
    end
end

--[[----------------------------------------------------------------------------
    Mount flag overrides stuff
----------------------------------------------------------------------------]]--

function LM_Options:ApplyMountFlags(m)
    local id = m:SpellID()
    local flags = m:Flags()
    local ov = self.db.profile.flagoverrides[id]

    if not ov then return flags end

    flags = bit.bor(flags, ov[1])
    flags = bit.band(flags, bit.bnot(ov[2]))

    return flags
end

function LM_Options:SetMountFlagBit(m, flagbit)
    local id, name = m:SpellID(), m:SpellName()
    LM_Debug(format("Set flag bit %d for spell %s (%d)", flagbit, name, id))
    LM_Options:SetMountFlags(m, bit.bor(m:CurrentFlags(), flagbit))
end

function LM_Options:ClearMountFlagBit(m, flagbit)
    local id, name = m:SpellID(), m:SpellName()
    LM_Debug(format("Clear flag bit %d for spell %s (%d)", flagbit, name, id))
    LM_Options:SetMountFlags(m, bit.band(m:CurrentFlags(), bit.bnot(flagbit)))
end

function LM_Options:ResetMountFlags(m)
    local id, name = m:SpellID(), m:SpellName()
    LM_Debug(format("Reset flags for spell %s (%d).", name, id))
    self.db.profile.flagoverrides[id] = nil
end

function LM_Options:SetMountFlags(m, flags)

    if flags == m:Flags() then
        return self:ResetMountFlags(m)
    end

    local id = m:SpellID()
    local def = m:Flags()

    local toset = bit.band(bit.bxor(flags, def), flags)
    local toclear = bit.band(bit.bxor(flags, def), bit.bnot(flags))

    self.db.profile.flagoverrides[id] = { toset, toclear }
end


--[[----------------------------------------------------------------------------
    Last resort / combat macro stuff
----------------------------------------------------------------------------]]--

function LM_Options:UseMacro()
    return self.db.profile.unavailableMacro.enabled
end

function LM_Options:GetMacro()
    return self.db.profile.unavailableMacro.macroText
end

function LM_Options:SetMacro(text)
    LM_Debug("Setting custom macro: " .. tostring(text))
    self.db.profile.unavailableMacro.macroText = text
end

function LM_Options:UseCombatMacro(trueFalse)
    if trueFalse == true or trueFalse == 1 or trueFalse == "on" then
        LM_Debug("Enabling custom combat macro.")
        self.db.profile.combatMacro.enabled = 1
    elseif trueFalse == false or trueFalse == 0 or trueFalse == "off" then
        LM_Debug("Disabling custom combat macro.")
        self.db.profile.combatMacro.macroText = nil
    end

    return self.db.combatMacro.macroText ~= nil
end

function LM_Options:GetCombatMacro()
    return self.db.combatMacro.macroText
end

function LM_Options:SetCombatMacro(text)
    LM_Debug("Setting custom combat macro: " .. (text or "nil"))
    self.db.combatMacro.macroText = text
end


--[[----------------------------------------------------------------------------
    Copying Target's Mount 
----------------------------------------------------------------------------]]--

function LM_Options:CopyTargetsMount(v)
    if v ~= nil then
        LM_Debug(format("Setting copy targets mount: %s", tostring(v)))
        self.db.profile.copyTargetsMount = v
    end
    return self.db.profile.copyTargetsMount
end


--[[----------------------------------------------------------------------------
    Exclude newly learned mounts
----------------------------------------------------------------------------]]--

function LM_Options:ExcludeNewMounts(v)
    if v ~= nil then
        LM_Debug(format("Setting exclude new mounts: %s", tostring(v)))
        self.db.profile.excludeNewMounts = v
    end
    return self.db.profile.excludeNewMounts
end


--[[----------------------------------------------------------------------------
    Have we seen a mount before on this toon?
    Includes automatically adding it to the excludes if requested.
----------------------------------------------------------------------------]]--

function LM_Options:SeenMount(m, flagSeen)
    local id = m:SpellID()

    local seen = self.db.profile.seenspells[id]

    if flagSeen and not seen then
        self.db.global.seenspells[id] = true
        if self.db.profile.excludeNewMounts == true then
            self:AddExcludedMount(m)
        end
    end

    return seen

end

--[[----------------------------------------------------------------------------
    Action Lists
----------------------------------------------------------------------------]]--

function LM_Options:ActionListNames()
    local names = { }
    for name, _ in pairs(self.db.global.actionLists) do
        tinsert(names, name)
    end
    sort(names)
    return names
end

function LM_Options:ActionList(name, text)
    if text ~= nil then
        self.db.global.actionLists[name] = text
    end
    return self.db.global.actionLists[name]
end

function LM_Options:ActionListBinding(i, name)
    return self.db.global.
end

