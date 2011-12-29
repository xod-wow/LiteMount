--[[----------------------------------------------------------------------------

  LiteMount/UIOptionsFrame.lua

  Options frame to plug in to the Blizzard interface menu.

----------------------------------------------------------------------------]]--

function LiteMountOptionsMacro_OnLoad(self)

    LiteMount_Frame_AutoLocalize(self)

    self.parent = LiteMountOptions.name
    self.name = MACRO
    self.title:SetText("LiteMount : " .. self.name)

    self.default = function ()
            LM_Options:SetMacro(nil)
        end

    InterfaceOptions_AddCategory(self)
end

function LiteMountOptionsMacro_OnShow(self)
    LiteMountOptions.CurrentOptionsPanel = self
    local m = LM_Options:GetMacro()
    if m then
        LiteMountOptionsMacroEditBox:SetText(m)
    end
end

function LiteMountOptionsMacro_OnTextChanged(self)
    local m = LiteMountOptionsMacroEditBox:GetText()
    if not m or string.match(m, "^%s*$") then
        LM_Options:SetMacro(nil)
    else
        LM_Options:SetMacro(m)
    end

    local c = string.len(m or "")
    LiteMountOptionsMacroCount:SetText(string.format(MACROFRAME_CHAR_LIMIT, c))
end

