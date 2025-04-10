#!/usr/bin/python3 -tt

import ssl

import warnings
warnings.simplefilter("ignore", Exception, append=True)
import requests
warnings.resetwarnings()

import os, re
from pprint import pprint
from argparse import ArgumentParser

auth = (os.environ['WOW_API_CLIENT_ID'], os.environ['WOW_API_CLIENT_SECRET'])

parser = ArgumentParser()
parser.add_argument('-t', '--type', default='item', nargs='?')
parser.add_argument('-c', '--compact', action='store_true')
parser.add_argument('-s', '--sort', action='store_true')
parser.add_argument('id', nargs='+')
args = parser.parse_args()

r = requests.post('https://oauth.battle.net/token', auth=auth, params={ 'grant_type': 'client_credentials' })
r.raise_for_status()

s = requests.session()
s.headers['Authorization'] = 'Bearer {}'.format(r.json()['access_token'])
s.headers['Battlenet-Namespace'] = 'static-us'

rows = []

for id in args.id:
    if '=' in id:
        qtype, id = id.split('=')
    else:
        qtype = args.type

    try:
        id = int(id)
    except:
        pass

    if type(id) == int:
        r = s.get('https://us.api.blizzard.com/data/wow/{}/{}'.format(qtype, id))
        r.raise_for_status()
        data = [ r.json() ]
    else:
        params = { 'name.en_US': id }
        r = s.get('https://us.api.blizzard.com/data/wow/search/{}'.format(qtype), params=params)
        r.raise_for_status()
        data = [ x['data'] for x in r.json()['results'] ]
        exactMatch = [ x for x in data if x['name']['en_US'] == id ]
        patternMatch = [ x for x in data if re.match(id, x['name']['en_US']) ]
        if exactMatch:
            data = exactMatch
        elif patternMatch:
            data = patternMatch

    for d in data:
        for locale, name in d['name'].items():
            if locale not in [ 'en_US', 'en_GB' ]:
                rows.append((locale, d['name']['en_US'], name))

current_locale = ''

if args.sort:
    rows.sort(key=lambda x: x)
else:
    rows.sort(key=lambda x: x[0])

for r in rows:
    if args.compact:
        print('{} L["{}"] = "{}"'.format(*r))
    else:
        if r[0] != current_locale:
            print(r[0])
            current_locale = r[0]
        print('  L["{}"] = "{}"'.format(r[1], r[2]))
