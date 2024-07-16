mockFrame = {
    __allFrames = {},
    __frameEventRegistry = {},
}
mockFrame.__index = mockFrame

function mockFrame:New(frameName, frameParent, ...)
    local f = setmetatable({}, self)
    f.__parent = frameParent
    f.__name = frameName
    f.__scripts = {}

    self.__allFrames[f] = true
    if frameName then _G[frameName] = f end
    return f
end

function mockFrame:RegisterUnitEvent(ev, unit)
    self:RegisterEvent(ev)
end

function mockFrame:RegisterEvent(ev)
    self.__frameEventRegistry[ev] = self.__frameEventRegistry[ev] or {}
    self.__frameEventRegistry[ev][self] = true
end

function mockFrame:UnregisterEvent(ev)
    if self.__frameEventRegistry[ev] then
        self.__frameEventRegistry[ev][self] = nil
    end
end

function mockFrame:SetScript(scriptName, func)
    self.__scripts[scriptName] = func
end

function mockFrame:GetScript(scriptName, func)
    return self.__scripts[scriptName]
end

function mockFrame:GetName()
    return self.__name
end

function mockFrame:GetParent()
    return self.__parent
end

function mockFrame:Show()
    self.isShown = true
end

function mockFrame:Hide()
    self.isShown = false
end

function mockFrame:SetShown(v)
    if v then
        self.isShown = true
    else
        self.isShown = false
    end
end

function mockFrame:IsShown()
    return self.isShown == false
end

function mockFrame:IsVisible()
    return self.isShown == false
end

function mockFrame:SetAttribute(k, v)
    self[k] = v
end

function mockFrame:GetAttribute(k)
    return self[k]
end

function mockFrame:SetSize(w, h)
    return w, h
end

function CreateFrame(frameType, ...)
    local class = _G["mock"..frameType]
    if class then
        return class:New(...)
    else
        return mockFrame:New(...)
    end
end

local lastOnUpdate = GetTime()

function SendOnUpdate()
    local now = GetTime()
    for f in pairs(mockFrame.__allFrames) do
        local func = f:GetScript('OnUpdate')
        if func then
            func(f, now - lastOnUpdate)
        end
    end
    lastOnUpdate = now
end

function SendEvent(ev, ...)
    local frames = mockFrame.__frameEventRegistry[ev]
    if frames then
        for f in pairs(frames) do
            local script = f:GetScript('OnEvent')
            if script then
                script(f, ev, ...)
            end
        end
    end
end

