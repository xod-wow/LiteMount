--[[----------------------------------------------------------------------------

  LiteMount/Parser.lua

  Parser for action conditions.

  Copyright 2011-2016 Mike Battersby

----------------------------------------------------------------------------]]--

--[[

    <line>          :=  <action> |
                        <conditions> " " <action>

    action>         :=  STRING

    <conditions>    :=  <condition> |
                        <condition> <conditions>

    <condition>     :=  "[" <expressions> "]"

    <expressions>   :=  <expr> |
                        <expr> "," <expressions>

    <expr>          :=  "no" <setting> |
                        <setting>

    <setting>       :=  <tag> |
                        <tag> "=" <args>

    <args>          :=  <arg> |
                        <arg> / <args>

    <arg>           :=  [-a-zA-Z0-9]+

    <tag>           :=
                        "achievement"
                        "areaid" |
                        "class" |
                        "continent" |
                        "equipped" |
                        "flyable" |
                        "flying" |
                        "group" |
                        "indoors" |
                        "mounted" |
                        "outdoors" |
                        "pet" |
                        "spec" |
                        "swimming" |
                        "talent"
                        "vehicle" |
]]

-- This is going to be slow. Also regex parsers are hell.

function LiteMountCmdParse(line)
end
