--[[----------------------------------------------------------------------------

  LiteMount/Conditions.lua

  Parser/evaluator for action conditions.

  Copyright 2011-2018 Mike Battersby

----------------------------------------------------------------------------]]--

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local L = LM_Localize

--[[

    <conditions>    :=  <condition> |
                        <condition> <conditions>

    <condition>     :=  "[" <expressions> "]"

    <expressions>   :=  <expr> |
                        <expr> "," <expressions>

    <expr>          :=  "no" <setting> |
                        <setting>

    <setting>       :=  <tag> |
                        <tag> ":" <args>

    <args>          :=  <arg> |
                        <arg> / <args>

    <arg>           :=  [-a-zA-Z0-9]+

    <tag>           :=  See CONDITIONS array in code

]]

-- If any condition starts with "no" we're screwed
-- ":args" functions take a fixed set of arguments rather than 0 or one with / separators

local CONDITIONS = { }

CONDITIONS["achievement"] =
    function (cond, v)
        return select(4, GetAchievementInfo(tonumber(v or 0)))
    end

CONDITIONS["area"] =
    function (cond, v)
        LM_WarningAndPrint(format(L.LM_WARN_REPLACE_COND, "area", "map"))
    end

CONDITIONS["aura"] =
    function (cond, v)
        if v then
            local spellID, auraID = tonumber(v)
            local i = 1
            while true do
                auraID = select(10, UnitAura("player", i, 'HELPFUL|HARMFUL'))
                if not auraID then return end
                if auraID == spellID then return true end
                i = i + 1
            end
        end
    end

CONDITIONS["breathbar"] =
    function (cond)
        local name, _, _, rate = GetMirrorTimerInfo(2)
        return (name == "BREATH" and rate < 0)
    end

CONDITIONS["canexitvehicle"] =
    function (cond)
        return CanExitVehicle()
    end

CONDITIONS["channeling"] =
    function (cond)
        return UnitChannelInfo("player") ~= nil
    end

CONDITIONS["class"] =
    function (cond, v)
        if v then
            return tContains({ UnitClass("player") }, v)
        end
    end

-- This can never work, but included for completeness
CONDITIONS["combat"] =
    function (cond)
        return UnitAffectingCombat("player") or UnitAffectingCombat("pet")
    end

CONDITIONS["continent"] =
    function (cond, v)
        LM_WarningAndPrint(format(L.LM_WARN_REPLACE_COND, "continent", "map"))
    end

-- For completeness, as far as I know. Note that this diverges from the
-- macro [dead] which is applied to "target".
CONDITIONS["dead"] =
    function (cond)
        return UnitIsDead("player")
    end

-- Persistent "deck of cards" draw randomness

CONDITIONS["draw:args"] =
    function (cond, x, y)
        x, y = tonumber(x), tonumber(y)
        if not cond.deck then
            if y > 52 then
                x, y = math.ceil(52 * x/y), 52
            end
            cond.deck = { }
            cond.deckIndex = y+1
            for i = 1,x do cond.deck[i] = true end
            for i = x+1,y do cond.deck[i] = false end
        end
        if cond.deckIndex > #cond.deck then 
            -- shuffle
            for i = #cond.deck, 2, -1 do
                local j = math.random(i)
                cond.deck[i], cond.deck[j] = cond.deck[j], cond.deck[i]
            end
            cond.deckIndex = 1
        end
        local result = cond.deck[cond.deckIndex]
        cond.deckIndex = cond.deckIndex + 1
        return result
    end

CONDITIONS["equipped"] =
    function (cond, v)
        if v then
            return IsEquippedItem(v) or IsEquippedItemType(v)
        end
    end

CONDITIONS["exists"] =
    function (cond, unit)
        return UnitExists(unit or "target")
    end

-- Check for an extraactionbutton, optionally with a specific spell
CONDITIONS["extra"] =
    function (cond, v)
        if HasExtraActionBar() and HasAction(169) then
            if v then
                local aType, aID = GetActionInfo(169)
                if aType == "spell" and aID == tonumber(v) then
                    return true
                end
            else
                return true
            end
        end
    end

CONDITIONS["faction"] =
    function (cond, v)
        if v then
            return tContains({ UnitFactionGroup("player") }, v)
        end
    end

CONDITIONS["falling"] =
    function (cond)
        return IsFalling()
    end

CONDITIONS["false"] =
    function (cond)
        return false
    end

CONDITIONS["floating"] =
    function (cond)
        return LM_Location:IsFloating()
    end

CONDITIONS["form"] =
    function (cond, v)
        if v then
            return GetShapeshiftForm() == tonumber(v)
        else
            return GetShapeshiftForm() > 0
        end
    end

CONDITIONS["flyable"] =
    function (cond)
        return LM_Location:CanFly()
    end

CONDITIONS["flying"] =
    function (cond)
        return IsFlying()
    end

CONDITIONS["group"] =
    function (cond, groupType)
        if not groupType then
            return IsInGroup() or IsInRaid()
        elseif groupType == "raid" then
            return IsInRaid()
        elseif groupType == "party" then
            return IsInGroup()
        end
    end

CONDITIONS["harm"] =
    function (cond, unit)
        return not UnitIsFriend("player", unit or "target")
    end

CONDITIONS["help"] =
    function (cond, unit)
        return UnitIsFriend("player", unit or "target")
    end

CONDITIONS["indoors"] =
    function (cond)
        return IsIndoors()
    end

CONDITIONS["instance"] =
    function (cond, v)
        if not v then
            return IsInInstance()
        elseif tonumber(v) then
            return LM_Location.instanceID == tonumber(v)
        else
            -- "none", "scenario", "party", "raid", "arena", "pvp"
            local _, instanceType = GetInstanceInfo()
            return instanceType == v
        end
    end

CONDITIONS["map"] =
    function (cond, v)
        return LM_Location:MapInPath(tonumber(v))
    end

CONDITIONS["mod"] =
     function (cond, v)
        if not v then
            return IsModifierKeyDown()
        elseif v == "alt" then
            return IsAltKeyDown()
        elseif v == "ctrl" then
            return IsControlKeyDown()
        elseif v == "shift" then
            return IsShiftKeyDown()
        else
            return false
        end
    end

CONDITIONS["mounted"] =
    function (cond)
        return IsMounted()
    end

CONDITIONS["moving"] =
    function (cond)
        return IsFalling() or GetUnitSpeed("player") > 0
    end

CONDITIONS["name"] =
    function (cond, v)
        if v then
            return UnitName("player") == v
        end
    end

CONDITIONS["outdoors"] =
    function (cond)
        return IsOutdoors()
    end

CONDITIONS["party"] =
    function (cond, unit)
        return UnitPlayerOrPetInParty(unit or "target")
    end

CONDITIONS["pet"] =
    function (cond, v)
        if v then
            return UnitName("pet") == v or UnitCreatureFamily("pet") == v
        else
             return UnitExists("pet")
        end
    end

CONDITIONS["pvp"] =
    function (cond)
        return UnitIsPVP("player")
    end

CONDITIONS["race"] =
    function (cond, v)
        if v then
            return tContains({ UnitRace("player") }, v)
        end
    end

CONDITIONS["raid"] =
    function (cond, unit)
        return UnitPlayerOrPetInRaid(unit or "target")
    end

CONDITIONS["random"] =
    function (cond, n)
        return math.random(100) <= tonumber(n)
    end

CONDITIONS["realm"] =
    function (cond, v)
        if v then
            return GetRealmName() == v
        end
    end

CONDITIONS["resting"] =
    function (cond)
        return IsResting()
    end

CONDITIONS["role"] =
    function (cond, v)
        if v then
            return UnitGroupRolesAssigned("player") == v
        end
    end

CONDITIONS["sex"] =
    function (cond, v)
        if v then
            return UnitSex("player") == tonumber(v)
        end
    end

-- The difference between IsSwimming and IsSubmerged is that IsSubmerged
-- will also return true when you are standing on the bottom.  Note that
-- it sadly does not return false when you are floating on the top, that
-- is still counted as being submerged.

CONDITIONS["swimming"] =
    function (cond)
        return IsSubmerged()
    end

CONDITIONS["shapeshift"] =
    function (cond)
        return HasTempShapeshiftActionBar()
    end

CONDITIONS["spec"] =
    function (cond, v)
        if v then
            local index = GetSpecialization()
            if tonumber(v) ~= nil then
                v = tonumber(v)
                return index == v or GetSpecializationInfo(index) == v
            else
                local _, name, _, _, _, role = GetSpecializationInfo(index)
                return (name == v or role == v)
            end
        end
    end

CONDITIONS["stealthed"] =
    function (cond)
        return IsStealthed()
    end

CONDITIONS["submerged"] =
    function (cond)
        return (IsSubmerged() and not LM_Location:IsFloating())
    end

CONDITIONS["talent:args"] =
    function (cond, tier, talent)
        return select(2, GetTalentTierInfo(tier, 1)) == tonumber(talent)
    end

CONDITIONS["tracking"] =
    function (cond, v)
        local name, active, _
        for i = 1, GetNumTrackingTypes() do
            name, _, active = GetTrackingInfo(i)
            if active and (not v or strlower(name) == strlower(v) or i == tonumber(v)) then
                return true
            end
        end
        return false
    end

CONDITIONS["true"] =
    function (cond)
        return true
    end

CONDITIONS["xmog:args"] =
    function (cond, slotID, appearanceID)
        slotID, appearanceID = tonumber(slotID), tonumber(appearanceID)
        local ok, _, _, _, current = pcall(C_Transmog.GetSlotVisualInfo, slotID, LE_TRANSMOG_TYPE_APPEARANCE)
        return ok and current == appearanceID
    end

local function any(f, cond, ...)
    local n = select('#', ...)
    for i = 1, n do
        local v = select(i, ...)
        if f(cond, v) then return true end
    end
    return false
end


_G.LM_Conditions = { }

function LM_Conditions:IsTrue(condition)
    local str = condition[1]

    if condition.vars then
        str = LM_Vars:StrSubVars(str)
    end

    local cond, valuestr = strsplit(':', str)

    -- Empty condition [] is true
    if cond == "" then return true end

    local values
    if valuestr then
        values = { strsplit('/', valuestr) }
    else
        values = { }
    end

    local handler = CONDITIONS[cond..":args"]
    if handler then
        return handler(condition, unpack(values))
    end

    handler = CONDITIONS[cond]
    if handler and #values == 0 then
        return handler(condition)
    end

    if handler then
        return any(handler, condition, unpack(values))
    end

    LM_WarningAndPrint(format(L.LM_ERR_BAD_CONDITION, cond))
    return false
end

function LM_Conditions:EvalNot(conditions)
    return not self:Eval(conditions[1])
end

function LM_Conditions:EvalAnd(conditions)
    for _,e in ipairs(conditions) do
        if not self:Eval(e) then return false end
    end
    return true
end

function LM_Conditions:EvalOr(conditions)
    for _,e in ipairs(conditions) do
        if self:Eval(e) then return true end
    end
    return false
end

-- outer grouping is ORed together
function LM_Conditions:Eval(conditions)
    if not conditions or conditions[1] == nil then return true end

    if conditions.op == "OR" then
        return self:EvalOr(conditions)
    elseif conditions.op == "AND" then
        return self:EvalAnd(conditions)
    elseif conditions.op == "NOT" then
        return self:EvalNot(conditions)
    else
        return self:IsTrue(conditions)
    end
end
