--[[----------------------------------------------------------------------------

  LiteMount/Conditions.lua

  Parser/evaluator for action conditions.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local L = LM.Localize

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
-- ":args" functions take a fixed set of arguments rather using / for OR

local CONDITIONS = { }

CONDITIONS["achievement"] =
    function (cond, env, v)
        return select(4, GetAchievementInfo(tonumber(v or 0)))
    end

CONDITIONS["aura"] =
    function (cond, env, v)
        local unit = env.unit or "player"
        if LM.UnitAura(unit, v) or LM.UnitAura(unit, v, "HARMFUL") then
            return true
        end
    end

CONDITIONS["breathbar"] =
    function (cond, env)
        local name, _, _, rate = GetMirrorTimerInfo(2)
        return (name == "BREATH" and rate < 0)
    end

CONDITIONS["canexitvehicle"] =
    function (cond, env)
        return CanExitVehicle()
    end

CONDITIONS["channeling"] =
    function (cond, env, v)
        local unit = env.unit or "player"
        if not v then
            return UnitChannelInfo(unit) ~= nil
        elseif tonumber(v) then
            return select(8, UnitChannelInfo(unit)) == tonumber(v)
        else
            return UnitChannelInfo(unit) == v
        end
    end

CONDITIONS["class"] =
    function (cond, env, v)
        if v then
            return tContains({ UnitClass(env.unit or "player") }, v)
        end
    end

-- This can never work, but included for completeness
CONDITIONS["combat"] =
    function (cond, env)
        local unit, petunit
        if not env.unit then
            unit, petunit = "player", "pet"
        elseif env.unit == "player" then
            petunit = "pet"
        else
            unit = env.unit
            petunit = env.unit .. "pet"
        end
        return UnitAffectingCombat(unit) or UnitAffectingCombat(petunit)
    end

CONDITIONS["covenant"] =
    function (cond, env, v)
        if not C_Covenants or not v then return end
        local id = C_Covenants.GetActiveCovenantID()
        if not id then return end
        if tonumber(v) == id then return true end
        local data = C_Covenants.GetCovenantData(id)
        if data.name == v then return true end
    end

--- Note that this diverges from the macro [dead] defaults to "target".
CONDITIONS["dead"] =
    function (cond, env)
        return UnitIsDead(env.unit or "player")
    end

-- https://wow.gamepedia.com/DifficultyID
CONDITIONS["difficulty"] =
    function (cond, env, v)
        if v then
            local id, name = select(3, GetInstanceInfo())
            if id == tonumber(v) or name == v then
                return true
            end
        end
    end

-- Persistent "deck of cards" draw randomness

CONDITIONS["draw:args"] =
    function (cond, env, x, y)
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

CONDITIONS["elapsed"] =
    function (cond, env, v)
        v = tonumber(v)
        if v then
            if time() - (cond.elapsed or 0) >= v then
                cond.elapsed = time()
                return true
            end
        end
    end

CONDITIONS["equipped"] =
    function (cond, env, v)
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
    function (cond, env)
        return UnitExists(env.unit or "target")
    end

-- Check for an extraactionbutton, optionally with a specific spell
CONDITIONS["extra"] =
    function (cond, env, v)
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
    function (cond, env, v)
        if v then
            return tContains({ UnitFactionGroup(env.unit or "player") }, v)
        end
    end

CONDITIONS["falling"] =
    function (cond, env)
        return LM.Environment:IsFalling()
    end

CONDITIONS["false"] =
    function (cond, env)
        return false
    end

CONDITIONS["floating"] =
    function (cond, env)
        return LM.Environment:IsFloating()
    end

CONDITIONS["flyable"] =
    function (cond, env)
        return LM.Environment:CanFly()
    end

CONDITIONS["flying"] =
    function (cond, env)
        return IsFlying()
    end

CONDITIONS["form"] =
    function (cond, env, v)
        if v == "slow" then
            return LM.Environment.combatTravelForm
        elseif v then
            return GetShapeshiftForm() == tonumber(v)
        else
            return GetShapeshiftForm() > 0
        end
    end

CONDITIONS["group"] =
    function (cond, env, groupType)
        if not groupType then
            return IsInGroup() or IsInRaid()
        elseif groupType == "raid" then
            return IsInRaid()
        elseif groupType == "party" then
            return IsInGroup()
        end
    end

CONDITIONS["harm"] =
    function (cond, env)
        return not UnitIsFriend("player", env.unit or "target")
    end

CONDITIONS["help"] =
    function (cond, env)
        return UnitIsFriend("player", env.unit or "target")
    end

CONDITIONS["indoors"] =
    function (cond, env)
        return IsIndoors()
    end

CONDITIONS["instance"] =
    function (cond, env, v)
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
    function (cond, env)
        local jumpTime = LM.Environment:JumpTime()
        return ( jumpTime and jumpTime < 2 )
    end

CONDITIONS["keybind"] =
    function (cond, env, v)
        if v then
            return env.id == tonumber(v)
        end
    end

CONDITIONS["location"] =
    function (cond, env, v)
        if LM.Environment.uiMapName == v then return true end
        if LM.Environment.instanceName == v then return true end
    end

CONDITIONS["map"] =
    function (cond, env, v)
        if v:sub(1,1) == '*' then
            return LM.Environment.uiMapID == tonumber(v:sub(2))
        else
            return LM.Environment:MapInPath(tonumber(v))
        end
    end

CONDITIONS["maw"] =
    function (cond, env, v)
        return LM.Environment:TheMaw()
    end

CONDITIONS["mod"] =
     function (cond, env, v)
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
    function (cond, env)
        return IsMounted()
    end

CONDITIONS["moving"] =
    function (cond, env)
        return LM.Environment:IsMovingOrFalling()
    end

CONDITIONS["name"] =
    function (cond, env, v)
        if v then
            return UnitName(env.unit or "player") == v
        end
    end

CONDITIONS["outdoors"] =
    function (cond, env)
        return IsOutdoors()
    end

CONDITIONS["playermodel"] =
    function (cond, env, v)
        if v then
            return LM.Environment:GetPlayerModel() == tonumber(v)
        end
    end

CONDITIONS["party"] =
    function (cond, env)
        return UnitPlayerOrPetInParty(env.unit or "target")
    end

CONDITIONS["pet"] =
    function (cond, env, v)
        local petunit
        if not env.unit or env.unit == "player" then
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
    function (cond, env, v)
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
    function (cond, env, v)
        if not v then
            return UnitIsPVP(env.unit or "player")
        else
            return GetZonePVPInfo() == v
        end
    end

CONDITIONS["qfc"] =
    function (cond, env, v)
        if v then
            v = tonumber(v)
            return v and C_QuestLog.IsQuestFlaggedCompleted(v)
        end
    end

CONDITIONS["race"] =
    function (cond, env, v)
        local race, raceEN, raceID = UnitRace(env.unit or "player")
        return ( race == v or raceEN == v or raceID == tonumber(v) )
    end

CONDITIONS["raid"] =
    function (cond, env)
        return UnitPlayerOrPetInRaid(env.unit or "target")
    end

CONDITIONS["random"] =
    function (cond, env, n)
        return math.random(100) <= tonumber(n)
    end

CONDITIONS["realm"] =
    function (cond, env, v)
        if v then
            return GetRealmName() == v
        end
    end

CONDITIONS["resting"] =
    function (cond, env)
        return IsResting()
    end

CONDITIONS["role"] =
    function (cond, env, v)
        if v then
            return UnitGroupRolesAssigned(env.unit or "player") == v
        end
    end

CONDITIONS["sameunit:args"] =
    function (cond, env, unit1)
        if unit1 then
            return UnitIsUnit(unit1, env.unit or "player")
        end
    end

CONDITIONS["sex"] =
    function (cond, env, v)
        if v then
            return UnitSex(env.unit or "player") == tonumber(v)
        end
    end

-- The difference between IsSwimming and IsSubmerged is that IsSubmerged
-- will also return true when you are standing on the bottom.  Note that
-- it sadly does not return false when you are floating on the top, that
-- is still counted as being submerged.

CONDITIONS["swimming"] =
    function (cond, env)
        return IsSubmerged()
    end

CONDITIONS["shapeshift"] =
    function (cond, env)
        return HasTempShapeshiftActionBar()
    end

CONDITIONS["spec"] =
    function (cond, env, v)
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

CONDITIONS["stationary:args"] =
    function (cond, env, minv, maxv)
        minv = tonumber(minv)
        maxv = tonumber(maxv)
        local stationaryTime = LM.Environment:StationaryTime()
        if stationaryTime then
            if stationaryTime < ( minv or 0 ) then
                return false
            elseif maxv then
                return ( stationaryTime <= maxv )
            else
                return true
            end
        end
    end

CONDITIONS["stealthed"] =
    function (cond, env)
        return IsStealthed()
    end

CONDITIONS["submerged"] =
    function (cond, env)
        return (IsSubmerged() and not LM.Environment:IsFloating())
    end

CONDITIONS["talent:args"] =
    function (cond, env, tier, talent)
        return select(2, GetTalentTierInfo(tier, 1)) == tonumber(talent)
    end

CONDITIONS["tracking"] =
    function (cond, env, v)
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
    function (cond, env)
        return true
    end

CONDITIONS["waterwalking"] =
    function (cond, env)
        -- Anglers Waters Striders (168416) or Inflatable Mount Shoes (168417)
        if not C_MountJournal.AreMountEquipmentEffectsSuppressed() then
            local id = C_MountJournal.GetAppliedMountEquipmentID()
            if id == 168416 or id == 168417 then
                return true
            end
        end

        -- Water Walking (546)
        if LM.UnitAura('player', 546) then
            return true
        end
        -- Elixir of Water Walking (11319)
        if LM.UnitAura('player', 11319) then
            return true
        end
        --  Path of Frost (3714)
        if LM.UnitAura('player', 3714) then
            return true
        end
    end

-- See WardrobeSetsTransmogMixin:GetFirstMatchingSetID

local function GetTransmogLocationSourceID(location)
    local baseSourceID, _, appliedSourceID = C_Transmog.GetSlotVisualInfo(location)
    if appliedSourceID == 0 then
        return baseSourceID
    else
        return appliedSourceID
    end
end

local function GetTransmogSetIDByName(name)
    local usableSets = C_TransmogSets.GetUsableSets()
    for _,info in ipairs(usableSets) do
        if info.name == name then
            return info.setID
        end
    end
end

local function GetTransmogOutfitIDByName(name)
    local outfits = C_TransmogCollection.GetOutfits()
    for id, info in ipairs(outfits) do
        if info.name == name then
            return info.outfitID
        end
    end
end

local function IsTransmogSetActive(setID)
    if not C_TransmogSets.GetSetInfo(setID) then
        return false
    end
    for key, slotInfo in pairs(TRANSMOG_SLOTS) do
        if slotInfo.location:IsAppearance() then
            local sourceIDs = C_TransmogSets.GetSourceIDsForSlot(setID, slotInfo.location.slotID)
            if #sourceIDs > 0 then
                local activeSourceID = GetTransmogLocationSourceID(slotInfo.location)
                if not tContains(sourceIDs, activeSourceID) then
                    return false
                end
            end
        end
    end
    return true
end

local function IsTransmogOutfitActive(outfitID)
    local sourceIDs = C_TransmogCollection.GetOutfitSources(outfitID)
    if not sourceIDs then
        return false
    end
    for key, slotInfo in pairs(TRANSMOG_SLOTS) do
        if slotInfo.location:IsAppearance() then
            local sourceID = sourceIDs[slotInfo.location.slotID]
            if sourceID ~= NO_TRANSMOG_SOURCE_ID then
                local activeSourceID = GetTransmogLocationSourceID(slotInfo.location)
                if activeSourceID ~= sourceID then
                    return false
                end
            end
        end
    end
    return true
end

-- The :args version of this takes slotid/appearanceid and really should be junked
-- now that the other form works.

CONDITIONS["xmog:args"] =
    function (cond, env, arg1, arg2)
        if arg2 then
            local slotID, appearanceID = tonumber(arg1), tonumber(arg2)
            local tmSlot = TRANSMOG_SLOTS[(slotID or 0) * 100]
            if tmSlot then
                local ok, _, _, _, current = pcall(C_Transmog.GetSlotVisualInfo, tmSlot.location)
                return ok and current == appearanceID
            end
        else
            local setID = tonumber(arg1) or GetTransmogSetIDByName(arg1)
            if setID then
                return IsTransmogSetActive(setID)
            end
            local outfitID = GetTransmogOutfitIDByName(arg1)
            if outfitID then
                return IsTransmogOutfitActive(outfitID)
            end
        end
    end

local function any(f, cond, env, ...)
    local n = select('#', ...)
    for i = 1, n do
        local v = select(i, ...)
        if f(cond, env, v) then return true end
    end
    return false
end


LM.Conditions = { }

function LM.Conditions:IsTrue(condition, env, vars)
    if vars then
        condition = LM.Vars:StrSubVars(condition)
    end

    local newunit = condition:match('^@(.+)')
    if newunit then
        env.unit = newunit
        return true
    end

    local cond, valuestr = strsplit(':', condition)

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
        return handler(condition, env, unpack(values))
    end

    handler = CONDITIONS[cond]
    if handler then
        if #values == 0 then
            return handler(condition, env)
        else
            return any(handler, condition, env, unpack(values))
        end
    end

    LM.WarningAndPrint(format(L.LM_ERR_BAD_CONDITION, cond))
    return false
end

function LM.Conditions:EvalNot(conditions, env, vars)
    local v = self:Eval(conditions[1], env, vars)
    return not v
end

-- the ANDed sections carry the unit between them
function LM.Conditions:EvalAnd(conditions, env, vars)
    for _,e in ipairs(conditions) do
        local v = self:Eval(e, env, vars)
        if not v then return false end
    end
    return true
end

-- Note: deliberately resets the unit on false
function LM.Conditions:EvalOr(conditions, env, vars)
    for _,e in ipairs(conditions) do
        local v = self:Eval(e, env, vars)
        if v then return v end
        env.unit = nil
    end
    return false
end

-- outer grouping is ORed together
function LM.Conditions:Eval(conditions, env, vars)
    if not conditions then return true end

    if type(conditions) == 'table' then
        if conditions.op == "NOT" then
            return self:EvalNot(conditions, env, vars)
        elseif conditions.op == "AND" then
            return self:EvalAnd(conditions, env, vars)
        else
            return self:EvalOr(conditions, env, vars)
        end
    else
        return self:IsTrue(conditions, env, vars)
    end
end

function LM.Conditions:Check(checks, env)
    local conditions = { op = "AND" }
    for _, check in ipairs(checks) do
        table.insert(conditions, { check })
    end
    return self:Eval(conditions, env or {})
end

function LM.Conditions:Validate(text)
    return CONDITIONS[text] ~= nil or CONDITIONS[text..':args'] ~= nil
end
