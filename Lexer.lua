--[[----------------------------------------------------------------------------

  LiteMount/Lexer.lua

  Copyright 2011-2016 Mike Battersby

----------------------------------------------------------------------------]]--

function tokenize(str)
    return function ()
        if str == "" then return end

        local c = str:match('^("[^"]*")') or
                  str:match('^([%[%]%(%),:/])') or
                  str:match('^(%s+)') or
                  str:match('^([^"%[%]%(%),:/%s]+)')
        
        if c then
            str = str:sub(c:len()+1, -1)
            c = c:gsub('^"(.*)"$', '%1')
            return c
        end

        error("syntax error: " .. str)
    end
end

tokens = { }
for t in tokenize(arg[1]) do
    print(t)
    table.insert(tokens, t)
end

for _, t in ipairs(tokens) do
    print(t)
end
