TRANSMOG_SLOTS = {
    [100] = { location = 100 },
    [300] = { location = 300 },
    [301] = { location = 301 },
    [400] = { location = 400 },
    [500] = { location = 500 },
    [600] = { location = 600 },
    [700] = { location = 700 },
    [800] = { location = 800 },
    [900] = { location = 900 },
    [1000] = { location = 1000 },
    [1500] = { location = 1500 },
    [1600] = { location = 1600 },
    [1610] = { location = 1610 },
    [1700] = { location = 1700 },
    [1710] = { location = 1710 },
    [1900] = { location = 1900 },
}

C_Transmog = { }

function C_Transmog.GetSlotVisualInfo(transmogLocation)
    return math.random(1000000)
end
