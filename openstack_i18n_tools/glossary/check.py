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

from cliff import command
import yaml


class Check(command.Command):
    """Syntax check of Glossary YAML file."""

    def get_parser(self, prog_name):
        parser = super(Check, self).get_parser(prog_name)
        parser.add_argument('infile',
                            help='Input YAML file.')
        parser.add_argument('--show-contents',
                            action='store_true',
                            help='Show contents loaded from YAML file.')
        return parser

    def print_entry(self, entry):
        print('%s: %s' % (entry['id'], entry['string']))
        if entry['note']:
            print('  note: %s' % entry['note'])

    def take_action(self, parsed_args):
        with open(parsed_args.infile) as f:
            data = yaml.safe_load(f.read())

        if parsed_args.show_contents:
            print('--- Loaded contents ---')
            for entry in data:
                self.print_entry(entry)
