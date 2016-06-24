# All Rights Reserved.
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

import difflib

from cliff import command
import yaml


class Sync(command.Command):
    """Sync per-language glossary with the master glossary"""

    def get_parser(self, prog_name):
        parser = super(Sync, self).get_parser(prog_name)
        parser.add_argument('masterfile',
                            help='Master glossary file.')
        parser.add_argument('langfile',
                            help='Per-language glossary file.')
        return parser

    def load_file(self, infile):
        """Load YAML data."""
        with open(infile) as f:
            data = yaml.safe_load(f.read())
        return dict((d['id'], d) for d in data)

    def sync_data(self, masterdata, langdata):
        for entry in masterdata:
            if entry not in langdata:
                print('Need to add "%s".' % entry)
                data = {'id': masterdata[entry]['id'],
                        'string': '',
                        'note': ''}
                langdata[entry] = data
            if masterdata[entry].get('note'):
                langdata[entry]['masternote'] = masterdata[entry]['note']
            elif 'masternote' in langdata[entry]:
                del langdata[entry]['masternote']

        nonexisting = [entry for entry in langdata
                       if entry not in masterdata]
        for entry in nonexisting:
            print('"%s" not found in the master data.' % entry)
            del langdata[entry]

    def get_yamldata(self, data):
        newdata = sorted(data.values(),
                         key=lambda x: x['id'].lower())
        return yaml.safe_dump(newdata, default_flow_style=False,
                              allow_unicode=True)

    def show_diff(self, newdata, langfile):
        with open(langfile) as f:
            olddata = f.read().split('\n')
        diff = difflib.context_diff(olddata, newdata.split('\n'),
                                    fromfile='before', tofile='after')
        for line in diff:
            print(line.rstrip())

    def write_data(self, data, outfile):
        with open(outfile, 'w') as f:
            f.write(data)

    def take_action(self, parsed_args):
        masterdata = self.load_file(parsed_args.masterfile)
        langdata = self.load_file(parsed_args.langfile)
        self.sync_data(masterdata, langdata)

        newdata = self.get_yamldata(langdata)
        self.show_diff(newdata, parsed_args.langfile)

        self.write_data(newdata, parsed_args.langfile)
