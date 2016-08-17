--[[----------------------------------------------------------------------------

  LiteMount/Conditions.lua

  Parser/evaluator for action conditions.

  Copyright 2011-2016 Mike Battersby

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
                        <tag> "=" <args>

    <args>          :=  <arg> |
                        <arg> / <args>

    <arg>           :=  [-a-zA-Z0-9]+

    <tag>           :=  See map array in code
]]

LM_Conditions = { }

local map = {

    -- Key stuff

    ["mod:v"] = function (v)
            if not v then
                return IsModifierKeyDown()
            elseif v == "shift" then
                return IsShiftKeyDown()
            elseif v == "alt" then
                return IsAltKeyDown()
            elseif v == "control" then
                return IsControlKeyDown()
            else
                return false
            end
        end,

    -- Location conditions

    ["area:v"] = function (v)
            return tonumber(v) == LM_Location.areaID
        end,

    ["continent:v"] = function (v)
            return tonumber(v) == LM_Location.continent
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

    ["form:v"] = function (v)
            return GetShapeshiftForm() == tonumber(v)
        end,

    ["group"] = function (groupType)
            if groupType == "raid" then return IsInRaid() end
            if not groupType or groupType == "group" then return IsInGroup() end
            return false
        end,

    ["pet:v"] = function (v)
            --- XXX FIXME XXX pet types
            if not v then return UnitExists("pet") end
            return UnitName("pet") == v
        end,

    ["spec:v"] = function (v)
            return GetSpecialization() == tonumber(v)
        end,

    ["talent"] = function (tier, talent)
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
    local cond, valuestr = strsplit(':', str)

    -- Empty condition [] is true
    if cond == "" then return true end

    local values
    if valuestr then
        values = { strsplit('/', valuestr) }
    else
        values = { }
    end

    -- ":v" functions take one value and should support a/b/c "OR"
    if map[cond..":v"] then
        return any(map[cond..":v"], unpack(values))
    end

    -- Takes N values
    -- If you give anything that doesn't exist that's error and false
    if type(map[cond]) ~= "function" then
        LM_WarningAndPrint("Unknown LiteMount action list conditional: " .. cond)
        return false
    end

    return map[cond](unpack(values))
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
