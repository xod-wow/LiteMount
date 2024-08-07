ColorMixin = {}

local function round(x) return math.floor(x + 0.5) end

function CreateColor(r, g, b, a)
    return CreateFromMixins({ r=r, g=g, b=b, a=a }, ColorMixin)
end

function ColorMixin:GenerateHexColor()
    return string.format('ff%02x%02x%02x', round(self.r*255), round(self.g*255), round(self.b*255))
end

function ColorMixin:WrapTextInColorCode(text)
    return string.format('|c%s%s|r', text, self:GenerateHexColor())
end

-- Totally fake
FACTION_RED_COLOR = CreateColor(1, 0, 0, 1)
