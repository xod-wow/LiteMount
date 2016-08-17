--[[----------------------------------------------------------------------------

  LiteMount/ActionButton.lua

  A SecureActionButton to call mount actions based on an action list.

  Copyright 2011-2016 Mike Battersby

----------------------------------------------------------------------------]]--

LM_ActionButton = CreateFrame("Button", nil, nil, "SecureActionButtonTemplate")
LM_ActionButton.__index = LM_ActionButton

-- Fancy SecureActionButton stuff. The default button mechanism is
-- type="macro" macrotext="...". If we're not in combat we
-- use a preclick handler to set it to what we really want to do.

function LM_ActionButton:Dispatch(condAction)

    local action = condAction["action"]
    local conditions = condAction["conditions"]
    local args = condAction["args"]

    if not LM_Actions[action] then
        LM_Print(format("Error: bad action '%s' in action list.", action))
        return
    end

    if conditions then
        local t = LM_Conditions:Eval(conditions)
        LM_Debug(format("Eval \"%s\" -> %s", conditions, tostring(t)))
        if not t then return end
    end
        
    LM_Debug("Dispatching action " .. action .. "(" .. (args or "") .. ")")

    -- This is super ugly.
    local m = LM_Actions[action](LM_Actions, args)
    if not m then return end

    LM_Debug("Setting up button as " .. (m:Name() or action) .. ".")
    m:SetupActionButton(self)

    return true
end

function LM_ActionButton:PreClick(mouseButton)

    if InCombatLockdown() then return end

    LM_Debug("PreClick handler called on " .. self:GetName())

    LM_PlayerMounts:ScanMounts()

    for i, condAction in ipairs(self.actionList) do
        if self:Dispatch(condAction) then return end
    end

    self:Dispatch({ action = "CantMount" })
end

function LM_ActionButton:PostClick()
    if InCombatLockdown() then return end

    LM_Debug("PostClick handler called.")

    -- We'd like to set the macro to undo whatever we did, but
    -- tests like IsMounted() and CanExitVehicle() will still
    -- represent the pre-action state at this point.  We don't want
    -- to just blindly do the opposite of whatever we chose because
    -- it might not have worked.

    LM_Actions:Combat():SetupActionButton(self)
end

function LM_ActionButton:LoadActionLines(actionLines)
    wipe(self.actionList)

    for _, line in ipairs({ strsplit("\r?\n", actionLines) }) do
        if line then
            self:LoadActionLine(line)
        end
    end
end

function LM_ActionButton:LoadActionLine(line)
    if line:match("^%s*$") then
        return
    end

    -- trim whitespace
    line = line:match("^%s*(.-)%s*$")

    local action, conditions = line:match("^(%S+)%s*(.*)$")
    if conditions == "" then
        conditions = "[]"
    end

    local args

    local i, j = action:find("%(.*%)$")
    if i ~= nil then
        LM_Debug(format("i, j = %d, %d", i, j))
        args = action:sub(i+1, j-1)
        action = action:sub(1, i-1)
    end

    tinsert(
        self.actionList,
        {
            ["action"] = action,
            ["args"] = args,
            ["conditions"] = conditions
        })
end

function LM_ActionButton:Create(n, actionLines)

    local name = "LiteMountActionButton" .. n

    local b = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate")
    setmetatable(b, LM_ActionButton)

    -- Save for use in PreClick handler
    b.actionList = { }
    b:LoadActionLines(actionLines)

    -- Button-fu
    b:RegisterForClicks("AnyDown")

    -- SecureActionButton setup
    b:SetScript("PreClick", self.PreClick)
    b:SetScript("PostClick", self.PostClick)

    b:PostClick()

    return b
end
