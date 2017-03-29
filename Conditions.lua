--[[----------------------------------------------------------------------------

  LiteMount/Conditions.lua

  Parser/evaluator for action conditions.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

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
    function (v)
        return select(4, GetAchievementInfo(v))
    end

CONDITIONS["area"] =
    function (v)
        return tonumber(v) == LM_Location.areaID
    end

CONDITIONS["aura"] =
    function (v)
        local auraName = GetSpellInfo(v)
        return UnitAura("player", auraName)
    end

CONDITIONS["breathbar"] =
    function ()
        local name, _, _, rate = GetMirrorTimerInfo(2)
        return (name == "BREATH" and rate < 0)
    end

CONDITIONS["canexitvehicle"] =
    function ()
        return CanExitVehicle()
    end

CONDITIONS["channeling"] =
    function ()
        return UnitChannelInfo( "player" ) ~= nil
    end

CONDITIONS["class"] =
    function (v)
        return tContains({ UnitClass("player") }, v)
    end

CONDITIONS["combat"] =
    function ()
        return UnitAffectingCombat("player") or UnitAffectingCombat("pet")
    end

CONDITIONS["continent"] =
    function (v)
        return tonumber(v) == LM_Location.continent
    end

CONDITIONS["dead"] =
    function ()
        return UnitIsDead("player")
    end

CONDITIONS["equipped"] =
    function (v)
        return IsEquippedItem(v) or IsEquippedItemType(v)
    end

CONDITIONS["exists:args"] =
    function (unit)
        return UnitExists(unit or "target")
    end

CONDITIONS["faction"] =
    function (v)
        return tContains({ UnitFactionGroup("player") }, v)
    end

CONDITIONS["falling"] =
    function ()
        return IsFalling()
    end

CONDITIONS["false"] =
    function ()
        return false
    end

CONDITIONS["form"] =
    function (v)
        if v == nil then 
            return GetShapeshiftForm() > 0
        else
            return GetShapeshiftForm() == tonumber(v)
        end
    end

CONDITIONS["flyable"] =
    function ()
        return LM_Location:CanFly()
    end

CONDITIONS["flying"] =
    function ()
        return IsFlying()
    end

CONDITIONS["group"] =
    function (groupType)
        if groupType == "raid" then
            return IsInRaid()
        end
        if not groupType or groupType == "party" then
            return IsInGroup()
        end
        return false
    end

CONDITIONS["harm:args"] =
    function (unit)
        return not UnitIsFriend("player", unit)
    end

CONDITIONS["help:args"] =
    function (unit)
        return UnitIsFriend("player", unit)
    end

CONDITIONS["indoors"] =
    function ()
        return IsIndoors()
    end

CONDITIONS["instance"] =
    function (v)
        if not v then
            return IsInInstance()
        else
            return LM_Location.instanceID == tonumber(v)
        end
    end

CONDITIONS["mod"] =
     function (v)
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
    function ()
        return IsMounted()
    end

CONDITIONS["moving"] =
    function ()
        return IsFalling() or GetUnitSpeed("player") > 0
    end

CONDITIONS["outdoors"] =
    function ()
        return IsOutdoors()
    end

CONDITIONS["party:args"] =
    function (unit)
        return UnitPlayerOrPetInParty(unit or "target")
    end

CONDITIONS["pet"] =
    function (v)
        if not v then return UnitExists("pet") end
        return UnitName("pet") == v or UnitCreatureFamily("pet") == v
    end

CONDITIONS["pvp"] =
    function ()
        return UnitIsPVP("player")
    end

CONDITIONS["race"] =
    function (v)
        return tContains({ UnitRace("player") }, v)
    end

CONDITIONS["raid:args"] =
    function (unit)
        return UnitPlayerOrPetInRaid(unit or "target")
    end

CONDITIONS["resting"] =
    function ()
        return IsResting()
    end

-- The difference between IsSwimming and IsSubmerged is that IsSubmerged
-- will also return true when you are standing on the bottom.  Note that
-- it sadly does not return false when you are floating on the top, that
-- is still counted as being submerged.

CONDITIONS["swimming"] =
    function ()
        return IsSubmerged()
    end

CONDITIONS["shapeshift"] =
    function ()
        return HasTempShapeshiftActionBar()
    end

CONDITIONS["spec"] =
    function (v)
        return GetSpecialization() == tonumber(v)
    end

CONDITIONS["stealthed"] =
    function ()
        return IsStealthed()
    end

CONDITIONS["talent:args"] =
    function (tier, talent)
        return select(2, GetTalentTierInfo(tier, 1)) == tonumber(talent)
    end

CONDITIONS["true"] =
    function ()
        return true
    end


local function any(f, ...)
    local n = select('#', ...)
    for i = 1, n do
        local v = select(i, ...)
        if f(v) then return true end
    end
    return false
end


LM_Conditions = { }

function LM_Conditions:IsTrue(str)
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
        return handler(unpack(values))
    end

    handler = CONDITIONS[cond]
    if handler and #values == 0 then
        return handler()
    end

    if handler then
        return any(handler, unpack(values))
    end

    LM_WarningAndPrint("Unknown LiteMount action conditional: " .. cond)
    return false
end

-- "OR" together comma-separated tests
function LM_Conditions:EvalCommaOr(str)
    for _, e in ipairs({ strsplit(",", str) }) do
        if e:match("^no") then
            if self:IsTrue(e:sub(3)) then return false end
        else
            if not self:IsTrue(e) then return false end
        end
    end
    return true
end

-- "AND" together [] sections
function LM_Conditions:Eval(str)
    for e in str:gmatch('%[(.-)%]') do
        if self:EvalCommaOr(e) then
            return true
        end
    end
    return false
end

function LM_Conditions:CheckSyntax(str)
    return true
end
