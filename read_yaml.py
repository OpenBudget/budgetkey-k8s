#!/usr/bin/env python

import sys, json, yaml, os

filename = sys.argv[1]
with open(filename) as f:
    values = yaml.load(f, Loader=yaml.SafeLoader)

def get_from_dict(values, keys):
    if len(keys) < 1:
        return '{}'
    if len(keys) > 1:
        return get_from_dict(values[keys[0]], keys[1:])
    else:
        return values[keys[0]]


print(json.dumps(get_from_dict(values, sys.argv[2:]), separators=(',', ':')))

