--[[----------------------------------------------------------------------------

  LiteMount/ActionButton.lua

  A SecureActionButton to call mount actions based on an action list.

  Copyright 2011-2016 Mike Battersby

----------------------------------------------------------------------------]]--

LM_ActionButton = CreateFrame("Button", "LM_ActionButton", UIParent, "SecureActionButtonTemplate")
LM_ActionButton.__index = LM_ActionButton

-- Fancy SecureActionButton stuff. The default button mechanism is
-- type="macro" macrotext="...". If we're not in combat we
-- use a preclick handler to set it to what we really want to do.

function LM_ActionButton:Dispatch(condAction)

    local action = condAction["action"]
    local conditions = condAction["conditions"]
    local args = condAction["args"]

    local handler = LM_Actions:GetHandler(action)

    if not handler then
        LM_Print(format("Error: bad action '%s' in action list.", action))
        return
    end

    if conditions then
        local t = LM_Conditions:Eval(conditions)
        LM_Debug(format("Eval \"%s\" -> %s", conditions, tostring(t)))
        if not t then return end
    end

    LM_Debug("Dispatching action " .. action .. "(" .. (args or "") .. ")")

    local m = handler(args)
    if m then
        LM_Debug("Setting up button as " .. (m.name or action) .. ".")
        m:SetupActionButton(self)
        return true
    end
end

function LM_ActionButton:PreClick(mouseButton)

    if InCombatLockdown() then return end

    LM_Debug("*** PreClick handler called on " .. self:GetName() .. " ***")

    for i, condAction in ipairs(self.actionList) do
        if self:Dispatch(condAction) then return end
    end

    self:Dispatch({ action = "CantMount" })
end

function LM_ActionButton:PostClick()
    if InCombatLockdown() then return end

    LM_Debug("PostClick handler called.")

    -- Switch back to the default combat actions.
    LM_Actions:GetHandler("Combat")():SetupActionButton(self)
end

function LM_ActionButton:LoadActionLines(actionLines)

    self.actionLines = ""
    wipe(self.actionList)

    for _, line in ipairs({ strsplit("\r?\n", actionLines) }) do
        -- trim whitespace
        line = line:match("^%s*(.-)%s*$")

        self.actionLines = self.actionLines .. line .. "\n"

        if line then
            local act = self:ParseActionLine(line)
            tinsert(self.actionList, act)
        end
    end
end

function LM_ActionButton:ParseActionLine(line)
    if line:match("^%s*$") then
        return
    end

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

    return {
            ["action"] = action,
            ["args"] = args,
            ["conditions"] = conditions
        }
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

function LM_ActionButton:GetActionList()
    return self.actionLines
end

