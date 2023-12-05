--[[----------------------------------------------------------------------------

  LiteMount/UI/PriorityImport.lua

  Pop-over to allow import of priorities via cut-and-paste.

  Copyright 2011 Mike Battersby

----------------------------------------------------------------------------]]--

local _, LM = ...

local L = LM.Localize

--[[
/run LiteMountOptionsPanel_PopOver(LiteMountMountsPanel, LiteMountPriorityImport)
]]

LiteMountPriorityImportMixin = {}

function LiteMountPriorityImportMixin:Okay()
    local text = self.Scroll.EditBox:GetText()
    for line in text:gmatch('[^\r\n]+') do
    end
    -- self:Hide()
end

function LiteMountPriorityImportMixin:Cancel()
    self:Hide()
end
