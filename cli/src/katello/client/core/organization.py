#
# Katello Organization actions
# Copyright (c) 2012 Red Hat, Inc.
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

from katello.client.api.organization import OrganizationAPI
from katello.client.api.product import ProductAPI
from katello.client.api.organization_default_info import OrganizationDefaultInfoAPI
from katello.client.core.base import BaseAction, Command
from katello.client.lib.async import AsyncTask, evaluate_task_status
from katello.client.lib.ui.progress import run_spinner_in_bg, wait_for_async_task
from katello.client.lib.utils.data import test_record
from katello.client.lib.ui.printer import VerboseStrategy
from katello.client.lib.ui import printer
from datetime import timedelta, datetime
from katello.client.lib.ui.printer import batch_add_columns


# base organization action -----------------------------------------------------

class OrganizationAction(BaseAction):

    def __init__(self):
        super(OrganizationAction, self).__init__()
        self.api = OrganizationAPI()


# organization actions ---------------------------------------------------------

class List(OrganizationAction):

    description = _('list all known organizations')

    def run(self):
        orgs = self.api.organizations()

        batch_add_columns(self.printer, {'id': _("ID")}, {'name': _("Name")}, {'label': _("Label")})
        self.printer.add_column('description', _("Description"), multiline=True)

        self.printer.set_header(_("Organization List"))
        self.printer.print_items(orgs)
        return os.EX_OK

# ------------------------------------------------------------------------------

class Create(OrganizationAction):

    description = _('create an organization')

    def setup_parser(self, parser):
        # always provide --id option for create, even on registered clients
        parser.add_option('--name', dest='name',
                               help=_("organization name eg: ACME Corporation (required)"))
        parser.add_option('--label', dest='label',
                               help=_("organization label, ASCII identifier for the Organization " +
                                      "with no spaces eg: ACME_Corporation (will be generated if not specified)"))
        parser.add_option("--description", dest="description",
                               help=_("consumer description eg: foo's organization"))

    def check_options(self, validator):
        validator.require('name')

    def run(self):
        name        = self.get_option('name')
        label       = self.get_option('label')
        description = self.get_option('description')

        org = self.api.create(name, label, description)
        test_record(org,
            _("Successfully created org [ %s ]") % name,
            _("Could not create org [ %s ]") % name
        )


# ------------------------------------------------------------------------------

class Info(OrganizationAction):

    description = _('list information about an organization')

    def setup_parser(self, parser):
        # always provide --id option for create, even on registered clients
        parser.add_option('--name', dest='name',
                               help=_("organization name eg: foo.example.com (required)"))

    def check_options(self, validator):
        validator.require('name')

    def run(self):
        name = self.get_option('name')

        org = self.api.organization(name)

        org['system_info_keys'] = "[ %s ]" % ", ".join(org['default_info']['system'])

        self.printer.add_column('id', _("ID"))
        self.printer.add_column('name', _("Name"))
        self.printer.add_column('description', _("Description"), multiline=True)
        self.printer.add_column('service_levels', _("Available Service Levels"), multiline=True)
        self.printer.add_column('system_info_keys', _("Default System Info Keys"), multiline=True,
            show_with=printer.VerboseStrategy)

        self.printer.set_header(_("Organization Information"))
        self.printer.print_item(org)
        return os.EX_OK

# ------------------------------------------------------------------------------

class Delete(OrganizationAction):

    description = _('delete an organization')

    def setup_parser(self, parser):
        # always provide --id option for create, even on registered clients
        parser.add_option('--name', dest='name',
                               help=_("organization name eg: foo.example.com (required)"))

    def check_options(self, validator):
        validator.require('name')

    def run(self):
        name = self.get_option('name')

        task = self.api.delete(name)
        task = AsyncTask(task)

        run_spinner_in_bg(wait_for_async_task, [task], message=_("Deleting the organization, please wait... "))

        return evaluate_task_status(task,
            failed = _("Organization [ %s ] deletion failed:") % name,
            ok =     _("Successfully deleted org [ %s ]") % name
        )

# ------------------------------------------------------------------------------

class Update(OrganizationAction):

    description = _('update an organization')

    def setup_parser(self, parser):
        # always provide --id option for create, even on registered clients
        parser.add_option('--name', dest='name',
                               help=_("organization name eg: foo.example.com (required)"))
        parser.add_option("--description", dest="description",
                               help=_("consumer description eg: foo's organization"))

    def check_options(self, validator):
        validator.require('name')

    def run(self):
        name        = self.get_option('name')
        description = self.get_option('description')

        self.api.update(name, description)
        print _("Successfully updated org [ %s ]") % name
        return os.EX_OK

# ------------------------------------------------------------------------------

class GenerateDebugCert(OrganizationAction):

    description = _('generate and show ueber certificate')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name',
                               help=_("organization name eg: foo.example.com (required)"))
        parser.add_option("--regenerate", dest="regenerate", action="store_true",
                               help=_("regenerate the certificate"))

    def check_options(self, validator):
        validator.require('name')

    def run(self):
        name = self.get_option('name')
        regenerate = self.get_option('regenerate')

        uebercert = self.api.uebercert(name, regenerate)

        self.printer.add_column('key', _("Key"))
        self.printer.add_column('cert', _("Cert"))
        self.printer.set_header(_("Organization Uebercert"))
        self.printer.print_item(uebercert)

        return os.EX_OK

# ------------------------------------------------------------------------------

class ShowSubscriptions(OrganizationAction):

    description = _('show subscriptions')

    def __init__(self):
        super(ShowSubscriptions, self).__init__()
        self.productApi = ProductAPI()

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name',
                               help=_("organization name eg: foo.example.com (required)"))

    def check_options(self, validator):
        validator.require('name')

    def run(self):
        name = self.get_option('name')
        org = self.api.organization(name)
        pools = self.api.pools(org["label"])

        updated_pool_info = [self.displayable_pool(pool) for pool in pools]

        # by default use verbose mode
        if not self.has_option('grep'):
            self.printer.set_strategy(VerboseStrategy())

        self.printer.add_column('productName', _("Subscription"))
        self.printer.add_column('consumed', _("Consumed"))
        self.printer.add_column('contractNumber', _("Contract Number"), show_with=printer.VerboseStrategy)
        self.printer.add_column('sla', _("SLA"), show_with=printer.VerboseStrategy)
        self.printer.add_column('id', _("ID"))
        self.printer.add_column('startDate', _("Start Date"), show_with=printer.VerboseStrategy)
        self.printer.add_column('endDate', _("End Date"), show_with=printer.VerboseStrategy)
        self.printer.set_header(_("Organization's Subscriptions"))
        self.printer.print_items(updated_pool_info)

        return os.EX_OK

    def sla(self, pool):
        return {'sla': self.extract_sla_from_product(self.productApi.show(self.get_option('name'), pool['productId']))}

    @classmethod
    def convert_timestamp(cls, timestamp_field):
        offset = int(timestamp_field[-5:])
        delta = timedelta(hours = offset / 100)
        t = datetime.strptime(timestamp_field[:-9], "%Y-%m-%dT%H:%M:%S") - delta
        return datetime.strftime(t, "%Y/%m/%d %H:%M:%S")

    @classmethod
    def extract_sla_from_product(cls, p):
        sla_attr = [attr.get("value", "") for attr in p["attributes"] if attr.get("name", "") == "sla"]
        return sla_attr[0] if len(sla_attr) > 0 else ""

    def displayable_pool(self, pool):
        p = dict(list(pool.items()) + list(self.sla(pool).items()))
        p['startDate'] = self.convert_timestamp(pool['startDate'])
        p['endDate'] = self.convert_timestamp(pool['endDate'])

        return p

# ------------------------------------------------------------------------------

class AddDefaultInfo(OrganizationAction):

    description = _("add default custom info")

    def __init__(self):
        super(AddDefaultInfo, self).__init__()
        self.default_info_api = OrganizationDefaultInfoAPI()

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name', help=_("organization name eg: foo.example.com (required)"))
        parser.add_option('--type', dest='type', help=_("'system' (required)"))
        parser.add_option('--keyname', dest='keyname', help=_("name of the default custom info (required)"))

    def check_options(self, validator):
        validator.require(('name', 'keyname', 'type'))

    def run(self):
        org_name = self.get_option('name')
        keyname = self.get_option('keyname')
        informable_type = self.get_option('type').lower()

        response = self.default_info_api.create(org_name, informable_type, keyname)

        output_hash = {'keyname': keyname, 'org_name': org_name, 'katello_obj': informable_type.capitalize()}
        if response:
            print _("Successfully added [ %(katello_obj)s ] " \
                + "default custom info [ %(keyname)s ] to Org [ %(org_name)s ]") \
                % output_hash
        else:
            print _("Could not add [ %(katello_obj)s ] " \
                + "default custom info [ %(keyname)s ] to Org [ %(org_name)s ]") \
                % output_hash

# ------------------------------------------------------------------------------

class RemoveDefaultInfo(OrganizationAction):

    description = _("remove default custom info")

    def __init__(self):
        super(RemoveDefaultInfo,  self).__init__()
        self.default_info_api = OrganizationDefaultInfoAPI()

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name', help=_("organization name eg: foo.example.com (required)"))
        parser.add_option('--type', dest='type', help=_("'system' (required)"))
        parser.add_option('--keyname', dest='keyname', help=_("name of the default custom info (required)"))

    def check_options(self, validator):
        validator.require(('name', 'keyname', 'type'))

    def run(self):
        org_name = self.get_option('name')
        keyname = self.get_option('keyname')
        informable_type = self.get_option('type').lower()

        response = self.default_info_api.destroy(org_name, informable_type, keyname)

        output_hash = {'keyname': keyname, 'org_name': org_name, 'katello_obj': informable_type.capitalize()}
        if response:
            print _("Successfully removed [ %(katello_obj)s ] " \
                + "default custom info [ %(keyname)s ] for Org [ %(org_name)s ]") \
                % output_hash
        else:
            print _("Could not remove [ %(katello_obj)s ] " \
                + "default custom info [ %(keyname)s ] for Org [ %(org_name)s ]") \
                % output_hash

# ------------------------------------------------------------------------------

class ApplyDefaultInfo(OrganizationAction):

    description = _("apply default custom info keynames to all existing entities")

    def __init__(self):
        super(ApplyDefaultInfo, self).__init__()
        self.default_info_api = OrganizationDefaultInfoAPI()

    def setup_parser(self, parser):
        parser.add_option("--name", dest='name', help=_("organization name eg: foo.example.com (required)"))
        parser.add_option("--type", dest='type', help=_("'system' (required)"))

    def check_options(self, validator):
        validator.require(('name', 'type'))

    def run(self):
        org_name = self.get_option('name')
        informable_type = self.get_option('type').lower()
        response = self.default_info_api.apply(org_name, informable_type)

        if response:
            print _("Applied [ %(sys_count)d %(katello_obj)s ] default custom info in Org [ %(org_name)s ]") \
                % {'sys_count': len(response), 'org_name': org_name, 'katello_obj': informable_type.capitalize()}
        else:
            print _("Could not apply [ %(katello_obj)s ] default custom info keys to Org [ %(org_name)s ]") \
                % {'org_name': org_name, 'katello_obj': informable_type.capitalize()}

# organization command ------------------------------------------------------------

class Organization(Command):

    description = _('organization specific actions in the katello server')

# organization command ------------------------------------------------------------

class DefaultInfo(Command):

    description = _('organization default info specific actions on the katello server')
