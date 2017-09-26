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
        return select(4, GetAchievementInfo(tonumber(v or 0)))
    end

CONDITIONS["area"] =
    function (v)
        if v then
            return tonumber(v) == LM_Location.areaID
        else
            return LM_Location.areaID > 0
        end
    end

CONDITIONS["aura"] =
    function (v)
        if v then
            local auraName = GetSpellInfo(v)
            return UnitAura("player", auraName, 'HELPFUL|HARMFUL')
        end
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
        return UnitChannelInfo("player") ~= nil
    end

CONDITIONS["class"] =
    function (v)
        if v then
            return tContains({ UnitClass("player") }, v)
        end
    end

CONDITIONS["combat"] =
    function ()
        return UnitAffectingCombat("player") or UnitAffectingCombat("pet")
    end

CONDITIONS["continent"] =
    function (v)
        if v then
            return tonumber(v) == LM_Location.continent
        end
    end

CONDITIONS["dead"] =
    function ()
        return UnitIsDead("player")
    end

CONDITIONS["equipped"] =
    function (v)
        if v then
            return IsEquippedItem(v) or IsEquippedItemType(v)
        end
    end

CONDITIONS["exists"] =
    function (unit)
        return UnitExists(unit or "target")
    end

-- Check for an extraactionbutton, optionally with a specific spell
CONDITIONS["extra"] =
    function (v)
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
    function (v)
        if v then
            return tContains({ UnitFactionGroup("player") }, v)
        end
    end

CONDITIONS["falling"] =
    function ()
        return IsFalling()
    end

CONDITIONS["false"] =
    function ()
        return false
    end

CONDITIONS["floating"] =
    function ()
        return LM_Location:IsFloating()
    end

CONDITIONS["form"] =
    function (v)
        if v then
            return GetShapeshiftForm() == tonumber(v)
        else
            return GetShapeshiftForm() > 0
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

CONDITIONS["harm"] =
    function (unit)
        return not UnitIsFriend("player", unit or "target")
    end

CONDITIONS["help"] =
    function (unit)
        return UnitIsFriend("player", unit or "target")
    end

CONDITIONS["indoors"] =
    function ()
        return IsIndoors()
    end

CONDITIONS["instance"] =
    function (v)
        if v then
            return LM_Location.instanceID == tonumber(v)
        else
            return IsInInstance()
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

CONDITIONS["name"] =
    function (v)
        if v then
            return UnitName("player") == v
        end
    end

CONDITIONS["outdoors"] =
    function ()
        return IsOutdoors()
    end

CONDITIONS["party"] =
    function (unit)
        return UnitPlayerOrPetInParty(unit or "target")
    end

CONDITIONS["pet"] =
    function (v)
        if v then
            return UnitName("pet") == v or UnitCreatureFamily("pet") == v
        else
             return UnitExists("pet")
        end
    end

CONDITIONS["pvp"] =
    function ()
        return UnitIsPVP("player")
    end

CONDITIONS["race"] =
    function (v)
        if v then
            return tContains({ UnitRace("player") }, v)
        end
    end

CONDITIONS["raid"] =
    function (unit)
        return UnitPlayerOrPetInRaid(unit or "target")
    end

CONDITIONS["realm"] =
    function (v)
        if v then
            return GetRealmName() == v
        end
    end

CONDITIONS["resting"] =
    function ()
        return IsResting()
    end

CONDITIONS["role"] =
    function (v)
        if v then
            return UnitGroupRolesAssigned("player") == v
        end
    end

CONDITIONS["sex"] =
    function (v)
        if v then
            return UnitSex("player") == tonumber(v)
        end
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
        if v then
            local index = GetSpecialization()
            if tonumber(v) ~= nil then
                v = tonumber(v)
                return index == v or GetSpecializationInfo(index) == v
            else
                local name = select(2, GetSpecializationInfo(index))
                return name == v
            end
        end
    end

CONDITIONS["specrole"] =
    function (v)
        if v then
            local index = GetSpecialization("player")
            return GetSpecializationRole(index) == v
        end
    end

CONDITIONS["stealthed"] =
    function ()
        return IsStealthed()
    end

CONDITIONS["submerged"] =
    function ()
        return (IsSubmerged() and not LM_Location:IsFloating())
    end

CONDITIONS["talent:args"] =
    function (tier, talent)
        return select(2, GetTalentTierInfo(tier, 1)) == tonumber(talent)
    end

CONDITIONS["tracking"] =
    function (v)
        local name, active
        for i = 1, GetNumTrackingTypes() do
            name, _, active = GetTrackingInfo(i)
            if active and (not v or strlower(name) == strlower(v) or i == tonumber(v)) then
                return true
            end
        end
        return false
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

-- "AND" together comma-separated tests
function LM_Conditions:EvalCommaAnd(str)
    for _, e in ipairs({ strsplit(",", str) }) do
        if e:match("^no") then
            if self:IsTrue(e:sub(3)) then return false end
        else
            if not self:IsTrue(e) then return false end
        end
    end
    return true
end

-- "OR" together [] sections
function LM_Conditions:Eval(str)
    for e in str:gmatch('%[(.-)%]') do
        if self:EvalCommaAnd(e) then
            return true
        end
    end
    return false
end

function LM_Conditions:CheckSyntax(str)
    return true
end
