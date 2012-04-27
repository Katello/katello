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
from katello.client.api.utils import get_system_group


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

        self.printer.setHeader(_("System Groups List For Org [ %s ]") % org_name)

        if system_groups is None:
            return os.EX_DATAERR

        self.printer.addColumn('id')
        self.printer.addColumn('name')

        self.printer._grep = True
        self.printer.printItems(system_groups)
        return os.EX_OK


class Info(SystemGroupAction):

    description = _('display a system group within an organization')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                       help=_("organization name eg: foo.example.com (required)"))
        self.parser.add_option('--name', dest='name',
                       help=_("system group name (required)"))

    def check_options(self):
        self.require_option('org')
        self.require_option('name')

    def run(self):
        org_name = self.get_option('org')
        system_group_name = self.get_option('name')
        # info is always grep friendly

        self.printer.setHeader(_("System Group Information For Org [ %s ]") % (org_name))

        # get system details
        system_group = get_system_group(org_name, system_group_name)

        if not system_group:
            return os.EX_DATAERR

        self.printer.addColumn('id')
        self.printer.addColumn('name')
        self.printer.addColumn('description', multiline=True)
        self.printer.addColumn('locked')

        self.printer.printItem(system_group)

        return os.EX_OK


class Systems(SystemGroupAction):

    description = _('display the systems in a system group within an organization')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                       help=_("organization name eg: foo.example.com (required)"))
        self.parser.add_option('--name', dest='name',
                       help=_("system group name (required)"))

    def check_options(self):
        self.require_option('org')
        self.require_option('name')

    def run(self):
        org_name = self.get_option('org')
        system_group_name = self.get_option('name')
        # info is always grep friendly

        # get system details
        system_group = get_system_group(org_name, system_group_name)
        if not system_group:
            return os.EX_DATAERR

        systems = self.api.system_group_systems(org_name, system_group["id"])
        if not systems:
            return os.EX_DATAERR

        self.printer.setHeader(_("Systems within System Group [ %s ] For Org [ %s ]") % (system_group["name"], org_name))

        self.printer.addColumn('id')
        self.printer.addColumn('name')

        self.printer.printItems(systems)

        return os.EX_OK
