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
from gettext import gettext as _

from katello.client.api.system import SystemAPI
from katello.client.api.task_status import SystemTaskStatusAPI
from katello.client.api.utils import get_environment, get_system
from katello.client.config import Config
from katello.client.core.base import Action, Command
from katello.client.core.utils import test_record, convert_to_mime_type, attachment_file_name, save_report
from katello.client.utils.printer import VerboseStrategy
from katello.client.core.utils import run_spinner_in_bg, wait_for_async_task, SystemAsyncTask, format_date
from katello.client.utils.encoding import u_str
from katello.client.utils import printer
from katello.client.server import ServerRequestError

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
        self.parser.add_option('--pool', dest='pool_id',
                       help=_("pool id to filter systems by subscriptions"))

    def check_options(self):
        self.require_option('org')

    def get_systems(self, org_name, env_name, pool_id):
        query = {'pool_id': pool_id} if pool_id else {}
        if env_name is None:
            return self.api.systems_by_org(org_name, query)
        else:
            environment = get_environment(org_name, env_name)
            return self.api.systems_by_env(org_name, environment["id"], query)

    def run(self):
        org_name = self.get_option('org')
        env_name = self.get_option('environment')
        pool_id = self.get_option('pool_id')

        systems = self.get_systems(org_name, env_name, pool_id)

        if env_name is None:
            self.printer.set_header(_("Systems List For Org [ %s ]") % org_name)
        else:
            self.printer.set_header(_("Systems List For Environment [ %s ] in Org [ %s ]") % (env_name, org_name))

        self.printer.add_column('name')
        self.printer.add_column('ipv4_address')
        self.printer.add_column('serviceLevel', _('Service Level'))

        self.printer.print_items(systems)
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

        if env_name is None:
            self.printer.set_header(_("System Information For Org [ %s ]") % org_name)
        else:
            self.printer.set_header(_("System Information For Environment [ %s ] in Org [ %s ]") % (env_name, org_name))

        # get system details
        system = get_system(org_name, sys_name, env_name)

        for akey in system['activation_key']:
            system["activation_keys"] = "[ "+ ", ".join([akey["name"] for pool in akey["pools"]]) +" ]"
        if 'host' in system:
            system['host'] = system['host']['name']
        if 'guests' in system:
            system["guests"] = "[ "+ ", ".join([guest["name"] for guest in system["guests"]]) +" ]"

        self.printer.add_column('name')
        self.printer.add_column('ipv4_address')
        self.printer.add_column('uuid')
        self.printer.add_column('location')
        self.printer.add_column('created_at', 'Registered', formatter=format_date)
        self.printer.add_column('updated_at', 'Last updated', formatter=format_date)
        self.printer.add_column('description', multiline=True)
        if 'releaseVer' in system and system['releaseVer']:
            self.printer.add_column('releaseVer', 'OS release')
        self.printer.add_column('activation_keys', multiline=True, show_with=printer.VerboseStrategy)
        self.printer.add_column('host', show_with=printer.VerboseStrategy)
        self.printer.add_column('serviceLevel', _('Service Level'))
        self.printer.add_column('guests', show_with=printer.VerboseStrategy)
        if "template" in system:
            self.printer.add_column('template', show_with=printer.VerboseStrategy, value=system["template"]["name"])

        self.printer.print_item(system)

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
            self.printer.set_header(_("Package Information for System [ %s ] in Org [ %s ]") % (sys_name, org_name))
        else:
            self.printer.set_header(_("Package Information for System [ %s ] in Environment [ %s ] in Org [ %s ]") % (sys_name, env_name, org_name))

        system = get_system(org_name, sys_name, env_name)
        system_id = system['uuid']

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

        self.printer.add_column('name', show_with=printer.VerboseStrategy)
        self.printer.add_column('vendor', show_with=printer.VerboseStrategy)
        self.printer.add_column('version', show_with=printer.VerboseStrategy)
        self.printer.add_column('release', show_with=printer.VerboseStrategy)
        self.printer.add_column('arch', show_with=printer.VerboseStrategy)
        self.printer.add_column('name_version_release_arch',
                    show_with=printer.GrepStrategy,
                    item_formatter=lambda p: "%s-%s-%s.%s" % (p['name'], p['version'], p['release'], p['arch']))

        self.printer.print_items(packages)

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

        self.printer.set_header(_("Remote tasks"))

        environment = get_environment(org_name, env_name)
        tasks = self.api.tasks(org_name, environment["id"], sys_name)

        for t in tasks:
            t['result'] = "\n" + t['result_description']

        self.printer.add_column('uuid', name=_("Task id"))
        self.printer.add_column('system_name', name=_("System"))
        self.printer.add_column('description', name=_("Action"))
        self.printer.add_column('created_at', name=_("Started"), formatter=format_date, show_with=printer.VerboseStrategy)
        self.printer.add_column('finish_time', name=_("Finished"), formatter=format_date, show_with=printer.VerboseStrategy)
        self.printer.add_column('state', name=_("Status"))
        self.printer.add_column('result', name=_("Result"), show_with=printer.VerboseStrategy)

        self.printer.print_items(tasks)

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

        self.printer.set_header(_("Remote task"))

        task = SystemTaskStatusAPI().status(uuid)
        task['result'] = "\n" + task['result_description']

        self.printer.add_column('system_name', name=_("System"))
        self.printer.add_column('description', name=_("Action"))
        self.printer.add_column('created_at', name=_("Started"), formatter=format_date)
        self.printer.add_column('finish_time', name=_("Finished"), formatter=format_date)
        self.printer.add_column('state', name=_("Status"))
        self.printer.add_column('result', name=_("Result"))
        self.printer.print_item(task)

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
            system = get_system(org_name, sys_name)
            releases = self.api.releases_for_system(system["uuid"])["releases"]
        else:
            environment = get_environment(org_name, env_name)
            releases = self.api.releases_for_environment(environment['id'])["releases"]

        releases = [{"value": r} for r in releases]

        self.printer.set_header(_("Available releases"))
        self.printer.add_column('value')

        self.printer.print_items(releases)
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

        if env_name is None:
            self.printer.set_header(_("System Facts For System [ %s ] in Org [ %s ]") % (sys_name, org_name))
        else:
            self.printer.set_header(_("System Facts For System [ %s ] in Environment [ %s]  in Org [ %s ]") % (sys_name, env_name, org_name))

        system = get_system(org_name, sys_name, env_name)
        system_id = system['uuid']

        facts_hash = system['facts']
        facts_tuples_sorted = [(k, facts_hash[k]) for k in sorted(facts_hash.keys())]
        for k, v in facts_tuples_sorted:
            self.printer.add_column(k)
            system[k] = v

        self.printer.print_item(system)

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
        environment_name = self.get_option('environment')
        activation_keys = self.get_option('activationkey')
        release = self.get_option('release')
        sla = self.get_option('sla')
        facts = dict(self.get_option('fact') or {})

        environment = get_environment(org, environment_name)
        system = self.api.register(name, org, environment['id'], activation_keys, 'system', release, sla, facts=facts)

        test_record(system,
            _("Successfully registered system [ %s ]") % name,
            _("Could not register system [ %s ]") % name
        )

class RemoveDeletion(SystemAction):

    description = _("remove a deletion record for hypervisor")

    def setup_parser(self):
        self.parser.add_option("--uuid", dest="uuid",
                       help=_("hypervisor uuid (required"))

    def check_options(self):
        self.require_option('uuid')

    def run(self):
        uuid = self.get_option('uuid')
        self.api.remove_consumer_deletion_record(uuid)
        print _("Successfully removed deletion record for hypervisor with uuid [ %s ]") % uuid
        return os.EX_OK


class Unregister(SystemAction):

    description = _('unregister a system')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                       help=_("organization name (required)"))
        self.parser.add_option('--name', dest='name',
                               help=_("system name (required)"))
        self.parser.add_option('--environment', dest='environment',
                               help=_("environment name eg: development"))

    def check_options(self):
        self.require_option('org')
        self.require_option('name')

    def run(self):
        name = self.get_option('name')
        org = self.get_option('org')
        env_name = self.get_option('environment')
        try:
            system = get_system(org, name, env_name)

        except ServerRequestError, e:
            if e[0] == 404:
                return os.EX_DATAERR
            else:
                raise e

        self.api.unregister(system['uuid'])
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

        system = get_system(org, name)

        self.api.subscribe(system['uuid'], pool, qty)
        print _("Successfully subscribed System [ %s ]") % name
        return os.EX_OK

class Subscriptions(SystemAction):

    description = _('list subscriptions for a system')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org', help=_("organization name (required)"))
        self.parser.add_option('--name', dest='name', help=_("system name (required)"))
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

        system = get_system(org, name)

        self.printer.set_strategy(VerboseStrategy())
        if not available:
            # listing current subscriptions
            result = self.api.subscriptions(system['uuid'])
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

            self.printer.set_header(_("Current Subscriptions for System [ %s ]") % name)
            self.printer.add_column('entitlementId')
            self.printer.add_column('serialIds', name=_('Serial Id'))
            self.printer.add_column('poolName')
            self.printer.add_column('expires')
            self.printer.add_column('consumed')
            self.printer.add_column('quantity')
            self.printer.add_column('sla')
            self.printer.add_column('contractNumber')
            self.printer.add_column('providedProductsFormatted', name=_('Provided products'))
            self.printer.print_items(entitlements())
        else:
            # listing available pools
            result = self.api.available_pools(system['uuid'])

            if result == None or len(result) == 0:
                print _("No Pools found for System [ %s ] in Org [ %s ]") % (name, org)
                return os.EX_OK

            def available_pools():
                for pool in result['pools']:
                    pool_ext = pool.copy()
                    provided_products = ', '.join([p['name'] for p in pool_ext['providedProducts']])
                    pool_ext['providedProductsFormatted'] = provided_products
                    yield pool_ext

            self.printer.set_header(_("Available Subscriptions for System [ %s ]") % name)
            self.printer.add_column('poolId')
            self.printer.add_column('poolName')
            self.printer.add_column('expires')
            self.printer.add_column('consumed')
            self.printer.add_column('quantity')
            self.printer.add_column('sockets')
            self.printer.add_column('multiEntitlement')
            self.printer.add_column('providedProductsFormatted', name=_('Provided products'))
            self.printer.print_items(available_pools())

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

        system = get_system(org, name)

        if all_entitlements: #unsubscribe from all
            self.api.unsubscribe_all(system['uuid'])
        elif serial: # unsubscribe from cert
            self.api.unsubscribe_by_serial(system['uuid'], serial)
        elif entitlement: # unsubscribe from entitlement
            self.api.unsubscribe(system['uuid'], entitlement)
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

        system = get_system(org_name, sys_name, env_name)
        system_uuid = system['uuid']

        updates = {}
        if new_name: updates['name'] = new_name
        if new_description: updates['description'] = new_description
        if new_location: updates['location'] = new_location
        if new_release: updates['releaseVer'] = new_release
        if new_sla: updates['serviceLevel'] = new_sla

        response = self.api.update(system_uuid, updates)

        test_record(response,
            _("Successfully updated system [ %s ]") % system['name'],
            _("Could not update system [ %s ]") % system['name']
        )


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
            report = self.api.report_by_env(environment['id'], convert_to_mime_type(format, 'text'))

        if format == 'pdf':
            save_report(report[0], attachment_file_name(report[1], 'katello_systems_report.pdf'))
        else:
            print report[0]

        return os.EX_OK


class System(Command):

    description = _('system specific actions in the katello server')
