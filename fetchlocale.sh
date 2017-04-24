#!/bin/sh

# Password-encrypted for git storage.
if [ "$APIKEY" = "" ]; then
    APIKEY=`openssl enc -d -a -A -aes-256-cbc <<_EOT
U2FsdGVkX1+CTBBSfInL8LMPiI7om41sGD6f5HWBCVDyFpIym5dodQNe3Y0L3fz+S3qdQWvkZV5Sj7mx9Yh9rA==
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
        printf "L.%-21s = %s\n" "C1" 'CUSTOM .. "1"'
        printf "L.%-22s= %s\n" "C2" 'CUSTOM .. "2"'
        ;;
    esac

    echo "end"
    echo
done
