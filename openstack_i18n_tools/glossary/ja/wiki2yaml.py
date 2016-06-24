#!/usr/bin/env python

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import argparse
import sys

import yaml


def convert(infile, outfile):
    glossaries = []
    with open(infile) as f:
        for line in f:
            if not line.startswith('|'):
                continue
            if line.startswith('|-') or line.startswith('|}'):
                continue
            if 'colspan=' in line:
                continue
            line = line.lstrip('|')
            entry = [elm.strip() for elm in line.split('||', 3)]
            if not entry:
                continue
            while len(entry) < 3:
                entry.append('')
            glossaries.append({'id': entry[0],
                               'string': entry[1],
                               'note': entry[2]})

    with open(outfile, 'w') as f:
        f.write(yaml.safe_dump(glossaries,
                               default_flow_style=False,
                               allow_unicode=True))


def main(argv=sys.argv[1:]):
    parser = argparse.ArgumentParser()
    parser.add_argument('infile', help='Wiki text')
    parser.add_argument('outfile', help='Output YAML file')
    parsed_args = parser.parse_args()

    convert(parsed_args.infile, parsed_args.outfile)
