--[[----------------------------------------------------------------------------

  LiteMount/Conditions.lua

  Parser/evaluator for action conditions.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local L = LM.Localize

local ANY_TEXT = CLUB_FINDER_ANY_FLAG or SPELL_TARGET_TYPE1_DESC:upper()

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

local function IterateGroupUnits()
   local unit, numMembers
   if IsInRaid() then
      unit, numMembers = 'raid', GetNumGroupMembers()
   else
      unit, numMembers = 'party', GetNumSubgroupMembers()
   end
   local i = 0
   return function ()
      i = i + 1
      if i <= numMembers then
         return unit..i
      end
   end
end

-- If any condition starts with "no" we're screwed
-- ".args" functions take a fixed set of arguments rather using / for OR

local CONDITIONS = { }

CONDITIONS["achievement"] = {
    -- name = BATTLE_PET_SOURCE_6,
    handler =
        function (cond, context, v)
            return select(4, GetAchievementInfo(tonumber(v or 0)))
        end
}

CONDITIONS["advflyable"] = {
    disabled = ( IsAdvancedFlyableArea == nil ),
    handler =
        function (cond, context)
            return IsAdvancedFlyableArea and IsAdvancedFlyableArea()
        end,
}

CONDITIONS["aura"] = {
    -- name = L["Aura"],
    handler =
        function (cond, context, v)
            local unit = context.unit or "player"
            if LM.UnitAura(unit, v) or LM.UnitAura(unit, v, "HARMFUL") then
                return true
            end
        end,
}

CONDITIONS["breathbar"] = {
    handler =
        function (cond, context)
            local name, _, _, rate = GetMirrorTimerInfo(2)
            return (name == "BREATH" and rate < 0)
        end
}

CONDITIONS["canexitvehicle"] = {
    handler =
        function (cond, context)
            return CanExitVehicle()
        end
}

CONDITIONS["channeling"] = {
    -- name = CHANNELING,
    handler =
        function (cond, context, v)
            local unit = context.unit or "player"
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
    toDisplay =
        function (v)
            if v then
                return LOCALIZED_CLASS_NAMES_FEMALE[v]
            end
        end,
    menu = function ()
        local out = { }
        for _, v in ipairs(CLASS_SORT_ORDER) do
            table.insert(out, { val = "class:" .. v})
        end
        return out
    end,
    handler =
        function (cond, context, v)
            if v then
                return tContains({ UnitClass(context.unit or "player") }, v)
            end
        end,
}

CONDITIONS["click"] = {
    handler =
        function (cond, context, v)
            if v and context.inputButton == v then
                return true
            end
        end
}

-- This can never work, but included for completeness.
CONDITIONS["combat"] = {
    -- name = GARRISON_LANDING_STATUS_MISSION_COMBAT,
    handler =
        function (cond, context)
            local unit, petunit
            if not context.unit then
                unit, petunit = "player", "pet"
            elseif context.unit == "player" then
                petunit = "pet"
            else
                unit = context.unit
                petunit = context.unit .. "pet"
            end
            return UnitAffectingCombat(unit) or UnitAffectingCombat(petunit)
        end
}

CONDITIONS["covenant"] = {
    name = L.LM_COVENANT,
    disabled = ( C_Covenants == nil ),
    toDisplay =
        function (v)
            local id = tonumber(v)
            if id then
                if id == 0 then return NONE end
                local info = C_Covenants.GetCovenantData(id)
                if info then return info.name end
            end
            return v
        end,
    menu =
        function ()
            local out = { nosort=true, { val = "covenant:0" } }
            for _,id in ipairs(C_Covenants.GetCovenantIDs()) do
                table.insert(out, { val = "covenant:" .. id })
            end
            return out
        end,
    handler =
        function (cond, context, v)
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
        function (cond, context)
            return UnitIsDead(context.unit or "player")
        end
}

-- https://wow.gamepedia.com/DifficultyID
CONDITIONS["difficulty"] = {
    --[[
    name = DUNGEON_DIFFICULTY,
    toDisplay =
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
        function (cond, context, v)
            if v then
                local id, name = select(3, GetInstanceInfo())
                if id == tonumber(v) or name == v then
                    return true
                end
            end
        end
}

CONDITIONS["dragonridable"] = {
    name = L.LM_DRAGONRIDING_AREA,
    disabled = ( IsAdvancedFlyableArea == nil ),
    handler =
        function (cond, context)
            return LM.Environment:CanDragonride(context.mapPath)
        end,
}

CONDITIONS["dragonriding"] = {
    -- name = MOUNT_JOURNAL_FILTER_DRAGONRIDING,
    disabled = ( IsAdvancedFlyableArea == nil ),
    handler =
        function (cond, context)
            return LM.Environment:IsDragonriding()
        end,
}

-- Persistent "deck of cards" draw randomness

CONDITIONS["draw"] = {
    args = true,
    handler =
        function (cond, context, x, y)
            x, y = tonumber(x), tonumber(y)
            if not x or not y then return end
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
    args = true,
    handler =
        function (cond, context, v)
            v = tonumber(v)
            if v then
                if time() - (cond.elapsed or 0) >= v then
                    cond.elapsed = time()
                    return true
                end
            end
        end
}

-- This is here in case I want to use it in the combat handler code, it doesn't work
-- for player actions because you're in combat at the time. In general it's not reliable
-- because if you are the first hit you will start combat before the encounter info is
-- available.

CONDITIONS["encounter"] = {
    handler =
        function (cond, context, v)
            v = tonumber(v)
            if v then
                return LM.Environment:GetEncounterInfo() == v
            end
        end
}

CONDITIONS["equipped"] = {
    handler =
        function (cond, context, v)
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

            if C_MountJournal.GetAppliedMountEquipmentID then
                local id = C_MountJournal.GetAppliedMountEquipmentID()
                if id and id == v then
                    return true
                end
            end
        end
}

CONDITIONS["exists"] = {
    handler =
        function (cond, context)
            return UnitExists(context.unit or "target")
        end
}

-- Check for an extraactionbutton, optionally with a specific spell
CONDITIONS["extra"] = {
    handler =
        function (cond, context, v)
            if HasExtraActionBar and HasExtraActionBar() and HasAction(169) then
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
    toDisplay =
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
        function (cond, context, v)
            if v then
                return tContains({ UnitFactionGroup(context.unit or "player") }, v)
            end
        end,
}

CONDITIONS["falling"] = {
    -- name = STRING_ENVIRONMENTAL_DAMAGE_FALLING,
    handler =
        function (cond, context)
            return LM.Environment:IsFalling()
        end
}

CONDITIONS["false"] = {
    -- name = NEVER,
    handler =
        function (cond, context)
            return false
        end
}

CONDITIONS["floating"] = {
    handler =
        function (cond, context)
            return LM.Environment:IsFloating()
        end
}

CONDITIONS["flyable"] = {
    name = L.LM_FLYABLE_AREA,
    handler =
        function (cond, context)
            return LM.Environment:CanFly()
        end,
}

CONDITIONS["flying"] = {
    handler =
        function (cond, context)
            return IsFlying()
        end
}

CONDITIONS["form"] = {
    handler =
        function (cond, context, v)
            if v == "slow" then
                return LM.Environment:IsCombatTravelForm()
            elseif v then
                return GetShapeshiftForm() == tonumber(v)
            else
                return GetShapeshiftForm() > 0
            end
        end
}

CONDITIONS["gather"] = {
    name = L.LM_GATHERED_RECENTLY,
    toDisplay =
        function (v)
            if not v or v == "any" then
                return ANY_TEXT
            elseif v == "ore" then
                return L.LM_ORE
            elseif v == "herb" then
                return L.LM_HERB
            end
        end,
    menu = {
        { val = "gather:any" },
        { val = "gather:herb" },
        { val = "gather:ore" },
    },
    args = true,
    handler =
        function (cond, context, what, n)
            local sinceHerb = GetTime() - LM.Environment:GetHerbTime()
            local sinceMine = GetTime() - LM.Environment:GetMineTime()
            n = tonumber(n) or 30
            if what == "herb" then
                return sinceHerb < n
            elseif what == "ore" then
                return sinceMine < n
            elseif what == nil or what == "any" then
                return math.min(sinceHerb, sinceMine) < n
            end
        end
}

local function IsInCrossFactionGroup()
    local myFaction = UnitFactionGroup('player')
    for unit in IterateGroupUnits() do
        if UnitFactionGroup(unit) ~= myFaction then
            return true
        end
    end
end

CONDITIONS["group"] = {
    name = L.LM_PARTY_OR_RAID_GROUP,
    toDisplay =
        function (v)
            if v == "party" then
                return PARTY
            elseif v == "raid" then
                return RAID
            elseif v == "crossfaction" then
                return CROSS_FACTION_CLUB_FINDER_SEARCH_OPTION
            elseif not v then
                return ANY_TEXT
            end
        end,
    menu =
        function ()
            local out = {
                nosort = true,
                { val = "group" },
                { val = "group:party" },
                { val = "group:raid" },
            }
            if CROSS_FACTION_CLUB_FINDER_SEARCH_OPTION then
                table.insert(out, { val = "group:crossfaction" })
            end
            return out
        end,
    handler =
        function (cond, context, groupType)
            if not groupType then
                return IsInGroup() or IsInRaid()
            elseif groupType == "raid" then
                return IsInRaid()
            elseif groupType == "party" then
                return IsInGroup()
            elseif groupType == "crossfaction" then
                return IsInCrossFactionGroup()
            end
        end
}

CONDITIONS["harm"] = {
    handler =
        function (cond, context)
            return not UnitIsFriend("player", context.unit or "target")
        end
}

CONDITIONS["help"] = {
    handler =
        function (cond, context)
            return UnitIsFriend("player", context.unit or "target")
        end
}

CONDITIONS["holiday"] = {
    name = L.LM_HOLIDAY,
    toDisplay =
        function (v)
            return LM.Environment:GetHolidayName(tonumber(v)) or v
        end,
    menu =
        function ()
            local out = {}
            for id, title in pairs(LM.Environment:GetHolidays()) do
                table.insert(out, { val="holiday:"..id, text=string.format("%s (%d)", title, id) })
            end
            return out
        end,
    handler =
        function (cond, context, v)
            if v then
                return LM.Environment:IsHolidayActive(tonumber(v) or v)
            end
        end
}

CONDITIONS["indoors"] = {
    handler =
        function (cond, context)
            return IsIndoors()
        end
}

CONDITIONS["instance"] = {
    name = INSTANCE,
    toDisplay =
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
        function (cond, context, v)
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
        function (cond, context)
            local jumpTime = LM.Environment:GetJumpTime()
            return ( jumpTime and jumpTime < 2 )
        end
}

CONDITIONS["keybind"] = {
    handler =
        function (cond, context, v)
            if v then
                return context.id == tonumber(v)
            end
        end
}

CONDITIONS["known"] = {
    handler =
        function (cond, context, v)
            if v then
                local spellID = select(7, GetSpellInfo(v))
                if spellID then
                    return IsSpellKnown(spellID) or IsPlayerSpell(spellID)
                end
            end
        end
}

local MAXLEVEL = GetMaxLevelForExpansionLevel(LE_EXPANSION_LEVEL_CURRENT)

CONDITIONS["level"] = {
    name = LEVEL,
    args = true,
    menu = {
        nosort = true,
        { val = "level" },
    },
    toDisplay =
        function (l1, l2)
            if l1 == nil then
                return string.format('%s (%d)', GUILD_RECRUITMENT_MAXLEVEL, MAXLEVEL)
            elseif l2 == nil then
                return l1
            else
                return string.format("%d - %d", l1, l2)
            end
        end,
    handler =
        function (cond, context, l1, l2)
            local level = UnitLevel('player')
            if not l1 then
                return level == MAXLEVEL
            elseif not l2 then
                return level == tonumber(l1)
            elseif l2 then
                return level >= tonumber(l1) and level <= tonumber(l2)
            end
        end
}


CONDITIONS["loadout"] = {
    name = L["Talent loadout"],
    disabled = ( C_ClassTalents == nil ),
    toDisplay =
        function (v)
            return v
        end,
    menu =
        function ()
            local loadoutMenu = {}
            local _, _, classIndex = UnitClass('player')
            for specIndex = 1, 4 do
                local specID = GetSpecializationInfoForClassID(classIndex, specIndex)
                if not specID then break end
                local configIDs = C_ClassTalents.GetConfigIDsBySpecID(specID)
                for _, id in ipairs(configIDs) do
                    local info = C_Traits.GetConfigInfo(id)
                    table.insert(loadoutMenu, { val = "loadout:"..info.name, text = info.name })
                end
            end
            return loadoutMenu
        end,
    handler =
        function (cond, context, v)
            if v then
                local specID = PlayerUtil.GetCurrentSpecID()
                local id = C_ClassTalents.GetLastSelectedSavedConfigID(specID)
                if id then
                    local info = C_Traits.GetConfigInfo(id)
                    return info and info.name == v
                end
            end
        end
}

CONDITIONS["location"] = {
--  name = LOCATION_COLON:gsub(":", ""),
    toDisplay =
        function (v)
            return v
        end,
    handler =
        function (cond, context, v)
            local mapID = C_Map.GetBestMapForUnit('player')
            if mapID and C_Map.GetMapInfo(mapID).name == v then
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
    name = BRAWL_TOOLTIP_MAP,
    toDisplay =
        function (v)
            local info = C_Map.GetMapInfo(tonumber(v))
            if info then return string.format("%s (%s)", info.name, info.mapID) end
        end,
    menu =
        function ()
            return MapTreeToMenu(LM.Environment:GetMapTree())
        end,
    handler =
        function (cond, context, v)
            if v:sub(1,1) == '*' then
                return LM.Environment:IsOnMap(tonumber(v:sub(2)))
            else
                return LM.Environment:IsMapInPath(tonumber(v), context.mapPath, true)
            end
        end,
}

CONDITIONS["maw"] = {
    handler =
        function (cond, context, v)
            return LM.Environment:IsTheMaw(context.mapPath)
        end
}

CONDITIONS["member"] = {
    handler =
        function (cond, context, name)
            if not name then return end
            if name:find('#') then
                for u in IterateGroupUnits() do
                    local guid = UnitGUID(u)
                    local info = C_BattleNet.GetAccountInfoByGUID(guid)
                    if info and info.battleTag == name then return true end
                end
            elseif name:find('-') then
                for u in IterateGroupUnits() do
                    local n, r = UnitName(u)
                    r = r or GetRealmName()
                    if n..'-'..r == name then return true end
                end
            else
                for u in IterateGroupUnits() do
                    local n, r = UnitName(u)
                    if n == name and r == nil then return true end
                end
            end
        end
}

CONDITIONS["mod"] = {
    name = L.LM_MODIFIER_KEY,
    toDisplay =
        function (v)
            if not v then
                return ANY_TEXT
            elseif tonumber(v) then
                return v
            elseif type(v) == "string" then
                return _G[v:upper().."_KEY_TEXT"] or v
            end
        end,
    menu = {
        nosort = true,
        { val = "mod" },
        { val = "mod:alt" },
        { val = "mod:lalt" },
        { val = "mod:ralt" },
        { val = "mod:ctrl" },
        { val = "mod:lctrl" },
        { val = "mod:rctrl" },
        { val = "mod:shift" },
        { val = "mod:lshift" },
        { val = "mod:rshift" },
    },
    handler =
        function (cond, context, v)
            if not v then
                return IsModifierKeyDown()
            elseif tonumber(v) then
                local i = 0
                if IsLeftAltKeyDown() then i = i + 1 end
                if IsLeftShiftKeyDown() then i = i + 1 end
                if IsLeftControlKeyDown() then i = i + 1 end
                if IsRightAltKeyDown() then i = i + 1 end
                if IsRightShiftKeyDown() then i = i + 1 end
                if IsRightControlKeyDown() then i = i + 1 end
                if IsRightControlKeyDown() then i = i + 1 end
                return tonumber(v) == i
            elseif v == "alt" then
                return IsAltKeyDown()
            elseif v == "lalt" then
                return IsLeftAltKeyDown()
            elseif v == "ralt" then
                return IsRightAltKeyDown()
            elseif v == "ctrl" then
                return IsControlKeyDown()
            elseif v == "lctrl" then
                return IsLeftControlKeyDown()
            elseif v == "rtrl" then
                return IsRightoControlKeyDown()
            elseif v == "shift" then
                return IsShiftKeyDown()
            elseif v == "lshift" then
                return IsLeftShiftKeyDown()
            elseif v == "rshift" then
                return IsRightShiftKeyDown()
            else
                return false
            end
        end,
}

CONDITIONS["mounted"] = {
    handler =
        function (cond, context, v)
            if not v then
                return IsMounted()
            else
                local m = LM.MountRegistry:GetActiveMount()
                if tonumber(v) then
                    return m.spellID == tonumber(v)
                else
                    return m.name == v
                end
            end
        end
}

CONDITIONS["moving"] = {
    handler =
        function (cond, context)
            return LM.Environment:IsMovingOrFalling()
        end
}

CONDITIONS["name"] = {
    handler =
        function (cond, context, v)
            if v then
                return UnitName(context.unit or "player") == v
            end
        end
}

CONDITIONS["option"] = {
    args = true,
    handler =
        function (cond, context, setting, ...)
            if not setting then return end
            setting = setting:lower()
            if setting == "copytargetsmount" then
                return LM.Options:GetOption('copyTargetsMount')
            elseif setting == "instantonlymoving" then
                return LM.Options:GetOption('instantOnlyMoving')
            elseif setting == "debug" then
                return LM.Options:GetOption('debugEnabled')
            elseif setting == "uidebug" then
                return LM.Options:GetOption('uiDebugEnabled')
            end
        end
}

CONDITIONS["outdoors"] = {
    handler =
        function (cond, context)
            return IsOutdoors()
        end
}

CONDITIONS["pcall"] = {
    handler =
        function (cond, context, text)
            if text then
                -- In theory someone could make a complex function and decide
                -- which part to return but I sure hope they don't.
                if not text:find("return ") then
                    text = "return " .. text
                end
                local f, err = loadstring(text)
                if f and err == nil then
                    local ok, rc = pcall(f)
                    return ok and rc
                end
            end
        end
}

CONDITIONS["party"] = {
    handler =
        function (cond, context)
            return UnitPlayerOrPetInParty(context.unit or "target")
        end
}

CONDITIONS["pet"] = {
    handler =
        function (cond, context, v)
            local petunit
            if not context.unit or context.unit == "player" then
                petunit = "pet"
            else
                petunit = context.unit .. "pet"
            end
            if v then
                return UnitName(petunit) == v or UnitCreatureFamily(petunit) == v
            else
                 return UnitExists(petunit)
            end
        end
}

CONDITIONS["playermodel"] = {
    handler =
        function (cond, context, v)
            if v then
                return LM.Environment:GetPlayerModel() == tonumber(v)
            end
        end
}

CONDITIONS["profession"] = {
    disabled = ( GetProfessions == nil ),
    handler =
        function (cond, context, v)
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
        function (cond, context, v)
            if not v then
                return UnitIsPVP(context.unit or "player")
            else
                return GetZonePVPInfo() == v
            end
        end
}

CONDITIONS["qfc"] = {
    handler =
        function (cond, context, v)
            if v then
                v = tonumber(v)
                return v and C_QuestLog.IsQuestFlaggedCompleted(v)
            end
        end
}

CONDITIONS["race"] = {
    handler =
        function (cond, context, v)
            local race, raceEN, raceID = UnitRace(context.unit or "player")
            return ( race == v or raceEN == v or raceID == tonumber(v) )
        end
}

CONDITIONS["raid"] = {
    handler =
        function (cond, context)
            return UnitPlayerOrPetInRaid(context.unit or "target")
        end
}

CONDITIONS["random"] = {
    handler =
        function (cond, context, n)
            return math.random(100) <= tonumber(n)
        end
}

CONDITIONS["realm"] = {
    handler =
        function (cond, context, v)
            if v then
                return GetRealmName() == v
            end
        end
}

CONDITIONS["resting"] = {
    name = TUTORIAL_TITLE30,
    handler =
        function (cond, context)
            return IsResting()
        end
}

CONDITIONS["role"] = {
    handler =
        function (cond, context, v)
            if v then
                return UnitGroupRolesAssigned(context.unit or "player") == v
            end
        end
}

CONDITIONS["sameunit"] = {
    handler =
        function (cond, context, v)
            if v then
                return UnitIsUnit(v, context.unit or "player")
            end
        end
}

CONDITIONS["season"] = {
    name = L.LM_SEASON,
    disabled = ( C_MountJournal.GetMountInfoExtraByID(1458) == nil ),
    toDisplay =
        function (v)
            if v == "spring" then
                return L.LM_SEASON_SPRING
            elseif v == "summer" then
                return L.LM_SEASON_SUMMER
            elseif v == "autumn" or v == "fall" then
                return L.LM_SEASON_FALL
            elseif v == "winter" then
                return L.LM_SEASON_WINTER
            end
        end,
    menu = {
        { val = "season:spring" },
        { val = "season:summer" },
        { val = "season:fall" },
        { val = "season:winter" },
    },
    handler =
        function (cond, context, v)
            -- From the mount Wandering Ancient's model, as it changes
            local modelID = C_MountJournal.GetMountInfoExtraByID(1458)
            if v == "spring" then
                return modelID == 100463
            elseif v == "summer" then
                return modelID == 100464
            elseif v == "autumn" or v == "fall" then
                return modelID == 100465
            elseif v == "winter" then
                return modelID == 100466
            end
        end
}

CONDITIONS["sex"] = {
    name = L.LM_SEX,
    toDisplay =
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
        function (cond, context, v)
            if v then
                return UnitSex(context.unit or "player") == tonumber(v)
            end
        end
}

CONDITIONS["shapeshift"] = {
    handler =
        function (cond, context)
            return HasTempShapeshiftActionBar()
        end
}

CONDITIONS["spec"] = {
    name = SPECIALIZATION,
    disabled = ( GetSpecializationInfoByID == nil ),
    toDisplay =
        function (v)
            local _, name, _, _, _, _, class = GetSpecializationInfoByID(v)
            if name and name ~= "" then return class .. " : " .. name end
        end,
    menu =
        function ()
            local specs = {}
            for classIndex = 1, GetNumClasses() do
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
        function (cond, context, v)
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
        function (cond, context, minv, maxv)
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
        function (cond, context)
            return IsStealthed()
        end
}

-- The difference between IsSwimming and IsSubmerged is that IsSubmerged
-- will also return true when you are standing on the bottom.  Note that
-- it sadly does not return false when you are floating on the top, that
-- is still counted as being submerged.

CONDITIONS["submerged"] = {
    name = TUTORIAL_TITLE28,
    handler =
        function (cond, context)
            return (IsSubmerged() and not LM.Environment:IsFloating())
        end,
}

CONDITIONS["swimming"] = {
    handler =
        function (cond, context)
            return IsSubmerged()
        end
}

CONDITIONS["tracking"] = {
    disabled = not ( C_Minimap and C_Minimap.GetNumTrackingTypes ),
    handler =
        function (cond, context, v)
            local name, active, _
            for i = 1, C_Minimap.GetNumTrackingTypes() do
                name, _, active = C_Minimap.GetTrackingInfo(i)
                if active and (not v or strlower(name) == strlower(v) or i == tonumber(v)) then
                    return true
                end
            end
            return false
        end
}

CONDITIONS["true"] = {
    handler =
        function (cond, context)
            return true
        end
}

CONDITIONS["waterwalking"] = {
    handler =
        function (cond, context)
            if C_MountJournal.AreMountEquipmentEffectsSuppressed then
                -- Anglers Waters Striders (168416) or Inflatable Mount Shoes (168417)
                if not C_MountJournal.AreMountEquipmentEffectsSuppressed() then
                    local id = C_MountJournal.GetAppliedMountEquipmentID()
                    if id == 168416 or id == 168417 then
                        return true
                    end
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
            local activeSourceID = GetTransmogLocationSourceID(slotInfo.location)
            if not tContains(sourceIDs, activeSourceID) then
                return false
            end
        end
    end
    return true
end

-- This makes me want to kill myself instantly.
-- See WardrobeOutfitDropDownMixin:IsOutfitDressed()

local ExcludeOutfitSlot = {
    [INVSLOT_MAINHAND] = true, [INVSLOT_OFFHAND] = true, [INVSLOT_RANGED] = true,
}

local function IsTransmogOutfitActive(outfitID)
    local outfitInfoList = C_TransmogCollection.GetOutfitItemTransmogInfoList(outfitID)
    if not outfitInfoList then return end

    local currentInfoList = LM.Environment:GetPlayerTransmogInfo()
    if not currentInfoList then return end

    for slotID, info in ipairs(currentInfoList) do
        if info.appearanceID ~= Constants.Transmog.NoTransmogID then
            if not ExcludeOutfitSlot[slotID] and not info:IsEqual(outfitInfoList[slotID]) then
                return false
            end
        end
    end
    return true
end

local function GetTransmogOutfitsMenu()
    local outfits = { text = TRANSMOG_OUTFIT_HYPERLINK_TEXT:match("|t(.*)") }
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
        local text = info.name
        if info.description then
            text = text .. " (" .. info.description .. ")"
        end
        table.insert(byExpansion[expansion], { val = "xmog:"..info.setID, text = text })
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
    name = PERKS_VENDOR_CATEGORY_TRANSMOG,
    disabled = not ( C_TransmogSets and C_Transmog ),
    toDisplay =
        function (v)
            if tonumber(v) then
                local info = C_TransmogSets.GetSetInfo(v)
                if info then
                    if info.description then
                        return string.format("%s (%s)", info.name, info.description)
                    else
                        return info.name
                    end
                end
            end
            return v
        end,
    menu =
        function ()
            return { GetTransmogOutfitsMenu(), GetTransmogSetsMenu() }
        end,
    handler =
        function (cond, context, arg1, arg2)
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

--[[------------------------------------------------------------------------]]--

LM.Conditions = { }

local CheckConditionCache = {}

function LM.Conditions:Check(conditions, context)
    local line = "DUMMY " .. conditions
    if not CheckConditionCache[line] then
        local rule = LM.Rule:ParseLine(line)
        CheckConditionCache[line] = rule.conditions
    end
    return CheckConditionCache[line]:Eval(context or {})
end

function LM.Conditions:GetCondition(cond)
    local c = CONDITIONS[cond]
    if c then return c end
end

function LM.Conditions:GetConditions()
    local out = { }
    for _, info in pairs(CONDITIONS) do
        if not info.disabled and info.name then
            table.insert(out, info)
        end
    end
    table.sort(out, function (a, b) return a.name < b.name end)
    return out
end

local function FillMenuTextsRecursive(t)
    for _,item in ipairs(t) do
        if not item.text then
            item.text = select(2, LM.Conditions:ToDisplay(item.val))
        end
        FillMenuTextsRecursive(item)
    end
    if not t.nosort then
        table.sort(t, function (a,b) return a.text < b.text end)
    end
    return t
end

function LM.Conditions:ArgsMenu(cond)
    local c = CONDITIONS[cond]
    if not c or c.disabled then return end
    if type(c.menu) == 'table' then
        return FillMenuTextsRecursive(c.menu)
    elseif type(c.menu) == 'function' then
        return FillMenuTextsRecursive(c.menu())
    end
end

function LM.Conditions:IsValidCondition(text)
    if text then
        local cond, valuestr = strsplit(':', text)
        if cond and CONDITIONS[cond] and not CONDITIONS[cond].disabled then
            return true
        end
    end
end

function LM.Conditions:ToDisplay(text)
    local cond, valuestr = strsplit(':', text)

    local c = CONDITIONS[cond]
    if not c or c.disabled then return end

    if not c.name then
        return ADVANCED_LABEL, text
    end

    if not c.toDisplay then
        return c.name, nil
    end

    local values
    if valuestr then
        values = { strsplit('/', valuestr) }
    else
        values = { }
    end

    local argText
    if c.args then
        argText = c.toDisplay(unpack(values))
    elseif #values == 0 then
        argText = c.toDisplay()
    else
        argText = table.concat(LM.tMap(values, c.toDisplay, values), " ")
    end
    return c.name, argText
end
