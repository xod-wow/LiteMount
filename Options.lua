--[[----------------------------------------------------------------------------

  LiteMount/Options.lua

  Options for excluding mounts.

----------------------------------------------------------------------------]]--

LM_OptionsDB = { }

LM_Options = LM_CreateAutoEventFrame("Frame", "LM_Options")
LM_Options:RegisterEvent("ADDON_LOADED")

function LM_Options:Initialize()
    self.db = LM_OptionsDB
end

function LM_Options:AddExcludedSpell(spellId)
    self.db[spellId] = GetSpellInfo(spellId)
end

function LM_Options:RemoveExcludedSpell(mountType, spellId)
    self.db[spellId] = nil
end

function LM_Options:GetExcludedSpellIds()
    local ids = { }
    for s in pairs(self.db) do
        table.insert(ids, s)
    end
    return ids
end

function LM_Options:ADDON_LOADED()
    self:Initialize()
end
