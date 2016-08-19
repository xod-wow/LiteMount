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

-- If any of these start with "no" we're screwed
-- ":*" functions take 0 or more arguments slash separated
-- ":+" functions take 1 or more arguments slash separated
-- other functions take defined set of arguments

local map = {

    -- Key stuff

    ["mod:*"] = function (v)
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

    ["area:+"] = function (v)
            return tonumber(v) == LM_Location.areaID
        end,

    ["breathbar"] = function ()
            return GetMirrorTimerInfo(2) == "BREATH"
        end,

    ["continent:+"] = function (v)
            return tonumber(v) == LM_Location.continent
        end,

    ["flyable"] = function ()
            return LM_Location:CanFly()
        end,

    ["instance:*"] = function (v)
            if not v then
                return IsInInstance()
            else
                return LM_Location.instanceID == tonumber(v)
            end
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

    -- The difference between IsSwimming and IsSubmerged is that IsSubmerged will
    -- also return true when you are standing on the bottom.  Note that it sadly
    -- does not return false when you are floating on the top, that is still counted
    -- as being submerged.

    ["swimming"] = function ()
            return IsSubmerged()
        end,

    ["vehicle"] = function ()
            return CanExitVehicle()
        end,


    -- Character conditions

    ["achievement:+"] = function (v)
            return select(4, GetAchievementInfo(v))
        end,

    ["class:+"] = function (v)
            return tContains({ UnitClass("player") }, v)
        end,

    ["equipped:+"] = function (v)
            return IsEquippedItem(v) or IsEquippedItemType(v)
        end,

    ["form:*"] = function (v)
            if v == nil then 
                return GetShapeshiftForm() > 0
            else
                return GetShapeshiftForm() == tonumber(v)
            end
        end,

    ["group"] = function (groupType)
            if groupType == "raid" then return IsInRaid() end
            if not groupType or groupType == "group" then return IsInGroup() end
            return false
        end,

    ["pet:*"] = function (v)
            --- XXX FIXME XXX pet types
            if not v then return UnitExists("pet") end
            return UnitName("pet") == v
        end,

    ["spec:+"] = function (v)
            return GetSpecialization() == tonumber(v)
        end,

    ["talent"] = function (tier, talent)
            return select(2, GetTalentTierInfo(tier, 1)) == tonumber(talent)
        end,

}

local function any(f, ...)
    local n = select('#', ...)
    for i = 1, n do
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

    -- ":+" functions take one value and should support a/b/c "OR"
    -- ":*" functions are the same but but can also be called with no arguments
    -- This is really just for giving an error message when args are missing
    if #values > 0 and map[cond..":+"] then
        return any(map[cond..":+"], unpack(values))
    elseif map[cond..":*"] then
        if #values == 0 then
            return map[cond..":*"]()
        else
            return any(map[cond..":*"], unpack(values))
        end
    end

    -- If you give anything that doesn't exist that's error and false
    if type(map[cond]) ~= "function" then
        LM_WarningAndPrint("Unknown LiteMount action conditional: " .. cond)
        return false
    end

    return map[cond](unpack(values))
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
