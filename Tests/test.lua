--[[------------------------------------------------------------------------]]--

dofile("Mock/WoWAPI.lua")
dofile("LoadAddOn.lua")

local function CheckFile(svFile)
    _ENV = setmetatable({}, { __index = _G })

    SendEvent('ADDON_LOADED', 'LiteMount')

    dofile(svFile)

    SendEvent('VARIABLES_LOADED')
    SendEvent('PLAYER_LOGIN')
    SendEvent('PLAYER_ENTERING_WORLD')

    -- print('LiteMountDB = ' .. DumpTable(LiteMountDB, 1))

    -- MockState.extraActionButton = 202477
    -- MockState.keyDown.shift = true
    -- MockState.inCombat = true
    -- MockState.moving = true

    for i = 1, 10000 do
        MockStateRandomize()
        -- local n = math.random(4)
        -- LiteMount.actions[n]:Click()
        if MockState.inCombat == false then
            MockStatePrint()
            LiteMount.actions[1]:Click()
        end
    end

    SendEvent('PLAYER_LOGOUT')

    print('\nCompleted and exiting.\n')
end

if #arg == 0 then
    table.insert(arg, "SavedVariables/LiteMount.lua")
end

for _,svFile in ipairs(arg) do
    CheckFile(svFile)
end

os.exit(0)
