#
# Katello Organization actions
# Copyright (c) 2010 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
#
# Red Hat trademarks are not licensed under GPLv2. No permission is
# granted to use or replicate Red Hat trademarks that are incorporated
# in this software or its documentation.
#

import os
from gettext import gettext as _

from katello.client.config import Config
from katello.client.shell import KatelloShell
from katello.client.core.base import Action

Config()

# shell action ------------------------------------------------------------

class ShellAction(Action):

    description = _('run the cli as a shell')
    name = "shell"

    def __init__(self, cli):
        super(ShellAction, self).__init__()
        self.admin = cli

    def setup_parser(self, parser):
        return 0

    def run(self):
        self.admin.usage_line = '[cmd] <options>'
        self.admin.remove_command(ShellAction.name)
        shell = KatelloShell(self.admin)
        shell.cmdloop()

        return os.EX_OK
