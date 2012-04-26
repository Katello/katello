# -*- coding: utf-8 -*-
#
# Copyright © 2011 Red Hat, Inc.
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
import os
from gettext import gettext as _

from katello.client.config import Config
from katello.client.core.base import Action, Command
from katello.client.core.utils import Printer
from katello.client.api.system_group import SystemGroupAPI


Config()

# base system group action --------------------------------------------------------
class SystemGroup(Command):

    description = _('system group specific actions in the katello server')

class SystemGroupAction(Action):

    def __init__(self):
        super(SystemGroupAction, self).__init__()
        self.api = SystemGroupAPI()

# system group actions ------------------------------------------------------------


class List(SystemGroupAction):

    description = _('list system groups within an organization')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                       help=_("organization name eg: foo.example.com (required)"))

    def check_options(self):
        self.require_option('org')

    def run(self):
        org_name = self.get_option('org')

        system_groups = self.api.system_groups(org_name)

        if system_groups is None:
            return os.EX_DATAERR

        self.printer.setHeader(_("System Groups"))

        self.printer.addColumn('id')
        self.printer.addColumn('name')

        self.printer._grep = True
        self.printer.printItems(system_groups)
        return os.EX_OK
