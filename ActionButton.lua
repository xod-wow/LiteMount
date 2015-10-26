--[[----------------------------------------------------------------------------

  LiteMount/ActionButton.lua

  A SecureActionButton to call mount actions based on an action list.

  Copyright 2011-2015 Mike Battersby

----------------------------------------------------------------------------]]--

LM_ActionButton = CreateFrame("Button", nil, nil, "SecureActionButtonTemplate")
LM_ActionButton.__index = LM_ActionButton

-- Fancy SecureActionButton stuff. The default button mechanism is
-- type="macro" macrotext="...". If we're not in combat we
-- use a preclick handler to set it to what we really want to do.

function LM_ActionButton:Dispatch(action, args)

    if not LM_Action[action] then
        LM_Print(format("Error: bad action '%s' in action list.", action))
        return
    end

    LM_Debug("Dispatching action " .. action .. ".")

    -- This is super ugly.
    local m = LM_Action[action](LM_Action, self, args)
    if not m then return end

    LM_Debug("Setting up button as " .. (m:Name() or action) .. ".")
    m:SetupActionButton(self)

    return true
end

function LM_ActionButton:PreClick(mouseButton)

    if InCombatLockdown() then return end

    LM_Debug("PreClick handler called on " .. self:GetName())

    LM_PlayerMounts:ScanMounts()

    for action in gmatch(self.actionList, "%S+") do
        if self:Dispatch(action) then return end
    end

    self:Dispatch("CantMount")
end

function LM_ActionButton:PostClick()
    if InCombatLockdown() then return end

    LM_Debug("PostClick handler called.")

    -- We'd like to set the macro to undo whatever we did, but
    -- tests like IsMounted() and CanExitVehicle() will still
    -- represent the pre-action state at this point.  We don't want
    -- to just blindly do the opposite of whatever we chose because
    -- it might not have worked.

    LM_Action:Combat():SetupActionButton(self)
end

function LM_ActionButton:Create(n, actionList)

    local name = "LiteMountActionButton" .. n

    local b = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate")
    setmetatable(b, LM_ActionButton)

    -- Save for use in PreClick handler
    b.actionList = actionList

    -- Button-fu
    b:RegisterForClicks("AnyDown")

    -- SecureActionButton setup
    b:SetScript("PreClick", self.PreClick)
    b:SetScript("PostClick", self.PostClick)

    b:PostClick()

    return b
end
