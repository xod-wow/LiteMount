Notes To Myself
---------------


------------------------------------------------------------------------------
* Git setup

    git config user.name 'Mike "Xodiv" Battersby'
    git config user.email mib@post.com
    git config tag.sort -version:refname
    git config fetch.prune true
    git config core.filemode false
    git config --global push.default simple


------------------------------------------------------------------------------
* Branch-fu

    Make a branch locally:
        git checkout -b newfeature
    List branches:
        git branch -a
    Switch between branches:
        git checkout master
        git checkout newfeature
    Push the branch to github:
        git push --set-upstream origin newfeature
    Delete the branch locally:
        git branch -d newfeature
        git branch -r -d origin/newfeature
    Delete the branch on github (after deleting locally):
        git push origin --delete newfeature
    Delete the branch locally when it's already been deleted from curseforge:
        git branch -d newfeature
        git remote prune origin
    Merge the branch into master:
        git checkout master
        git merge --log newfeature

------------------------------------------------------------------------------
* XML syntax check

    xmllint --noout UI/*.xml


------------------------------------------------------------------------------
* To Do List

    Try to get more translations done.

    Export profiles or all settings with serialize/compress.


------------------------------------------------------------------------------
* Running Wild under ShapeShift

    You can't use Running Wild when you are shapeshifted (e.g., you are
    transformed into a Night Elf or Human by a dungeon buff).  Unfortunately
    IsUsableSpell() still returns true in that case.


------------------------------------------------------------------------------
* [CLOSED] Code to check every spell usability

    Moved into LM_Developer.

    I hope that someday the ability to tell if we are on top of the water
    or under it will return. WTB IsFloating()


------------------------------------------------------------------------------
* [CLOSED] Passenger-capable mounts

    Conclusion: handled by the action list mechanism now.

    Possibility of preferring a passenger-capable mount if you are in
    a group.


------------------------------------------------------------------------------
* [CLOSED] Better "undo".

    Conclusion: seems unncessary.

    Might be able to set up the macro better for undoing in combat what we
    last did (mount -> dismount, form -> cancelform, aura -> cancelaura, etc.)
    by passing params between the PreClick handler and the PostClick handler
    as button attributes.


------------------------------------------------------------------------------
* [CLOSED] Suggestions

    Conclusion: I ripped it out completely.


------------------------------------------------------------------------------
* [CLOSED] "Dragonwrath, Tarecgosa's Rest" (71086)

    Item ID 71086.  Spell ID is 101641 (Tarecgosa's Visage)

    You can only use it by "/use slot", you can't cast the spell.


------------------------------------------------------------------------------
* [CLOSED] Might be better to look for Sea Legs aura for Vashj'ir.

    Sea legs is present even on the surface and flying so don't do it.


------------------------------------------------------------------------------
* [CLOSED] Does GetUnitSpeed return negative if you go backwards?

    No it doesn't.


------------------------------------------------------------------------------
* Expression parser

    Periodically I think I should properly parse things but then it
    doesn't work out, but to save me writing a shunting algorithm parser
    every time then throwing it away, here it is for posterity.

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

------------------------------------------------------------------------------
* How it all hangs together (not the UI).

This is a sort of bottom-up idea of how things work.

Options.lua

  Firstly, all the options are stored in LM.Options which uses AceDB-3.0.

  There are a bunch of getter and setter methods which sometimes do other
  processing.

  Lots of the other parts of the code look at the options to decide how to
  behave. They should always use the getter/setter method.

  LM.Options.db fires two LibCallback events that can be listened for:
  OnOptionsModified (when any setting is changed) and OnOptionsProfile
  (profile changed).

Mount.lua and LM_*.lua

  The basic object is LM.Mount, which is  subclassed to a bunch of specifics
  for various mounts and mount-like things. The majority of which are
  LM.Journal - mounts from the mount journal.

  All mounts must have a
    .name                   - Mount name
    .spellID                - Spell that summons this mount
    .flags                  - Inherent default flags

  The important methods are

    IsCastable()
    GetCurrentFlags()       - Returns the options-modified set
    GetSecureAttributes()   - Returns a table of attributes to set on a
                              SecureActionButton frame to make it activate
                              the mount when clicked.

MountList.lua

  LM.MountList              - A list of mounts.
    Copy()
    Search(matchFunc, ...)  - calls matchFunc(mount, ...) to test
    Shuffle()               - not used any more with the weighting system
    Random(r)               - if r [0,1) is passed it is used as the
    PriorityRandom(r)         random number
    Sort()

PlayerMounts.lua

  LM.PlayerMounts is a singleton that contains all of the mounts that we
  know about.  The naming is historical, because before the mount journal
  you couldn't query for mounts you hadn't learned.

  The code looks up the journal, various items, class spells, etc and adds
  them all into a MountList. Some mounts come and go depending on specs
  and spells and glyphs and this has the code to watch for those events and
  keep the list updated.

ActionButton.lua

  LM.ActionButton is a SecureActionButton frame actually does the summoning
  - it's not a visible button, just a Frame that is clicked by the
  keybindings. The magic is all done in a PreClick handler, which (out of
  combat) can modify what the button will do immediately before it does it.

  Each ActionButton has an LM.ActionList assigned to it with the list of
  actions that are attempted when it is clicked.

  LM.ActionButton
    Create(n)               - Buttons are named LM_{n} and

ActionList.lua

  LM.ActionList is a parser for the action lists. It doesn't really understand
  anything, it just assumes various things in various positions on the lines
  are actions, various things are tests and various things are arguments.

  The only method is

    LM.ActionList:Compile(text)

  which returns a list of (action, args, conditions) tuples in a format that
  LM.ActionButton knows how to dispatch.

Actions.lua

  Handlers for each of the LiteMount actions and the flow control pseudo-
  actions.

    handler = LM.Actions:GetHandler(action)
    mount = handler(args, env)

  Handlers return a LM.Mount(-like) object if they were successful, which
  should be applied to an LM.ActionButton's secure attributes.

Conditions.lua

  LM.Conditions is an evaluator for the parsed conditions, and is mostly
  a heap of WoW API calls to do tests.

  LM.Conditions
    Eval(connditions, unit)

Vars.lua

  The small number of {NAME} variables and constants that are supported
  in action lists.

  newStr = LM.Vars:StrSubConsts(str)
  newStr = LM.Vars:StrSubVars(str)

Core.lua

  Addon core that initializes everything and creates the 4 action buttons.

  So here's what happens, tying it all together:

    1. person hits a LiteMount keybinding
    2. if we're not in combat:
        3. the keybinding triggers a click on the matching LM.ActionButton
        4. the preclick handler on the button runs:
            - evaluates each line in its action list in turn
            - once one returns a mount, sets up its secure attributes
    5. the blizzard secure click handler uses the attributes to perform
       the mount action
    6. if we're not in combat:
        7. the postclick handler runs and sets the actions to the default
           combat actions

AutoEventFrame.lua

  LM.CreateAutoEventFrame(...) takes the same arguments as CreateFrame but
  sets up an OnEvent handler that dispatches events using a method with the
  matching name.

  E.g.,

    f = LM.CreateAutoEventFrame('Frame')
    function f:PLAYER_LOGIN() print('You logged in!') end
    f:RegisterEvent('PLAYER_LOGIN')

Bindings.xml
KeyBindingStrings.xml

  This is some deeply weird voodoo that WoW looks for in an addon to set up
  keybindings.

Localization.lua

  Translations of all the texts.

Location.lua

  Keeps track of various things about the player's environment. The location
  part of it was more of a big deal before BfA when the map system changed and
  you didn't have to keep messing with the map GUI to find out where you are.

  The table InstanceNotFlyable is really the only interesting part.

  LM.Location
    CanFly()
    CantBreath()
    InInstance(instanceID, [instanceID, ...])
    IsFloating()
    MapInPath(mapID, [mapID, ...])
  
Print.lua

  Printing and debugging functions.

  LM.Print
    Print(msg)
    PrintError(msg)
    Warning(msg)            - warnings go to UIErrorsFrame
    WarningAndPrint(msg)
    Debug(msg)
    UIDebug(frame, msg)

SlashCommand.lua

  The slash command parsing and executing function. It's attached to the
  actual /litemount and /lmt texts in Core.lua

SpellInfo.lua

  Some constants about items and spells that are mounts or mount-like, as
  well as the definition of the default flags and their sort order.


------------------------------------------------------------------------------
* How it all hangs together (the UI).

WoW UI programming is not something I really know well enough to explain. It's
gotten better since Mixins and it looks to be better again in Shadowlands with
the ability to prepend/append script handlers when inheriting.

Each UI panel frame inherits from LiteMountOptionsPanelTemplate, and defines
a number of controls by calling

    LiteMountOptionsPanel_RegisterControl(self, control)

The controls are UI elements. It doesn't really matter what they are but they
must implement this interface:

    val = control:GetOption()
    val = control:GetDefaultOption()
    control:SetOption(val)

and optionally:
    val = control:Getcontrol()
    control:SetControl(val)

The panel template code takes care calling these methods to keep the state
of the options and the controls in sync, as well as keeping the "undo" state
and reverting on cancel.

It's not strictly necessary that GetOption() and SetOption() have anything to
do with what the control shows.  Usually the flow is something like:

    OnPanelOpened:
        foreach control
            control.oldValues = control:GetOption()

    OnOkay:
        foreach control:
            control.oldValues = nil

    OnCancel:
        foreach control
            control:SetOption(control.oldValues)
            control.oldValues = nil

    OnOptionsModified:
        foreach control:
            val = control:GetOption()
            control:SetControl(val)

    OnControlChanged:
        val = control:GetControl()
        control:SetOption(val)

But if you ignore the passed value on SetControl and query it in the UI itself
then you can just use the GetOption/SetOption for the undo behaviour.

