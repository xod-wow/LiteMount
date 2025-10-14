#!/usr/bin/python3 -tt

import json

def PrintModels(dataFile):
    mountsByModel = {}
    with open(dataFile) as f:
        data = json.load(f)
        for r in data:
            filename = r['FilePath'].split('/')[-1]
            if not filename in mountsByModel:
                mountsByModel[filename] = []
            mountsByModel[filename].append(r)

    for t in mountsByModel.values():
        t.sort(key=lambda x: x['Name_lang'])

    for n in sorted(mountsByModel.keys()):
        print(n)
        for r in mountsByModel[n]:
            print('   [{SourceSpellID:>7}] = true, -- {ID} {Name_lang}'.format(**r))
        print()

if __name__ == '__main__':
    from argparse import ArgumentParser

    p = ArgumentParser()
    p.add_argument('dataFile')
    args = p.parse_args()

    PrintModels(args.dataFile)
