#!/usr/bin/python3 -tt

from warnings import catch_warnings
with catch_warnings(record=True) as w:
    import requests
import os, re

SupportedLocales = [ "enUS", "deDE", "esES", "esMX", "frFR", "itIT", "koKR", "ptBR", "ruRU", "zhCN", "zhTW" ]

def GetFamiliesFromCurse(locale):
    headers = {
        'X-Api-Token': os.environ['APIKEY']
    }
    params = {
        'export-type': 'TableAdditions',
        'lang': locale,
        'namespaces': 'Family',
        'unlocalized': 'Ignore',
        # 'concatenate-subnamespaces': true,
    }

    r = requests.get(
            'https://wow.curseforge.com/api/projects/30359/localization/export',
            params=params,
            headers=headers
        )
    r.raise_for_status()

    out = []
    for line in r.content.decode().splitlines():
        m = re.match('L\["(.+)"\] = ', line)
        if m:
            out.append(m.group(1))
    return out

def GetFamiliesFromFile(fileName):
    out = []
    with open(fileName) as f:
        for line in f:
            m = re.match('^Model\["(.+)"\] = ', line)
            if m and m.group(1) not in [ 'DRIVE', 'Unknown' ]:
                out.append(m.group(1))
    return out

allFamilies = GetFamiliesFromFile('../MountDB/Model.lua')

translatedFamilies =  {}

for locale in SupportedLocales:
    translatedFamilies[locale] = GetFamiliesFromCurse(locale)

for fam in allFamilies:
    missingLocales = [ locale for locale in translatedFamilies if fam not in translatedFamilies[locale] ]
    if missingLocales:
        print('{} : {}'.format(fam, ','.join(missingLocales)))

