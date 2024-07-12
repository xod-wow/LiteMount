mockPlayerModel = setmetatable({}, mockFrame)
mockPlayerModel.__index = mockPlayerModel

function mockPlayerModel:SetUnit(unit)
end

function mockPlayerModel:GetModelFileID()
    return 123456
end
