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

from babel.messages import pofile
from cliff import command
import yaml


class ReadPo(command.Command):
    """Load glosarry from PO file."""

    def get_parser(self, prog_name):
        parser = super(ReadPo, self).get_parser(prog_name)
        parser.add_argument('infile',
                            help='PO file to be parsed.')
        parser.add_argument('outfile',
                            help='Output file.')
        return parser

    def take_action(self, parsed_args):
        data = []
        with open(parsed_args.infile) as f:
            catalog_in = pofile.read_po(f)
        data = [{'id': msg.id.strip(),
                 'string': msg.string,
                 'note': ''}
                for msg in catalog_in if msg.id]
        data = sorted(data, key=lambda x: x['id'].lower())

        with open(parsed_args.outfile, 'w') as f:
            f.write(yaml.safe_dump(data,
                                   default_flow_style=False,
                                   allow_unicode=True))
