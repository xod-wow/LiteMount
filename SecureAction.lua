--[[----------------------------------------------------------------------------

  LiteMount/SecureAction.lua

  A set of secure attributes that know how to put themselves onto a button
  to perform an action.

  Way too many things in this addon are named "action" and I should think of
  better names.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

-- This wrapper class is so that LM.ActionButton can treat all of the returns
-- from action functions as if they were a Mount class.

LM.SecureAction = { }
LM.SecureAction.__index = LM.SecureAction

function LM.SecureAction:New(attr)
    return setmetatable(attr, LM.SecureAction)
end

function LM.SecureAction:SetupActionButton(button, mouseButtonIndex)
    button:SetAttribute('type', self.type)
    button.clickHookFunction = self.EXECUTE
    for k,v in pairs(self) do
        if k ~= 'type' and k ~= 'EXECUTE' then
            if mouseButtonIndex then
                k = k .. tostring(mouseButtonIndex)
            end
            button:SetAttribute(k, v)
        end
    end
    -- https://github.com/Stanzilla/WoWUIBugs/issues/317#issuecomment-1510847497
    button:SetAttribute("pressAndHoldAction", true)
    button:SetAttribute("typerelease", button:GetAttribute("type"))
end

function LM.SecureAction:ClearActionButton(button)
    button.clickHookFunction = nil
    button:SetAttribute('type', nil)
    button:SetAttribute('typerelease', nil)
end

function LM.SecureAction:NoAction()
    return self:New( {
                ["type"] = nil,
            } )
end

function LM.SecureAction:Macro(macroText, unit)
    return self:New( {
                ["type"] = "macro",
                ["macrotext"] = macroText,
                ["unit"] = unit or "player",
            } )
end

function LM.SecureAction:Spell(spellName, unit)
    local attr = {
            ["type"] = "spell",
            ["unit"] = unit or "player",
            ["spell"] = spellName
    }
    return self:New(attr)
end

function LM.SecureAction:CancelAura(spellName, unit)
    local attr = {
            ["type"] = "cancelaura",
            ["spell"] = spellName
    }
    return self:New(attr)
end

function LM.SecureAction:Item(useArg, unit)
    local attr = {
            ["type"] = "item",
            ["unit"] = unit or "player",
            ["item"] = useArg
    }
    return self:New(attr)
end

function LM.SecureAction:LeaveVehicle()
    local attr = {
        ["type"] = "leavevehicle",
    }
    return self:New(attr)
end

function LM.SecureAction:Click(clickButton)
    local attr = {
            ["type"] = "click",
            ["clickbutton"] = clickButton
    }
    return self:New(attr)
end

function LM.SecureAction:AddExecute(script)
    if type(script) == 'string' then
        script = loadstring(script)
    end
    self.EXECUTE = script
end

function LM.SecureAction:Execute(script)
    local act = LM.SecureAction:New({})
    act:AddExecute(script)
    return act
end

function LM.SecureAction:GetDescription()
    if self.type == 'spell' or self.type == 'cancelaura' then
        return format("%s %s", self.type, self.spell)
    elseif self.type == 'item' then
        return format("%s %s", self.type, self.item)
    elseif self.type == 'click' then
        return format("%s %s", self.type, self.clickbutton)
    elseif self.EXECUTE then
        return 'function'
    else
        return self.type
    end
end
