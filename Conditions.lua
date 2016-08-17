--[[----------------------------------------------------------------------------

  LiteMount/Conditions.lua

  Parser/evaluator for action conditions.

  Copyright 2011-2016 Mike Battersby

----------------------------------------------------------------------------]]--

--[[

    <line>          :=  <action> |
                        <conditions> " " <action>

    <action>        :=  STRING

    <conditions>    :=  <condition> |
                        <condition> <conditions>

    <condition>     :=  "[" <expressions> "]"

    <expressions>   :=  <expr> |
                        <expr> "," <expressions>

    <expr>          :=  "no" <setting> |
                        <setting>

    <setting>       :=  <tag> |
                        <tag> "=" <args>

    <args>          :=  <arg> |
                        <arg> / <args>

    <arg>           :=  [-a-zA-Z0-9]+

    <tag>           :=  See checkMap array in code
]]

LM_Conditions = { }

local map = {

    -- Location conditions

    ["area:v"] = function (v)
            return v == LM_Location.areaID
        end,

    ["continent:v"] = function (v)
            return v == LM_Location.continent
        end,

    ["flyable"] = function ()
            return LM_Location:CanFly()
        end,

    ["instance"] = function ()
            return IsInInstance()
        end,

    ["indoors"] = function ()
            return IsIndoors()
        end,

    ["outdoors"] = function ()
            return IsOutdoors()
        end,


    -- Situation conditions

    ["falling"] = function ()
            return IsFalling()
        end,

    ["flying"] = function ()
            return IsFlying()
        end,

    ["mounted"] = function ()
            return IsMounted()
        end,

    ["moving"] = function ()
            return IsFalling() or GetUnitSpeed("player") > 0
        end,

    ["swimming"] = function ()
            return IsSubmerged()
        end,

    ["vehicle"] = function ()
            return CanExitVehicle()
        end,


    -- Character conditions

    ["achievement:v"] = function (v)
            return select(4, GetAchievementInfo(v))
        end,

    ["class:v"] = function (v)
            return tContains({ UnitClass("player") }, v)
        end,

    ["equipped:v"] = function (v)
            return IsEquippedItem(v) or IsEquippedItemType(v)
        end,

    ["group:1"] = function (groupType)
            if groupType == "raid" then return IsInRaid() end
            if not groupType or groupType == "group" then return IsInGroup() end
            return false
        end,

    ["pet:v"] = function (v)
            --- XXX FIXME XXX pet types
            if not v then return UnitExists("pet") end
            return UnitName("pet") == v
        end,

    ["spec:v"] = function (n)
            return n == GetSpecialization()
        end,

    ["talent:2"] = function (tier, talent)
            return select(2, GetTalentTierInfo(tier, 1)) == talent
        end,

}

local function any(f, ...)
    for i = 1, select('#', ...) do
        local v = select(i, ...)
        if f(v) then return true end
    end
    return false
end

function LM_Conditions:IsTrue(str)
    local cond, values = strsplit(':', str)

    values = { strsplit('/', args or "") }

    -- Empty condition [] is true
    if cond == "" then
        return true
    end

    -- Takes one value and should support a/b/c "OR"
    if map[cond..":v"] then
        return any(map[cond..":v"], unpack(values))
    end

    -- Takes N values
    -- If you give anything that doesn't exist that's error and false
    if type(conditionMap[cond]) ~= "function" then
        LM_WarningAndPrint("Unknown LiteMount action list conditional: " .. cond)
        return false
    end

    -- Blizzard screwed this up. In most cases the / separator means "any of these
    -- values", so [x:1/2] == [x:1][x:2].  But for talent it's separating the 
    -- tier from the talent in that tier.

    local argList

    if not args then
        argList = { }
    else
        argList = strsplit('/', args)
    end

    if type(conditionMap[cond]) ~= "function" then
    end

    return conditionMap[cond](unpack(argList))
end

-- "OR" together comma-separated tests
function LM_Conditions:EvalCommaOr(str)
    for _, e in ipairs({ strsplit(",", str) }) do
        if not self:IsTrue(e) then
            return false
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
