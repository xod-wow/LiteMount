--[[----------------------------------------------------------------------------

  LiteMount/Parser.lua

  Parser for action conditions.

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

local conditionMap = { }

local function any(f)
    return function(...)
            for i = 1, select('#', ...) do
                local v = select(i, ...)
                if f(v) then return true end
            end
    end
end

conditionMap.achievement = function (...)
    for i = 1, select('#', ...) do
        local id = select(i, ...)
        if select(4, GetAchievementInfo(id)) then
            return true
        end
    end
    return false
end

conditionMap.areaid = function (...)
    return tContains({...}, LM_Location.areaID)
end

conditionMap.class = function (...)
    local playerClassNames = { UnitClass("player") }
    for i = 1, select('#', ...) do
        local class = select(i, ...)
        if tContains(playerClassNames, class) then
            return true
        end
    end
    return false
end

conditionMap.continent = function (...)
    return tContains({...}, LM_Location.continent)
end

conditionMap.equipped = function (...)
    for i = 1, select('#', ...) do
        local v = select(i, ...)
        if IsEquippedItem(v) or IsEquippedItemType(v) then
            return true
        end
    end
    return false
end

conditionMap.flyable = function ()
    return LM_Location:CanFly()
end

conditionMap.flying = IsFlying

conditionMap.falling = IsFalling

conditionMap.moving = function ()
    return (IsFalling() or GetUnitSpeed("player") > 0)
end

conditionMap.group = function (groupType)
    if groupType == "raid" then return IsInRaid() end
    if not groupType or groupType == "group" then return IsInGroup() end
    return false
end

conditionMap.instance = IsInInstance
conditionMap.indoors = IsIndoors
conditionMap.mounted = IsMounted
conditionMap.outdoors = IsOutdoors

conditionMap.pet = function (v)
    --- XXX FIXME XXX pet types
    if not v then return UnitExists("pet") end
    return UnitName("pet") == v
end

conditionMap.spec = function (...)
    return tContains({...}, GetSpecialization())
end

conditionMap.swimming = IsSubmerged

conditionMap.talent = function (tier, talent)
    return select(2, GetTalentTierInfo(tier, 1)) == talent
end

conditionMap.vehicle = CanExitVehicle

local function TrimWS(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function EvaluateExpression(str)
    local cond, args = strsplit(':', str)

    local argList

    if not args then
        argList = { }
    else
        argList = strsplit('/', args)
    end

    if type(conditionMap[cond]) ~= "function" then
        -- XXX FIXME XXX
        print("Unknown LiteMount action list conditional: " .. cond)
        return false
    end

    return conditionMap[cond](unpack(argList))
end

local function EvaluateExpressions(str)
    local expArray = { strsplit(",", str) }
    for _, e in ipairs(expArray) do
        if not EvaluateExpression(e) then
            return false
        end
    end
    return true
end

local function EvaluateConditions(str)
    for e in str:gmatch('%[(.-)%]') do
        if EvaluateExpressions(e) then
            return true
        end
    end
    return false
end

-- Returns action if conditions match, or nil otherwise

function LiteMountCmdParse(line)

    line = TrimWS(line)

    local conditions, action = strsplit(" ", line)

    -- No conditions part is always true
    if not action then return conditions end

    if EvaluateConditions(conditions) then return action end

    return nil
end
