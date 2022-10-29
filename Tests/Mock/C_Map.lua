C_Map = {}

function C_Map.GetBestMapForUnit(unit)
    return 1565
end

function C_Map.GetMapInfo(map)
    return data.GetMapInfo[map]
end

function C_Map.GetMapChildrenInfo(map)
    local children = data.GetMapChildrenInfo[map]
    local out = {}
    for _,childMapID in ipairs(children or {}) do
        table.insert(out, data.GetMapInfo[childMapID])
    end
    return out
end

function C_Map.GetMapGroupID(map)
    return data.GetMapGroupID[map]
end

function C_Map.IsMapValidForNavBarDropDown(map)
    return data.IsMapValidForNavBarDropDown[map] or false
end

function GetZoneText()
    return "MockZone"
end

function GetSubZoneText()
    return "MockSubZone"
end
