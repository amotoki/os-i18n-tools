#!/usr/bin/env python

from __future__ import print_function

import argparse
import glob
import os
import pprint
import re
import subprocess

from django.conf.locale import LANG_INFO


DEBUG = False


def get_django_lang_name(code, all_codes):
    code = code.lower().replace('_', '-')
    code_orig = code
    lang_info = LANG_INFO.get(code)
    if not lang_info:
        code = code.split('-', 1)[0]
        if code not in all_codes:
            lang_info = LANG_INFO.get(code)
    if lang_info:
        return code, lang_info['name']
    else:
        return code_orig, code_orig


def get_lang_list_per_module(base_dir, module, po_name, threshold):
    locale_dir = os.path.join(base_dir, module, 'locale')
    pot_file = os.path.join(locale_dir, '%s.pot' % po_name)
    if not os.path.exists(pot_file):
        return
    po_glob = os.path.join(locale_dir, '*', 'LC_MESSAGES', '%s.po' % po_name)
    po_files = glob.glob(po_glob)
    return [get_lang_name(po_file, locale_dir) for po_file in po_files
            if get_translation_progress(po_file, pot_file) >= threshold]


def get_lang_name(po_file, locale_dir):
    parent_component_len = len(locale_dir.split('/'))
    po_file_components = po_file.split('/')
    return po_file_components[parent_component_len]


def get_translation_progress(po_file, pot_file):
    output = subprocess.check_output(
        ['msgfmt', '-o', '/dev/null', '--statistics', pot_file],
        stderr=subprocess.STDOUT)
    total = float(re.match('.* ([0-9]+) untranslated messages.*',
                           output.strip()).group(1))
    output = subprocess.check_output(
        ['msgfmt', '-o', '/dev/null', '--statistics', po_file],
        stderr=subprocess.STDOUT)
    translated = float(re.match('^([0-9]+) translated messages.*',
                                output.strip()).group(1))
    return translated / total


def get_lang_list(base_dir, threshold):
    locale_files = [('horizon', 'django'),
                    ('horizon', 'djangojs'),
                    ('openstack_dashboard', 'django'),
                    ('openstack_dashboard', 'djangojs')]
    lang_lists = [get_lang_list_per_module(base_dir, module, po_file,
                                           threshold)
                  for module, po_file in locale_files]
    if DEBUG:
        for entry, result in zip(locale_files, lang_lists):
            if result:
                print('%s => %s %s' % (entry, len(result), sorted(result)))
    langs = reduce(lambda a, b: set(a) & set(b), lang_lists)
    return langs


if __name__ == '__main__':

    parser = argparse.ArgumentParser()
    parser.add_argument('--threshold', '-t', type=float, default=0.75,
                        help='Minimum percentage of translations')
    parser.add_argument('--horizon-path', '-p', default='/opt/stack/horizon',
                        help='Path of Horizon repository')
    parser.add_argument('--debug', '-d', action='store_true',
                        help='Debug mode')
    parsed_args = parser.parse_args()

    if parsed_args.debug:
        DEBUG = True

    langs = get_lang_list(parsed_args.horizon_path, parsed_args.threshold)
    lang_list = [get_django_lang_name(l, langs) for l in sorted(langs)]

    if parsed_args.debug:
        pprint.pprint(tuple(lang_list))
    else:
        print('LANGUAGES = ', end='')
        pprint.pprint(tuple(lang_list))
