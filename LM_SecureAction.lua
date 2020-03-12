--[[----------------------------------------------------------------------------

  LiteMount/LM_SecureAction.lua

  Copyright 2011-2020 Mike Battersby

----------------------------------------------------------------------------]]--

--@debug@
if LibDebug then LibDebug() end
--@end-debug@

-- This wrapper class is so that LM_ActionButton can treat all of the returns
-- from action functions as if they were a Mount class.

_G.LM_SecureAction = { }
LM_SecureAction.__index = LM_SecureAction

function LM_SecureAction:New(attr)
    return setmetatable(attr, LM_SecureAction)
end

function LM_SecureAction:Macro(macroText)
    return self:New( { ["type"] = "macro", ["macrotext"] = macroText } )
end

function LM_SecureAction:Spell(spellName)
    local attr = {
            ["type"] = "spell",
            ["unit"] = "player",
            ["spell"] = spellName
    }
    return self:New(attr)
end

function LM_SecureAction:Item(itemArg)
    local attr = {
            ["type"] = "item",
            ["unit"] = "player",
            ["item"] = itemArg
    }
    return self:New(attr)
end

function LM_SecureAction:Click(clickButton)
    local attr = {
            ["type"] = "click",
            ["clickbutton"] = clickButton
    }
    return self:New(attr)
end


function LM_SecureAction:GetSecureAttributes()
    return self
end
