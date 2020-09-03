--[[------------------------------------------------------------------------]]--

dofile("mock/WoWAPI.lua")
dofile("LoadAddOn.lua")

SendEvent('ADDON_LOADED', 'LiteMount')

loadfile("SavedVariables/LiteMount.lua")()

SendEvent('VARIABLES_LOADED')
SendEvent('PLAYER_LOGIN')
SendEvent('PLAYER_ENTERING_WORLD')

-- print('LiteMountDB = ' .. DumpTable(LiteMountDB, 1))

-- MockState.extraActionButton = 202477
-- MockState.keyDown.shift = true
-- MockState.inCombat = true
-- MockState.moving = true

for i = 1, 1000 do
    LiteMount.actions[1]:Click()
end

SendEvent('PLAYER_LOGOUT')
