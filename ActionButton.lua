--[[----------------------------------------------------------------------------

  LiteMount/ActionButton.lua

  A SecureActionButton to call mount actions based on an action list.

  Copyright 2011-2015 Mike Battersby

----------------------------------------------------------------------------]]--

local function SetAsInCombatAction(self)
    LM_Action:Combat():SetupActionButton(self)
end

-- Fancy SecureActionButton stuff. The default button mechanism is
-- type="macro" macrotext="...". If we're not in combat we
-- use a preclick handler to set it to what we really want to do.

local function Dispatch(self, action, args)

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

local function PreClick(self, mouseButton)

    if InCombatLockdown() then return end

    LM_Debug("PreClick handler called on " .. self:GetName())

    LiteMount:ScanMounts()

    for action in gmatch(self.actionList, "%S+") do
        if Dispatch(self, action) then return end
    end

    Dispatch(self, "CantMount")
end

local function PostClick(self)
    if InCombatLockdown() then return end

    LM_Debug("PostClick handler called.")

    -- We'd like to set the macro to undo whatever we did, but
    -- tests like IsMounted() and CanExitVehicle() will still
    -- represent the pre-action state at this point.  We don't want
    -- to just blindly do the opposite of whatever we chose because
    -- it might not have worked.

    SetAsInCombatAction(self)
end

function LM_ActionButton_Create(n, actionList)

    local name = "LiteMountActionButton" .. n

    local b = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate")

    -- Save for use in PreClick handler
    b.actionList = actionList

    -- Button-fu
    b:RegisterForClicks("AnyDown")

    -- SecureActionButton setup
    b:SetScript("PreClick", PreClick)
    b:SetScript("PostClick", PostClick)

    SetAsInCombatAction(b)

    return b
end
