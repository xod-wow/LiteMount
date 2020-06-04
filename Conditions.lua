--[[----------------------------------------------------------------------------

  LiteMount/Conditions.lua

  Parser/evaluator for action conditions.

  Copyright 2011-2020 Mike Battersby

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

local function UnitHasAura(unit, spellID, filter)
    local i = 1
    local auraID
    while true do
        auraID = select(10, UnitAura(unit, i, filter))
        if not auraID then
            break
        end
        if auraID == spellID then
            return true
        end
        i = i + 1
    end
end

-- If any condition starts with "no" we're screwed
-- ":args" functions take a fixed set of arguments rather using / for OR

local CONDITIONS = { }

CONDITIONS["achievement"] =
    function (cond, unit, v)
        return select(4, GetAchievementInfo(tonumber(v or 0)))
    end

CONDITIONS["aura"] =
    function (cond, unit, v)
        v = tonumber(v)
        if not v then
            return
        end

        unit = unit or "player"

        if UnitHasAura(unit, v) or UnitHasAura(unit, v, "HARMFUL") then
            return true
        end
    end

CONDITIONS["breathbar"] =
    function (cond, unit)
        local name, _, _, rate = GetMirrorTimerInfo(2)
        return (name == "BREATH" and rate < 0)
    end

CONDITIONS["canexitvehicle"] =
    function (cond, unit)
        return CanExitVehicle()
    end

CONDITIONS["channeling"] =
    function (cond, unit)
        return UnitChannelInfo(unit or "player") ~= nil
    end

CONDITIONS["class"] =
    function (cond, unit, v)
        if v then
            return tContains({ UnitClass(unit or "player") }, v)
        end
    end

-- This can never work, but included for completeness
CONDITIONS["combat"] =
    function (cond, unit)
        local petunit
        if not unit then
            unit, petunit = "player", "pet"
        elseif unit == "player" then
            petunit = "pet"
        else
            petunit = unit .. "pet"
        end
        return UnitAffectingCombat(unit) or UnitAffectingCombat(petunit)
    end

-- For completeness, as far as I know. Note that this diverges from the
-- macro [dead] which is applied to "target".
CONDITIONS["dead"] =
    function (cond, unit)
        return UnitIsDead(unit or "player")
    end

-- Persistent "deck of cards" draw randomness

CONDITIONS["draw:args"] =
    function (cond, unit, x, y)
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
    function (cond, unit, v)
        if not v then
            return false
        end

        if IsEquippedItemType(v) then
            return true
        end

        v = tonumber(v) or v
        if IsEquippedItem(v) then
            return true
        end

        local id = C_MountJournal.GetAppliedMountEquipmentID()
        if id and id == v then
            return true
        end
    end

CONDITIONS["exists"] =
    function (cond, unit)
        return UnitExists(unit or "target")
    end

-- Check for an extraactionbutton, optionally with a specific spell
CONDITIONS["extra"] =
    function (cond, unit, v)
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
    function (cond, unit, v)
        if v then
            return tContains({ UnitFactionGroup(unit or "player") }, v)
        end
    end

CONDITIONS["falling"] =
    function (cond, unit)
        return IsFalling() and ( GetTime() - LM_Location.lastJumpTime > 1 )
    end

CONDITIONS["false"] =
    function (cond, unit)
        return false
    end

CONDITIONS["floating"] =
    function (cond, unit)
        return LM_Location:IsFloating()
    end

CONDITIONS["flyable"] =
    function (cond, unit)
        return LM_Location:CanFly()
    end

CONDITIONS["flying"] =
    function (cond, unit)
        return IsFlying()
    end

CONDITIONS["form"] =
    function (cond, unit, v)
        if v then
            return GetShapeshiftForm() == tonumber(v)
        else
            return GetShapeshiftForm() > 0
        end
    end

CONDITIONS["group"] =
    function (cond, unit, groupType)
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
    function (cond, unit)
        return IsIndoors()
    end

CONDITIONS["instance"] =
    function (cond, unit, v)
        if not v then
            return IsInInstance()
        end

        local _, instanceType, _, _, _, _, _, instanceID = GetInstanceInfo()

        if instanceID == tonumber(v) then
            return true
        end

        -- "none", "scenario", "party", "raid", "arena", "pvp"
        return instanceType == v
    end

CONDITIONS["jump"] =
    function (cond, unit)
        if GetTime() - LM_Location.lastJumpTime < 2 then
            return true
        end
    end

CONDITIONS["map"] =
    function (cond, unit, v)
        if v:sub(1,1) == '*' then
            return LM_Location.uiMapID == tonumber(v:sub(2))
        else
            return LM_Location:MapInPath(tonumber(v))
        end
    end

CONDITIONS["mod"] =
     function (cond, unit, v)
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
    function (cond, unit)
        return IsMounted()
    end

CONDITIONS["moving"] =
    function (cond, unit)
        return IsFalling() or GetUnitSpeed("player") > 0
    end

CONDITIONS["name"] =
    function (cond, unit, v)
        if v then
            return UnitName(unit or "player") == v
        end
    end

CONDITIONS["outdoors"] =
    function (cond, unit)
        return IsOutdoors()
    end

CONDITIONS["party"] =
    function (cond, unit)
        return UnitPlayerOrPetInParty(unit or "target")
    end

CONDITIONS["pet"] =
    function (cond, unit, v)
        local petunit
        if not unit or unit == "player" then
            petunit = "pet"
        else
            petunit = unit .. "pet"
        end
        if v then
            return UnitName(petunit) == v or UnitCreatureFamily(petunit) == v
        else
             return UnitExists(petunit)
        end
    end

CONDITIONS["profession"] =
    function (cond, unit, v)
        if not v then return end
        local professions = { GetProfessions() }
        local n = tonumber(v)
        if n then
            return tContains(professions, n)
        else
            for _,id in ipairs(professions) do
                if GetProfessionInfo(id) == v then
                    return true
                end
            end
        end
    end

CONDITIONS["pvp"] =
    function (cond, unit)
        return UnitIsPVP(unit or "player")
    end

CONDITIONS["qfc"] =
    function (cond, unit, v)
        if v then
            v = tonumber(v)
            return v and IsQuestFlaggedCompleted(v)
        end
    end

CONDITIONS["race"] =
    function (cond, unit, v)
        local race, raceEN, raceID = UnitRace(unit or "player")
        return ( race == v or raceEN == v or raceID == tonumber(v) )
    end

CONDITIONS["raid"] =
    function (cond, unit)
        return UnitPlayerOrPetInRaid(unit or "target")
    end

CONDITIONS["random"] =
    function (cond, unit, n)
        return math.random(100) <= tonumber(n)
    end

CONDITIONS["realm"] =
    function (cond, unit, v)
        if v then
            return GetRealmName() == v
        end
    end

CONDITIONS["resting"] =
    function (cond, unit)
        return IsResting()
    end

CONDITIONS["role"] =
    function (cond, unit, v)
        if v then
            return UnitGroupRolesAssigned(unit or "player") == v
        end
    end

CONDITIONS["sameunit:args"] =
    function (cond, unit, unit1)
        if unit1 then
            return UnitIsUnit(unit1, unit or "player")
        end
    end

CONDITIONS["sex"] =
    function (cond, unit, v)
        if v then
            return UnitSex(unit or "player") == tonumber(v)
        end
    end

-- The difference between IsSwimming and IsSubmerged is that IsSubmerged
-- will also return true when you are standing on the bottom.  Note that
-- it sadly does not return false when you are floating on the top, that
-- is still counted as being submerged.

CONDITIONS["swimming"] =
    function (cond, unit)
        return IsSubmerged()
    end

CONDITIONS["shapeshift"] =
    function (cond, unit)
        return HasTempShapeshiftActionBar()
    end

CONDITIONS["spec"] =
    function (cond, unit, v)
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
    function (cond, unit)
        return IsStealthed()
    end

CONDITIONS["submerged"] =
    function (cond, unit)
        return (IsSubmerged() and not LM_Location:IsFloating())
    end

CONDITIONS["talent:args"] =
    function (cond, unit, tier, talent)
        return select(2, GetTalentTierInfo(tier, 1)) == tonumber(talent)
    end

CONDITIONS["tracking"] =
    function (cond, unit, v)
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
    function (cond, unit)
        return true
    end

CONDITIONS["waterwalking"] =
    function (cond, unit)
        -- Anglers Waters Striders (168416) or Inflatable Mount Shoes (168417)
        if not C_MountJournal.AreMountEquipmentEffectsSuppressed() then
            local id = C_MountJournal.GetAppliedMountEquipmentID()
            if id == 168416 or id == 168417 then
                return true
            end
        end

        -- Water Walking (546)
        if PlayerHasAura(546) then
            return true
        end
        -- Elixir of Water Walking (11319)
        if PlayerHasAura(11319) then
            return true
        end
        --  Path of Frost (3714)
        if PlayerHasAura(3714) then
            return true
        end
    end

CONDITIONS["xmog:args"] =
    function (cond, unit, slotID, appearanceID)
        slotID, appearanceID = tonumber(slotID), tonumber(appearanceID)
        local ok, _, _, _, current = pcall(C_Transmog.GetSlotVisualInfo, slotID, LE_TRANSMOG_TYPE_APPEARANCE)
        return ok and current == appearanceID
    end

local function any(f, cond, unit, ...)
    local n = select('#', ...)
    for i = 1, n do
        local v = select(i, ...)
        if f(cond, unit, v) then return true end
    end
    return false
end


_G.LM_Conditions = { }

function LM_Conditions:IsTrue(condition, unit)
    local str = condition[1]

    if condition.vars then
        str = LM_Vars:StrSubVars(str)
    end

    local newunit = str:match('^@(.+)')
    if newunit then return true, newunit end

    local cond, valuestr = strsplit(':', str)

    -- Empty condition [] is true
    if cond == "" then return true, unit end

    local values
    if valuestr then
        values = { strsplit('/', valuestr) }
    else
        values = { }
    end

    local handler = CONDITIONS[cond..":args"]
    if handler then
        return handler(condition, unit, unpack(values))
    end

    handler = CONDITIONS[cond]
    if handler then
        if #values == 0 then
            return handler(condition, unit)
        else
            return any(handler, condition, unit, unpack(values))
        end
    end

    LM_WarningAndPrint(format(L.LM_ERR_BAD_CONDITION, cond))
    return false
end

function LM_Conditions:EvalNot(conditions, unit)
    local v
    v, unit = self:Eval(conditions[1], unit)
    return not v, unit
end

-- the ANDed sections carry the unit between them as well as returning it
function LM_Conditions:EvalAnd(conditions, unit)
    for _,e in ipairs(conditions) do
        local v, u = self:Eval(e, unit)
        if not v then return false end
        unit = u or unit
    end
    return true, unit
end

function LM_Conditions:EvalOr(conditions, unit)
    -- Note: deliberately resets the unit
    for _,e in ipairs(conditions) do
        local v, u = self:Eval(e, nil)
        if v then return v, u end
    end
    return false
end

-- outer grouping is ORed together
function LM_Conditions:Eval(conditions, unit)
    if not conditions or conditions[1] == nil then return true, unit end

    if conditions.op == "OR" then
        return self:EvalOr(conditions, unit)
    elseif conditions.op == "AND" then
        return self:EvalAnd(conditions, unit)
    elseif conditions.op == "NOT" then
        return self:EvalNot(conditions, unit)
    else
        return self:IsTrue(conditions, unit)
    end
end

-- Parsing is slow so we don't want to do it a million times
local cachedConditions = {}

function LM_Conditions:Check(line)
    if not line then return end

    local _, cond
    if not cachedConditions[line] then
        _, _, cond = LM_ActionList:ParseActionLine('DUMMY ' .. line)
        cachedConditions[line] = { cond }
    end

    return self:Eval(cachedConditions[line][1])
end
