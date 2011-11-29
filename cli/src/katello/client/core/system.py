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
from katello.client.core.utils import is_valid_record, Printer, convert_to_mime_type, attachment_file_name, save_report

Config()

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

        if env_name is None:
            systems = self.api.systems_by_org(org_name)
        else:
            systems = self.api.systems_by_env(org_name, env_name)

        if systems is None:
            return os.EX_DATAERR

        if env_name is None:
            self.printer.setHeader(_("Systems List For Org [ %s ]") % org_name)
        else:
            self.printer.setHeader(_("Systems List For Environment [ %s ] in Org [ %s ]") % (env_name, org_name))

        self.printer.addColumn('name')

        self.printer._grep = True
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

        if env_name is None:
            self.printer.setHeader(_("System Information For Org [ %s ]") % org_name)
            systems = self.api.systems_by_org(org_name, {'name': sys_name})
        else:
            self.printer.setHeader(_("System Information For Environment [ %s ] in Org [ %s ]") % (env_name, org_name))
            systems = self.api.systems_by_env(org_name, env_name,
                    {'name': sys_name})

        if not systems:
            return os.EX_DATAERR

        # get system details
        system = self.api.system(systems[0]['uuid'])

        for akey in system['activation_key']:
            system["activation_keys"] = "[ "+ ", ".join([akey["name"] for pool in akey["pools"]]) +" ]"

        self.printer.addColumn('name')
        self.printer.addColumn('uuid')
        self.printer.addColumn('location')
        self.printer.addColumn('created_at', 'Registered', time_format=True)
        self.printer.addColumn('updated_at', 'Last updated', time_format=True)
        self.printer.addColumn('description', multiline=True)
        self.printer.addColumn('activation_keys', multiline=True, show_in_grep=False)

        self.printer.printItem(system)

        return os.EX_OK

class InstalledPackages(SystemAction):

    description = _('display the installed packages of a system')

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
        verbose = self.get_option('verbose')

        if env_name is None:
            self.printer.setHeader(_("Package Information for System [ %s ] in Org [ %s ]") % (sys_name, org_name))
            systems = self.api.systems_by_org(org_name, {'name': sys_name})
        else:
            self.printer.setHeader(_("Package Information for System [ %s ] in Environment [ %s ] in Org [ %s ]") % (sys_name, env_name, org_name))
            systems = self.api.systems_by_env(org_name, env_name, {'name': sys_name})

        if not systems:
            return os.EX_DATAERR

        packages = self.api.packages(systems[0]['uuid'])

        for p in packages:
            p['name_version_release_arch'] = "%s-%s-%s.%s" % \
                    (p['name'], p['version'], p['release'], p['arch'])

        if verbose:
            self.printer.addColumn('name')
            self.printer.addColumn('vendor')
            self.printer.addColumn('version')
            self.printer.addColumn('release')
            self.printer.addColumn('arch')
        else:
            # print compact list of package names only
            self.printer.addColumn('name_version_release_arch')
            self.printer._grep = True

        self.printer.printItems(packages)

        return os.EX_OK

class Facts(SystemAction):

    description = _('display a the hardware facts of a system')

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

        if env_name is None:
            self.printer.setHeader(_("System Facts For System [ %s ] in Org [ %s ]") % (sys_name, org_name))
            systems = self.api.systems_by_org(org_name, {'name': sys_name})
        else:
            self.printer.setHeader(_("System Facts For System [ %s ] in Environment [ %s]  in Org [ %s ]") % (sys_name, env_name, org_name))
            systems = self.api.systems_by_env(org_name, env_name, {'name': sys_name})

        if not systems:
            return os.EX_DATAERR

        # get system details
        system = self.api.system(systems[0]['uuid'])

        facts_hash = system['facts']
        facts_tuples_sorted = [(k, facts_hash[k]) for k in sorted(facts_hash.keys())]
        for k, v in facts_tuples_sorted:
            self.printer.addColumn(k)
            system[k] = v

        self.printer.printItem(system)

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
        self.parser.add_option('--activationkey', dest='activationkey',
            help=_("activation key, more keys are separated with comma e.g. --activationkey=key1,key2"))

    def check_options(self):
        self.require_option('name')
        self.require_option('org')
        if not self.option_specified('activationkey'):
            self.require_option('environment')
        elif self.option_specified('environment'):
            self.add_option_error(_('Option %s can not be specified with %s') % ("--environment", "--activationkey"))


    def require_credentials(self):
        if self.option_specified('activationkey'):
            return False
        else:
            return super

    def run(self):
        name = self.get_option('name')
        org = self.get_option('org')
        environment = self.get_option('environment')
        activation_keys = self.get_option('activationkey')

        system = self.api.register(name, org, environment, activation_keys, 'system')

        if is_valid_record(system):
            print _("Successfully registered system [ %s ]") % system['name']
        else:
            print _("Could not register system [ %s ]") % name
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
            print _("Could not find System [ %s ] in Org [ %s ]") % (name, org)
            return os.EX_DATAERR
        else:
            result = self.api.unregister(systems[0]['uuid'])
            print _("Successfully unregistered System [ %s ]") % name
            return os.EX_OK

class Subscribe(SystemAction):

    description = _('subscribe a system to certificate')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                help=_("organization name (required)"))
        self.parser.add_option('--name', dest='name',
                help=_("system name (required)"))
        self.parser.add_option('--pool', dest='pool',
                help=_("certificate serial to unsubscribe (required)"))
        self.parser.add_option('--quantity', dest='quantity',
                help=_("quantity (default: 1)"))

    def check_options(self):
        self.require_option('org')
        self.require_option('name')
        self.require_option('pool')

    def run(self):
        name = self.get_option('name')
        org = self.get_option('org')
        pool = self.get_option('pool')
        qty = self.get_option('quantity') or 1
        systems = self.api.systems_by_org(org, {'name': name})
        if systems == None or len(systems) != 1:
            print _("Could not find System [ %s ] in Org [ %s ]") % (name, org)
            return os.EX_DATAERR
        else:
            result = self.api.subscribe(systems[0]['uuid'], pool, qty)
            print _("Successfully subscribed System [ %s ]") % name
            return os.EX_OK

class Subscriptions(SystemAction):

    description = _('list subscriptions for a system')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                help=_("organization name (required)"))
        self.parser.add_option('--name', dest='name',
                help=_("system name (required)"))
        self.parser.add_option('--serials', dest='serials',
                action="store_true", default=False,
                help=_("show certificate serial numbers"))
        self.parser.add_option('--available', dest='available',
                action="store_const", const=1, default=0,
                help=_("show available subscription"))

    def check_options(self):
        self.require_option('org')
        self.require_option('name')

    def run(self):
        name = self.get_option('name')
        org = self.get_option('org')
        serials = self.get_option('serials')
        available = self.get_option('available')
        systems = self.api.systems_by_org(org, {'name': name})

        if serials and available == 0:
            print _("Serial parameter cannot be used with available")
            return os.EX_DATAERR

        if systems == None or len(systems) != 1:
            print _("Could not find System [ %s ] in Org [ %s ]") % (name, org)
            return os.EX_DATAERR
        else:
            self.printer.setOutputMode(Printer.OUTPUT_FORCE_VERBOSE)
            if available:
                # listing available pools
                result = self.api.available_pools(systems[0]['uuid'])
                if result == None or len(result) == 0:
                    print _("No Pools found for System [ %s ] in Org [ %s ]") % (name, org)
                    return os.EX_DATAERR
                self.printer.setHeader(_("Available Pools for System [ %s ]") % name)
                self.printer.addColumn('poolId')
                self.printer.addColumn('poolName')
                self.printer.addColumn('expires')
                self.printer.addColumn('consumed')
                self.printer.addColumn('quantity')
                self.printer.addColumn('sockets')
                self.printer.addColumn('multiEntitlement')
                self.printer.addColumn('providedProducts')
                self.printer.printItems(result['pools'])
            else:
                # listing current subscriptions
                result = self.api.subscriptions(systems[0]['uuid'])
                if result == None or len(result) == 0:
                    print _("No Subscriptions found for System [ %s ] in Org [ %s ]") % (name, org)
                    return os.EX_DATAERR
                self.printer.setHeader(_("Available Subscriptions for System [ %s ]") % name)
                self.printer.addColumn('entitlementId')
                self.printer.addColumn('poolName')
                self.printer.addColumn('expires')
                self.printer.addColumn('consumed')
                self.printer.addColumn('quantity')
                self.printer.addColumn('sla')
                self.printer.addColumn('contractNumber')
                self.printer.addColumn('providedProducts')
                self.printer.printItems(result['entitlements'])

            return os.EX_OK

class Unsubscribe(SystemAction):

    description = _('unsubscribe a system from certificate')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                       help=_("organization name (required)"))
        self.parser.add_option('--name', dest='name',
                               help=_("system name (required)"))
        self.parser.add_option('--pool', dest='pool',
                               help=_("pool id to unsubscribe from (required)"))

    def check_options(self):
        self.require_option('org')
        self.require_option('name')
        self.require_option('pool')

    def run(self):
        name = self.get_option('name')
        org = self.get_option('org')
        pool = self.get_option('pool')
        systems = self.api.systems_by_org(org, {'name': name})
        if systems == None or len(systems) != 1:
            print _("Could not find System [ %s ] in Org [ %s ]") % (name, org)
            return os.EX_DATAERR
        else:
            result = self.api.unsubscribe(systems[0]['uuid'], pool)
            print _("Successfully unsubscribed System [ %s ]") % name
            return os.EX_OK

class Update(SystemAction):

    description = _('update a system')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                       help=_('organization name (required)'))
        self.parser.add_option('--name', dest='name',
                       help=_('system name (required)'))
        self.parser.add_option('--environment', dest='environment',
                       help=_("environment name"))

        self.parser.add_option('--new-name', dest='new_name',
                       help=_('a new name for the system'))
        self.parser.add_option('--description', dest='description',
                       help=_('a description of the system'))
        self.parser.add_option('--location', dest='location',
                       help=_("location of the system"))

    def check_options(self):
        self.require_option('org')
        self.require_option('name')

    def run(self):
        org_name = self.get_option('org')
        env_name = self.get_option('environment')
        sys_name = self.get_option('name')
        new_name = self.get_option('new_name')
        new_description = self.get_option('description')
        new_location = self.get_option('location')

        if env_name is None:
            systems = self.api.systems_by_org(org_name, {'name': sys_name})
        else:
            systems = self.api.systems_by_env(org_name, env_name,
                    {'name': sys_name})

        if not systems:
            return os.EX_DATAERR

        system_uuid = systems[0]['uuid']
        updates = {}
        if new_name: updates['name'] = new_name
        if new_description: updates['description'] = new_description
        if new_location: updates['location'] = new_location

        response = self.api.update(system_uuid, updates)

        if is_valid_record(response):
            print _("Successfully updated system [ %s ]") % systems[0]['name']
        else:
            print _("Could not update system [ %s ]") % systems[0]['name']

        return os.EX_OK

class Report(SystemAction):

    description = _('systems report')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                    help=_("organization name eg: foo.example.com (required)"))
        self.parser.add_option('--environment', dest='environment',
                    help=_("environment name eg: development"))
        self.parser.add_option('--format', dest='format',
             help=_("report format (possible values: 'html', 'text' (default), 'csv', 'pdf')"))

    def check_options(self):
        self.require_option('org')

    def run(self):
        orgId = self.get_option('org')
        envName = self.get_option('environment')
        format = self.get_option('format')

        if envName is None:
            report = self.api.report_by_org(orgId, convert_to_mime_type(format, 'text'))
        else:
            report = self.api.report_by_env(orgId, envName, convert_to_mime_type(format, 'text'))


        if format == 'pdf':
            save_report(report[0], attachment_file_name(report[1], 'katello_systems_report.pdf'))
        else:
            print report[0]

        return os.EX_OK


class System(Command):

    description = _('system specific actions in the katello server')
