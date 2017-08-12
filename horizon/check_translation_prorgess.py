#!/usr/bin/env python

import argparse
import collections
import glob
import itertools
import os.path
import pprint
import sys

from babel.messages import pofile

DEBUG = False
DOMAINS = ['django', 'djangojs']
MODULES = ['horizon', 'openstack_dashboard']


def get_pot_num_entries(pot_file):
    with open(pot_file) as f:
        catalog = pofile.read_po(f)
    return len(catalog)


def get_po_num_entries(po_file):
    with open(po_file) as f:
        catalog = pofile.read_po(f)
    return len([x for x in catalog
                if x.id and x.string and not x.fuzzy])


def get_pot_files():
    pot_files = {}
    for module, domain in itertools.product(MODULES, DOMAINS):
        pot_file = '%s/locale/%s.pot' % (module, domain)
        if not os.path.exists(pot_file):
            raise Exception('Some POT file(s) do not exist. '
                            'Generate POT files first.')
        pot_files[(module, domain)] = get_pot_num_entries(pot_file)
    return pot_files


def gather_lang_files_per_domain(lang_stats, module, domain):
    files = glob.glob('%s/locale/*/LC_MESSAGES/%s.po' % (module, domain))
    for f in files:
        lang = f.split('/')[2]
        print('Processing %s...' % f)
        lang_stats[lang][(module, domain)] = get_po_num_entries(f)


def calculate_language_progress(lang, lang_stats, pot_files, threshold):
    translated = sum(lang_stats[lang].values())
    total = sum(pot_files.values())
    progress = 100.0 * translated / total
    if progress >= threshold:
        print('%s: %.1f%%' % (lang, progress))
    elif DEBUG:
        print('%s: %.1f%% (XXXX)' % (lang, progress))
    if DEBUG:
        for key in pot_files:
            print('  %s: %s/%s' %
                  (key, lang_stats[lang].get(key, 0), pot_files[key]))


if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('--debug', action='store_true')
    parser.add_argument('--threshold', type=float, default=0.0)
    parsed_args = parser.parse_args()

    DEBUG = parsed_args.debug

    POT_FILES = get_pot_files()
    pprint.pprint(POT_FILES)

    LANG_STATS = collections.defaultdict(dict)
    for module, domain in POT_FILES:
        gather_lang_files_per_domain(LANG_STATS, module, domain)

    for lang in sorted(LANG_STATS):
        calculate_language_progress(lang, LANG_STATS, POT_FILES,
                                    parsed_args.threshold)
