#!/usr/bin/python3 -tt

from warnings import catch_warnings
with catch_warnings(record=True) as w:
    import requests

import os, re
from argparse import ArgumentParser

auth = (os.environ['WOW_API_CLIENT_ID'], os.environ['WOW_API_CLIENT_SECRET'])

parser = ArgumentParser()
parser.add_argument('-c', '--compact', action='store_true')
parser.add_argument('-s', '--sort', action='store_true')
parser.add_argument('id', nargs='+')
args = parser.parse_args()

r = requests.post('https://oauth.battle.net/token', auth=auth, params={ 'grant_type': 'client_credentials' })
r.raise_for_status()

s = requests.session()
s.headers['Authorization'] = 'Bearer {}'.format(r.json()['access_token'])
s.headers['Battlenet-Namespace'] = 'static-us'
s.headers['Connection'] = 'close'

def find_best(data, id):
    exactMatch = [ x for x in data if x['name']['en_US'] == id ]
    if exactMatch:
        return exactMatch

    subMatch = [ x for x in data if id in x['name']['en_US'] ]
    if subMatch:
        return subMatch

    words = id.split(' ')
    wordMatch = [ x for x in data if all(w in x['name']['en_US'] for w in words) ]
    if wordMatch:
        return wordMatch

    patternMatch = [ x for x in data if re.match(id, x['name']['en_US']) ]
    if patternMatch:
        return patternMatch

    return data

def query_type(qtype, id):
    params = { 'name.en_US': id }
    r = s.get('https://us.api.blizzard.com/data/wow/search/{}'.format(qtype), params=params)
    r.raise_for_status()
    data = [ x['data'] for x in r.json()['results'] ]
    return data

rows = set()

for id in args.id:
    qtype = None
    if '=' in id:
        qtype, id = id.split('=')
        try:
            id = int(id)
        except:
            pass

    if qtype:
        if type(id) == int:
            r = s.get('https://us.api.blizzard.com/data/wow/{}/{}'.format(qtype, id))
            r.raise_for_status()
            data = [ r.json() ]
        else:
            data = query_type(qtype, id)
    else:
        data = []
        for qtype in [ 'creature', 'mount', 'journal-encounter' ]:
            data.extend(query_type(qtype, id))

    for d in find_best(data, id):
        for locale, name in d['name'].items():
            if locale not in [ 'en_US', 'en_GB' ]:
                rows.add((locale, id, name, d['name']['en_US']))

rows = list(rows)

current_locale = ''

if args.sort:
    rows.sort(key=lambda x: x)
else:
    # multi-sort because python
    rows.sort(key=lambda x: x[2])
    rows.sort(key=lambda x: x[3])
    rows.sort(key=lambda x: x[1])
    rows.sort(key=lambda x: x[0])

for r in rows:
    if args.compact:
        print('{} L["{}"] = "{}" -- {}'.format(*r))
    else:
        if r[0] != current_locale:
            print(r[0])
            current_locale = r[0]
        print('  L["{}"] = "{}" -- {}'.format(r[1], r[2], r[3]))
