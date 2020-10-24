#!/usr/bin/python3.7 -tt

import requests, sys
import unicodecsv as csv

translations = {}

with open(sys.argv[1], 'rb') as f:
    reader = csv.reader(f, dialect=csv.excel_tab)
    headers = next(reader, None)

    headers[0] = 'enUS'

    for lang in headers:
        translations[lang] = []

    for row in reader:
        phrase = row[0]
        for i in range(0, len(row)):
            translations[headers[i]].append( (phrase, row[i]) )

print("{")

for t in translations[sys.argv[2]]:
    print('    ["{0}"] = "{1}",'.format(*t))

print("}")

#https://wow.curseforge.com/api/projects/{projectID}/localization/import
#
#
#
#    {
#       metadata: {
#           //Note all of these are optional exception language
#           language: "enUS", //[enUS, deDE, esES, ect], Required, No Default
#           namespace: "toc", //Any namespace name, comma delimited. Default: Base Namespace
#           formatType: TableAdditions, //['GlobalStrings','TableAdditions','SimpleTable']. Default: TableAdditions
#           missing-phrase-handling: DoNothing //['DoNothing', 'DeleteIfNoTranslations', 'DeleteIfTranslationsOnlyExistForSelectedLanguage', 'DeletePhrase']. Default: DoNothing
#       }, 
#       localizations: "Localizations To Import"
#    }
#
#
#
#curl -H "X-Api-Token: $APIKEY" \
#    https://wow.curseforge.com/api/projects/30359/localization/export
#
#?export-type=GlobalStrings&lang=$1&unlocalized=Ignore
#    https://wow.curseforge.com/api/projects/{projectID}/localization/export
#
