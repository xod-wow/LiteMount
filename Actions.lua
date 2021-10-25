--[[----------------------------------------------------------------------------

  LiteMount/Actions.lua

  Mounting actions.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local function ReplaceVars(list)
    local out = {}
    for _,l in ipairs(list) do
        l = LM.Vars:StrSubVars(l)
        tinsert(out, l)
    end
    return out
end

local FLOWCONTROLS = { }

FLOWCONTROLS['IF'] =
    function (args, env, isTrue)
        LM.Debug(' - IF test is ' .. tostring(isTrue))
        table.insert(env.flowControl, isTrue)
    end

FLOWCONTROLS['ELSEIF'] =
    function (args, env, isTrue)
        local wasTrue = env.flowControl[#env.flowControl]
        isTrue = not wasTrue and isTrue
        LM.Debug(' - ELSEIF test is ' .. tostring(isTrue))
        env.flowControl[#env.flowControl] = isTrue
    end

FLOWCONTROLS['ELSE'] =
    function (args, env, isTrue)
        local wasTrue = env.flowControl[#env.flowControl]
        isTrue = not wasTrue
        LM.Debug(' - ELSE test is ' .. tostring(isTrue))
        env.flowControl[#env.flowControl] = isTrue
    end

FLOWCONTROLS['END'] =
    function (args, env, isTrue)
        table.remove(env.flowControl)
    end

local ACTIONS = { }

-- Modifies the list of usable mounts so action list lines after this one
-- get the restricted list. Always returns no action.

ACTIONS['Limit'] = {
    handler =
        function (args, env)
            local filters = LM.tJoin(env.filters[1], args)
            table.insert(env.filters, 1, filters)
            LM.Debug(" - new filter: " .. table.concat(env.filters[1], ' '))
        end
}

-- These ones are really just for user rules.

ACTIONS['LimitSet'] = {
    name = L.LM_LIMIT_MOUNTS,
    toDisplay =
        function (v)
            -- XXX Doesn't support multiple args XXX
            return LM.Mount:FilterToDisplay(v)
        end,
    handler = function (args, env)
            -- There's no point of multi-arg, just use the last
            if #args > 0 then
                local setArgs = { '=' .. args[#args] }
                ACTIONS['Limit'].handler(setArgs, env)
            end
        end
}

ACTIONS['LimitInclude'] = {
    name = L.LM_INCLUDE_MOUNTS,
    toDisplay = function (v) return LM.Mount:FilterToDisplay(v) end,
    handler = function (args, env)
            -- XXX this multi-arg support is super sketchy/wrong XXX
            local plusArgs = LM.tMap(args, function (a) return '+' .. a end)
            ACTIONS['Limit'].handler(plusArgs, env)
        end
}

ACTIONS['LimitExclude'] = {
    name = L.LM_EXCLUDE_MOUNTS,
    toDisplay = function (v) return LM.Mount:FilterToDisplay(v) end,
    handler = function (args, env)
            -- XXX this multi-arg support is super sketchy/wrong XXX
            local minusArgs = LM.tMap(args, function (a) return '-' .. a end)
            ACTIONS['Limit'].handler(minusArgs, env)
        end
}

ACTIONS['Endlimit'] = {
    handler =
        function (args, env)
            if #env.filters == 1 then return end
            table.remove(env.filters, 1)
            LM.Debug(" - restored filter: " .. table.concat(env.filters[1], ' '))
        end
}

local function GetUsableSpell(arg)
    local spellID, name, _

    -- You can look up any spell from any class by number so we have to
    -- test numbers to see if we know them
    spellID = tonumber(arg)
    if spellID and not IsSpellKnown(spellID) then
        return
    end

    -- For names, GetSpellInfo returns nil if it's not in your spellbook
    -- so we don't need to call IsSpellKnown
    name, _, _, _, _, _, spellID = GetSpellInfo(arg)

    -- Glide won't cast while mounted
    if spellID == 131347 and IsMounted() then
        return
    end

    -- Zen Flight only works if you can fly
    if spellID == 125883 and not LM.Environment:CanFly() then
        return
    end

    if name and IsUsableSpell(name) and GetSpellCooldown(name) == 0 then
        return name, spellID
    end
end

ACTIONS['Spell'] = {
    name = L.LM_CAST_SPELL,
    toDisplay =
        function (v)
            local name, _, _, _, _, _, id = GetSpellInfo(v)
            if name then
                return string.format("%s (%d)", name, id)
            else
                return v
            end
        end,
    handler =
        function (args, env)
            for _, arg in ipairs(args) do
                LM.Debug(' - trying spell: ' .. tostring(arg))
                local name, id = GetUsableSpell(arg)
                if name then
                    LM.Debug(" - setting action to spell " .. name)
                    return LM.SecureAction:Spell(name, env.unit)
                end
            end
        end
}

-- Buff is the same as Spell but checks if you have a matching aura and
-- doesn't recast. Note that it checks only for buffs on the assumption
-- that you can't cast a debuff on yourself, and that it checks by name
-- because for some spells (e.g., Levitate) the ID doesn't match.

ACTIONS['Buff'] = {
    name = L.LM_APPLY_BUFF,
    toDisplay = ACTIONS["Spell"].toDisplay,
    handler =
        function (args, env)
            for _, arg in ipairs(args) do
                LM.Debug(' - trying buff: ' .. tostring(arg))
                local name, id = GetUsableSpell(arg)
                if name and not LM.UnitAura(env.unit or 'player', name) then
                    LM.Debug(" - setting action to spell " .. name)
                    return LM.SecureAction:Spell(name, env.unit)
                end
            end
        end
}

-- Set env.precast to a spell name to try to macro in before mounting journal
-- mounts. This is a bit less strict than Spell and Buff because the macro
-- still works even if the spell isn't usable, and has the advantage of
-- avoiding the IsUsableSpell failures when targeting others.

ACTIONS['PreCast'] = {
    toDisplay = ACTIONS["Spell"].toDisplay,
    handler =
        function (args, env)
            for _, arg in ipairs(args) do
                local name, _, _, castTime, _, _, id = GetSpellInfo(arg)
                if name and IsPlayerSpell(id) and castTime == 0 then
                    LM.Debug(" - setting preCast to spell " .. name)
                    env.preCast = name
                    return
                end
            end
        end
}

ACTIONS['CancelAura'] = {
    name = L.LM_CANCEL_BUFF,
    toDisplay = ACTIONS['Spell'].toDisplay,
    handler =
        function (args, env)
            for _, arg in ipairs(args) do
                local name, _, _, _, _, _, _, _, _, _, castable = LM.UnitAura('player', arg)
                if name and castable then
                    return LM.SecureAction:CancelAura(name)
                end
            end
        end
}

-- In vehicle -> exit it
ACTIONS['LeaveVehicle'] = {
    handler =
        function (args, env)
            if CanExitVehicle() then
                LM.Debug(" - setting action to leavevehicle")
                return LM.SecureAction:LeaveVehicle()
            end
        end
}

-- This includes dismounting from mounts and also canceling other mount-like
-- things such as shapeshift forms

ACTIONS['Dismount'] = {
    name = BINDING_NAME_DISMOUNT,
    handler =
        function (args, env)
            -- Shortcut dismount from journal mounts. This has the (wanted) side
            -- effect of dismounting you even from mounts that aren't enabled,
            -- and the (wanted) side effect of dismounting while in moonkin form
            -- without cancelling it.
            if IsMounted() then
                LM.Debug(" - setting action to dismount")
                return LM.SecureAction:Macro(SLASH_DISMOUNT1)
            end

            -- Otherwise we look for the mount from its buff and return the cancel
            -- actions.
            local m = LM.PlayerMounts:GetActiveMount()
            if m and m:IsCancelable() then
                LM.Debug(" - setting action to cancel " .. m.name)
                return m:GetCancelAction()
            end
        end
}

-- CancelForm has been absorbed into Dismount
ACTIONS['CancelForm'] = {
    handler = function (args, env) end
}

-- Got a player target, try copying their mount
ACTIONS['CopyTargetsMount'] = {
    handler =
        function (args, env)
            local unit = env.unit or "target"
            if LM.Options:GetCopyTargetsMount() and UnitIsPlayer(unit) then
                LM.Debug(string.format(" - trying to clone %s's mount", unit))
                local m = LM.PlayerMounts:GetMountFromUnitAura(unit)
                if m and m:IsCastable() then
                    LM.Debug(format(" - setting action to mount %s", m.name))
                    return m:GetCastAction(env)
                end
            end
        end
}

ACTIONS['ApplyRules'] = {
    handler =
        function (args, env)
            local ruleSet = LM.Options:GetCompiledRuleSet(env.id)
            LM.Debug(string.format(" - checking %d rules for button %d", #ruleSet, env.id))
            local act, n = ruleSet:Run(env)
            if act then
                LM.Debug(string.format(" - found matching rule %d", n))
                return act
            end
            LM.Debug(" - no rules matched")
        end
}

ACTIONS['SmartMount'] = {
    name = L.LM_SMARTMOUNT_ACTION,
    toDisplay =
        function (v) return LM.Mount:FilterToDisplay(v) end,
    handler =
        function (args, env)

            local filters = ReplaceVars(LM.tJoin(env.filters[1], args))
            local filteredList = LM.PlayerMounts:FilterSearch("CASTABLE"):Limit(unpack(filters))

            LM.Debug(" - filters: " .. table.concat(filters, ' '))
            LM.Debug(" - filtered list contains " .. #filteredList .. " mounts")

            if next(filteredList) == nil then return end

            local m

            if not m and LM.Conditions:Check("[submerged]", env) then
                LM.Debug(" - trying Aquatic Mount (underwater)")
                local swim = filteredList:FilterSearch('SWIM')
                LM.Debug(" - found " .. #swim .. " mounts.")
                m = swim:PriorityRandom(env.random)
            end

            if not m and LM.Conditions:Check("[flyable]", env) then
                LM.Debug(" - trying Flying Mount")
                local fly = filteredList:FilterSearch('FLY')
                LM.Debug(" - found " .. #fly .. " mounts.")
                m = fly:PriorityRandom(env.random)
            end

            if not m and LM.Conditions:Check("[floating,nowaterwalking]", env) then
                LM.Debug(" - trying Aquatic Mount (on the surface)")
                local swim = filteredList:FilterSearch('SWIM')
                LM.Debug(" - found " .. #swim .. " mounts.")
                m = swim:PriorityRandom(env.random)
            end

            if not m then
                LM.Debug(" - trying Ground Mount")
                local run = filteredList:FilterSearch('RUN', '~SLOW')
                LM.Debug(" - found " .. #run .. " mounts.")
                m = run:PriorityRandom(env.random)
            end

            if not m then
                LM.Debug(" - trying Slow Ground Mount")
                local walk = filteredList:FilterSearch('RUN', 'SLOW')
                LM.Debug(" - found " .. #walk .. " mounts.")
                m = walk:PriorityRandom(env.random)
            end

            if m then
                LM.Debug(format(" - setting action to mount %s", m.name))
                return m:GetCastAction(env)
            end
        end
}

ACTIONS['Mount'] = {
    name = L.LM_MOUNT_ACTION,
    toDisplay =
        function (v) return LM.Mount:FilterToDisplay(v) end,
    handler =
        function (args, env)
            local filters = ReplaceVars(LM.tJoin(env.filters[1], args))
            LM.Debug(" - filters: " .. table.concat(filters, ' '))
            local mounts = LM.PlayerMounts:FilterSearch("CASTABLE"):Limit(unpack(filters))
            local m = mounts:Random(env.random)
            if m then
                LM.Debug(format(" - setting action to mount %s", m.name))
                return m:GetCastAction(env)
            end
        end
}

ACTIONS['Macro'] = {
    handler =
        function (args, env)
            if LM.Options:GetUseUnavailableMacro() then
                LM.Debug(" - using unavailable macro")
                local macrotext = LM.Options:GetUnavailableMacro()
                return LM.SecureAction:Macro(macrotext)
            end
        end
}

ACTIONS['Script'] = {
    handler =
        function (args, env)
            local macroText = table.concat(args, ' ')
            if SecureCmdOptionParse(macroText) then
                LM.Debug(" - running script line: " .. macroText)
                return LM.SecureAction:Macro(macroText)
            end
        end
}

ACTIONS['CantMount'] = {
    handler =
        function (args, env)
            -- This isn't a great message, but there isn't a better one that
            -- Blizzard have already localized. See FrameXML/GlobalStrings.lua.
            -- LM.Warning("You don't know any mounts you can use right now.")
            LM.Warning(SPELL_FAILED_NO_MOUNTS_ALLOWED)

            LM.Debug(" - setting action to can't mount now")
            return LM.SecureAction:Macro("")
        end
}

ACTIONS['Combat'] = {
    handler =
        function (args, env)
            LM.Debug(" - setting action to in-combat action")

            local macrotext
            if LM.Options:GetUseCombatMacro() then
                macrotext = LM.Options:GetCombatMacro()
            else
                macrotext = LM.Actions:DefaultCombatMacro()
            end
            return LM.SecureAction:Macro(macrotext)
        end
}

ACTIONS['Stop'] = {
    handler =
        function (args, env)
            -- return true and set up to do nothing
            return LM.SecureAction:Macro("")
        end
}

local function IsCastableItem(itemID)
    if not itemID then
        return false
    end

    if PlayerHasToy(itemID) then
        if not C_ToyBox.IsToyUsable(itemID) then
            return false
        end
    elseif not IsUsableItem(itemID) then
        return false
    elseif IsEquippableItem(itemID) and not IsEquippedItem(itemID) then
        return false
    end

    local s, d, e = GetItemCooldown(itemID)
    if s == 0 and e == 1 then
        return true
    end

    return false
end

-- A derpy version of SecureCmdItemParse that doesn't support bags but does
-- support item IDs as well as slot names. The assumption is that if you have
-- the item then GetItemInfo will always return values immediately.

local function UsableItemParse(arg)
    local name, itemID, slotNum

    local slotOrID = tonumber(arg)
    if slotOrID and slotOrID <= INVSLOT_LAST_EQUIPPED then
        slotNum = slotOrID
    elseif slotOrID then
        name = GetItemInfo(slotOrID)
        itemID = slotOrID
    else
        local slotName = "INVSLOT_"..arg:upper()
        if _G[slotName] then
            slotNum = _G[slotName]
        else
            name = arg
            itemID = GetItemInfoInstant(arg)
        end
    end

    return name, itemID, slotNum
end

ACTIONS['Use'] = {
    handler =
        function (args, env)
            for _, arg in ipairs(args) do
                local name, itemID, slotNum = UsableItemParse(arg)
                if slotNum then
                    local s, d, e = GetInventoryItemCooldown('player', slotNum)
                    if s == 0 and e == 1 then
                        LM.Debug(' - Setting action to use slot ' .. slotNum)
                        return LM.SecureAction:Item(slotNum, env.unit)
                    end
                    return
                else
                    if name and IsCastableItem(itemID) then
                        LM.Debug(' - setting action to use item ' .. name)
                        return LM.SecureAction:Item(name, env.unit)
                    end
                end
            end
        end
}

do
    for a, info in pairs(ACTIONS) do
        info.action = a
    end
end

--[[------------------------------------------------------------------------]]--

LM.Actions = { }

local function GetDruidMountForms()
    local forms = {}
    for i = 1,GetNumShapeshiftForms() do
        local spell = select(4, GetShapeshiftFormInfo(i))
        if spell == LM.SPELL.TRAVEL_FORM or spell == LM.SPELL.MOUNT_FORM then
            tinsert(forms, i)
        end
    end
    return table.concat(forms, "/")
end

-- This is the macro that gets set as the default and will trigger if
-- we are in combat.  Don't put anything in here that isn't specifically
-- combat-only, because out of combat we've got proper code available.
-- Note that macros are limited to 255 chars, even inside a SecureActionButton.

function LM.Actions:DefaultCombatMacro()

    local mt = "/dismount [mounted]\n"

    local _, playerClass = UnitClass("player")

    if playerClass ==  "DRUID" then
        local forms = GetDruidMountForms()
        local mount = LM.PlayerMounts:GetMountBySpell(LM.SPELL.TRAVEL_FORM)
        if mount and LM.Options:GetPriority(mount) > 0 then
            mt = mt .. format("/cast [noform:%s] %s\n", forms, mount.name)
            mt = mt .. format("/cancelform [form:%s]\n", forms)
        end
    elseif playerClass == "SHAMAN" then
        local mount = LM.PlayerMounts:GetMountBySpell(LM.SPELL.GHOST_WOLF)
        if mount and LM.Options:GetPriority(mount) > 0 then
            local s = GetSpellInfo(LM.SPELL.GHOST_WOLF)
            mt = mt .. "/cast [noform] " .. s .. "\n"
            mt = mt .. "/cancelform [form]\n"
        end
    end

    mt = mt .. "/leavevehicle\n"

    return mt
end

function LM.Actions:GetFlowControlHandler(action)
    return FLOWCONTROLS[action]
end

function LM.Actions:GetHandler(action)
    local a = ACTIONS[action]
    if a then return a.handler end
end

function LM.Actions:IsFlowSkipped(env)
    return tContains(env.flowControl, false)
end

function LM.Actions:ToDisplay(action, args)
    local a = ACTIONS[action]
    local name = a.name or action
    if not args then
        return name
    elseif a.toDisplay then
        return name, table.concat(LM.tMap(args, a.toDisplay), "\n")
    else
        return name, table.concat(args, ' ')
    end
end
