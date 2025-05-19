#!/usr/bin/python3 -tt

import json

def printVariance(dataFile, maxVariance):
    fieldVals = {}

    with open(dataFile) as f:
        data = json.load(f)
        for record in data:
            for k,v in record.items():
                if k not in fieldVals:
                    fieldVals[k] = set()
                fieldVals[k].add(v)

    for k in fieldVals:
        fieldVals[k] = list(fieldVals[k])
        if len(fieldVals[k]) > maxVariance:
            fieldVals[k] = len(fieldVals[k])
        else:
            fieldVals[k].sort()

    print(json.dumps(fieldVals, indent=2))

if __name__ == '__main__':
    from argparse import ArgumentParser

    p = ArgumentParser()
    p.add_argument('dataFile')
    p.add_argument('--max', type=int, default=20)
    args = p.parse_args()

    printVariance(args.dataFile, args.max)
