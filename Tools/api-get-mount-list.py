#!/usr/bin/python3 -tt

from warnings import catch_warnings

with catch_warnings(record=True) as w:
    import requests

import os, json

auth = (os.environ['WOW_API_CLIENT_ID'], os.environ['WOW_API_CLIENT_SECRET'])

r = requests.post('https://oauth.battle.net/token', auth=auth, params={ 'grant_type': 'client_credentials' })
r.raise_for_status()

s = requests.session()
s.headers['Authorization'] = 'Bearer {}'.format(r.json()['access_token'])
s.headers['Battlenet-Namespace'] = 'static-us'
s.headers['Connection'] = 'close'

params = { 'name.en_US': id }
r = s.get('https://us.api.blizzard.com/data/wow/mount/index', params=params)
r.raise_for_status()
print(json.dumps(r.json(), ensure_ascii=False, indent=4))
