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
-- ".args" functions take a fixed set of arguments rather using / for OR

local CONDITIONS = { }

CONDITIONS["achievement"] = {
    -- name = BATTLE_PET_SOURCE_6,
    handler =
        function (cond, env, v)
            return select(4, GetAchievementInfo(tonumber(v or 0)))
        end
}

CONDITIONS["aura"] = {
    -- name = L["Aura"],
    handler =
        function (cond, env, v)
            local unit = env.unit or "player"
            if LM.UnitAura(unit, v) or LM.UnitAura(unit, v, "HARMFUL") then
                return true
            end
        end,
}

CONDITIONS["breathbar"] = {
    handler =
        function (cond, env)
            local name, _, _, rate = GetMirrorTimerInfo(2)
            return (name == "BREATH" and rate < 0)
        end
}

CONDITIONS["canexitvehicle"] = {
    handler =
        function (cond, env)
            return CanExitVehicle()
        end
}

CONDITIONS["channeling"] = {
    -- name = CHANNELING,
    handler =
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
}

CONDITIONS["class"] = {
    name = CLASS,
    tostring =
        function (v)
            if v then
                return LOCALIZED_CLASS_NAMES_FEMALE[v]
            end
        end,
    menu = {
        { val = "class:" .. select(2, GetClassInfo(1)) },
        { val = "class:" .. select(2, GetClassInfo(2)) },
        { val = "class:" .. select(2, GetClassInfo(3)) },
        { val = "class:" .. select(2, GetClassInfo(4)) },
        { val = "class:" .. select(2, GetClassInfo(5)) },
        { val = "class:" .. select(2, GetClassInfo(6)) },
        { val = "class:" .. select(2, GetClassInfo(7)) },
        { val = "class:" .. select(2, GetClassInfo(8)) },
        { val = "class:" .. select(2, GetClassInfo(9)) },
        { val = "class:" .. select(2, GetClassInfo(10)) },
        { val = "class:" .. select(2, GetClassInfo(11)) },
        { val = "class:" .. select(2, GetClassInfo(12)) },
    },
    handler =
        function (cond, env, v)
            if v then
                return tContains({ UnitClass(env.unit or "player") }, v)
            end
        end,
}

-- This can never work, but included for completeness.
CONDITIONS["combat"] = {
    -- name = GARRISON_LANDING_STATUS_MISSION_COMBAT,
    handler =
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
}

CONDITIONS["covenant"] = {
    -- name = L["Covenant"],
    tostring =
        function (v)
            local info = C_Covenants.GetCovenantData(tonumber(v))
            if info then return info.name end
        end,
    menu =
        function ()
            local out = {}
            for _,id in ipairs(C_Covenants.GetCovenantIDs()) do
                table.insert(out, { val = "covenant:" .. id })
            end
            return out
        end,
    handler =
        function (cond, env, v)
            if not C_Covenants or not v then return end
            local id = C_Covenants.GetActiveCovenantID() -- 0 for none
            if not id then return end
            if tonumber(v) == id then return true end
            local data = C_Covenants.GetCovenantData(id)
            if data and data.name == v then return true end
        end
}

--- Note that this diverges from the macro [dead] defaults to "target".
CONDITIONS["dead"] = {
    -- name = DEAD,
    handler =
        function (cond, env)
            return UnitIsDead(env.unit or "player")
        end
}

-- https://wow.gamepedia.com/DifficultyID
CONDITIONS["difficulty"] = {
    --[[
    name = DUNGEON_DIFFICULTY,
    tostring =
        function (v)
            if tonumber(v) then
                return DifficultyUtil.GetDifficultyName(tonumber(v))
            else
                return v
            end
        end,
    menu =
        function ()
            local names = {}
            for _, id  in pairs(DifficultyUtil.ID) do
                names[DifficultyUtil.GetDifficultyName(id)] = true
            end
            local out = {}
            for name in pairs(names) do
                table.insert(out, { val = "difficulty:" .. name })
            end
            return out
        end,
    ]]
    handler =
        function (cond, env, v)
            if v then
                local id, name = select(3, GetInstanceInfo())
                if id == tonumber(v) or name == v then
                    return true
                end
            end
        end
}

-- Persistent "deck of cards" draw randomness

CONDITIONS["draw"] = {
    handler =
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
}

CONDITIONS["elapsed"] = {
    handler =
        function (cond, env, v)
            v = tonumber(v)
            if v then
                if time() - (cond.elapsed or 0) >= v then
                    cond.elapsed = time()
                    return true
                end
            end
        end
}

CONDITIONS["equipped"] = {
    handler =
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
}

CONDITIONS["exists"] = {
    handler =
        function (cond, env)
            return UnitExists(env.unit or "target")
        end
}

-- Check for an extraactionbutton, optionally with a specific spell
CONDITIONS["extra"] = {
    handler =
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
}

CONDITIONS["faction"] = {
    name = FACTION,
    tostring =
        function (v)
            if v and PLAYER_FACTION_GROUP[v] then
                return FACTION_LABELS[PLAYER_FACTION_GROUP[v]]
            end
        end,
    menu =
        function ()
            return {
                { val = "faction:" .. PLAYER_FACTION_GROUP[0] },
                { val = "faction:" .. PLAYER_FACTION_GROUP[1] },
            }
        end,
    handler =
        function (cond, env, v)
            if v then
                return tContains({ UnitFactionGroup(env.unit or "player") }, v)
            end
        end,
}

CONDITIONS["falling"] = {
    -- name = STRING_ENVIRONMENTAL_DAMAGE_FALLING,
    handler =
        function (cond, env)
            return LM.Environment:IsFalling()
        end
}

CONDITIONS["false"] = {
    -- name = NEVER,
    handler =
        function (cond, env)
            return false
        end
}

CONDITIONS["floating"] = {
    handler =
        function (cond, env)
            return LM.Environment:IsFloating()
        end
}

CONDITIONS["flyable"] = {
    L.LM_FLYABLE_AREA,
    name = L["Flyable area"],
    handler =
        function (cond, env)
            return LM.Environment:CanFly()
        end,
}

CONDITIONS["flying"] = {
    handler =
        function (cond, env)
            return IsFlying()
        end
}

CONDITIONS["form"] = {
    handler =
        function (cond, env, v)
            if v == "slow" then
                return LM.Environment:IsCombatTravelForm()
            elseif v then
                return GetShapeshiftForm() == tonumber(v)
            else
                return GetShapeshiftForm() > 0
            end
        end
}

CONDITIONS["group"] = {
    name = L.LM_PARTY_OR_RAID_GROUP,
    handler =
        function (cond, env, groupType)
            if not groupType then
                return IsInGroup() or IsInRaid()
            elseif groupType == "raid" then
                return IsInRaid()
            elseif groupType == "party" then
                return IsInGroup()
            end
        end
}

CONDITIONS["harm"] = {
    handler =
        function (cond, env)
            return not UnitIsFriend("player", env.unit or "target")
        end
}

CONDITIONS["help"] = {
    handler =
        function (cond, env)
            return UnitIsFriend("player", env.unit or "target")
        end
}

CONDITIONS["indoors"] = {
    handler =
        function (cond, env)
            return IsIndoors()
        end
}

CONDITIONS["instance"] = {
    name = INSTANCE,
    tostring =
        function (v)
            local n = LM.Options:GetInstanceNameByID(tonumber(v))
            if n then
                return string.format("%s (%s)", n, v)
            end
        end,
    menu =
        function ()
            local out = { }
            for id, name in pairs(LM.Environment:GetInstances()) do
                table.insert(out, { val = "instance:" .. id })
            end
            return out
        end,
    handler =
        function (cond, env, v)
            if not v then
                return IsInInstance()
            end

            local instanceName, instanceType, _, _, _, _, _, instanceID = GetInstanceInfo()

            if instanceName == v or instanceID == tonumber(v) then
                return true
            end

            -- "none", "scenario", "party", "raid", "arena", "pvp"
            return instanceType == v
        end,
}

CONDITIONS["jump"] = {
    handler =
        function (cond, env)
            local jumpTime = LM.Environment:GetJumpTime()
            return ( jumpTime and jumpTime < 2 )
        end
}

CONDITIONS["keybind"] = {
    handler =
        function (cond, env, v)
            if v then
                return env.id == tonumber(v)
            end
        end
}

CONDITIONS["location"] = {
--  name = LOCATION_COLON:gsub(":", ""),
    tostring =
        function (v)
            return v
        end,
    handler =
        function (cond, env, v)
            local mapID = C_Map.GetBestMapForUnit('player')
            if C_Map.GetMapInfo(mapID).name == v then
                return true
            end
            if GetInstanceInfo() == v then
                return true
            end
        end,
}

local function MapTreeToMenu(node)
    local out = { val = "map:" .. node.mapID, nosort = true }
    for _, n in ipairs(node) do table.insert(out, MapTreeToMenu(n)) end
    return out
end

CONDITIONS["map"] = {
    name = WORLD_MAP,
    tostring =
        function (v)
            local info = C_Map.GetMapInfo(tonumber(v))
            if info then return string.format("%s (%s)", info.name, info.mapID) end
        end,
    menu =
        function ()
            return MapTreeToMenu(LM.Environment:GetMapTree())
        end,
    handler =
        function (cond, env, v)
            if v:sub(1,1) == '*' then
                return LM.Environment:IsOnMap(tonumber(v:sub(2)))
            else
                return LM.Environment:IsMapInPath(tonumber(v))
            end
        end,
}

CONDITIONS["maw"] = {
    handler =
        function (cond, env, v)
            return LM.Environment:IsTheMaw()
        end
}

CONDITIONS["mod"] = {
    name = L.LM_MODIFIER_KEY,
    tostring =
        function (v)
            if v == "alt" then
                return ALT_KEY_TEXT
            elseif v == "ctrl" then
                return CTRL_KEY_TEXT
            elseif v == "shift" then
                return SHIFT_KEY_TEXT
            elseif not v then
                return CLUB_FINDER_ANY_FLAG
            end
        end,
    menu = {
        nosort = true,
        { val = "mod" },
        { val = "mod:alt" },
        { val = "mod:ctrl" },
        { val = "mod:shift" },
    },
    handler =
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
        end,
}

CONDITIONS["mounted"] = {
    handler =
        function (cond, env)
            return IsMounted()
        end
}

CONDITIONS["click"] = {
    handler =
        function (cond, env, v)
            if v and env.clickArg == v then
                return true
            end
        end
}

CONDITIONS["moving"] = {
    handler =
        function (cond, env)
            return LM.Environment:IsMovingOrFalling()
        end
}

CONDITIONS["name"] = {
    handler =
        function (cond, env, v)
            if v then
                return UnitName(env.unit or "player") == v
            end
        end
}

CONDITIONS["outdoors"] = {
    handler =
        function (cond, env)
            return IsOutdoors()
        end
}

CONDITIONS["playermodel"] = {
    handler =
        function (cond, env, v)
            if v then
                return LM.Environment:GetPlayerModel() == tonumber(v)
            end
        end
}

CONDITIONS["party"] = {
    handler =
        function (cond, env)
            return UnitPlayerOrPetInParty(env.unit or "target")
        end
}

CONDITIONS["pet"] = {
    handler =
        function (cond, env, v)
            local petunit
            if not env.unit or env.unit == "player" then
                petunit = "pet"
            else
                petunit = env.unit .. "pet"
            end
            if v then
                return UnitName(petunit) == v or UnitCreatureFamily(petunit) == v
            else
                 return UnitExists(petunit)
            end
        end
}

CONDITIONS["profession"] = {
    handler =
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
}

CONDITIONS["pvp"] = {
    name = PVP,
    handler =
        function (cond, env, v)
            if not v then
                return UnitIsPVP(env.unit or "player")
            else
                return GetZonePVPInfo() == v
            end
        end
}

CONDITIONS["qfc"] = {
    handler =
        function (cond, env, v)
            if v then
                v = tonumber(v)
                return v and C_QuestLog.IsQuestFlaggedCompleted(v)
            end
        end
}

CONDITIONS["race"] = {
    handler =
        function (cond, env, v)
            local race, raceEN, raceID = UnitRace(env.unit or "player")
            return ( race == v or raceEN == v or raceID == tonumber(v) )
        end
}

CONDITIONS["raid"] = {
    handler =
        function (cond, env)
            return UnitPlayerOrPetInRaid(env.unit or "target")
        end
}

CONDITIONS["random"] = {
    handler =
        function (cond, env, n)
            return math.random(100) <= tonumber(n)
        end
}

CONDITIONS["realm"] = {
    handler =
        function (cond, env, v)
            if v then
                return GetRealmName() == v
            end
        end
}

CONDITIONS["resting"] = {
    name = TUTORIAL_TITLE30,
    handler =
        function (cond, env)
            return IsResting()
        end
}

CONDITIONS["role"] = {
    handler =
        function (cond, env, v)
            if v then
                return UnitGroupRolesAssigned(env.unit or "player") == v
            end
        end
}

CONDITIONS["sameunit"] = {
    handler =
        function (cond, env, v)
            if v then
                return UnitIsUnit(v, env.unit or "player")
            end
        end
}

CONDITIONS["sex"] = {
    name = L.LM_SEX,
    tostring =
        function (v)
            v = tonumber(v)
            if v == 2 then
                return MALE
            elseif v == 3 then
                return FEMALE
            else
                return UNKNOWN
            end
        end,
    menu = {
        { val = "sex:2" },
        { val = "sex:3" }
    },
    handler =
        function (cond, env, v)
            if v then
                return UnitSex(env.unit or "player") == tonumber(v)
            end
        end
}

-- The difference between IsSwimming and IsSubmerged is that IsSubmerged
-- will also return true when you are standing on the bottom.  Note that
-- it sadly does not return false when you are floating on the top, that
-- is still counted as being submerged.

CONDITIONS["swimming"] = {
    handler =
        function (cond, env)
            return IsSubmerged()
        end
}

CONDITIONS["shapeshift"] = {
    handler =
        function (cond, env)
            return HasTempShapeshiftActionBar()
        end
}

CONDITIONS["spec"] = {
    name = SPECIALIZATION,
    tostring =
        function (v)
            local _, name, _, _, _, _, class = GetSpecializationInfoByID(v)
            if name and name ~= "" then return class .. " : " .. name end
        end,
    menu =
        function ()
            local specs = {}
            for classIndex = 1, GetNumClasses() do
                local className = GetClassInfo(classIndex)
                local classMenu = { text = GetClassInfo(classIndex) }
                for specIndex = 1, 4 do
                    local id, name = GetSpecializationInfoForClassID(classIndex, specIndex)
                    if not id then break end
                    table.insert(classMenu, { val = string.format("spec:%d", id), text = name })
                end
                table.insert(specs, classMenu)
            end
            return specs
        end,
    handler =
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
}

CONDITIONS["stationary"] = {
    args = true,
    handler =
        function (cond, env, minv, maxv)
            minv = tonumber(minv)
            maxv = tonumber(maxv)
            local stationaryTime = LM.Environment:GetStationaryTime()
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
}

CONDITIONS["stealthed"] = {
    handler =
        function (cond, env)
            return IsStealthed()
        end
}

CONDITIONS["submerged"] = {
    name = TUTORIAL_TITLE28,
    handler =
        function (cond, env)
            return (IsSubmerged() and not LM.Environment:IsFloating())
        end,
}

CONDITIONS["talent"] = {
    args = true,
    handler =
        function (cond, env, tier, talent)
            return select(2, GetTalentTierInfo(tier, 1)) == tonumber(talent)
        end
}

CONDITIONS["tracking"] = {
    handler =
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
}

CONDITIONS["true"] = {
    handler =
        function (cond, env)
            return true
        end
}

CONDITIONS["waterwalking"] = {
    handler =
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
}

-- See WardrobeSetsTransmogMixin:GetFirstMatchingSetID

local function GetTransmogLocationSourceID(location)
    local baseSourceID, _, appliedSourceID = C_Transmog.GetSlotVisualInfo(location)
    if appliedSourceID == Constants.Transmog.NoTransmogID then
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
    for _, id in ipairs(C_TransmogCollection.GetOutfits()) do
        if name == C_TransmogCollection.GetOutfitInfo(id) then
            return id
        end
    end
end

local function IsTransmogSetActive(setID)
    if not C_TransmogSets.GetSetInfo(setID) then
        return false
    end
    for key, slotInfo in pairs(TRANSMOG_SLOTS) do
        if not slotInfo.location:IsSecondary() then
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

-- This makes me want to kill myself instantly.
-- See WardrobeOutfitDropDownMixin:IsOutfitDressed()

local function IsTransmogOutfitActive(outfitID)
    local outfitInfoList = C_TransmogCollection.GetOutfitItemTransmogInfoList(outfitID)
    if not outfitInfoList then return end

    local currentInfoList = LM.Environment:GetPlayerTransmogInfo()
    if not currentInfoList then return end

    for slotID, info in ipairs(currentInfoList) do
        if info.appearanceID ~= Constants.Transmog.NoTransmogID then
            if not info:IsEqual(outfitInfoList[slotID]) then
                return false
            end
        end
    end
    return true
end

local function GetTransmogOutfitsMenu()
    local outfits = { text = L.LM_OUTFITS }
    for _, id in ipairs(C_TransmogCollection.GetOutfits()) do
        local name = C_TransmogCollection.GetOutfitInfo(id)
        table.insert(outfits, { val = "xmog:"..name, text = name })
    end
    return outfits
end

local function GetTransmogSetsMenu()
    LoadAddOn("Blizzard_EncounterJournal")
    local byExpansion = { }
    for _,info in ipairs(C_TransmogSets.GetUsableSets()) do
        local expansion = info.expansionID + 1
        if not byExpansion[expansion] then
            local name = EJ_GetTierInfo(expansion) or NONE
            byExpansion[expansion] = { text = name }
        end
        table.insert(byExpansion[expansion], { val = "xmog:"..info.setID, text = info.name })
    end
    local sets = { nosort = true, text = WARDROBE_SETS }
    for _,t in LM.PairsByKeys(byExpansion) do
        table.insert(sets, t)
    end
    return sets
end

-- The args version of this takes slotid/appearanceid and really should be junked
-- now that the other form works. Well, if it reliably did. :(

CONDITIONS["xmog"] = {
    args = true,
    tostring =
        function (v)
            if tonumber(v) then
                local info = C_TransmogSets.GetSetInfo(v)
                if info then return
                    info.name
                else
                    return v
                end
            else
                return v
            end
        end,
    menu =
        function ()
            return { GetTransmogOutfitsMenu(), GetTransmogSetsMenu() }
        end,
    handler =
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
}

do
    for c, info in pairs(CONDITIONS) do
        info.condition = c
    end
end

--[[--------------------------------------------------------------------------]]--

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

    local c = CONDITIONS[cond]
    if not c then
        LM.WarningAndPrint(format(L.LM_ERR_BAD_CONDITION, cond))
        return false
    end

    if c.args then
        return c.handler(condition, env, unpack(values))
    elseif #values == 0 then
        return c.handler(condition, env)
    else
        return any(c.handler, condition, env, unpack(values))
    end
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

function LM.Conditions:GetCondition(cond)
    local c = CONDITIONS[cond]
    if c then return c end
end

function LM.Conditions:GetConditions()
    local out = { }
    for _, info in pairs(CONDITIONS) do
        if info.name then
            table.insert(out, info)
        end
    end
    table.sort(out, function (a, b) return a.name < b.name end)
    return out
end

local function FillMenuTexts(t)
    for _,item in ipairs(t) do
        item.text = item.text or LM.Conditions:ArgsToString(item.val)
        FillMenuTexts(item)
    end
    if not t.nosort then
        table.sort(t, function (a,b) return a.text < b.text end)
    end
    return t
end

function LM.Conditions:ArgsMenu(cond)
    local c = CONDITIONS[cond]
    if not c then return end
    if type(c.menu) == 'table' then
        return FillMenuTexts(c.menu)
    elseif type(c.menu) == 'function' then
        return FillMenuTexts(c.menu())
    end
end

function LM.Conditions:ToString(text)
    local cond, valuestr = strsplit(':', text)
    local c = CONDITIONS[cond]
    if c then return c.name or ADVANCED_LABEL end
end

function LM.Conditions:ArgsToString(text)
    local cond, valuestr = strsplit(':', text)

    local c = CONDITIONS[cond]
    if not c then return end

    if not c.name then return text end
    if not c.tostring then return end

    local values
    if valuestr then
        values = { strsplit('/', valuestr) }
    else
        values = { }
    end

    local argText
    if c.args then
        argText = c.tostring(unpack(values))
    elseif #values == 0 then
        argText = c.tostring()
    else
        argText = table.concat(LM.tMap(values, c.tostring, values), " ")
    end
    return argText
end

-- I regret not turning conditions into a proper parse tree about now

local function SquareBracket(txt) return '[' .. txt .. ']' end

local function ToLineRecursive(c)
    if type(c) == 'table' then
        if c.op == 'NOT' then return 'no' .. c[1] end
        local children = LM.tMap(c, ToLineRecursive)
        if c.op == 'AND' then
            return SquareBracket(table.concat(children, ','))
        elseif c.op == 'OR' then
            return table.concat(LM.tMap(children, SquareBracket), '')
        end
    else
        return c
    end
end

function LM.Conditions:ToLine(conditions)
    return ToLineRecursive(conditions)
end
