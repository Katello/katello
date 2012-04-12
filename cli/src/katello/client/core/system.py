#
# Katello System actions
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
import sys
from gettext import gettext as _

from katello.client.api.system import SystemAPI
from katello.client.api.task_status import SystemTaskStatusAPI
from katello.client.api.utils import get_environment
from katello.client.config import Config
from katello.client.core.base import Action, Command
from katello.client.core.utils import is_valid_record, Printer, convert_to_mime_type, attachment_file_name, save_report
from katello.client.core.utils import run_spinner_in_bg, wait_for_async_task, SystemAsyncTask
from katello.client.utils.encoding import u_str

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
        self.printer.addColumn('ipv4_address')
        self.printer.addColumn('serviceLevel', _('Service Level'))

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
        if system.has_key('host'):
            system['host'] = system['host']['name']
        if system.has_key('guests'):
            system["guests"] = "[ "+ ", ".join([guest["name"] for guest in system["guests"]]) +" ]"

        self.printer.addColumn('name')
        self.printer.addColumn('ipv4_address')
        self.printer.addColumn('uuid')
        self.printer.addColumn('location')
        self.printer.addColumn('created_at', 'Registered', time_format=True)
        self.printer.addColumn('updated_at', 'Last updated', time_format=True)
        self.printer.addColumn('description', multiline=True)
        if system.has_key('release') and system['release']:
             self.printer.addColumn('release', 'OS release')
        self.printer.addColumn('activation_keys', multiline=True, show_in_grep=False)
        self.printer.addColumn('host', show_in_grep=False)
        self.printer.addColumn('serviceLevel', _('Service Level'))
        self.printer.addColumn('guests',  show_in_grep=False)
        if system.has_key("template"):
            t = system["template"]["name"]
            self.printer.addColumn('template', show_in_grep=False, value=t)

        self.printer.printItem(system)

        return os.EX_OK

class InstalledPackages(SystemAction):

    description = _('display and manipulate with the installed packages of a system')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                       help=_("organization name eg: foo.example.com (required)"))
        self.parser.add_option('--name', dest='name',
                       help=_("system name (required)"))
        self.parser.add_option('--environment', dest='environment',
                       help=_("environment name"))
        self.parser.add_option('--install', dest='install',
                       help=_("packages to be installed remotely on the system, package names are separated with comma"))
        self.parser.add_option('--remove', dest='remove',
                       help=_("packages to be removed remotely from the system, package names are separated with comma"))
        self.parser.add_option('--update', dest='update',
                       help=_("packages to be updated on the system, use --all to update all packages, package names are separated with comma"))
        self.parser.add_option('--install_groups', dest='install_groups',
                       help=_("package groups to be installed remotely on the system, group names are separated with comma"))
        self.parser.add_option('--remove_groups', dest='remove_groups',
                       help=_("package groups to be removed remotely from the system, group names are separated with comma"))

    def check_options(self):
        self.require_option('org')
        self.require_option('name')
        remote_options = [self.get_option(option) for option in ['install', 'remove', 'update', 'install_groups', 'remove_groups']]
        if len([1 for o in remote_options if o]) > 1:
            self.add_option_error(_('You can specify at most one install/remove/update action per call'))


    def run(self):
        org_name = self.get_option('org')
        env_name = self.get_option('environment')
        sys_name = self.get_option('name')
        verbose = self.get_option('verbose')

        install = self.get_option('install')
        remove = self.get_option('remove')
        update = self.get_option('update')
        install_groups = self.get_option('install_groups')
        remove_groups = self.get_option('remove_groups')
        packages_separator = ","

        task = None

        if env_name is None:
            self.printer.setHeader(_("Package Information for System [ %s ] in Org [ %s ]") % (sys_name, org_name))
            systems = self.api.systems_by_org(org_name, {'name': sys_name})
        else:
            self.printer.setHeader(_("Package Information for System [ %s ] in Environment [ %s ] in Org [ %s ]") % (sys_name, env_name, org_name))
            systems = self.api.systems_by_env(org_name, env_name, {'name': sys_name})

        if not systems:
            return os.EX_DATAERR

        system_id = systems[0]['uuid']

        if install:
            task = self.api.install_packages(system_id, install.split(packages_separator))
        if remove:
            task = self.api.remove_packages(system_id, remove.split(packages_separator))
        if update:
            if update == '--all':
                update_packages = []
            else:
                update_packages = update.split(packages_separator)
            task = self.api.update_packages(system_id, update_packages)
        if install_groups:
            task = self.api.install_package_groups(system_id, install_groups.split(packages_separator))
        if remove_groups:
            task = self.api.remove_package_groups(system_id, remove_groups.split(packages_separator))

        if task:
            uuid = task["uuid"]
            print (_("Performing remote action [ %s ]... ") % uuid)
            task = SystemAsyncTask(task)
            run_spinner_in_bg(wait_for_async_task, [task])
            if task.succeeded():
                print _("Remote action finished:")
                print task.get_result_description()
                return os.EX_OK
            else:
                print _("Remote action failed:")
                print task.get_result_description()
                return os.EX_DATAERR

        packages = self.api.packages(system_id)


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

class TasksList(SystemAction):

    description = _('display status of remote tasks')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                       help=_("organization name eg: foo.example.com (required)"))
        self.parser.add_option('--name', dest='name',
                       help=_("system name"))
        self.parser.add_option('--environment', dest='environment',
                       help=_("environment name"))

    def check_options(self):
        self.require_option('org')

    def run(self):
        org_name = self.get_option('org')
        env_name = self.get_option('environment')
        sys_name = self.get_option('name')
        verbose = self.get_option('verbose')

        self.printer.setHeader(_("Remote tasks"))

        tasks = self.api.tasks(org_name, env_name, sys_name)


        for t in tasks:
            t['result'] = "\n" + t['result_description']

        if verbose:
            self.printer.addColumn('system_name', name=_("System"))
            self.printer.addColumn('description', name=_("Action"))
            self.printer.addColumn('created_at', name=_("Started"), time_format=True)
            self.printer.addColumn('finish_time', name=_("Finished"), time_format=True)
            self.printer.addColumn('state', name=_("Status"))
            self.printer.addColumn('result', name=_("Result"))
        else:
            self.printer.addColumn('uuid', name=_("Task id"))
            self.printer.addColumn('system_name', name=_("System"))
            self.printer.addColumn('description', name=_("Action"))
            self.printer.addColumn('state', name=_("Status"))

        self.printer.printItems(tasks)

        return os.EX_OK

class TaskInfo(SystemAction):

    description = _('display status of remote task')

    def setup_parser(self):
        self.parser.add_option('--id', dest='id',
                       help=_("UUID of the task"))

    def check_options(self):
        self.require_option('id')

    def run(self):
        uuid = self.get_option('id')

        self.printer.setHeader(_("Remote task"))

        task = SystemTaskStatusAPI().status(uuid)
        task['result'] = "\n" + task['result_description']

        self.printer.addColumn('system_name', name=_("System"))
        self.printer.addColumn('description', name=_("Action"))
        self.printer.addColumn('created_at', name=_("Started"), time_format=True)
        self.printer.addColumn('finish_time', name=_("Finished"), time_format=True)
        self.printer.addColumn('state', name=_("Status"))
        self.printer.addColumn('result', name=_("Result"))
        self.printer.printItem(task)

        return os.EX_OK


class Releases(SystemAction):

    description = _('list releases available for the system')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                       help=_("organization name eg: foo.example.com (required)"))
        self.parser.add_option('--name', dest='name',
                       help=_("system name (if not specified, list all releases in the environment)"))
        self.parser.add_option('--environment', dest='environment',
                       help=_("environment name eg: development"))

    def check_options(self):
        self.require_option('org')
        self.require_one_of_options('name', 'environment')

    def run(self):
        org_name = self.get_option('org')
        env_name = self.get_option('environment')
        sys_name = self.get_option('name')

        if sys_name:
            system = self.api.systems_by_org(org_name, {'name': sys_name})[0]
            releases = self.api.releases_for_system(system["uuid"])["releases"]
        else:
            environment = get_environment(org_name, env_name)
            releases = self.api.releases_for_environment(environment['id'])["releases"]

        releases = [{"value": r} for r in releases]

        self.printer.setHeader(_("Available releases"))
        self.printer.addColumn('value')

        self.printer._grep = True
        self.printer.printItems(releases)
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
        self.parser.add_option('--name', dest='name', help=_("system name (required)"))
        self.parser.add_option('--org', dest='org', help=_("organization name (required)"))
        self.parser.add_option('--environment', dest='environment', help=_("environment name eg: development"))
        self.parser.add_option('--servicelevel', dest='sla', help=_("service level agreement"))
        self.parser.add_option('--activationkey', dest='activationkey',
            help=_("activation key, more keys are separated with comma e.g. --activationkey=key1,key2"))
        self.parser.add_option('--release', dest='release', help=_("values of $releasever for the system"))
        self.parser.add_option('--fact', dest='fact', action='append', nargs=2, metavar="KEY VALUE",
                               help=_("system facts"))

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
        release = self.get_option('release')
        sla = self.get_option('sla')
        facts = dict(self.get_option('fact') or {})

        system = self.api.register(name, org, environment, activation_keys, 'system', release, sla, facts=facts)

        if is_valid_record(system):
            print _("Successfully registered system [ %s ]") % system['name']
        else:
            print >> sys.stderr, _("Could not register system [ %s ]") % name
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
            print >> sys.stderr, _("Could not find System [ %s ] in Org [ %s ]") % (name, org)
            return os.EX_DATAERR
        else:
            self.api.unregister(systems[0]['uuid'])
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
            print >> sys.stderr, _("Could not find System [ %s ] in Org [ %s ]") % (name, org)
            return os.EX_DATAERR
        else:
            self.api.subscribe(systems[0]['uuid'], pool, qty)
            print _("Successfully subscribed System [ %s ]") % name
            return os.EX_OK

class Subscriptions(SystemAction):

    description = _('list subscriptions for a system')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                help=_("organization name (required)"))
        self.parser.add_option('--name', dest='name',
                help=_("system name (required)"))
        self.parser.add_option('--available', dest='available',
                action="store_true", default=False,
                help=_("show available subscriptions"))

    def check_options(self):
        self.require_option('org')
        self.require_option('name')

    def run(self):
        name = self.get_option('name')
        org = self.get_option('org')
        available = self.get_option('available')
        systems = self.api.systems_by_org(org, {'name': name})


        if systems == None or len(systems) != 1:
            print >> sys.stderr, _("Could not find System [ %s ] in Org [ %s ]") % (name, org)
            return os.EX_DATAERR
        else:
            self.printer.setOutputMode(Printer.OUTPUT_FORCE_VERBOSE)
            if not available:
                # listing current subscriptions
                result = self.api.subscriptions(systems[0]['uuid'])
                if result == None or len(result['entitlements']) == 0:
                    print _("No Subscriptions found for System [ %s ] in Org [ %s ]") % (name, org)
                    return os.EX_OK

                def entitlements():
                    for entitlement in result['entitlements']:
                        entitlement_ext = entitlement.copy()
                        provided_products = ', '.join([e['name'] for e in entitlement_ext['providedProducts']])
                        entitlement_ext['providedProductsFormatted'] = provided_products
                        serial_ids = ', '.join([u_str(s['id']) for s in entitlement_ext['serials']])
                        entitlement_ext['serialIds'] = serial_ids
                        yield entitlement_ext

                self.printer.setHeader(_("Current Subscriptions for System [ %s ]") % name)
                self.printer.addColumn('entitlementId')
                self.printer.addColumn('serialIds', name=_('Serial Id'))
                self.printer.addColumn('poolName')
                self.printer.addColumn('expires')
                self.printer.addColumn('consumed')
                self.printer.addColumn('quantity')
                self.printer.addColumn('sla')
                self.printer.addColumn('contractNumber')
                self.printer.addColumn('providedProductsFormatted', name=_('Provided products'))
                self.printer.printItems(entitlements())
            else:
                # listing available pools
                result = self.api.available_pools(systems[0]['uuid'])

                if result == None or len(result) == 0:
                    print _("No Pools found for System [ %s ] in Org [ %s ]") % (name, org)
                    return os.EX_OK

                def available_pools():
                    for pool in result['pools']:
                        pool_ext = pool.copy()
                        provided_products = ', '.join([p['name'] for p in pool_ext['providedProducts']])
                        pool_ext['providedProductsFormatted'] = provided_products
                        yield pool_ext

                self.printer.setHeader(_("Available Subscriptions for System [ %s ]") % name)
                self.printer.addColumn('poolId')
                self.printer.addColumn('poolName')
                self.printer.addColumn('expires')
                self.printer.addColumn('consumed')
                self.printer.addColumn('quantity')
                self.printer.addColumn('sockets')
                self.printer.addColumn('multiEntitlement')
                self.printer.addColumn('providedProductsFormatted', name=_('Provided products'))
                self.printer.printItems(available_pools())

            return os.EX_OK

class Unsubscribe(SystemAction):

    description = _('unsubscribe a system from certificate')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                       help=_("organization name (required)"))
        self.parser.add_option('--name', dest='name',
                               help=_("system name (required)"))
        self.parser.add_option('--entitlement', dest='entitlement',
                               help=_("entitlement id to unsubscribe from (either entitlement or serial or all is required)"))
        self.parser.add_option('--serial', dest='serial',
                               help=_("serial id of a certificate to unsubscribe from (either entitlement or serial or all is required)"))
        self.parser.add_option('--all', dest='all', action="store_true", default=None,
                               help=_("unsubscribe from all currently subscribed certificates (either entitlement or serial or all is required)"))

    def check_options(self):
        self.require_option('org')
        self.require_option('name')
        self.require_one_of_options('entitlement', 'serial', 'all')

    def run(self):
        name = self.get_option('name')
        org = self.get_option('org')
        entitlement = self.get_option('entitlement')
        serial = self.get_option('serial')
        all_entitlements = self.get_option('all')
        systems = self.api.systems_by_org(org, {'name': name})
        if systems == None or len(systems) != 1:
            print >> sys.stderr, _("Could not find System [ %s ] in Org [ %s ]") % (name, org)
            return os.EX_DATAERR
        else:
            if all_entitlements: #unsubscribe from all
                self.api.unsubscribe_all(systems[0]['uuid'])
            elif serial: # unsubscribe from cert
                self.api.unsubscribe_by_serial(systems[0]['uuid'], serial)
            elif entitlement: # unsubscribe from entitlement
                self.api.unsubscribe(systems[0]['uuid'], entitlement)
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

        self.parser.add_option('--new_name', dest='new_name',
                       help=_('a new name for the system'))
        self.parser.add_option('--description', dest='description',
                       help=_('a description of the system'))
        self.parser.add_option('--location', dest='location',
                       help=_("location of the system"))
        self.parser.add_option('--release', dest='release',
                       help=_("value of $releasever for the system"))
        self.parser.add_option('--servicelevel', dest='sla',
                       help=_("service level agreement"))

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
        new_release = self.get_option('release')
        new_sla = self.get_option('sla')

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
        if new_release: updates['releaseVer'] = new_release
        if new_sla: updates['serviceLevel'] = new_sla

        response = self.api.update(system_uuid, updates)

        if is_valid_record(response):
            print _("Successfully updated system [ %s ]") % response['name']
        else:
            print >> sys.stderr, _("Could not update system [ %s ]") % systems[0]['name']

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
            environment = get_environment(orgId, envName)
            if environment is None:
                return os.EX_DATAERR
            report = self.api.report_by_env(environment['id'], convert_to_mime_type(format, 'text'))


        if format == 'pdf':
            save_report(report[0], attachment_file_name(report[1], 'katello_systems_report.pdf'))
        else:
            print report[0]

        return os.EX_OK


class System(Command):

    description = _('system specific actions in the katello server')
