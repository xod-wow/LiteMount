C_AddOns = {}

function C_AddOns.GetAddOnMetadata(name, attr)
    if attr == "Title" then
        return "LiteMount"
    elseif attr == "Version" then
        return "99.9"
    end
end
