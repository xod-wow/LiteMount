mockButton = setmetatable({}, mockFrame)
mockButton.__index = mockButton

function mockButton:RegisterForClicks(...)
    for i = 1, select('#', ...) do
        local r = select(i, ...)
        self.__wantClicks[r] = true
    end
end

function mockButton:New(...)
    local b = mockFrame.New(self, ...)
    b.__wantClicks = {}
    return b
end

function mockButton:ClickMatches(mouseButton, isDown)
    if isDown then
        if self.__wantClicks['AnyDown'] then
            return true
        elseif self.__wantClicks[mouseButton.."Down"] then
            return true
        end
    else
        if self.__wantClicks['AnyUp'] then
            return true
        elseif self.__wantClicks[mouseButton.."Up"] then
            return true
        end
    end
end

function mockButton:Click(mouseButton, isDown)
    if not self:ClickMatches(mouseButton, isDown) then
        return
    end

    print(">>> Clicked button:", tostring(self:GetName()))
    print(">>>    mouseButton:", tostring(mouseButton))
    print(">>>         isDown:", tostring(isDown))

    local pre = self:GetScript('PreClick')
    local post = self:GetScript('PostClick')

    if pre then
        pre(self, mouseButton, isDown)
    end

    -- SecureActionButton emulation
    if GetCVarBool("ActionButtonUseKeyDown") == isDown then
        local actionType = self:GetAttribute('type')
        if actionType == 'spell' then
            local spellName = self:GetAttribute('spell')
            CastSpellByName(spellName)
        elseif actionType == 'macro' then
            RunMacroText(self:GetAttribute('macrotext'))
        elseif actionType == 'cancelaura' then
            local spellName = self:GetAttribute('spell')
            CancelAuraByName(spellName)
        elseif actionType == "item" then
            local itemName = self:GetAttribute('item')
            C_Item.UseItemByName(itemName)
        else
            print(">>> " .. tostring(actionType))
        end
    end

    if post then
        post(self, mouseButton, isDown)
    end
end
