--[[----------------------------------------------------------------------------

  LiteMount/ActionButton.lua

  A SecureActionButton to call mount actions based on an action list.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

LM_ActionButton = CreateFrame("Button", nil, nil, "SecureActionButtonTemplate")
LM_ActionButton.__index = LM_ActionButton

-- Fancy SecureActionButton stuff. The default button mechanism is
-- type="macro" macrotext="...". If we're not in combat we
-- use a preclick handler to set it to what we really want to do.

function LM_ActionButton:SetupActionButton(mount)
    for k,v in pairs(mount:GetSecureAttributes()) do
        self:SetAttribute(k, v)
    end
end

function LM_ActionButton:Dispatch(action, filters)

    local handler = LM_Actions:GetHandler(action)
    if not handler then
        LM_WarningAndPrint(format("Error: bad action '%s' in action list.", action))
        return
    end

    LM_Debug("Dispatching action " .. action .. " with filters " .. table.concat(filters or {}, ' '))

    -- This is super ugly.
    local m = handler(filters)
    if not m then return end

    LM_Debug("Setting up button as " .. (m.name or action) .. ".")
    self:SetupActionButton(m)

    return true
end

function LM_ActionButton:CompileActions()
    local actionList = LM_Options.db.profile.buttonActions[self.id]
    self.actions = LM_ActionList:Compile(actionList)
end

function LM_ActionButton:PreClick(mouseButton)

    if InCombatLockdown() then return end

    LM_Debug("PreClick handler called on " .. self:GetName())

    LM_PlayerMounts:RefreshMounts()

    for _,a in ipairs(self.actions) do
        if LM_Conditions:Eval(a.conditions) then
            if self:Dispatch(a.action, a.filters) then
                return
            end
        end
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

    self:SetupActionButton(LM_Actions:GetHandler('Combat')())
end

function LM_ActionButton:Create(n)

    local name = "LM_B" .. n

    local b = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate")
    setmetatable(b, LM_ActionButton)

    -- So we can look up action lists in LM_Options
    b.id = n

    b:CompileActions()

    -- Button-fu
    b:RegisterForClicks("AnyDown")

    -- SecureActionButton setup
    b:SetScript("PreClick", self.PreClick)
    b:SetScript("PostClick", self.PostClick)

    b:PostClick()

    return b
end
