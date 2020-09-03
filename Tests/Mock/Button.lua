mockButton = setmetatable({}, mockFrame)
mockButton.__index = mockButton

function mockButton:RegisterForClicks(mouseButton)
end

function mockButton:Click(mouseButton)
    print(">>> Clicked button:", tostring(self:GetName()))

    local pre = self:GetScript('PreClick')
    local post = self:GetScript('PostClick')

    if pre then
        pre(self, mouseButton)
    end

--[[
    for k,v in pairs(self) do
        if type(v) == 'string' then
            print("   ", k, v)
        end
    end
]]

    -- SecureActionButton emulation
    local actionType = self:GetAttribute('type')
    if actionType == 'spell' then
        local spellName = self:GetAttribute('spell')
        CastSpellByName(spellName)
    elseif actionType == 'macro' then
        RunMacroText(self:GetAttribute('macrotext'))
    elseif actionType == 'cancelaura' then
        local spellName = self:GetAttribute('spell')
        CancelAuraByName(spellName)
    else
        print(">>> " .. actionType)
    end

    if post then
        post(self, mouseButton)
    end
end
