# LiteMount World of Warcraft Addon

For the addon, see:
- https://www.curseforge.com/wow/addons/litemount

For the documentation see:
- https://github.com/xod-wow/LiteMount/wiki


## How it all hangs together (not the UI).

This is a sort of bottom-up idea of how things work.

### Options.lua

Firstly, all the options are stored in LM.Options which uses AceDB-3.0.

There are a bunch of getter and setter methods which sometimes do other
processing.

Lots of the other parts of the code look at the options to decide how to
behave. They should always use the getter/setter method.

LM.db fires two LibCallback events that can be listened for:
OnOptionsModified (when any setting is changed) and OnOptionsProfile
(profile changed).

### Mount.lua and LM\_\*.lua

The basic object is LM.Mount, which is  subclassed to a bunch of specifics
for various mounts and mount-like things. The majority of which are
LM.Journal - mounts from the mount journal.

All mounts must have:
```
  .name                     - Mount name
  .spellID                  - Spell that summons this mount
  .flags                    - Inherent default flags
```

The important methods are

```
  IsCastable()
  IsCancelable()
  GetFlags()                - Returns the options-modified set
  GetCastAction()           - Returns a LM.SecureAction to summon this mount.
  GetCancelAction()         - Same but for dismount/cancel
```

### MountList.lua

```
  LM.MountList              - A list of mounts.
    Copy()
    Search(matchFunc, ...)  - calls matchFunc(mount, ...) to test
    Shuffle()               - not used any more with the weighting system
    Random(r)               - if r [0,1) is passed it is used as the random number
    PriorityRandom(r)
    Sort()
```

### MountRegistry.lua

LM.MountRegistry is a singleton that contains all of the mounts that we
know about.

The code looks up the journal, various items, class spells, etc and adds
them all into a MountList. Some mounts come and go depending on specs
and spells and glyphs and this has the code to watch for those events and
keep the list updated.

### ActionButton.lua

LM.ActionButton is a SecureActionButton frame which actually does the
summoning - it's not a visible button, just a Frame that is clicked by the
keybindings. The magic is all done in a PreClick handler, which (out of
combat) can modify what the button will do immediately before it does it.

Each ActionButton has a RuleSet assigned to it with the list of
rules that are attempted when it is clicked.

```
  LM.ActionButton
    Create(n)               - Buttons are named LM_B{n} and use LM.db.buttonActions[n]
```

### Rule.lua

LM.Rule represents one action line rule, including a parser to read it
from a text line, and a ToString to turn it back. The parser is not very
good, it just assumes various things in various positions on the lines
are actions, various things are tests and various things are arguments.

```
  LM.Rule
    ParseLine(text)
    Dispatch()
    ToString()
    ToDisplay()
    IsSimpleRule()
```

### RuleBoolean.lua

LM.RuleBoolean is a boolean parse tree for the condition logic. It's used
as the .conditions attribute in a rule. It doesn't have a parser, it relies
on LM.Rule doing the parsing for it.

```
  LM.RuleBoolean
    Leaf(text)
    And(node, ...)
    Or(node, ...)
    Not(node)
    Eval()
    ToString()
    ToDisplay()
    IsSimpleCondition()
```
    
### RuleSet.lua

LM.RuleSet is a list of rules. Compile takes a text blob of rules or a
table of rule text lines.

```
  LM.RuleSet
    Compile(textOrLines)
    Run(context)
```

### Actions.lua

Handlers for each of the LiteMount actions and the flow control pseudo-
actions.

```
  fcHandler = LM.Actions:GetFlowControlHandler(action)
  fcHandler(args, context)

  handler = LM.Actions:GetHandler(action)
  secureAction = handler(args, context)
```

Handlers return a LM.SecureAction object if they were successful, which is
then used to set up an LM.ActionButton's secure attributes.

### SecureAction.lua

The intermediary between handlers and the action buttons.

```
  LM.SecureAction
    New(attr)
    SetupActionButton(button, n)
    Macro(macroText, unit)
    Spell(spellName, unit)
    CancelAura(spellName, unit)
    Item(useArg, unit)
    LeaveVehicle()
    Click(clickButton)
    SetupActionButton(button)
```

### Conditions.lua

LM.Conditions is an evaluator for the parsed conditions, and is mostly
a heap of WoW API calls to do tests.

```
  LM.Conditions
    GetCondition(name)
    IsValidCondition(text)
    ToDisplay(text)
```

### Vars.lua

The small number of {NAME} variables and constants that are supported
in action lists.

```
  newStr = LM.Vars:StrSubConsts(str)
  newStr = LM.Vars:StrSubVars(str)
```

### Core.lua

Addon core that initializes everything and creates the 4 action buttons.

So here's what happens, tying it all together:

1. person hits a LiteMount keybinding
1. the keybinding triggers a click on the matching LM.ActionButton
1. if we're not in combat:
    1. the preclick handler on the button runs:
       - evaluates each rule in its action list in turn
       - once one returns a SecureAction, sets up the button's secure attributes
1. the blizzard secure click handler uses the attributes to perform
   the mount action
1. if we're not in combat:
    1. the postclick handler runs and sets the actions to the default
       combat actions

### AutoEventFrame.lua

LM.CreateAutoEventFrame(...) takes the same arguments as CreateFrame but
sets up an OnEvent handler that dispatches events using a method with the
matching name.

E.g.,

```
  f = LM.CreateAutoEventFrame('Frame')
  function f:PLAYER\_LOGIN() print('You logged in!') end
  f:RegisterEvent('PLAYER\_LOGIN')
```

### Bindings.xml / KeyBindingStrings.lua

This is some deeply weird voodoo that WoW looks for in an addon to set up
keybindings.

### Localization.lua

Translations of all the texts.

### Environment.lua

Keeps track of various things about the player's environment. The location
part of it was more of a big deal before BfA when the map system changed and
you didn't have to keep messing with the map GUI to find out where you are.

The table InstanceFlyableOverride is really the only interesting part.

```
  LM.Environment
    CanFly()
    CantBreathe()
    GetJumpTime()
    GetMaxMapID()
    GetPlayerModel()
    GetPlayerTransmogInfo()
    GetStationaryTime()
    InInstance(...)
    IsCombatTravelForm()
    IsFalling()
    IsFloating()
    IsMapInPath(mapID)
    IsMovingOrFalling()
    IsOnMap(mapID)
    IsTheMaw()
    KnowsFlyingSkill()
```

### Print.lua

Printing and debugging functions.

```
  LM.Print
    Print(fmt, ...)
    PrintError(fmt, ...)
    Warning(fmt, ...)            - warnings go to UIErrorsFrame
    WarningAndPrint(fmt, ...)
    Debug(fmt, ...)
    UIDebug(frame, fmt, ...)
```

### SlashCommand.lua

The slash command parsing and executing function. It's attached to the
actual /litemount and /lmt texts in Core.lua

### SpellInfo.lua

Some constants about items and spells that are mounts or mount-like, as
well as the definition of the default flags and their sort order.


## How it all hangs together (the UI).

WoW UI programming is not something I really know well enough to explain. It's
gotten better since Mixins and it looks to be better again in Shadowlands with
the ability to prepend/append script handlers when inheriting.

Each UI panel frame inherits from LiteMountOptionsPanelTemplate, and defines
a number of controls by calling

```
  LiteMountOptionsPanel_RegisterControl(control [, self])
```

The second argument defaults to control:GetParent() if not specified.

The controls are UI elements. It doesn't really matter what they are but they
must implement this interface:

```
  val = control:GetOption()
  control:SetOption(val)
```

and optionally:

```
  val = control:GetDefaultOption()
  val = control:Getcontrol()
  control:SetControl(val)
```
The panel template code takes care of calling these methods to keep the
state of the options and the controls in sync, as well as keeping the "undo"
state and reverting on cancel.

It's not strictly necessary that GetOption() and SetOption() have anything to
do with what the control shows.  Usually the flow is something like:

```
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
```

But if you ignore the passed value on SetControl and query it in the UI itself
then you can just use the GetOption/SetOption for the undo behaviour.

