# Notes To Myself


* Git setup

  ```
  git config user.name 'Mike "Xodiv" Battersby'
  git config user.email mib@post.com
  git config tag.sort -version:refname
  git config fetch.prune true
  git config core.filemode false
  git config --global push.default simple
  ```

* Branch-fu

  Make a branch locally:
  ```
  git checkout -b newfeature
  ```
  List branches:
  ```
  git branch -a
  ```
  Switch between branches:
  ```
  git checkout master
  git checkout newfeature
  ```
  Push the branch to github:
  ```
  git push --set-upstream origin newfeature
  ```
  Delete the branch locally:
  ```
  git branch -d newfeature
  git branch -r -d origin/newfeature
  ```
  Delete the branch on github (after deleting locally):
  ```
  git push origin --delete newfeature
  ```
  Delete the branch locally when it's already been deleted from curseforge:
  ```
  git branch -d newfeature
  git remote prune origin
  ```
  Merge the branch into master:
  ```
  git checkout master
  git merge --log newfeature
  ```

* XML syntax check

  ```
  xmllint --noout UI/*.xml
  ```

* To Do List

  - Export profiles or all settings with serialize/compress.
  - Write a simplified UI for the action lists.


* Running Wild under ShapeShift

  You can't use Running Wild when you are shapeshifted (e.g., you are
  transformed into a Night Elf or Human by a dungeon buff).  Unfortunately
  IsUsableSpell() still returns true in that case.


* [CLOSED] Code to check every spell usability

  Moved into LM.Developer.

  I hope that someday the ability to tell if we are on top of the water
  or under it will return. WTB IsFloating()


* [CLOSED] Passenger-capable mounts

  Conclusion: handled by the action list mechanism now.

  Possibility of preferring a passenger-capable mount if you are in
  a group.


* [CLOSED] Better "undo".

  Conclusion: seems unncessary.

  Might be able to set up the macro better for undoing in combat what we
  last did (mount -> dismount, form -> cancelform, aura -> cancelaura, etc.)
  by passing params between the PreClick handler and the PostClick handler
  as button attributes.


* [CLOSED] Suggestions

  Conclusion: I ripped it out completely.


* [CLOSED] "Dragonwrath, Tarecgosa's Rest" (71086)

  Item ID 71086.  Spell ID is 101641 (Tarecgosa's Visage)

  You can only use it by "/use slot", you can't cast the spell.


* [CLOSED] Might be better to look for Sea Legs aura for Vashj'ir.

  Sea legs is present even on the surface and flying so don't do it.


* [CLOSED] Does GetUnitSpeed return negative if you go backwards?

  No it doesn't.

* Expression parser

  Periodically I think I should properly parse things but then it
  doesn't work out, but to save me writing a shunting algorithm parser
  every time then throwing it away, here it is for posterity.

```
    local OPERATORS = {
        ['('] = { type = 'LPAREN', value = '(' },
        [')'] = { type = 'RPAREN', value = ')' },
        ['/'] = { type = 'OPERATOR', value = 'OR',  prec = 2, nargs = 2 },
        [','] = { type = 'OPERATOR', value = 'AND', prec = 3, nargs = 2 },
        ['~'] = { type = 'OPERATOR', value = 'NOT', prec = 1, nargs = 1 },
    }

    local function Tokenize(expr)
        local tokens = { }

        -- this is going to be pretty slow, but that probably won't matter
        for c in expr:gmatch('.') do
            if OPERATORS[c] then
                table.insert(tokens, OPERATORS[c])
            elseif #tokens > 0 and tokens[#tokens].type == 'LITERAL' then
                tokens[#tokens].value = tokens[#tokens].value .. c
            else
                table.insert(tokens, { type = 'LITERAL', value = c })
            end
        end
        return tokens

    end

    local function Parse(expr)
        local tokens = Tokenize(expr)

        local output, stack = { }, { }

        for i = 1, #tokens do
            local t = tokens[i]

            if t.type == 'LITERAL' then
                table.insert(output, t.value)
            elseif t.type == 'VARIABLE' then
                table.insert(output, t.value)
            elseif t.type == 'OPERATOR' then
                while #stack > 0 and stack[#stack].type ~= 'LPAREN' do
                    table.insert(output, table.remove(stack))
                end
                table.insert(stack, t)
            elseif t.type == 'LPAREN' then
                table.insert(stack, t)
            elseif t.type == 'RPAREN' then
                while #stack > 0 and stack[#stack].type ~= 'LPAREN' do
                    table.insert(output, table.remove(stack))
                end
                if #stack == 0 or table.remove(stack).type ~= 'LPAREN' then
                    return
                end
            end
        end

        while #stack > 0 do
            local t = table.remove(stack)
            if t.type == 'LPAREN' or t.type == 'RPAREN' then return nil end
            table.insert(output, t)
        end

        return output
    end

    local function MergeWithOr(a, b)
        local r = { }
        for _, t in ipairs(a) do table.insert(r, t) end
        for _, t in ipairs(b) do table.insert(r, t) end
        if #a > 0 and #b > 0 then
            table.insert(r, OPERATORS['/'])
        end
        return r
    end
```
