--[[----------------------------------------------------------------------------

  LiteMount/UIOptionsCombatMacro.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2015 Mike Battersby

----------------------------------------------------------------------------]]--

function LiteMountOptionsCombatMacro_OnLoad(self)

    LiteMount_Frame_AutoLocalize(self)

    self.parent = LiteMountOptions.name
    self.name = MACRO .. " : " .. COMBAT
    self.title:SetText("LiteMount : " .. self.name)

    self.default = function (self)
            LiteMountOptionsPanel_Default(self)
            LiteMountOptionsPanel_Refresh(self)
        end

    InterfaceOptions_AddCategory(self)
end

function LiteMountOptionsCombatMacro_OnShow(self)
    LiteMountOptions.CurrentOptionsPanel = self
    LiteMountOptionsPanel_Refresh(self)
end

function LiteMountOptionsCombatMacro_OnHide(self)
    -- Currently set to combat action, refresh
    LiteMount:PostClick()
end

function LiteMountOptionsCombatMacro_OnTextChanged(self)
    local m = LiteMountOptionsCombatMacroEditBox:GetText()
    if not m or strmatch(m, "^%s*$") then
        LM_Options:SetCombatMacro(nil)
    else
        LM_Options:SetCombatMacro(m)
    end

    local c = strlen(m or "")
    LiteMountOptionsCombatMacroCount:SetText(format(MACROFRAME_CHAR_LIMIT, c))
end

