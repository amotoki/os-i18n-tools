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

from babel.messages import catalog
from babel.messages import pofile
from cliff import command
import yaml


class WritePo(command.Command):
    """Output glosarry to PO file."""

    def get_parser(self, prog_name):
        parser = super(WritePo, self).get_parser(prog_name)
        parser.add_argument('infile',
                            help='YAML file to be parsed.')
        parser.add_argument('outfile',
                            help='Output PO file.')
        parser.add_argument('--add-comment', action='store_true',
                            help='Add note as PO comment.')
        return parser

    def take_action(self, parsed_args):
        with open(parsed_args.infile) as f:
            data = yaml.safe_load(f.read())
        c = catalog.Catalog()
        c.fuzzy = False
        for d in data:
            params = {}
            if parsed_args.add_comment:
                params['auto_comments'] = [d['note']]
            c.add(d['id'], d['string'], **params)
        with open(parsed_args.outfile, 'w') as f:
            pofile.write_po(f, c, width=80)
