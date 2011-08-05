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
from gettext import gettext as _

from katello.client.api.system import SystemAPI
from katello.client.config import Config
from katello.client.core.base import Action, Command
from katello.client.core.utils import is_valid_record
from katello.client.core.utils import Printer

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

        if env_name is None:
            systems = self.api.systems_by_org(org_name)
        else:
            systems = self.api.systems_by_env(org_name, env_name)

        if systems is None:
            return os.EX_DATAERR

        if env_name is None:
            self.printer.setHeader(_("Systems List For Org %s") % org_name)
        else:
            self.printer.setHeader(_("Systems List For Environment %s in Org %s") % (env_name, org_name))

        self.printer.printItems(systems)
        return os.EX_OK

class Info(SystemAction):

    description = _('display a system within an organization')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                       help=_("organization name eg: foo.example.com (required)"))
        self.parser.add_option('--name', dest='name',
                       help=_("system name (required)"))
        self.parser.add_option('--environment', dest='environment',
                       help=_("environment name"))

    def check_options(self):
        self.require_option('org')
        self.require_option('name')

    def run(self):
        org_name = self.get_option('org')
        env_name = self.get_option('environment')
        sys_name = self.get_option('name')
        # info is always grep friendly
        printer = Printer(False)

        if env_name is None:
            printer.setHeader(_("System Information For Org %s") % org_name)
            systems = self.api.systems_by_org(org_name, {'name': sys_name})
        else:
            printer.setHeader(_("System Information For Environment %s in Org %s") % (env_name, org_name))
            systems = self.api.systems_by_env(org_name, env_name,
                    {'name': sys_name})

        # get system details
        system = self.api.system(systems[0]['uuid'])

        printer.addColumn('name')
        printer.addColumn('uuid')
        printer.addColumn('location')

        # add facts to the system result object
        facts_hash = system['facts']
        facts_tuples_sorted = [ ('fact ' + k, facts_hash[k]) for k in
                sorted(facts_hash.keys())]
        for (k, v) in facts_tuples_sorted:
            printer.addColumn(k)
            system[k] = v

        printer.printItem(system)

        return os.EX_OK

class Register(SystemAction):

    description = _('register a system')

    def setup_parser(self):
        self.parser.add_option('--name', dest='name',
                       help=_("system name (required)"))
        self.parser.add_option('--org', dest='org',
                       help=_("organization name (required)"))
        self.parser.add_option('--environment', dest='environment',
                       help=_("environment name eg: development"))
        self.parser.add_option('--activationkey', dest='activationkey', action='append',
            help=_("activation key, more keys can be specified eg: --activationkey key1 --activationkey key2 or --activationkey=key1,key2"))

    def check_options(self):
        self.require_option('name')
        self.require_option('org')

    # turns --activationkey=key1,key2 --activationkey=key3,key4 into
    # ['key1','key2','key3','key4']
    def get_activation_keys(self):
        if self.get_option('activationkey'):
            activation_keys = self.get_option('activationkey')
            activation_keys = map(lambda x: x.split(","), activation_keys)
            activation_keys = [item for sublist in activation_keys for item in sublist] # flatten array
            return activation_keys
        else:
            return None

    def run(self):
        name = self.get_option('name')
        org = self.get_option('org')
        environment = self.get_option('environment')
        activation_keys = self.get_activation_keys()

        system = self.api.register(name, org, environment, activation_keys, 'system')

        if is_valid_record(system):
            print _("Successfully created system [ %s ]") % system['name']
        else:
            print _("Could not create system [ %s ]") % system['name']
        return os.EX_OK

class Unregister(SystemAction):

    description = _('unregister a system')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                       help=_("organization name (required)"))
        self.parser.add_option('--name', dest='name',
                               help=_("system name (required)"))

    def check_options(self):
        self.require_option('org')
        self.require_option('name')

    def run(self):
        name = self.get_option('name')
        org = self.get_option('org')
        systems = self.api.systems_by_org(org, {'name': name})
        if systems == None or len(systems) != 1:
            print _("Could not find system named [ %s ] within organization [ %s ]") % (name, org)
            return os.EX_DATAERR
        else:
            result = self.api.unregister(systems[0]['uuid'])
            print _("Successfully unregistered system [ %s ]") % name
            return os.EX_OK

class System(Command):

    description = _('system specific actions in the katello server')
