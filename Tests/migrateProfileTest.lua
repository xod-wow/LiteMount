dofile("Mock/WoWAPI.lua")
dofile("LoadAddOn.lua")

SendEvent('ADDON_LOADED', 'LiteMount')

local svFile = arg[1] or "SavedVariables/LiteMount.lua"

print("================================================================================")
print("Checking " .. svFile)
print("")
dofile(svFile)

local originalDB = CopyTable(LiteMountDB)

-- force debugging
local charKey = string.format('%s - %s', UnitFullName('player'))
LiteMountDB.char = LiteMountDB.char or {}
LiteMountDB.char[charKey] = LiteMountDB.char[charKey] or {}
LiteMountDB.char[charKey].debugEnabled = true

SendEvent('VARIABLES_LOADED')
SendEvent('PLAYER_LOGIN')
SendEvent('PLAYER_ENTERING_WORLD')

local function FlagTableMatches(a, b)
    for k in pairs(a or {}) do
        if LM.FLAG[k] and k ~= 'FAVORITES' then
            if a[k] ~= b[k] then return false end
        end
    end
    for k in pairs(b or {}) do
        if LM.FLAG[k] and k ~= 'FAVORITES' then
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
        print("  >>> Error: old profile doesn't exist. <<<")
        return
    end

    if not newp then
        print("  Error: new profile doesn't exist.")
        return
    end

    print("  Checking flagChanges")

    if oldp.flagChanges then
        for k,v in pairs(oldp.flagChanges) do
            if not FlagTableMatches(v, newp.flagChanges[k]) then
                print(">>>  Error: flag difference. <<<")
                print('  old' .. DumpTable(v, 1))
                print('  new' .. DumpTable(newp.flagChanges[k], 1))
            end
        end
    end

    print("  Checking buttonActions")

    for i = 1, 4 do
        local oldAction = (oldp.buttonActions or {})[i]
        local newAction = rawget(newp.buttonActions or {}, i)
        if oldAction ~= newAction then
            print(">>>  Error: buttonActions difference: " .. i .. " <<<")
            print("  old = " .. oldAction)
            print("  new = " .. newAction)
        end
    end

    print("  Checking flagChanges -> group")

    if oldp.flagChanges then
        for spellID,changes in pairs(oldp.flagChanges) do
            for group,c in ipairs(changes) do
                if newp.flagChanges[spellID] and newp.flagChanges[spellID][group] then
                    print(">>> Error: still exists in flagchanges: " .. group .. " <<<")
                elseif not newp.groups or not newp.groups[group] or not newp.groups[group][spellID] then
                    print(">>> Error: not migrated to group <<<")
                    print("  group = " .. group)
                    print("  spellID = " .. spellID)
                end
            end
        end
    end
    for spellID,changes in pairs(newp.flagChanges or {}) do
        for k,c in ipairs(changes) do
            if not LM.FLAG[k] then
                print(">>> Error: group left as flag: " .. k .. " <<<")
            end
        end
    end

    print("  Checking rules")

    if oldp.rules then
        for buttonIndex,ruleList in pairs(oldp.rules) do
            for ruleIndex in ipairs(ruleList) do
                if oldp.rules[buttonIndex][ruleIndex] ~= newp.rules[buttonIndex][ruleIndex] then
                    print(">>>  Error: rule difference. <<<")
                    print(string.format('  old[%d][%d] %s', buttonIndex, ruleIndex, oldp.rules[buttonIndex][ruleIndex]))
                    print(string.format('  new[%d][%d] %s', buttonIndex, ruleIndex, newp.rules[buttonIndex][ruleIndex]))
                end
            end
        end
    end

    
end

local profileNames = {}
for profileName in pairs(originalDB.profiles) do
   table.insert(profileNames, profileName)
end

table.sort(profileNames)

for _, profileName in ipairs(profileNames) do
    CheckProfile(profileName)
end

SendEvent('PLAYER_LOGOUT')

-- print(LM.TableToString(LiteMountDB))
