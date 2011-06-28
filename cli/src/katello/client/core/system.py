#!/usr/bin/python
#
# Katello Repos actions
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
import urlparse
from gettext import gettext as _

from katello.client.api.system import SystemAPI
from katello.client.config import Config
from katello.client.core.base import Action, Command
from katello.client.core.utils import is_valid_record

_cfg = Config()

# base system action --------------------------------------------------------

class SystemAction(Action):

    def __init__(self):
        super(SystemAction, self).__init__()
        self.api = SystemAPI()


# system actions ------------------------------------------------------------

class List(SystemAction):

    description = _('list systems within an organization')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                       help=_("organization name eg: foo.example.com (required)"))
        self.parser.add_option('--environment', dest='environment', 
                       help=_("environment name eg: development"))

    def check_options(self):
        self.require_option('org')

    def run(self):
        org_name = self.get_option('org')
        env_name = self.get_option('environment')

        self.printer.addColumn('id')
        self.printer.addColumn('uuid')
        self.printer.addColumn('name')

        if not env_name:
            systems = self.api.systems_by_org(org_name)
            self.printer.printHeader(_("Systems List For Org %s") % org_name)            
        else:
            systems = self.api.systems_by_env(org_name, env_name)
            self.printer.printHeader(_("Systems List For Environment %s in Org %s") % (env_name, org_name))            

        self.printer.printItems(systems)

        return os.EX_OK

class Register(SystemAction):

    description = _('register a system')

    def setup_parser(self):
        self.parser.add_option('--name', dest='name',
                               help=_("system name (required)"))
        self.parser.add_option('--org', dest='org',
                       help=_("organization name (required)"))

    def check_options(self):
        self.require_option('name')
        self.require_option('org')

    def run(self):

        name = self.get_option('name')
        org = self.get_option('org')
        system = self.api.register(name, org, 'system')

        if is_valid_record(system):
          print _("Successfully created system [ %s ]") % system['name']
        else:
          print _("Could not create system [ %s ]") % system['name']
        return os.EX_OK

class System(Command):

    description = _('system specific actions in the katello server')

