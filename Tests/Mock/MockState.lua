local StateInfo = {
    playerName = 'Xodiv',
    playerClass = 'Warrior',
    playerRace = 'NightElf',
    playerFactionGroup = 'Alliance',
    playerLevel = 120,
    realmName = 'MockRealm',
    buffs = {},
    debuffs = {},
    equipped = {},
    locale = "enUS",
    region = 1,
    submerged = false,
    falling = false,
    indoors = false,
    inVehicle = false,
    inCombat = false,
    keyDown = { shift = false, ctrl = false, alt = false },
    extraActionButton = nil,
    playerKnowsFlying = true,
    flyableArea = true,
    moving = false,
}

local function Randomize(tbl)
    for k,v in pairs(tbl) do
        if type(v) == 'table' then
            Randomize(v)
        elseif type(v) == 'boolean' then
            tbl[k] = ( math.random(2) == 1 )
        end
    end
end

function MockStateRandomize()
    Randomize(MockState)
    print("MockState = " ..DumpTable(MockState, 1))
end

MockState = CopyTable(StateInfo)
