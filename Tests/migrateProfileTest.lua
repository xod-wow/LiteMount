dofile("mock/WoWAPI.lua")
dofile("LoadAddOn.lua")

SendEvent('ADDON_LOADED', 'LiteMount')

local svFile = arg[1] or "SavedVariables/LiteMount.lua"
dofile(svFile)

local originalDB = CopyTable(LiteMountDB)

SendEvent('VARIABLES_LOADED')
SendEvent('PLAYER_LOGIN')
SendEvent('PLAYER_ENTERING_WORLD')

local function FlagTableMatches(a, b)
    for k in pairs(a) do
        if k ~= 'FAVORITES' then
            if a[k] ~= b[k] then return false end
        end
    end
    for k in pairs(b) do
        if k ~= 'FAVORITES' then
            if a[k] ~= b[k] then return false end
        end
    end
    return true
end

function CheckProfile(profileName)
    print("Checking profile " .. profileName)

    local oldp = originalDB.profiles[profileName]
    local newp = LiteMountDB.profiles[profileName]

    if not oldp then
        print("  Error: old profile doesn't exist.")
        return
    end

    if not newp then
        print("  Error: new profile doesn't exist.")
        return
    end

    print("  Checking excludedSpells -> mountPriorities")

    if oldp.excludedSpells and not oldp.mountPriorities then
        for spellId, isExcluded in pairs(oldp.excludedSpells) do
            if not newp.mountPriorities[spellID] then
                print("Error: new profile missing priorirty for " .. tostring(spellId))
            elseif isExcluded and newp.mountPriorities[spellId] ~= 0 then
                print("Error: migrate priority failed: " ..tostring(spellId))
            end
        end
    end

    print("  Checking flagChanges")

    if oldp.flagChanges then
        for k,v in pairs(oldp.flagChanges) do
            if not FlagTableMatches(v, newp.flagChanges[k]) then
                print("  Error: flag difference.")
                print('  old = ' .. DumpTable(v, 1))
                print('  new = ' .. DumpTable(newp.flagChanges[k], 1))
            end
        end
    end

    print("  Checking buttonActions")
    for i = 1, 4 do
        local oldAction = oldp.buttonActions[i]
        local newAction = rawget(newp.buttonActions, i)
        if oldAction ~= newAction then
            print("  Error: buttonActions difference: " .. i)
            print("  old = " .. oldAction)
            print("  new = " .. newAction)
        end
    end
end

for profileName in pairs(originalDB.profiles) do
    CheckProfile(profileName)
end

SendEvent('PLAYER_LOGOUT')
