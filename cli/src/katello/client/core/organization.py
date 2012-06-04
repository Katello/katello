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

from katello.client.api.organization import OrganizationAPI
from katello.client.api.product import ProductAPI
from katello.client.config import Config
from katello.client.core.base import Action, Command
from katello.client.core.utils import test_record, run_spinner_in_bg, wait_for_async_task, AsyncTask, format_task_errors
from katello.client.utils.printer import VerboseStrategy
from katello.client.utils import printer
from datetime import timedelta, datetime

Config()

# base organization action -----------------------------------------------------

class OrganizationAction(Action):

    def __init__(self):
        super(OrganizationAction, self).__init__()
        self.api = OrganizationAPI()


# organization actions ---------------------------------------------------------

class List(OrganizationAction):

    description = _('list all known organizations')

    def run(self):
        orgs = self.api.organizations()

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('description', multiline=True)

        self.printer.set_header(_("Organization List"))
        self.printer.print_items(orgs)
        return os.EX_OK

# ------------------------------------------------------------------------------

class Create(OrganizationAction):

    description = _('create an organization')

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

        org = self.api.create(name, description)
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

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('description', multiline=True)
        self.printer.add_column('service_levels', name=_("Available Service Levels"), multiline=True)

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

        if task.succeeded():
            print _("Successfully deleted org [ %s ]") % name
            return os.EX_OK
        else:
            print _("Organization [ %s ] deletion failed: %s" % (name, format_task_errors(task.errors())) )
            return os.EX_DATAERR

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

        self.printer.add_column('key')
        self.printer.add_column('cert')
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
        pools = self.api.pools(org["cp_key"])

        updated_pool_info = [self.displayable_pool(pool) for pool in pools]

        # by default use verbose mode
        if not self.has_option('grep'):
            self.printer.set_strategy(VerboseStrategy())

        self.printer.add_column('productName', name='Subscription')
        self.printer.add_column('consumed')
        self.printer.add_column('contractNumber', show_with=printer.VerboseStrategy)
        self.printer.add_column('sla', show_with=printer.VerboseStrategy)
        self.printer.add_column('id')
        self.printer.add_column('startDate', show_with=printer.VerboseStrategy)
        self.printer.add_column('endDate', show_with=printer.VerboseStrategy)
        self.printer.set_header(_("Organization's Subscriptions"))
        self.printer.print_items(updated_pool_info)

        return os.EX_OK

    def sla(self, pool):
        return {'sla': self.extract_sla_from_product(self.productApi.show(self.get_option('name'), pool['productId']))}

    def convert_timestamp(self, timestamp_field):
        offset = int(timestamp_field[-5:])
        delta = timedelta(hours = offset / 100)
        t = datetime.strptime(timestamp_field[:-9], "%Y-%m-%dT%H:%M:%S") - delta
        return datetime.strftime(t, "%Y/%m/%d %H:%M:%S")

    def extract_sla_from_product(self, p):
        sla_attr = [attr.get("value", "") for attr in p["attributes"] if attr.get("name", "") == "sla"]
        return sla_attr[0] if len(sla_attr) > 0 else ""

    def displayable_pool(self, pool):
        p = dict(list(pool.items()) + list(self.sla(pool).items()))
        p['startDate'] = self.convert_timestamp(pool['startDate'])
        p['endDate'] = self.convert_timestamp(pool['endDate'])

        return p

# organization command ------------------------------------------------------------

class Organization(Command):

    description = _('organization specific actions in the katello server')
