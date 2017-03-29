--[[----------------------------------------------------------------------------

  LiteMount/PlayerMounts.lua

  Information on all your mounts.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

LM_PlayerMounts = LM_CreateAutoEventFrame("Frame", "LM_PlayerMounts", UIParent)

local ExtraMountList = {
    -- { Type, type class create args ... }
    {"RunningWild", LM_SPELL.RUNNING_WILD },
    { "FlightForm", LM_SPELL.FLIGHT_FORM },
    { "TravelForm", LM_SPELL.TRAVEL_FORM },
    { "Nagrand", LM_SPELL.FROSTWOLF_WAR_WOLF },
    { "Nagrand", LM_SPELL.TELAARI_TALBUK },
    { "ItemSummoned",
        LM_ITEM.FLYING_BROOM, LM_SPELL.FLYING_BROOM, { LM_FLAG.FLY }
    },
    { "ItemSummoned",
        LM_ITEM.MAGIC_BROOM, LM_SPELL.MAGIC_BROOM, { LM_FLAG.FLY, LM_FLAG.RUN }
    },
    { "ItemSummoned",
        LM_ITEM.DRAGONWRATH_TARECGOSAS_REST, LM_SPELL.TARECGOSAS_VISAGE,
        { LM_FLAG.FLY }
    },
    { "ItemSummoned",
        LM_ITEM.SHIMMERING_MOONSTONE, LM_SPELL.MOONFANG, { LM_FLAG.RUN }
    },
}

local LearnMountEvents = {
    -- Companion change. Don't add COMPANION_UPDATE to this as it fires
    -- for units other than "player" and triggers constantly.
    "COMPANION_LEARNED", "COMPANION_UNLEARNED",
    -- Talents (might have mount abilities).
    "ACTIVE_TALENT_GROUP_CHANGED", "PLAYER_LEVEL_UP", "PLAYER_TALENT_UPDATE",
    -- You might have received a mount item (e.g., Magic Broom).
    "BAG_UPDATE",
    -- Draenor flying is an achievement
    "ACHIEVEMENT_EARNED",
}

function LM_PlayerMounts:Initialize()
    self.byName = { }
    self.byIndex = LM_FancyList:New()

    self:AddJournalMounts()
    self:AddExtraMounts()
    self:Refresh()

    -- Events that might cause a mount to be "learned"
    for _,ev in ipairs(LearnMountEvents) do
        self[ev] = function (self, event, ...)
                            LM_Debug("Got learn event "..event)
                            self:Refresh()
                        end
        self:RegisterEvent(ev)
    end

end

function LM_PlayerMounts:AddMount(m)
    if not m then return end

    tinsert(self.byIndex, m)

    -- sometimes mounts have the same name because they are
    -- not both usable

    if not self.byName[m.name] or self.byName[m.name].isFiltered then
        self.byName[m.name] = m
    end

end

function LM_PlayerMounts:AddJournalMounts()
    for _, mountID in ipairs(C_MountJournal.GetMountIDs()) do
        local m = LM_Mount:Get("Journal", mountID)
        self:AddMount(m)
    end
end

-- The unpack function turns a table into a list. I.e.,
--      unpack({ a, b, c }) == a, b, c
function LM_PlayerMounts:AddExtraMounts()
    for _,typeAndArgs in ipairs(ExtraMountList) do
        local m = LM_Mount:Get(unpack(typeAndArgs))
        self:AddMount(m)
    end
end

function LM_PlayerMounts:Refresh()
    LM_Debug("Refreshing mount statuses.")
    for m in self.byIndex:Iterate() do
        m:Refresh()
        LM_Options:SeenMount(m, true)
    end
end

function LM_PlayerMounts:Iterate()
    return self.byIndex:Iterate()
end

function LM_PlayerMounts:Search(matchfunc)
    return self.byIndex:Search(matchfunc)
end

function LM_PlayerMounts:GetAllMounts()
    local function match() return true end
    local function cmp(a,b) return a.name < b.name end
    result = self:Search(match)
    sort(result, cmp)
    return result
end

function LM_PlayerMounts:GetAvailableMounts(f)
    local function match(m)
        if not m.isCollected or not m:IsUsable() then return end
        if not m:CurrentFlags()[f] then return end
        if LM_Options:IsExcludedMount(m) then return end
        return true
    end

    return self:Search(match)
end

function LM_PlayerMounts:GetMountFromUnitAura(unitid)
    for i = 1,BUFF_MAX_DISPLAY do
        local m = self:GetMountByName(UnitAura(unitid, i))
        if m and m.isCollected and m:IsUsable() then return m end
    end
end

function LM_PlayerMounts:GetMountByName(name)
    return self.byName[name]
end

function LM_PlayerMounts:GetMountBySpell(id)
    local name = GetSpellInfo(id)
    if name then return self:GetMountByName(name) end
end

-- For some reason GetShapeshiftFormInfo doesn't work on Ghost Wolf.
function LM_PlayerMounts:GetMountByShapeshiftForm(i)
    if not i then return end
    local class = select(2, UnitClass("player"))
    if class == "SHAMAN" and i == 1 then
         return self:GetMountBySpell(LM_SPELL.GHOST_WOLF)
    end
    local name = select(2, GetShapeshiftFormInfo(i))
    if name then return self:GetMountByName(name) end
end

function LM_PlayerMounts:GetRandomMount(...)
    local poss = self:GetAvailableMounts(...)
    return poss:Random()
end

function LM_PlayerMounts:Dump()
    for m in self.byIndex:Iterate() do
        m:Dump()
    end
end
