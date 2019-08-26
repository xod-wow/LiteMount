--[[----------------------------------------------------------------------------

  LiteMount/UI/Bindings.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2019 Mike Battersby

----------------------------------------------------------------------------]]--

function LiteMountBinding_OnLoad(self)
    self.name = "XXX FIXME XXX"

    self.BindingButton1.ntabs = 4
    self.BindingButton2.ntabs = 4

    LiteMountOptionsPanel_OnLoad(self)
end

function LiteMountBindings_OnShow(self)
    LiteMountBinding_Update(self)
    LiteMountOptionsPanel_OnShow(self)
end

function LiteMountBindings_OnHide(self)
    self.currentlyBinding = nil
end

local function CurrentBindingName()
    local bindingID = LiteMountBindings.EditBox.tab or 1
    return format("CLICK LM_B%d:LeftButton", bindingID)
end

function LiteMountBindings_Update(self)
    local bindingName = CurrentBindingName()
    local keys = { GetBindingKey(bindingName, 1) }

    for i = 1,2 do
        local b = self['BindingButton'..i]
        b:SetText(keys[i] or GRAY_FONT_COLOR_CODE..NOT_BOUND..FONT_COLOR_CODE_CLOSE)
        if self.currentlyBinding == b then
            b.selectedHighlight:Show()
        else
            b.selectedHighlight:Hide()
        end
    end
end

function LiteMountBindingsBinding_OnClick(self, button)
    PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
    if LiteMountBindings.currentlyBinding == self then
        if button == "LeftButton" then
            LiteMountBindings.currentlyBinding = nil
        else
            LiteMountBindings_OnKeyDown(LiteMountBindings, button)
        end
    else
        LiteMountBindings.currentlyBinding = self
        if button == "RightButton" then
            LiteMountBindings_OnKeyDown(LiteMountBindings, button)
        end
    end
    LiteMountBindings_Update(LiteMountBindings)
end

local NOBINDKEYS = { "LeftButton", "RightButton", "LSHIFT", "RSHIFT", "LCTRL", "RCTRL", "LALT", "RALT" }

function LiteMountBindings_OnKeyDown(self, keyOrButton)

    if not self.currentlyBinding then
        self:SetPropagateKeyboardInput(true)
        return
    end

    self:SetPropagateKeyboardInput(false)

    if keyOrButton == "ESCAPE" then
        LiteMountBindings.currentlyBinding = nil
        LiteMountBindings_Update(self)
        return
    end

    -- Mappings and aborts
    if keyOrButton == "RightButton" and not IsModifierKeyDown() then
        keyOrButton = nil
    elseif keyOrButton == "MiddleButton" then
        keyOrButton = "BUTTON3"
    elseif keyOrButton:match('Button%d+') then
        keyOrButton = string.upper(keyOrButton)
    elseif tContains(NOBINDKEYS, keyOrButton) then
        return
    end

    -- Modifier handling
    if IsShiftKeyDown() then
        keyOrButton = "SHIFT-" .. keyOrButton
    elseif IsControlKeyDown() then
        keyOrButton = "CTRL-" .. keyOrButton
    elseif IsAltKeyDown() then
        keyOrButton = "ALT-" .. keyOrButton
    end

    -- OK, let's bind something
    local bindingName = CurrentBindingName()
    local id = self.currentlyBinding:GetID()

    -- Unbind the key that was pressed
    if keyOrButton then
        SetBinding(keyOrButton, nil)
    end

    -- Unbind both current keys
    local key1, key2 = GetBindingKey(bindingName)
    if key1 then SetBinding(key1, nil) end
    if key2 then SetBinding(key2, nil) end

    -- Bind the new key and the left-over old key
    if id == 1 then
        if keyOrButton then
            SetBinding(keyOrButton, bindingName)
        end
        if key2 then
            SetBinding(key2, bindingName)
        end
    elseif id == 2 then
        if key1 then
            SetBinding(key1, bindingName)
        end
        if keyOrButton then
            SetBinding(keyOrButton, bindingName)
        end
    end

    self.currentlyBinding = nil
    LiteMountBindings_Update(self)
end
