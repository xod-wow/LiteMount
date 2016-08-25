--[[----------------------------------------------------------------------------

  LiteMount/Mount/SecureAction.lua

  Copyright 2011-2016 Mike Battersby

----------------------------------------------------------------------------]]--

LM_SecureAction = setmetatable({ }, LM_Mount)
LM_SecureAction.__index = LM_SecureAction

function LM_SecureAction:Get(attr)
    local self = { ["attr"] = attr }
    return setmetatable(self, LM_SecureAction)
end

function LM_SecureAction:SetupActionButton(button)
    for k,v in pairs(self.attr) do
        button:SetAttribute(k, v)
    end
end

function LM_SecureAction:MacroText(macrotext)
    local m = self:Get( { ["type"] = "macro", ["macrotext"] = macrotext } )
    m.name = "MacroText"
    return m
end

function LM_SecureAction:Macro(macroname)
    local m = self:Get( { ["type"] = "macro", ["macro"] = macroname } )
    m.name = format("Macro: %s", macroname)
    return m
end

function LM_SecureAction:Spell(spellname)
    local m = self:Get({
                ["type"] = "spell",
                ["unit"] = "player",
                ["spell"] = spellname
            })
    m.name = spellname
    return m
end
