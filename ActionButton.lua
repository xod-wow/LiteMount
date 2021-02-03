--[[----------------------------------------------------------------------------

  LiteMount/ActionButton.lua

  A SecureActionButton to call mount actions based on an action list.

  Fancy SecureActionButton stuff. The default button mechanism is
  type="macro" macrotext="...". If we're not in combat we
  use a preclick handler to set it to what we really want to do.

  Copyright 2011-2021 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local L = LM.Localize

LM.ActionButton = { }

function LM.ActionButton:Dispatch(action, env)

    local isTrue
    isTrue, env.unit = LM.Conditions:Eval(action.conditions)

    local handler = LM.Actions:GetFlowControlHandler(action.action)
    if handler then
        LM.Debug("Dispatching flow control action " .. action.line)
        handler(action.args or {}, env, isTrue)
        return
    end

    if not isTrue or LM.Actions:IsFlowSkipped(env) then
        return
    end

    handler = LM.Actions:GetHandler(action.action)
    if not handler then
        LM.WarningAndPrint(format(L.LM_ERR_BAD_ACTION, action.action))
        return
    end

    LM.Debug("Dispatching action " .. action.line)

    local act = handler(action.args or {}, env)
    if act then
        act:SetupActionButton(self)
        return true
    end
end

function LM.ActionButton:CompileActions()
    local actionList = LM.Options:GetButtonAction(self.id)
    self.actions = LM.ActionList:Compile(actionList)
end

function LM.ActionButton:PreClick(mouseButton)

    if InCombatLockdown() then return end

    LM.Debug("PreClick handler called on " .. self:GetName())

    LM.PlayerMounts:RefreshMounts()

    -- Re-randomize if it's time
    local keepRandomForSeconds = LM.Options:GetRandomPersistence()
    if GetTime() - (self.globalEnv.randomTime or 0) > keepRandomForSeconds then
        self.globalEnv.random = math.random()
        self.globalEnv.randomTime = GetTime()
    end

    -- New sub-environment for this run
    local subEnv = CopyTable(self.globalEnv)

    -- Set up the fresh run environment for a new run.
    subEnv.filters = { { } }
    subEnv.flowControl = { }

    for _,a in ipairs(self.actions) do
        if self:Dispatch(a, subEnv) then
            return
        end
    end

    self:Dispatch({ action="CantMount", line="" }, subEnv)
end

function LM.ActionButton:PostClick()
    if InCombatLockdown() then return end

    LM.Debug("PostClick handler called on " .. self:GetName())

    -- We'd like to set the macro to undo whatever we did, but
    -- tests like IsMounted() and CanExitVehicle() will still
    -- represent the pre-action state at this point.  We don't want
    -- to just blindly do the opposite of whatever we chose because
    -- it might not have worked.

    local handler = LM.Actions:GetHandler('Combat')
    local act = handler()
    if act then
        act:SetupActionButton(self)
    end
end

function LM.ActionButton:Create(n)

    local name = "LM_B" .. n

    local b = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate")
    Mixin(b, LM.ActionButton)

    -- So we can look up action lists in LM.Options
    b.id = n

    -- Global actions environment
    b.globalEnv = { }

    -- Button-fu
    b:CompileActions()

    b:RegisterForClicks("AnyDown")

    -- SecureActionButton setup
    b:SetScript("PreClick", self.PreClick)
    b:SetScript("PostClick", self.PostClick)

    return b
end
