--[[----------------------------------------------------------------------------

  LiteMount/ActionButton.lua

  A SecureActionButton to call mount actions based on an action list.

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

local L = LM_Localize

_G.LM_ActionButton = { }

-- Fancy SecureActionButton stuff. The default button mechanism is
-- type="macro" macrotext="...". If we're not in combat we
-- use a preclick handler to set it to what we really want to do.

function LM_ActionButton:SetupActionButton(mount)
    for k,v in pairs(mount:GetSecureAttributes()) do
        self:SetAttribute(k, v)
    end
end

function LM_ActionButton:Dispatch(action, env)

    local isTrue, unit = LM_Conditions:Eval(action.conditions)

    -- Flow control actions use the run environment

    local handler = LM_Actions:GetFlowControlHandler(action.action)
    if handler then
        LM_Debug("Dispatching flow control action " .. action.action)
        handler(action.args or {}, env, isTrue)
        return
    end

    if not isTrue or LM_Actions:IsFlowSkipped(env) then
        return
    end

    handler = LM_Actions:GetHandler(action.action)
    if not handler then
        LM_WarningAndPrint(format(L.LM_ERR_BAD_ACTION, action.action))
        return
    end

    LM_Debug("Dispatching action " .. action.action)

    -- New sub-environment for this action
    local subEnv = CopyTable(env)
    subEnv.unit = unit

    local m = handler(action.args or {}, subEnv)
    if m then
        LM_Debug("Setting up button as " .. (m.name or action.action) .. ".")
        self:SetupActionButton(m)
        return true
    end
end

function LM_ActionButton:CompileActions()
    local actionList = LM_Options.db.profile.buttonActions[self.id]
    self.actions = LM_ActionList:Compile(actionList)
end

function LM_ActionButton:PreClick(mouseButton)

    if InCombatLockdown() then return end

    LM_Debug("PreClick handler called on " .. self:GetName())

    LM_PlayerMounts:RefreshMounts()

    -- Re-randomize if it's time
    local keepRandomForSeconds = LM_Options:GetRandomPersistence()
    if GetTime() - (self.globalEnv.randomTime or 0) > keepRandomForSeconds then
        self.globalEnv.random = math.random()
        self.globalEnv.randomTime = GetTime()
    end

    -- New sub-environment for this run
    local subEnv = CopyTable(self.globalEnv)

    -- Set up the fresh run environment for a new run.
    subEnv.filters = { { "CASTABLE", "ENABLED" } }
    subEnv.flowControl = { }

    for _,a in ipairs(self.actions) do
        if self:Dispatch(a, subEnv) then
            return
        end
    end

    self:Dispatch({ ['action'] = "CantMount" }, subEnv)
end

function LM_ActionButton:PostClick()
    if InCombatLockdown() then return end

    LM_Debug("PostClick handler called.")

    -- We'd like to set the macro to undo whatever we did, but
    -- tests like IsMounted() and CanExitVehicle() will still
    -- represent the pre-action state at this point.  We don't want
    -- to just blindly do the opposite of whatever we chose because
    -- it might not have worked.

    self:SetupActionButton(LM_Actions:GetHandler('Combat')())
end

function LM_ActionButton:Create(n)

    local name = "LM_B" .. n

    local b = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate")
    Mixin(b, LM_ActionButton)

    -- So we can look up action lists in LM_Options
    b.id = n

    -- Global actions environment
    b.globalEnv = { }

    -- Button-fu
    b:CompileActions()

    b:RegisterForClicks("AnyDown")

    -- SecureActionButton setup
    b:SetScript("PreClick", self.PreClick)
    b:SetScript("PostClick", self.PostClick)

    b:PostClick()

    return b
end
