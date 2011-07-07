--[[----------------------------------------------------------------------------

  LiteMount/Options.lua

  Options for excluding mounts.

----------------------------------------------------------------------------]]--

LM_OptionsDB = { }

LM_Options = LM_CreateAutoEventFrame("Frame", "LM_Options")
LM_Options:RegisterEvent("ADDON_LOADED")

function LM_Options:Initialize()
    self.db = LM_OptionsDB
    if not self.db.Walking then self.db.Walking = { } end
    if not self.db.Swimming then self.db.Swimming = { } end
    if not self.db.Flying then self.db.Flying = { } end
end

function LM_Options:IsFlyingExcluded(spellId)
    return self:IsExcludedSpell("Flying", spellId)
end

function LM_Options:IsWalkingExcluded(spellId)
    return self:IsExcludedSpell("Walking", spellId)
end

function LM_Options:IsSwimmingExcluded(spellId)
    return self:IsExcludedSpell("Swimming", spellId)
end

function LM_Options:IsExcludedSpell(mountType, spellId)
    if not self.db[mountType] then return end
    if self.db[mountType][spellId] then return true end
end

function LM_Options:AddExcludedSpell(mountType, spellId)
    if mountType == "Swimming" then
        self.db["Swimming"][spellId] = true
    elseif mountType == "Walking" then
        self.db["Walking"][spellId] = true
    elseif mountType == "Flying" then
        self.db["Flying"][spellId] = true
    end
end

function LM_Options:RemoveExcludedSpell(mountType, spellId)
    if mountType == "Swimming" then
        self.db["Swimming"][spellId] = nil
    elseif mountType == "Walking" then
        self.db["Walking"][spellId] = nil
    elseif mountType == "Flying" then
        self.db["Flying"][spellId] = nil
    end
end

function LM_Options:ADDON_LOADED()
    self:Initialize()
end
