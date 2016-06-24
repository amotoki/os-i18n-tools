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

import sys

from cliff import app
from cliff import commandmanager


DESCRIPTION = 'OpenStack i18n glossary tool'
VERSION = '0.1'
COMMAND_ENTRY_POINTS_BASE = 'openstack_i18n_tools.glossary'


class GlossaryTool(app.App):

    def __init__(self):
        super(GlossaryTool, self).__init__(
            description=DESCRIPTION,
            version='0.1',
            command_manager=commandmanager.CommandManager(
                COMMAND_ENTRY_POINTS_BASE),
            deferred_help=True)


def main(argv=sys.argv[1:]):
    glossary_app=GlossaryTool()
    return glossary_app.run(argv)


if __name__ == '__main__':
    sys.exit(main(sys.argv[1:]))
