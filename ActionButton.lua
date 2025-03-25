--[[----------------------------------------------------------------------------

  LiteMount/ActionButton.lua

  A SecureActionButton to call mount rules based on an action list.

  Fancy SecureActionButton stuff. The default button mechanism is
  type="macro" macrotext="...". If we're not in combat we
  use a preclick handler to set it to what we really want to do.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

LM.ActionButton = { }

-- inputButton here is not real, because only LeftButton comes through the
-- keybinding interface. But, you can pass arbitrary text as this argument
-- with the /click slash command. E.g., /click LM_B1 blah

function LM.ActionButton:PreClick(inputButton, isDown)

    -- SecureActionButtonTemplate in 10.0 only fires the secure actions when
    -- isDown matches the setting of ActionButtonUseKeyDown, even though it
    -- fires PreClick and PostClick for both. Due to poor code for for
    -- handling press-and-hold and the interns doing all the programming.
    --
    -- So our buttons are RegisterForClicks("AnyDown", "AnyUp"), this (and
    -- PostClick) get called twice and we only handle it if we match when
    -- Blizzard will call the actions.
    --
    -- Hilarously the Blizzard code has a comment saying "but we do want to
    -- allow AddOns to function as they did before"... and then they don't.
    -- Epic fail Blizzard!

    -- https://github.com/Stanzilla/WoWUIBugs/issues/317#issuecomment-1510847497
    -- if isDown ~= GetCVarBool("ActionButtonUseKeyDown") then return end

    local startTime = debugprofilestop()

    LM.Debug("[%d] PreClick handler (inputButton=%s, isDown=%s)",
             self.id, tostring(inputButton), tostring(isDown))

    if InCombatLockdown() then
        if GetRunningMacro() and self:GetAttribute("type") == 'macro' then
            if IsMounted() then
                Dismount()
            elseif CanExitVehicle() then
                VehicleExit()
            end
            LM.Debug("[%d] In combat direct time %0.2fms", self.id, debugprofilestop() - startTime)
        else
            LM.Debug("[%d] In combat abort time %0.2fms", self.id, debugprofilestop() - startTime)
        end
        return
    end

    LM.MountRegistry:RefreshMounts()

    -- Re-randomize if it's time, and update the last mount. Previously I was just
    -- relying on the random seed for the persistence, but "least summoned" isn't
    -- random. On the other hand, the seed is better because it will pick the same
    -- mount from each different set. So, now I have both I guess.

    local keepRandomForSeconds = LM.Options:GetOption('randomKeepSeconds')
    if GetTime() - (self.context.randomTime or 0) > keepRandomForSeconds then
        self.context.random = math.random()
        self.context.randomTime = GetTime()
        self.context.forceSummon = nil
    else
        -- Note, can't store objects in context, they don't survive Clone()
        local lastSummonedMount = LM.MountRegistry:GetLastSummoned()
        self.context.forceSummon = lastSummonedMount and lastSummonedMount.spellID
    end

    -- Set up the fresh run context for a new run.
    local context = self.context:Clone()
    context.inputButton = inputButton

    -- This uses a crazy amount of memory so just save it once
    context.mapPath = LM.Environment:GetMapPath()

    local ruleSet = LM.Options:GetCompiledButtonRuleSet(self.id)

    local act = ruleSet:Run(context)
    if act then
        act:SetupActionButton(self)
        LM.Debug("[%d] PreClick ok time %0.2fms", self.id, debugprofilestop() - startTime)
        return
    end

    local handler = LM.Actions:GetHandler('CantMount')
    handler():SetupActionButton(self)
    LM.Debug("[%d] PreClick fail time %0.2fms", self.id, debugprofilestop() - startTime)
end

-- Non-secure execute actions are done here with the SABT setup blank

function LM.ActionButton:OnClickHook(inputButton, isDown)
    if self.clickHookFunction then
        self.clickHookFunction()
    end
end

function LM.ActionButton:PostClick(inputButton, isDown)
    local startTime = debugprofilestop()

    LM.Debug("[%d] PostClick handler (inputButton=%s, isDown=%s)",
             self.id, tostring(inputButton), tostring(isDown))

    LM.Environment:ClearMouseButtonClicked()

    if not InCombatLockdown() then
        LM.SecureAction:ClearActionButton(self)
    end

    LM.Debug("[%d] PostClick finish time %0.2fms", self.id, debugprofilestop() - startTime)
end

-- Combat actions trigger on PLAYER_REGEN_DISABLED which happens before
-- lockdown starts so we can still do secure things. Unlike other places
-- it's possible this will do SecureHandlerWrapScript if it's being called
-- from a macro.
function LM.ActionButton:OnEvent(e, ...)
    if e == "PLAYER_REGEN_DISABLED" then
        LM.Debug('[%d] Combat started', self.id)
        local args = LM.RuleArguments:Get()
        local context = self.context:Clone()
        local act = LM.Actions:GetHandler('Combat')(args, context)
        if act then
            act:SetupActionButton(self)
        end
    elseif e == "PLAYER_REGEN_ENABLED" then
        LM.Debug('[%d] Combat ended', self.id)
        LM.SecureAction:ClearActionButton(self)
    end
end

function LM.ActionButton:Create(n)

    local name = "LM_B" .. n

    local b = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate")
    Mixin(b, LM.ActionButton)

    -- So we can look up action lists in LM.Options
    b.id = n

    -- Global context
    b.context = LM.RuleContext:New({ id = n })

    -- b:RegisterForClicks("AnyDown", "AnyUp")
    -- https://github.com/Stanzilla/WoWUIBugs/issues/317#issuecomment-1510847497
    b:RegisterForClicks("AnyDown")

    -- SecureActionButton setup
    b:SetScript("PreClick", self.PreClick)
    b:HookScript("OnClick", self.OnClickHook)
    b:SetScript("PostClick", self.PostClick)

    -- Events handler for combat setup just before lockdown starts/ends
    b:RegisterEvent("PLAYER_REGEN_DISABLED")
    b:RegisterEvent("PLAYER_REGEN_ENABLED")
    b:SetScript('OnEvent', self.OnEvent)

    return b
end
