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
from katello.client.config import Config
from katello.client.core.base import Action, Command
from katello.client.core.utils import is_valid_record

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
            print _("Could not create org [ %s ]") % org['name']
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

        self.api.delete(name)
        print _("Successfully deleted org [ %s ]") % name
        return os.EX_OK

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

    description = _('generate ueber certificate')

    def setup_parser(self):
        self.parser.add_option('--name', dest='name',
                               help=_("organization name eg: foo.example.com (required)"))

    def check_options(self):
        self.require_option('name')

    def run(self):
        name        = self.get_option('name')

        self.api.generate_debug_cert(name)
        print _("Successfully generated debug cert for org [ %s ]") % name
        return os.EX_OK

# ------------------------------------------------------------------------------

class DeleteDebugCert(OrganizationAction):

    description = _('remove ueber certificate')

    def setup_parser(self):
        self.parser.add_option('--name', dest='name',
                               help=_("organization name eg: foo.example.com (required)"))

    def check_options(self):
        self.require_option('name')

    def run(self):
        name        = self.get_option('name')

        self.api.delete_debug_cert(name)
        print _("Successfully deleted debug cert for org [ %s ]") % name
        return os.EX_OK

# organization command ------------------------------------------------------------

class Organization(Command):

    description = _('organization specific actions in the katello server')
