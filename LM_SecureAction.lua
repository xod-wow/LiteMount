--[[----------------------------------------------------------------------------

  LiteMount/LM_SecureAction.lua

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

-- This wrapper class is so that LM_ActionButton can treat all of the returns
-- from action functions as if they were a Mount class.

LM_SecureAction = { }
LM_SecureAction.__index = LM_SecureAction

function LM_SecureAction:New(attr)
    return setmetatable(attr, LM_SecureAction)
end

function LM_SecureAction:Macro(macrotext)
    return self:New( { ["type"] = "macro", ["macrotext"] = macrotext } )
end

function LM_SecureAction:Spell(spellname)
    local attr = {
            ["type"] = "spell",
            ["unit"] = "player",
            ["spell"] = spellname
    }
    return self:New(attr)
end

function LM_SecureAction:GetSecureAttributes()
    return self
end
