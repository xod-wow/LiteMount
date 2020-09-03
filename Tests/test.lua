--[[------------------------------------------------------------------------]]--

dofile("mock/WoWAPI.lua")
dofile("LoadAddOn.lua")

SendEvent('ADDON_LOADED', 'LiteMount')

local svFile = arg[1] or "SavedVariables/LiteMount.lua"
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
    local n = math.random(4)
    MockStateRandomize()
    LiteMount.actions[n]:Click()
end

SendEvent('PLAYER_LOGOUT')
