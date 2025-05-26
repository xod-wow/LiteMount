#!/bin/sh

if [ "$APIKEY" = "" ]; then
    exit 1
fi

DASHES=--------------------------------------------------------------------------------

header () {
    _LINE="-- $1 "
    _LEN=$(( 1 + 80 - $(echo "$_LINE" | wc -c) ))
    printf "%s%.*s\n" "$_LINE" $_LEN $DASHES
    echo
}

fetch () {
    curl -s -H "X-Api-Token: $APIKEY" "https://wow.curseforge.com/api/projects/30359/localization/export?export-type=TableAdditions&lang=$1&namespaces=Base+Namespace,Family&concatenate-subnamespaces=true&unlocalized=Ignore" | sed -e 's/..*/    &/'
}

header "enUS / enGB / Default"
fetch enUS
echo

for locale in "deDE" "esES" "esMX" "frFR" "itIT" "koKR" "ptBR" "ruRU" "zhCN" "zhTW"; do

    # esES includes esMX but is then overridden if a better translation is available
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
    if [ "$locale" != "zhTW" ]; then
        echo
    fi
done
