#
# Katello Distributor actions
# Copyright (c) 2013 Red Hat, Inc.
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

from katello.client import constants
from katello.client.api.distributor import DistributorAPI
from katello.client.api.custom_info import CustomInfoAPI
from katello.client.api.utils import get_environment, get_distributor
from katello.client.cli.base import opt_parser_add_org, opt_parser_add_environment
from katello.client.core.base import BaseAction, Command
from katello.client.server import ServerRequestError

from katello.client.lib.utils.data import test_record
from katello.client.lib.utils.encoding import u_str
from katello.client.lib.ui import printer
from katello.client.lib.ui.printer import VerboseStrategy, batch_add_columns
from katello.client.lib.ui.formatters import format_date, stringify_custom_info


# base distributor action --------------------------------------------------------

class DistributorAction(BaseAction):

    def __init__(self):
        super(DistributorAction, self).__init__()
        self.api = DistributorAPI()

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)
        opt_parser_add_environment(parser)

# distributor actions ------------------------------------------------------------

class List(DistributorAction):
    description = _('list distributors within an organization')

    def setup_parser(self, parser):
        super(List, self).setup_parser(parser)
        parser.add_option('--pool', dest='pool_id',
                       help=_("pool ID to filter distributors by subscriptions"))

    def check_options(self, validator):
        validator.require('org')

    def get_distributors(self, org_name, env_name, pool_id):
        query = {'pool_id': pool_id} if pool_id else {}
        if env_name is None:
            return self.api.distributors_by_org(org_name, query)
        else:
            environment = get_environment(org_name, env_name)
            return self.api.distributors_by_env(environment["id"], query)

    def run(self):
        org_name = self.get_option('org')
        env_name = self.get_option('environment')
        pool_id = self.get_option('pool_id')

        distributors = self.get_distributors(org_name, env_name, pool_id)

        if env_name is None:
            self.printer.set_header(_("Distributors List For Org [ %s ]") % org_name)
        else:
            self.printer.set_header(_("Distributors List For Environment [ %(env_name)s ] in Org [ %(org_name)s ]") \
                % {'env_name':env_name, 'org_name':org_name})

        batch_add_columns(self.printer, {'name': _("Name")}, {'uuid': _("UUID")})
        self.printer.add_column('environment', _("Environment"), \
            item_formatter=lambda p: "%s" % (p['environment']['name']))

        self.printer.add_column('serviceLevel', _("Service Level"))

        self.printer.print_items(distributors)
        return os.EX_OK

class Info(DistributorAction):
    description = _('display a distributor within an organization')

    def setup_parser(self, parser):
        super(Info, self).setup_parser(parser)
        parser.add_option('--name', dest='name',
                       help=_("distributor name (required)"))
        parser.add_option('--uuid', dest='uuid',
                       help=constants.OPT_HELP_DISTRIBUTOR_UUID)

    def check_options(self, validator):
        validator.require('org')
        validator.require_at_least_one_of(('name', 'uuid'))
        validator.mutually_exclude('name', 'uuid')
        validator.mutually_exclude('environment', 'uuid')

    def run(self):
        org_name = self.get_option('org')
        env_name = self.get_option('environment')
        dist_name = self.get_option('name')
        dist_uuid = self.get_option('uuid')

        if dist_uuid:
            self.printer.set_header(_("Distributor Information [ %s ]") % dist_uuid)
        elif env_name is None:
            self.printer.set_header(_("Distributor Information For Org [ %s ]") % org_name)
        else:
            self.printer.set_header(_("Distributor Information For Environment [ %(env)s ] in Org [ %(org)s ]") \
                % {'env':env_name, 'org':org_name})

        # get distributor details
        distributor = get_distributor(org_name, dist_name, env_name, dist_uuid)

        custom_info_api = CustomInfoAPI()
        custom_info = custom_info_api.get_custom_info("distributor", distributor['id'])
        distributor['custom_info'] = stringify_custom_info(custom_info)

        if 'environment' in distributor:
            distributor['environment'] = distributor['environment']['name']

        batch_add_columns(self.printer, {'name': _("Name")}, \
            {'uuid': _("UUID")}, {'environment': _("Environment")})
        self.printer.add_column('created_at', _("Created"), formatter=format_date)
        self.printer.add_column('updated_at', _("Last Updated"), formatter=format_date)
        self.printer.add_column('description', _("Description"), multiline=True)
        self.printer.add_column('custom_info', _("Custom Info"), multiline=True, show_with=printer.VerboseStrategy)

        self.printer.print_item(distributor)

        return os.EX_OK


class Create(DistributorAction):
    description = _('create a distributor')

    def setup_parser(self, parser):
        super(Create, self).setup_parser(parser)
        parser.add_option('--name', dest='name', help=_("distributor name"))

    def check_options(self, validator):
        validator.require(('name', 'org'))

    def run(self):
        name = self.get_option('name')
        org = self.get_option('org')
        environment_name = self.get_option('environment')

        environment_id = None
        if environment_name is not None:
            environment_id = get_environment(org, environment_name)['id']

        distributor = self.api.create(name, org, environment_id,
                                   'distributor')

        test_record(distributor,
            _("Successfully createed distributor [ %s ]") % name,
            _("Could not create distributor [ %s ]") % name
        )


class Delete(DistributorAction):
    description = _('delete a distributor')

    def setup_parser(self, parser):
        super(Delete, self).setup_parser(parser)
        parser.add_option('--name', dest='name',
                               help=_("distributor name"))
        parser.add_option('--uuid', dest='uuid',
                               help=constants.OPT_HELP_DISTRIBUTOR_UUID)

    def check_options(self, validator):
        validator.require('org')
        validator.require_at_least_one_of(('name', 'uuid'))
        validator.mutually_exclude('name', 'uuid')
        validator.mutually_exclude('environment', 'uuid')

    def run(self):
        name = self.get_option('name')
        org = self.get_option('org')
        env_name = self.get_option('environment')
        dist_uuid = self.get_option('uuid')

        display_name = name or dist_uuid

        try:
            distributor = get_distributor(org, name, env_name, dist_uuid)

        except ServerRequestError, e:
            if e[0] == 404:
                return os.EX_DATAERR
            else:
                raise

        self.api.delete(distributor['uuid'])
        print _("Successfully deleted Distributor [ %s ]") % display_name
        return os.EX_OK

class Subscribe(DistributorAction):
    description = _('attach a subscription to a distributor')

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)
        parser.add_option('--name', dest='name',
                help=_("distributor name (required)"))
        parser.add_option('--uuid', dest='uuid',
                help=constants.OPT_HELP_DISTRIBUTOR_UUID)
        parser.add_option('--pool', dest='pool',
                help=_("ID of subscription to attach (required)"))
        parser.add_option('--quantity', dest='quantity',
                help=_("quantity (default: 1)"))

    def check_options(self, validator):
        validator.require(('org', 'pool'))
        validator.require_at_least_one_of(('name', 'uuid'))
        validator.mutually_exclude('name', 'uuid')

    def run(self):
        name = self.get_option('name')
        org = self.get_option('org')
        pool = self.get_option('pool')
        qty = self.get_option('quantity') or 1
        dist_uuid = self.get_option('uuid')

        display_name = name or dist_uuid

        distributor = get_distributor(org, name, None, dist_uuid)

        self.api.subscribe(distributor['uuid'], pool, qty)
        print _("Successfully attached subscription to Distributor [ %s ]") % display_name
        return os.EX_OK

class Subscriptions(DistributorAction):
    description = _('list subscriptions for a distributor')

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)
        parser.add_option('--name', dest='name', help=_("distributor name"))
        parser.add_option('--uuid', dest='uuid', help=constants.OPT_HELP_DISTRIBUTOR_UUID)
        parser.add_option('--available', dest='available',
                action="store_true", default=False,
                help=_("show available subscriptions"))

    def check_options(self, validator):
        validator.require('org')
        validator.require_at_least_one_of(('name', 'uuid'))
        validator.mutually_exclude('name', 'uuid')

    def run(self):
        name = self.get_option('name')
        org = self.get_option('org')
        available = self.get_option('available')
        uuid = self.get_option('uuid')

        display_name = name or uuid

        if not uuid:
            uuid = get_distributor(org, name)['uuid']

        self.printer.set_strategy(VerboseStrategy())
        if not available:
            # listing current subscriptions
            result = self.api.subscriptions(uuid)
            if result == None or len(result['entitlements']) == 0:
                print _("No Subscriptions found for Distributor [ %(display_name)s ] in Org [ %(org)s ]") \
                    % {'display_name':display_name, 'org':org}
                return os.EX_OK

            def entitlements():
                for entitlement in result['entitlements']:
                    entitlement_ext = entitlement.copy()
                    provided_products = ', '.join([e['name'] for e in entitlement_ext['providedProducts']])
                    if provided_products:
                        entitlement_ext['providedProductsFormatted'] = _('Not Applicable')
                    else:
                        entitlement_ext['providedProductsFormatted'] = provided_products
                    serial_ids = ', '.join([u_str(s['id']) for s in entitlement_ext['serials']])
                    entitlement_ext['serialIds'] = serial_ids
                    yield entitlement_ext

            self.printer.set_header(_("Current Subscriptions for Distributor [ %s ]") % display_name)
            self.printer.add_column('entitlementId', _("Subscription ID"))
            self.printer.add_column('serialIds', _('Serial ID'))
            batch_add_columns(self.printer, {'poolName': _("Pool Name")}, \
                {'expires': _("Expires")}, {'consumed': _("Consumed")}, \
                {'quantity': _("Quantity")}, {'sla': _("SLA")}, {'contractNumber': _("Contract Number")})
            self.printer.add_column('providedProductsFormatted', _('Provided Products'))
            self.printer.print_items(entitlements())
        else:
            # listing available pools
            result = self.api.available_pools(uuid)

            if result == None or len(result) == 0:
                print _("No Pools found for Distributor [ %(display_name)s ] in Org [ %(org)s ]") \
                    % {'display_name':display_name, 'org':org}
                return os.EX_OK

            def available_pools():
                for pool in result['pools']:
                    pool_ext = pool.copy()
                    provided_products = ', '.join([p['productName'] for p in pool_ext['providedProducts']])
                    if provided_products:
                        pool_ext['providedProductsFormatted'] = _('Not Applicable')
                    else:
                        pool_ext['providedProductsFormatted'] = provided_products

                    if pool_ext['quantity'] == -1:
                        pool_ext['quantity'] = _('Unlimited')

                    # Make the productAttributes easier to access
                    for productAttribute in pool['productAttributes']:
                        pool_ext['attr_' + productAttribute['name']] = productAttribute['value']
                    yield pool_ext

            self.printer.set_header(_("Available Subscriptions for Distributor [ %s ]") % display_name)

            self.printer.add_column('id', _("ID"))
            self.printer.add_column('productName', _("Name"))
            batch_add_columns(self.printer, {'endDate': _("End Date")}, \
                {'consumed': _("Consumed")}, {'quantity': _("Quantity")}, {'sockets': _("Sockets")})
            self.printer.add_column('attr_stacking_id', _("Stacking ID"))
            self.printer.add_column('attr_multi-entitlement', _("Multi-entitlement"))
            self.printer.add_column('providedProductsFormatted', _("Provided products"))
            self.printer.print_items(available_pools())

        return os.EX_OK

class Unsubscribe(DistributorAction):
    description = _('remove a subscription from a distributor')

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)
        parser.add_option('--name', dest='name',
            help=_("distributor name"))
        parser.add_option('--uuid', dest='uuid',
                help=constants.OPT_HELP_DISTRIBUTOR_UUID)
        parser.add_option('--entitlement', dest='entitlement',
            help=_("ID of subscription to remove (either subscription or serial or all is required)"))
        parser.add_option('--serial', dest='serial',
            help=_("serial ID of a certificate to remove from (either subscription or serial or all is required)"))
        parser.add_option('--all', dest='all', action="store_true", default=None,
            help=_("remove all currently attached subscriptions from distributor (either subscription"
                + " or serial or all is required)"))

    def check_options(self, validator):
        validator.require('org')
        validator.require_at_least_one_of(('name', 'uuid'))
        validator.mutually_exclude('name', 'uuid')
        validator.require_one_of(('entitlement', 'serial', 'all'))

    def run(self):
        name = self.get_option('name')
        org = self.get_option('org')
        entitlement = self.get_option('entitlement')
        serial = self.get_option('serial')
        all_entitlements = self.get_option('all')
        uuid = self.get_option('uuid')

        display_name = name or uuid

        if not uuid:
            uuid = get_distributor(org, name)['uuid']

        if all_entitlements: #unsubscribe from all
            self.api.unsubscribe_all(uuid)
        elif serial: # unsubscribe from cert
            self.api.unsubscribe_by_serial(uuid, serial)
        elif entitlement: # unsubscribe from entitlement
            self.api.unsubscribe(uuid, entitlement)
        print _("Successfully removed subscription from Distributor [ %s ]") % display_name

        return os.EX_OK

class Update(DistributorAction):
    description = _('update a distributor')

    def setup_parser(self, parser):
        super(Update, self).setup_parser(parser)
        parser.add_option('--name', dest='name',
                       help=_('distributor name'))
        parser.add_option('--uuid', dest='uuid',
                       help=constants.OPT_HELP_DISTRIBUTOR_UUID)
        parser.add_option('--new_name', dest='new_name',
                       help=_('a new name for the distributor'))
        parser.add_option('--new_environment', dest='new_environment',
                       help=_('a new environment name for the distributor'))
        parser.add_option('--description', dest='description',
                       help=_('a description of the distributor'))

    def check_options(self, validator):
        validator.require('org')
        validator.require_at_least_one_of(('name', 'uuid'))
        validator.mutually_exclude('name', 'uuid')
        validator.mutually_exclude('environment', 'uuid')

    def run(self):
        org_name = self.get_option('org')
        env_name = self.get_option('environment')
        dist_name = self.get_option('name')
        new_name = self.get_option('new_name')
        new_environment_name = self.get_option('new_environment')
        new_description = self.get_option('description')
        dist_uuid = self.get_option('uuid')

        distributor = get_distributor(org_name, dist_name, env_name, dist_uuid)
        new_environment = get_environment(org_name, new_environment_name)

        updates = {}
        if new_name:
            updates['name'] = new_name
        if new_description:
            updates['description'] = new_description
        if new_environment_name:
            new_environment = get_environment(org_name, new_environment_name)
            updates['environment_id'] = new_environment['id']

        response = self.api.update(distributor['uuid'], updates)

        test_record(response,
            _("Successfully updated distributor [ %s ]") % distributor['name'],
            _("Could not update distributor [ %s ]") % distributor['name']
        )


class Distributor(Command):
    description = _('distributor specific actions in the katello server')
