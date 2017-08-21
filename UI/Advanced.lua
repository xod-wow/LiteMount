--[[----------------------------------------------------------------------------

  LiteMount/Advanced.lua

  Options frame to plug in to the Blizzard interface menu.

  Copyright 2011-2017 Mike Battersby

----------------------------------------------------------------------------]]--

local function BindingText(n)
    return format('%s %s', KEY_BINDING, n)
end

function LiteMountOptionsAdvanced_OnLoad(self)
    self.name = ADVANCED_OPTIONS

    self.EditBox.ntabs = 4
    self.BindingButton1.ntabs = 4
    self.BindingButton2.ntabs = 4

    UIDropDownMenu_Initialize(self.BindingDropDown, LiteMountOptionsAdvancedBindingDropDown_Initialize)
    UIDropDownMenu_SetText(self.BindingDropDown, BindingText(1))
    LiteMountOptionsPanel_OnLoad(self)
end

function LiteMountOptionsAdvanced_OnShow(self)
    self.EditBox:Disable()
    self.BindingButton1:Disable()
    self.BindingButton2:Disable()
    self.EditBox:SetAlpha(0.5)
    self.UnlockButton:Show()
    self.currentlyBinding = nil
    LiteMountOptionsAdvanced_Update(self)
    LiteMountOptionsPanel_OnShow(self)
end

function LiteMountOptionsAdvancedUnlock_OnClick(self)
    local parent = self:GetParent()
    parent.EditBox:SetAlpha(1.0)
    parent.EditBox:Enable()
    parent.BindingButton1:Enable()
    parent.BindingButton2:Enable()
    self:Hide()
end

function LiteMountOptionsAdvancedBindingDropDown_Initialize(dropDown, level)
    local info = UIDropDownMenu_CreateInfo()

    if level == 1 then
        for i = 1,4 do
            info.text = BindingText(i)
            info.arg1 = i
            info.arg2 = BindingText(i)
            info.func = function (button, v, t)
                    LiteMountOptionsControl_SetTab(LiteMountOptionsAdvanced.EditBox, v)
                    LiteMountOptionsAdvanced_Update(LiteMountOptionsAdvanced)
                    UIDropDownMenu_SetText(dropDown, t)
                end
            info.checked = (LiteMountOptionsAdvanced.currentButtonIndex == i)
            UIDropDownMenu_AddButton(info, level)
        end
    end
end


local function CurrentBindingName()
    local bindingID = LiteMountOptionsAdvanced.EditBox.tab or 1
    return format("CLICK LM_B%d:LeftButton", bindingID)
end

function LiteMountOptionsAdvanced_Update(self)
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

function LiteMountOptionsAdvancedBinding_OnClick(self, button)
    PlaySound("igMainMenuOptionCheckBoxOn")
    if LiteMountOptionsAdvanced.currentlyBinding == self then
        if button == "LeftButton" then
            LiteMountOptionsAdvanced.currentlyBinding = nil
        else
            LiteMountOptionsAdvanced_OnKeyDown(LiteMountOptionsAdvanced, button)
        end
    else
        LiteMountOptionsAdvanced.currentlyBinding = self
        if button == "RightButton" then
            LiteMountOptionsAdvanced_OnKeyDown(LiteMountOptionsAdvanced, button)
        end
    end
    LiteMountOptionsAdvanced_Update(LiteMountOptionsAdvanced)
end

local NOBINDKEYS = { "LeftButton", "RightButton", "LSHIFT", "RSHIFT", "LCTRL", "RCTRL", "LALT", "RALT" }

function LiteMountOptionsAdvanced_OnKeyDown(self, keyOrButton)

    if not self.currentlyBinding then
        self:SetPropagateKeyboardInput(true)
        return
    end

    self:SetPropagateKeyboardInput(false)

    if keyOrButton == "ESCAPE" then
        LiteMountOptionsAdvanced.currentlyBinding = nil
        LiteMountOptionsAdvanced_Update(self)
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
    LiteMountOptionsAdvanced_Update(self)
end
