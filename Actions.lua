--[[----------------------------------------------------------------------------

  LiteMount/Actions.lua

  Mounting actions.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local C_Spell = LM.C_Spell or C_Spell

local L = LM.Localize

--
-- This is the support for saving and restoring druid forms which is all done
-- in the Dismount action. Form IDs that you put here must be cancelled
-- automatically on mounting (otherwise trying to restore them when you are
-- already in them will cancel them).
--
-- See: https://wow.gamepedia.com/API_GetShapeshiftFormID
--

local savedFormName = nil

local restoreFormIDs = {
    [1] = true,     -- Cat Form
    [5] = true,     -- Bear Form
    [8] = true,     -- Bear Form (Classic)
    [31] = true,    -- Moonkin Form
    [35] = true,    -- Moonkin Form
    [36] = true,    -- Treant Form
}

local FLOWCONTROLS = { }

-- trueState values
--  0 false and never was true
--  1 true
--  2 false and previously was true

FLOWCONTROLS['IF'] =
    function (args, context, isTrue)
        local trueState = isTrue and 1 or 0
        table.insert(context.flowControl, trueState)
        LM.Debug('  * IF test is ' .. table.concat(context.flowControl, ','))
    end

FLOWCONTROLS['ELSEIF'] =
    function (args, context, isTrue)
        local trueState  = context.flowControl[#context.flowControl]
        trueState = trueState == 1 and 2 or isTrue and 1 or 0
        context.flowControl[#context.flowControl] = trueState
        LM.Debug('  * ELSEIF test is ' .. table.concat(context.flowControl, ','))
    end

FLOWCONTROLS['ELSE'] =
    function (args, context, isTrue)
        local trueState  = context.flowControl[#context.flowControl]
        trueState = trueState + 1
        context.flowControl[#context.flowControl] = trueState
        LM.Debug('  * ELSE test is ' .. table.concat(context.flowControl, ','))
    end

FLOWCONTROLS['END'] =
    function (args, context, isTrue)
        table.remove(context.flowControl)
        LM.Debug('  * END is ' .. table.concat(context.flowControl, ','))
    end

local ACTIONS = { }

-- Modifies the list of usable mounts so action list lines after this one
-- get the restricted list. Always returns no action.

ACTIONS['Limit'] = {
    handler =
        function (args, context)
            LM.Debug("  * Add limits: " .. args:ToString())
            table.insert(context.limits, args)
        end
}

-- These ones are really just for user rules.  The whole syntax of the Limit
-- args is a mess and doesn't parse well. If I had my time again I would
-- probably use & and | which are more obvious. Or, you know, start with a proper
-- grammar-based parser.


local function MountListToDisplay(args)
    local limits = args:ParseList()
    return LM.tMap(limits, LM.Mount.FilterToDisplay, true)
end

ACTIONS['LimitSet'] = {
    name = L.LM_LIMIT_MOUNTS,
    description = L.LM_LIMITSET_DESCRIPTION,
    argType = 'expression',
    toDisplay = MountListToDisplay,
    handler =
        function (args, context)
            ACTIONS.Limit.handler(args:Prepend('='), context)
        end,
}

ACTIONS['LimitInclude'] = {
    name = L.LM_INCLUDE_MOUNTS,
    description = L.LM_LIMITINCLUDE_DESCRIPTION,
    argType = 'expression',
    toDisplay = MountListToDisplay,
    handler =
        function (args, context)
            ACTIONS.Limit.handler(args:Prepend('+'), context)
        end,
}

ACTIONS['LimitExclude'] = {
    name = L.LM_EXCLUDE_MOUNTS,
    description = L.LM_LIMITEXCLUDE_DESCRIPTION,
    argType = 'expression',
    toDisplay = MountListToDisplay,
    handler =
        function (args, context)
            ACTIONS.Limit.handler(args:Prepend('-'), context)
        end,
}

ACTIONS['Endlimit'] = {
    argType = 'none',
    handler =
        function (args, context)
            local oldLimits = table.remove(context.limits)
            if oldLimits then
                LM.Debug("  * removed limits: " .. oldLimits:ToString())
            end
        end,
}

local function GetUsableSpell(arg)
    -- You can look up any spell from any class by number so we have to
    -- test numbers to see if we know them
    local argN = tonumber(arg)
    if argN and not IsPlayerSpell(argN) then
        return
    end

    -- For names, GetSpellInfo returns nil if it's not in your spellbook
    -- so we don't need to call IsPlayerSpell
    local info = C_Spell.GetSpellInfo(argN or arg)
    if not info then
        return
    end

    -- Glide won't cast while mounted
    if info.spellID == 131347 and IsMounted() then
        return
    end

    -- Zen Flight only works if you can fly
    if info.spellID == 125883 then
        if not ( IsFlyableArea() or IsAdvancedFlyableArea() ) then
            return
        end
    end

    -- Some spells share names (e.g., Surge Forward is both an Evoker ability
    -- and a Skyriding ability). If the spell has a subtext it can be
    -- distinguished by bracketing it after the name. This only works if you
    -- pass the spell in by ID since otherwise you'll get whichever one
    -- GetSpellInfo(name) decides to return.

    local subtext = C_Spell.GetSpellSubtext(argN or arg)
    local nameWithSubtext = string.format('%s(%s)', info.name, subtext or "")

    if C_Spell.IsSpellUsable(info.name) then
        local cooldownInfo = C_Spell.GetSpellCooldown(info.name)
        if cooldownInfo and cooldownInfo.startTime == 0 then
            return info.name, info.spellID, nameWithSubtext
        end
    end
end

local function SpellArgsToDisplay(args)
    local out = {}
    for _, v in ipairs(args:ParseList()) do
        local info = C_Spell.GetSpellInfo(v)
        if info then
            table.insert(out, string.format("%s (%d)", info.name, info.spellID))
        else
            table.insert(out, v)
        end
    end
    return out
end

ACTIONS['Spell'] = {
    name = L.LM_SPELL_ACTION,
    description = L.LM_SPELL_DESCRIPTION,
    argType = 'list',
    toDisplay = SpellArgsToDisplay,
    handler =
        function (args, context)
            for _, arg in ipairs(args:ParseList()) do
                LM.Debug('  * trying spell: ' .. tostring(arg))
                local name, id, nameWithSubtext = GetUsableSpell(arg)
                if nameWithSubtext then
                    LM.Debug("  * setting action to spell " .. nameWithSubtext)
                    return LM.SecureAction:Spell(nameWithSubtext, context.rule.unit)
                end
            end
        end
}

-- Buff is the same as Spell but checks if you have a matching aura and
-- doesn't recast. Note that it checks only for buffs on the assumption
-- that you can't cast a debuff on yourself, and that it checks by name
-- because for some spells (e.g., Levitate) the ID doesn't match.

ACTIONS['Buff'] = {
    toDisplay = SpellArgsToDisplay,
    argType = 'list',
    handler =
        function (args, context)
            for _, arg in ipairs(args:ParseList()) do
                LM.Debug('  * trying buff: ' .. tostring(arg))
                local name, id, nameWithSubtext = GetUsableSpell(arg)
                if name and not LM.UnitAura(context.rule.unit or 'player', name) then
                    LM.Debug("  * setting action to spell " .. nameWithSubtext)
                    return LM.SecureAction:Spell(nameWithSubtext, context.rule.unit)
                end
            end
        end
}

-- Set context.precast to a spell name to try to macro in before mounting journal
-- mounts. This is a bit less strict than Spell and Buff because the macro
-- still works even if the spell isn't usable, and has the advantage of
-- avoiding the IsSpellUsable failures when targeting others.

ACTIONS['PreCast'] = {
    name = L.LM_PRECAST_ACTION,
    description = L.LM_PRECAST_DESCRIPTION,
    argType = 'list',
    toDisplay = SpellArgsToDisplay,
    handler =
        function (args, context)
            for _, arg in ipairs(args:ParseList()) do
                local info = C_Spell.GetSpellInfo(arg)
                if info and IsPlayerSpell(info.spellID) and info.castTime == 0 then
                    LM.Debug("  * setting preCast to spell " .. info.name)
                    context.preCast = info.name
                    context.preUse = nil
                    return
                end
            end
        end
}

ACTIONS['CancelAura'] = {
    toDisplay = SpellArgsToDisplay,
    argType = 'list',
    handler =
        function (args, context)
            for _, arg in ipairs(args:ParseList()) do
                local info = LM.UnitAura('player', arg)
                if info then
                    -- Levitate (for example) is marked canApplyAura == false so this is a
                    -- half-workaround. You still won't cancel Levitate somone else put on you.
                    if info.canApplyAura then
                        return LM.SecureAction:CancelAura(info.name)
                    elseif info.sourceUnit == 'player' and C_Spell.GetSpellInfo(info.name) then
                        return LM.SecureAction:CancelAura(info.name)
                    end
                end
            end
        end
}

-- In vehicle -> exit it
ACTIONS['LeaveVehicle'] = {
    argType = 'none',
    handler =
        function (args, context)
            if UnitOnTaxi('player') then
                if MainMenuBarVehicleLeaveButton then
                    -- Clicking updates the state of the UI button which is nice
                    LM.Debug("  * setting action to click MainMenuBarVehicleLeaveButton")
                    return LM.SecureAction:Click(MainMenuBarVehicleLeaveButton)
                else
                    LM.Debug("  * setting action to TaxiRequestEarlyLanding")
                    return LM.SecureAction:Execute(TaxiRequestEarlyLanding)
                end
            elseif CanExitVehicle() then
                LM.Debug("  * setting action to leavevehicle")
                return LM.SecureAction:LeaveVehicle()
            end
        end
}

local function GetFormNameWithSubtext()
    local idx = GetShapeshiftForm()
    if idx and idx > 0 then
        local spellID = select(4, GetShapeshiftFormInfo(idx))
        local n = C_Spell.GetSpellName(spellID)
        local s = C_Spell.GetSpellSubtext(spellID) or ''
        return string.format('%s(%s)', n, s)
    end
end

-- This includes dismounting from mounts and also canceling other mount-like
-- things such as shapeshift forms. The logic here is torturous.

ACTIONS['Dismount'] = {
    name = BINDING_NAME_DISMOUNT,
    argType = 'none',
    handler =
        function (args, context)
            local action

            -- Shortcut dismount from journal mounts. This has the (wanted) side
            -- effect of dismounting you even from mounts that aren't enabled,
            -- and the (wanted) side effect of dismounting while in moonkin form
            -- without cancelling it.

            if IsMounted() then
                LM.Debug("  * setting action to dismount")
                action = LM.SecureAction:Execute(Dismount)
            else
                -- Otherwise we look for the mount from its buff and return the cancel
                -- actions.
                local m = LM.MountRegistry:GetActiveMount()
                if m and m:IsCancelable() then
                    LM.Debug("  * setting action to cancel " .. m.name)
                    action = m:GetCancelAction()
                end
            end

            -- This obeys "Auto Dismount in Flight", otherwise it would need a
            -- macrotext and not work from the actionbar.
            if action and savedFormName and savedFormName ~= GetFormNameWithSubtext() then
                local autoDismount = not IsFlying() or GetCVarBool('autoDismountFlying')
                if autoDismount or GetShapeshiftFormID() then
                    LM.Debug("  * override action to restore form: " .. savedFormName)
                    action = LM.SecureAction:Spell(savedFormName)
                end
            end

            if action then
                savedFormName = nil
                return action
            elseif LM.Options:GetOption('restoreForms') then
                -- Save current form, if any
                local currentFormID = GetShapeshiftFormID()
                if currentFormID and restoreFormIDs[currentFormID] then
                    savedFormName = GetFormNameWithSubtext()
                    LM.Debug("  * saving current form " .. savedFormName)
                end
            end
        end
}

-- CancelForm has been absorbed into Dismount
ACTIONS['CancelForm'] = {
    argType = 'none',
    handler = function (args, context) end
}

-- Got a player target, try copying their mount
ACTIONS['CopyTargetsMount'] = {
    argType = 'none',
    handler =
        function (args, context)
            local unit = context.rule.unit or "target"
--          if LM.Options:GetOption('copyTargetsMount') and UnitIsPlayer(unit) then
            if LM.Options:GetOption('copyTargetsMount') then
                LM.Debug("  * trying to clone %s's mount", unit)
                local m = LM.MountRegistry:GetMountFromUnitAura(unit)
                if m and m:IsCastable() then
                    LM.Debug("  * setting action to mount %s", m.name)
                    return m:GetCastAction(context)
                end
            end
        end
}

ACTIONS['ApplyRules'] = {
    argType = 'none',
    handler =
        function (args, context)
            local ruleSet = LM.Options:GetCompiledRuleSet(context.id)
            LM.Debug("  * checking %d rules for button %d", #ruleSet, context.id)
            local act, n = ruleSet:Run(context)
            if act then
                LM.Debug("  * found matching rule %d", n)
                return act
            end
            LM.Debug("  * no rules matched")
        end
}

local switchSpellID = C_MountJournal.GetDynamicFlightModeSpellID()
local switchSpellInfo = C_Spell.GetSpellInfo(switchSpellID or 0)

ACTIONS['SwitchFlightStyle'] = {
    name = switchSpellInfo and switchSpellInfo.name,
    argType = 'valueOrNone',
    toDisplay =
        function (args)
            if #args == 0 then
                return { switchSpellInfo.name }
            else
                -- XXX if there is a localization for Steady Flight it would
                -- be better to return it instead of L.FLY
                local typeName =  L[args[1]] or UNKNOWN
                return { switchSpellInfo.name .. ': ' .. typeName }
            end
        end,
    handler =
        function (args, context)
            if IsPlayerSpell(switchSpellID) then
                local argList = args:ParseList()
                if #argList == 0 or LM.Environment.flightStyle  ~= argList[1] then
                    LM.Debug("  * setting action to spell " .. switchSpellInfo.name)
                    return LM.SecureAction:Spell(switchSpellID, context.rule.unit)
                end
            end
        end
}

local castableArg = LM.RuleArguments:Get("CASTABLE")
local enabledArg = LM.RuleArguments:Get("ENABLED")

local smartActions = {
    {
        -- Only original aquatic mounts are sped up by the buff in Vashj'ir,
        -- newer hybrid ones like Ottuks are slow.
        condition   = "[submerged,map:203]",
        arg         = LM.RuleArguments:Get('mt:231', '/', 'mt:254'),
        debug       = "Aquatic Mount (Vashj'ir)",
    },
    {
        condition   = "[submerged]",
        arg         = LM.RuleArguments:Get('SWIM'),
        debug       = "Aquatic Mount (underwater)",
    },
    {
        condition   = "[flyable,advflyable]",
        arg         = LM.RuleArguments:Get('DRAGONRIDING'),
        debug       = "Skyriding Mount",
    },
    {
        condition   = "[flyable]",
        arg         = LM.RuleArguments:Get('FLY'),
        debug       = 'Flying Mount',
    },
    {
        condition   = "[drivable]",
        arg         = LM.RuleArguments:Get('DRIVE'),
        debug       = 'D.R.I.V.E.',
    },
    {
        condition   = "[floating,nowaterwalking]",
        arg         = LM.RuleArguments:Get('SWIM'),
        debug       = "Aquatic Mount (on the surface)",
    },
    {
        condition   = "[]",
        arg         = LM.RuleArguments:Get('RUN', ',', '~', 'SLOW'),
        debug       = "Ground Mount",
    },
    {
        condition   = "[]",
        arg         = LM.RuleArguments:Get('RUN', ',', 'SLOW'),
        debug       = "Slow Ground Mount",
    },
}

ACTIONS['Downshift'] = {
    argType = 'none',
    handler =
        function (args, context)
            LM.Debug("  * adding mount downshift limit.")
            if LM.Conditions:Check("[submerged]", context) then
                table.insert(context.limits, LM.RuleArguments:Get("-", "SWIM"))
            elseif LM.Conditions:Check("[flyable]", context) then
                table.insert(context.limits, LM.RuleArguments:Get("-", "DRAGONRIDING"))
                table.insert(context.limits, LM.RuleArguments:Get("-", "FLY"))
            elseif LM.Conditions:Check("[drivable]", context) then
                table.insert(context.limits, LM.RuleArguments:Get("-", "DRIVE"))
            elseif LM.Conditions:Check("[floating]", context) then
                table.insert(context.limits, LM.RuleArguments:Get("-", "SWIM"))
            end
        end,
}

ACTIONS['Mount'] = {
    name = L.LM_MOUNT_ACTION,
    description = L.LM_MOUNT_DESCRIPTION,
    argType = 'expression',
    toDisplay = MountListToDisplay,
    handler =
        function (args, context)
            local limits = CopyTable(context.limits)
            table.insert(limits, castableArg)
            if context.rule.priority then
                table.insert(limits, enabledArg)
            end
            if #args > 0 then
                table.insert(limits, args)
            end
            local filteredList = LM.MountRegistry:Limit(limits)

            LM.Debug("  * args: " .. args:ToString())
            LM.Debug("  * limits:")
            for i, l in ipairs(limits) do
                LM.Debug("    % 2d. %s", i, l:ToString())
            end
            LM.Debug("  * filtered list contains " .. #filteredList .. " mounts")

            -- XXX FIXME XXX set context.allMountsDisabled somehow?
            if next(filteredList) == nil then return end

            local mounts

            if context.rule.smart then
                for _, info in ipairs(smartActions) do
                    if LM.Conditions:Check(info.condition, context) then
                        LM.Debug("  * trying " .. info.debug)
                        local expr = info.arg:ParseExpression()
                        mounts = filteredList:ExpressionSearch(expr)
                        LM.Debug("  * found " .. #mounts .. " mounts.")
                        if #mounts > 0 then
                            break
                        end
                    end
                end
            else
                mounts = filteredList
            end

            -- It is only by good luck rather than good programming that we
            -- always reach here with mounts ~= nil and I should do something
            -- about that sometime.

            local m

            -- Clear the persisted mount if it's time. This logic is fairly
            -- wasteful in the common case of keepTime == 0, but also it needs
            -- to deal with the case where you turn keepTime from non-0 to 0.

            local keepTime = LM.Options:GetOption('randomKeepSeconds')
            local persistTime = GetTime() - (context.persistTime or 0)
            if  persistTime > keepTime then
                context.self.persistMount = nil
                context.self.persistTime = GetTime()
            elseif context.persistMount then
                m = mounts:Find(function (x) return x == context.persistMount end)
                LM.Debug('  * persistMount found %s', m and m.name or 'nil')
            end

            if not m then
                local randomStyle = context.rule.priority and LM.Options:GetOption('randomWeightStyle')
                m = mounts:Random(randomStyle)
            end

            if m then
                LM.Debug("  * setting action to mount %s", m.name)
                context.self.persistMount = m
                return m:GetCastAction(context), m
            end
        end
}

ACTIONS['SmartMount'] = {
    name = L.LM_SMARTMOUNT_ACTION,
    description = L.LM_SMARTMOUNT_DESCRIPTION,
    argType = 'expression',
    toDisplay = MountListToDisplay,
    handler =
        function (args, context)
            context.rule.priority = true
            context.rule.smart = true
            return ACTIONS.Mount.handler(args, context)
        end
}

ACTIONS['PriorityMount'] = {
    name = L.LM_PRIORITYMOUNT_ACTION,
    description = L.LM_PRIORITYMOUNT_DESCRIPTION,
    argType = 'expression',
    toDisplay = MountListToDisplay,
    handler =
        function (args, context)
            context.rule.priority = true
            return ACTIONS.Mount.handler(args, context)
        end
}

ACTIONS['Macro'] = {
    argType = 'none',
    handler =
        function (args, context)
            local macrotext = LM.Macro:GetMacro()
            if macrotext then
                if GetRunningMacro() then
                    LM.Debug("  * unavailable macro not possible from actionbar")
                else
                    LM.Debug("  * setting action to unavailable macro")
                    return LM.SecureAction:Macro(macrotext)
                end
            end
        end
}

ACTIONS['Script'] = {
    argType = 'macrotext',
    handler =
        function (args, context)
            if GetRunningMacro() then
                LM.Debug("  * Script action not available from actionbar")
            else
                local macroText = args:ToString()
                LM.Debug("  * setting action to script line: " .. macroText)
                return LM.SecureAction:Macro(macroText)
            end
        end
}

ACTIONS['CantMount'] = {
    argType = 'none',
    handler =
        function (args, context)
            if context.allMountsDisabled then
                LM.Warning(L.LM_ERR_ALL_MOUNTS_DISABLED)
                LM.Debug("  * setting action to NoAction due to all mounts disabled")
            else
                -- This isn't a great message, but there isn't a better one that
                -- Blizzard have already localized. See FrameXML/GlobalStrings.lua.
                -- LM.Warning("You don't know any mounts you can use right now.")
                LM.Warning(SPELL_FAILED_NO_MOUNTS_ALLOWED)
                LM.Debug("  * setting action to NoAction due to situation")
            end
            return LM.SecureAction:NoAction()
        end
}

-- In a theoretical world these could be rules, but the number of times you can do
-- something at all useful in combat at the moment is 1. It's hard to imagine
-- anything else useful you'd want to do in combat that isn't covered by the much
-- simpler combatMacro. If that were done it would need some way to override the normal
-- CASTABLE check for mounts since they won't be castable right away.
--
-- E.g, Mount [map:2234] DRAGONRIDING

local function SummonJournalMountDirect(context, flag)
    if IsMounted() then
        LM.Debug("  * calling dismount directly")
        Dismount()
    else
        LM.Debug("  * summoning a journal mount directly")
        local mounts = LM.MountRegistry:FilterSearch(flag, 'JOURNAL', 'CASTABLE')
        LM.Debug("  * found %d suitable journal mounts", #mounts)
        local randomStyle = LM.Options:GetOption('randomWeightStyle')
        local m = mounts:Random(randomStyle) or mounts:Random()
        if m then
            LM.Debug("  * summoning %s (id=%d)", m.name, m.mountID)
            C_MountJournal.SummonByID(m.mountID)
        end
    end
end

local function GetCombatMountAction(context, flag)
    -- C_MountJournal.SummonByID will fail if you are in a shapeshift form.
    if UnitClassBase("player") == "DRUID" then
        local act = LM.SecureAction:Macro("/cancelform [form]")
        act:AddExecute(function () SummonJournalMountDirect(context, flag) end)
        return act
    end
    return LM.SecureAction:Execute(function () SummonJournalMountDirect(context, flag) end)
end

local function CombatHandlerOverride(args, context)
    -- For speed these should try to return ASAP.

    -- It seems obvious that you should use the encounter info here, but
    -- if you are the one who pulled it's not set yet and doesn't work.

    -- When selecting maps be sure to consider the case where you get
    -- brezzed and are on a different map when entering combat anew.
    -- Auras are also generally not useful because they aren't on you
    -- when combat begins.

    -- Tindral Sageswift, Amirdrassil (DF). 2234 is the parent of all the
    -- relevant maps.
    if LM.Environment:IsMapInPath(2234) then
        return GetCombatMountAction(context, 'DRAGONRIDING')
    end

    -- Dimensius, Manaforge Omega raid (TWW)
    if LM.Environment:IsInInstance(2810) then
        local mapID = C_Map.GetBestMapForUnit('player')
        if mapID >= 2467 and mapID <= 2470 then
            return GetCombatMountAction(context, 'DRAGONRIDING')
        end
    end

    -- The Dawnbreaker dungeon (The War Within)
    if LM.Environment:IsInInstance(2662) then
        return GetCombatMountAction(context, 'DRAGONRIDING')
    end
end

-- Combat handler is a bit magic because it's called from PLAYER_REGEN_DISABLED
-- rather than by user activation, so you can't tell if it's being called from
-- a macro (and thus won't work).
ACTIONS['Combat'] = {
    argType = 'none',
    handler =
        function (args, context)
            -- If specific combat macro is set always use it
            local macrotext = LM.Macro:GetMacro(true)
            if macrotext then
                LM.Debug("  * setting action to options combat macro")
                return LM.SecureAction:Macro(macrotext)
            end
            -- Check for an override combat setting
            local act = CombatHandlerOverride(args, context)
            if act then
                LM.Debug("  * setting action to %s", act:GetDescription())
                return act
            end
            -- Otherwise use the default actions
            LM.Debug("  * setting action to default combat macro")
            macrotext = LM.Macro:DefaultCombatMacro()
            return LM.SecureAction:Macro(macrotext)
        end
}

ACTIONS['Stop'] = {
    argType = 'none',
    handler =
        function (args, context)
            -- return true and set up to do nothing
            LM.Debug("  * setting action to nothing for stop")
            return LM.SecureAction:NoAction()
        end
}

ACTIONS['ForceNewRandom'] = {
    -- Note these strings do not exist yet and need to be added before this
    -- could be added to rules, if that was even a good idea.
    name = L.LM_FORCE_NEW_RANDOM_ACTION,
    description = L.LM_FORCE_NEW_RANDOM_DESCRIPTION,
    argType = 'list',
    handler =
        function (args, context)
            local buttons = args:ParseList()
            if next(buttons) == nil then
                LM.Debug("  * forced new random selection for button: %d", context.id)
                context.self.persistMount = nil
                context.self.persistTime = GetTime()
            else
                LM.Debug("  * forced new random selection for buttons: %s", args:ToString())
                for _, n in ipairs(buttons) do
                    n = tonumber(n)
                    if n and context.button[n] then
                        context.button[n].persistMount = nil
                        context.button[n].persistTime = GetTime()
                    end
                end
            end
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
    elseif not C_Item.IsUsableItem(itemID) then
        return false
    elseif C_Item.IsEquippableItem(itemID) and not C_Item.IsEquippedItem(itemID) then
        return false
    end

    local s, d, e = C_Container.GetItemCooldown(itemID)
    if s == 0 and (e == true or e == 1) then
        return true
    end

    return false
end

-- A derpy version of SecureCmdItemParse that doesn't support bags but does
-- support item IDs as well as slot names. The assumption is that if you have
-- the item then GetItemName will always return values immediately.

local function UsableItemParse(arg)
    local name, itemID, slotNum

    local slotOrID = tonumber(arg)
    if slotOrID and slotOrID <= INVSLOT_LAST_EQUIPPED then
        slotNum = slotOrID
    elseif slotOrID then
        name = C_Item.GetItemNameByID(slotOrID)
        itemID = slotOrID
    else
        local slotName = "INVSLOT_"..arg:upper()
        if _G[slotName] then
            slotNum = _G[slotName]
        else
            name = arg
            itemID = C_Item.GetItemInfoInstant(arg)
        end
    end

    return name, itemID, slotNum
end

-- Is this really not in the game anywhere?
local InventorySlotTable = {
    [INVSLOT_AMMO]      = AMMOSLOT,
    [INVSLOT_HEAD]      = HEADSLOT,
    [INVSLOT_NECK]      = NECKSLOT,
    [INVSLOT_SHOULDER]  = SHOULDERSLOT,
    [INVSLOT_BODY]      = SHIRTSLOT,
    [INVSLOT_CHEST]     = CHESTSLOT,
    [INVSLOT_WRIST]     = WRISTSLOT,
    [INVSLOT_HAND]      = HANDSSLOT,
    [INVSLOT_WAIST]     = WAISTSLOT,
    [INVSLOT_LEGS]      = LEGSSLOT,
    [INVSLOT_FEET]      = FEETSLOT,
    [INVSLOT_FINGER1]   = FINGER0SLOT .. " (1)",
    [INVSLOT_FINGER2]   = FINGER1SLOT .. " (2)",
    [INVSLOT_TRINKET1]  = TRINKET0SLOT .. " (1)",
    [INVSLOT_TRINKET2]  = TRINKET1SLOT .. " (2)",
    [INVSLOT_BACK]      = BACKSLOT,
    [INVSLOT_MAINHAND]  = MAINHANDSLOT,
    [INVSLOT_OFFHAND]   = SECONDARYHANDSLOT,
    [INVSLOT_RANGED]    = RANGEDSLOT,
    [INVSLOT_TABARD]    = TABARDSLOT,
}

local function ItemArgsToDisplay(args)
    local out = {}
    for _, v in ipairs(args:ParseList()) do
        local name, id, slot = UsableItemParse(v)
        if name then
            table.insert(out, string.format("%s (%d)", name, id))
        elseif slot then
            table.insert(out, InventorySlotTable[slot] or slot)
        else
            table.insert(out, v)
        end
    end
    return out
end

ACTIONS['Use'] = {
    name = L.LM_USE_ACTION,
    description = L.LM_USE_DESCRIPTION,
    argType = 'list',
    toDisplay = ItemArgsToDisplay,
    handler =
        function (args, context)
            for _, arg in ipairs(args:ParseList()) do
                local name, itemID, slotNum = UsableItemParse(arg)
                if slotNum then
                    LM.Debug('  * trying slot ' .. tostring(slotNum))
                    local s, d, e = GetInventoryItemCooldown('player', slotNum)
                    if s == 0 and e == 1 then
                        LM.Debug('  * Setting action to use slot ' .. slotNum)
                        return LM.SecureAction:Item(slotNum, context.rule.unit)
                    end
                else
                    LM.Debug('  * trying item ' .. tostring(name))
                    if name and IsCastableItem(itemID) then
                        LM.Debug('  * setting action to use item ' .. name)
                        return LM.SecureAction:Item(name, context.rule.unit)
                    end
                end
            end
        end
}

ACTIONS['PreUse'] = {
    name = L.LM_PREUSE_ACTION,
    description = L.LM_PREUSE_DESCRIPTION,
    argType = 'list',
    toDisplay = ItemArgsToDisplay,
    handler =
        function (args, context)
            local action = ACTIONS['Use'].handler(args, context)
            if action and action.item then
                LM.Debug("  * setting preUse to item " .. action.item)
                context.preUse = action.item
                context.preCast = nil
                return
            end
        end
}

ACTIONS['Falling'] = {
    name = L.LM_FALLING_ACTION,
    description = L.LM_SPELL_DESCRIPTION,
    argType = 'none',
    handler =
        function (args, context)
            for _, action in ipairs(LM.Options:GetOption('falling')) do
                local type, id = string.split(':', action)
                if type == 'spell' then
                    local _, _, nameWithSubtext = GetUsableSpell(id)
                    if nameWithSubtext then
                        return LM.SecureAction:Spell(nameWithSubtext, context.rule.unit)
                    end
                elseif type == 'item' then
                    local name, itemID = UsableItemParse(id)
                    if IsCastableItem(itemID) then
                        return LM.SecureAction:Item(name, context.rule.unit)
                    end
                end
            end
        end
}

do
    -- Add the name from the table key to the info table
    for actionName, info in pairs(ACTIONS) do
        info.action = actionName
    end
end

--[[------------------------------------------------------------------------]]--

LM.Actions = { }

function LM.Actions:GetArgType(action)
    if FLOWCONTROLS[action] then
        return 'none'
    elseif ACTIONS[action] then
        return ACTIONS[action].argType
    end
end

function LM.Actions:GetFlowControlHandler(action)
    return FLOWCONTROLS[action]
end

function LM.Actions:GetHandler(action)
    local a = ACTIONS[action]
    if a then return a.handler end
end

function LM.Actions:IsFlowSkipped(context)
    return ContainsIf(context.flowControl, function (v) return v ~= 1 end)
end

-- This is really terrible and only works for a minimal amount of things
-- which rules might do, which is so far only one mount or group or type etc.
-- It will probably break if I ever make rules actions even slightly flexible.

function LM.Actions:ToDisplay(action, args)
    local a = ACTIONS[action]
    if a then
        local name = a.name or action
        if args == nil then
            return name
        elseif a.toDisplay then
            return name, table.concat(a.toDisplay(args), "\n")
        else
            return name, args:ToString()
        end
    else
        return action.." |A:gmchat-icon-alert:15:15|a", args:ToString()
    end
end

function LM.Actions:GetDescription(action)
    local a = ACTIONS[action]
    if a then return a.description end
end
