#!/usr/bin/env python

import json
import sys

def extract_langs_greater_than_thresh(threshold, filename):
    with open(filename) as f:
        stat = json.loads(f.read())
    langs = [lang for lang in stat
             if int(stat[lang]['completed'].replace('%','')) >= threshold]
    return set(langs)

def extract_lang_satisfy_all(threshold, filenames):
    return reduce(lambda x, y: x & y,
                  [extract_langs_greater_than_thresh(threshold, filename)
                   for filename in filenames])

def main(argv):
    if len(argv) < 3:
        print 'Usage: %s threshold statfile....' % argv[0]
        raise SystemExit(1)
    threshold = int(argv[1])
    filenames = argv[2:]
    langs = extract_lang_satisfy_all(threshold, filenames)
    for lang in sorted(langs):
        print lang

if __name__ == '__main__':
    main(sys.argv)
