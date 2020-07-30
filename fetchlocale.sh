#!/bin/sh

# Password-encrypted for git storage.
if [ "$APIKEY" = "" ]; then
    APIKEY=`openssl enc -d -a -A -aes-256-cbc -pbkdf2 <<_EOT
U2FsdGVkX1+IBMmKkSX455AIlhLvOq+/N2wbJOWIQotkGeL7J9fMaZLVXbHtH1HFY4r8nSo4/FEnWuwkQDQl0A==
_EOT`
fi

DASHES=--------------------------------------------------------------------------------

header () {
    _LINE="-- $1 "
    _LEN=$(( 1 + 80 - $(echo "$_LINE" | wc -c) ))
    printf "%s%.*s\n" "$_LINE" $_LEN $DASHES
    echo
}

fetch () {
    curl -s -H "X-Api-Token: $APIKEY" "https://wow.curseforge.com/api/projects/30359/localization/export?export-type=GlobalStrings&lang=$1&unlocalized=Ignore" | awk -F' = ' '{ printf("L.%-21s = %s\n", $1, $2) }'
}

header "enUS / enGB / Default"
fetch enUS
echo

for locale in "deDE" "esES" "frFR" "itIT" "koKR" "ptBR" "ruRU" "zhCN" "zhTW"; do

    # As far as I can tell everyone treats esES and esMX as identical
    case $locale in
    esES)
        header "esES / esMX"
        echo 'if locale == "esES" or locale == "esMX" then'
        ;;
    *)
        header $locale
        echo "if locale == \"$locale\" then"
        ;;
    esac
    fetch $locale

    # In logographic languages we don't need abbreviations
    case $locale in
    koKR|zhCN|zhTW)
        ;;
    esac

    echo "end"
    echo
done
