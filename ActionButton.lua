--[[----------------------------------------------------------------------------

  LiteMount/ActionButton.lua

  A SecureActionButton to call mount rules based on an action list.

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

function LM.ActionButton:CompileRules()
    local actionList = LM.Options:GetButtonAction(self.id)
    self.rules = LM.Rules:Compile(actionList)
end

-- mouseButton here is not real, because only LeftButton comes through the
-- keybinding interface. But, you can pass arbitrary text as this argument
-- with the /click slash command. E.g., /click LM_B1 blah

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

    -- Set up the fresh run environment for a new run.
    local subEnv = CopyTable(self.globalEnv)
    subEnv.filters = { { } }
    subEnv.flowControl = { }
    subEnv.clickArg = mouseButton

    for _,rule in ipairs(self.rules) do
        subEnv.unit = nil
        local act = LM.Rules:Dispatch(rule, subEnv)
        if act then
            act:SetupActionButton(self)
            return
        end
    end

    local handler = LM.Actions:GetHandler('CantMount')
    local act = handler()
    act:SetupActionButton(self)
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

    -- Global environment
    b.globalEnv = { id = n }

    -- Button-fu
    b:CompileRules()

    b:RegisterForClicks("AnyDown")

    -- SecureActionButton setup
    b:SetScript("PreClick", self.PreClick)
    b:SetScript("PostClick", self.PostClick)

    return b
end

function LM.ActionButton:HasApplyRules()
    for _,r in ipairs(self.rules) do
        if r.action == 'ApplyRules' then
            return true
        end
    end
    return false
end
