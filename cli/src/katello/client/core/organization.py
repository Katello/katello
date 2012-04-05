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
import sys
from gettext import gettext as _

from katello.client.api.organization import OrganizationAPI
from katello.client.api.product import ProductAPI
from katello.client.config import Config
from katello.client.core.base import Action, Command
from katello.client.core.utils import is_valid_record, run_spinner_in_bg, wait_for_async_task, AsyncTask, format_task_errors
from katello.client.utils.printer import Printer
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

        self.printer.addColumn('id')
        self.printer.addColumn('name')
        self.printer.addColumn('description', multiline=True)

        self.printer.setHeader(_("Organization List"))
        self.printer.printItems(orgs)
        return os.EX_OK

# ------------------------------------------------------------------------------

class Create(OrganizationAction):

    description = _('create an organization')

    def setup_parser(self):
        # always provide --id option for create, even on registered clients
        self.parser.add_option('--name', dest='name',
                               help=_("organization name eg: foo.example.com (required)"))
        self.parser.add_option("--description", dest="description",
                               help=_("consumer description eg: foo's organization"))

    def check_options(self):
        self.require_option('name')

    def run(self):
        name        = self.get_option('name')
        description = self.get_option('description')

        org = self.api.create(name, description)
        if is_valid_record(org):
            print _("Successfully created org [ %s ]") % org['name']
            return os.EX_OK
        else:
            print >> sys.stderr, _("Could not create org [ %s ]") % org['name']
            return os.EX_DATAERR


# ------------------------------------------------------------------------------

class Info(OrganizationAction):

    description = _('list information about an organization')

    def setup_parser(self):
        # always provide --id option for create, even on registered clients
        self.parser.add_option('--name', dest='name',
                               help=_("organization name eg: foo.example.com (required)"))

    def check_options(self):
        self.require_option('name')

    def run(self):
        name = self.get_option('name')

        org = self.api.organization(name)

        self.printer.addColumn('id')
        self.printer.addColumn('name')
        self.printer.addColumn('description', multiline=True)
        self.printer.addColumn('service_levels', name=_("Available Service Levels"), multiline=True)

        self.printer.setHeader(_("Organization Information"))
        self.printer.printItem(org)
        return os.EX_OK

# ------------------------------------------------------------------------------

class Delete(OrganizationAction):

    description = _('delete an organization')

    def setup_parser(self):
        # always provide --id option for create, even on registered clients
        self.parser.add_option('--name', dest='name',
                               help=_("organization name eg: foo.example.com (required)"))

    def check_options(self):
        self.require_option('name')

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

    def setup_parser(self):
        # always provide --id option for create, even on registered clients
        self.parser.add_option('--name', dest='name',
                               help=_("organization name eg: foo.example.com (required)"))
        self.parser.add_option("--description", dest="description",
                               help=_("consumer description eg: foo's organization"))

    def check_options(self):
        self.require_option('name')

    def run(self):
        name        = self.get_option('name')
        description = self.get_option('description')

        self.api.update(name, description)
        print _("Successfully updated org [ %s ]") % name
        return os.EX_OK

# ------------------------------------------------------------------------------

class GenerateDebugCert(OrganizationAction):

    description = _('generate and show ueber certificate')

    def setup_parser(self):
        self.parser.add_option('--name', dest='name',
                               help=_("organization name eg: foo.example.com (required)"))

    def check_options(self):
        self.require_option('name')

    def run(self):
        name = self.get_option('name')

        uebercert = self.api.uebercert(name)

        self.printer.addColumn('key')
        self.printer.addColumn('cert')
        self.printer.setHeader(_("Organization Uebercert"))
        self.printer.printItem(uebercert)

        return os.EX_OK

# ------------------------------------------------------------------------------

class ShowSubscriptions(OrganizationAction):

    description = _('show subscriptions')

    def __init__(self):
        super(ShowSubscriptions, self).__init__()
        self.productApi = ProductAPI()

    def setup_parser(self):
        self.parser.add_option('--name', dest='name',
                               help=_("organization name eg: foo.example.com (required)"))

    def check_options(self):
        self.require_option('name')

    def run(self):
        name = self.get_option('name')
        org = self.api.organization(name)
        pools = self.api.pools(org["cp_key"])

        updated_pool_info = [self.displayable_pool(pool) for pool in pools]

        # by default use verbose mode
        if not self.has_option('grep'):
            self.printer.setOutputMode(Printer.OUTPUT_FORCE_VERBOSE)

        self.printer.addColumn('productName')
        self.printer.addColumn('consumed')
        self.printer.addColumn('contractNumber', show_in_grep=False)
        self.printer.addColumn('sla', show_in_grep=False)
        self.printer.addColumn('id')
        self.printer.addColumn('startDate', show_in_grep=False)
        self.printer.addColumn('endDate', show_in_grep=False)
        self.printer.setHeader(_("Organization's Subscriptions"))
        self.printer.printItems(updated_pool_info)

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
