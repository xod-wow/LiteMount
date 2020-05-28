# Advanced Options

The Advanced Options sub-panel in the LiteMount settings exposes some of
the addon's internal workings to allow more advanced customization. You
can see and edit the action lists that are associated with each of the
four LiteMount key bindings.

From this panel you can also add and delete your own mount flags (in
addition to the default set of SWIM, FLY, RUN, WALK and FAVORITES).

You can add these flags to mounts using the Mounts settings panel,
and use them in action lists.

## Example

This is the default action list from LiteMount 8.3.5:

```
# Slow Fall, Levitate, Zen Flight, Glide
Spell [falling] 130, 1706, 125883, 131347
LeaveVehicle
CancelForm
Dismount
CopyTargetsMount
# Swimming mount to fly in Nazjatar with Budding Deepcoral
Mount [map:1355,flyable,qfc:56766] mt:254
# Vashj'ir seahorse is faster underwater there
Mount [map:203,submerged] mt:232
# AQ-only bugs in the raid zone
Mount [instance:531] mt:241
# The Nagrand (WoD) mounts can interact while mounted
Mount [map:550,noflyable,nosubmerged] 164222/165803
# Use Arcanist's Manasaber if it will disguise you
Mount [nosubmerged,extra:202477] id:881
Mount [nosubmerged,aura:202477] id:881
IF [mod:shift,flyable][mod:shift,waterwalking]
 Limit RUN/WALK,~FLY
END
SmartMount {CLASS}/{RACE}/{FACTION}
SmartMount
Macro
```

 
## Action List Format
 

The format of a LiteMount action list is:

- Each line is run in turn until one succeeds.
- Each line contains an action, optionally a set of tests to restrict when the action is tried, and finally a set of action parameters.
- Each test is contained inside square brackets []
- Tests are logically OR-ed; they are successful if ANY match.
- Each test (inside []) is a set of conditionals, separated by commas.
- Conditionals are logically AND-ed; they are successful only if ALL match.
- An action is not attempted unless its tests match.

  
## Actions

- `CancelForm`
- `CopyTargetsMount`
- `Dismount`
- `Limit MOUNTS / Endlimit`
- `LeaveVehicle`
- `Macro`
- `Mount MOUNTS`
- `Script SCRIPTLINE`
- `SmartMount MOUNTS`
- `Spell SPELLS`
- `Stop`
- `Use ITEMS`
- `IF / ELSEIF / ELSE / END`

 
## MOUNTS parameter

The `Limit`, `Mount` and `SmartMount` actions take a MOUNTS parameter.

The parameter is a comma separated list of mount selections, all of which
must match ("AND"). Selections may additionally be separated with /
(slash), which matches any of those conditions ("OR"). Selections may
be negated with ~SELECTION.

A selection that is all numbers is an exact mount spell ID to match.

The selection mt:<n> matches mounts with mountType <n>.

The selection id:<n> matches exactly the one mount with mountID <n>

All other selections are either an exact mount name, or a mount flag to
match. The default set of mount flags actions is:

- RUN
- FLY
- SWIM
- WALK
- FAVORITES

You can create and assign your own additional mount flags.

 
## Limit / EndLimit

The Limit action limits the set of mounts that will be considered by
all later action list lines.

The EndLimit action reverts the list of mounts to that prior to the most
recent Limit action.

 
## Mount vs SmartMount

The Mount action randomly chooses from all of the matching mounts.

The SmartMount action is location-aware. It will look for the type
of mount that is best for the current situation (Swimming / Flying /
Running) and choose a mount of that type from the filtered mounts.

 
## CancelForm

The CancelForm action attempts to cancel a mount-style shapeshift form
(Travel Form, Flight Form, Ghost Wolf). It will only cancel forms that
correspond to enabled mounts in the LiteMount settings.

CancelForm will attempt to put you back in the form you were in before
you activated LiteMount.

## CopyTargetsMount

Attempts to copy the mount of your target.

## Dismount

Dismount if mounted.

## LeaveVehicle

Leave vehicle if in one.

## Macro

Run the "Unavailable" macro from the LiteMount settings. See the Script
action if you want to run your own script line.
 
## Script SLASHCOMMAND

Run a slash command exactly as if you had typed it into the chat box.

If you need to include commas or [macroconditions] in your script,
quote the whole script line with "double quotes".

If a script command matches it is always run and LiteMount ends
processing, even if it does nothing.

## Spell SPELLS

The SPELLS parameter is a comma-separated list of spell names or spell
IDs to cast. If you need to include commas in your spell names, quote them
with "double quotes". The first one that is known and usable is cast..

## Stop

Stop processing and don't perform any action.

## Use ITEMS

The ITEMS parameter is a comma-separated list of item IDs, item names,
or inventory slot numbers, just like the /use macro command.

Checks each item in turn to see if it is usable. You cannot use this to
equip items.

## IF / ELSEIF / ELSE / END

Flow control options. These take no parameters but operate off the given
[conditions].

E.g.,

```
IF [instance:1]
  ...
ENDIF
```

## Conditionals

These can all be prefixed with "no" to reverse the check. E.g., [nopvp]

- achievement:\<achievementID>
- aura:\<spellID>
- breathbar
- canexitvehicle
- channeling
- class:\<classname>
- dead
- draw:\<x>/\<y> - random, x chances in y, deck-of-cards style, max y=52
- equipped:\<itemID> or equipped:<itemType>; includes mount equipment
- exists or exists:\<unit> - defaults to "target"
- extra or extra:\<spellID> - extra action button
- faction:Horde or faction:Alliance
- falling
- false
- floating - on the water surface, based on jumping out
- flyable - flyable area, better than the blizzard macro version
- flying - currently flying (on a flying mount)
- form:\<formID> - shapeshift form, /dump GetShapeshiftForm()
- group or group:raid - default is "party"
- harm:\<unit> - default is "target"
- help:\<unit> - default is "target"
- indoors
- instance or instance:\<instanceID> or instance:\<arena|pvp|party|raid|scenario>
- jump - jumped in the last 2 seconds
- map:\<uiMapID> - see /litemount maps, checks along the whole map path
- map:\*\<uiMapID> - prefix with * to check exactly the current map
- mod or mod:\<alt|ctrl|shift> - [mod:alt/ctrl] works if either are held
- mounted
- moving
- name:\<characterName>
- outdoors
- party:\<unit> - unit is in our party, default "target"
- pet or pet:\<petName> or pet:<petFamily>
- profession:\<id or name>
- pvp
- qfc:\<questid> - IsQuestFlaggedCompleted
- race:\<raceName> - second return value from /dump UnitRace("player")
- raid:\<unit> - unit is in our raid, default "target"
- random:\<percent> - random roll percentage chance
- realm:\<realmName> - as returned by /dump GetRealmName()
- role:\<roleName> - assigned LFG role, DAMAGER/HEALER/TANK
- resting
- sameunit:\<unit> - e.g., sameunit:target
- sex:\<n> - 2 = male, 3 = female
- shapeshift
- spec:\<specNum> or spec:\<specRole> - DAMAGER/HEALER/TANK
- stealthed
- submerged - in water, not floating
- swimming - in water, includes floating
- talent:\<row\>/\<talent\>
- tracking:\<name> - same as on the minimap button menu, e.g. "Find Herbs"
- true
- waterwalking - can walk on water (mount equipment or buff)
- xmog:\<slotNum\>/\<appearanceID\> - /litemount xmog \<slotNum\> shows current

  
## Variables

The following variables can be used in action lists, and will be replaced
before the action line is evaluated. You must include the text exactly
as listed, including the curly brackets.

- {CLASSID} the global class ID number of the player's class
- {CLASS} the non-localized English name of the player's class (e.g., WARRIOR)
- {CLASS\_L} - localized
- {FACTION} "Horde" or "Alliance"
- {FACTION\_L} - localized
- {MAPID} current map "uiMapID" number. /litemount maps \<searchText\>
- {RACE} - non-localized English name of the player's race
- {RACE\_L} - localized
- {ROLE} current spec's game role; one of DAMAGER, TANK, HEALER
- {SPEC} current spec's number within your class (1/2/3 etc).
- {SPECID} the global spec ID of the players class+spec. See http://wowwiki.wikia.com/wiki/SpecializationID

 
## Randomness

There are two randomizing conditions available:

[draw:\<x\>/\<y\>]

Makes a shuffled deck of cards with y cards, x of which are success and
the rest are failure. Draw and discard the top card of the deck. When
the deck is empty, reshuffle it.

[random:\<percentage\>]

Roll a 1-100 die, and if the number is <= the given percentage, return
success.
