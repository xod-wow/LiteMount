--[[----------------------------------------------------------------------------

  LiteMount/RuleContext.lua

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

local template = {
    limits = {},
    flowControl = {},
    rule = {},
}

LM.RuleContext = {}

function LM.RuleContext:New(t)
    return CreateFromMixins(t or {}, template, LM.RuleContext)
end

function LM.RuleContext:Clone()
    return CopyTable(self)
end

function LM.RuleContext:Clear()
    table.wipe(self)
    return Mixin(self, template)
end

function LM.RuleContext:Save()
    self.__saved = self:Clone()
end

function LM.RuleContext:Restore()
    if self.__saved then
        local old = self.__saved
        table.wipe(self)
        Mixin(self, old)
    end
end

function LM.RuleContext:ClearSaved()
    self.__saved = nil
end
