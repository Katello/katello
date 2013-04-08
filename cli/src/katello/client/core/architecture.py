#
# Katello Organization actions
# Copyright 2013 Red Hat, Inc.
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
from katello.client.api.architecture import ArchitectureAPI
from katello.client.core.base import BaseAction, Command
from katello.client.lib.utils.data import test_foreman_record, unnest_one
from katello.client.lib.ui.printer import batch_add_columns


# base architecture action --------------------------------------------------------

class ArchitectureAction(BaseAction):

    def __init__(self):
        super(ArchitectureAction, self).__init__()
        self.api = ArchitectureAPI()

# architecture actions ------------------------------------------------------------

class List(ArchitectureAction):

    description = _('list all known architectures')

    def run(self):
        archs = self.api.index()
        if archs:
            archs = unnest_one(archs)
        batch_add_columns(self.printer, {'id': _("ID")}, {'name': _("Name")})

        self.printer.set_header(_("Architectures List"))
        self.printer.print_items(archs)
        return os.EX_OK


class Create(ArchitectureAction):

    description = _('create an architecture')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name', help=constants.OPT_ARCHITECTURE_NAME)

    def check_options(self, validator):
        validator.require('name')

    def run(self):
        arch = self.api.create(self.get_option_dict("name"))
        test_foreman_record(arch, 'architecture',
            _("Architecture [ %s ] created.") % self.get_option("name"),
            _("Could not create architecture [ %s ].") % self.get_option("name")
        )


class Update(ArchitectureAction):

    description = _('update an architecture')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='old_name', help=constants.OPT_ARCHITECTURE_NAME)
        parser.add_option('--new_name', dest='name', help=_("new name for the architecture (required)"))

    def check_options(self, validator):
        validator.require(('old_name', 'name'))

    def run(self):
        architecture = self.api.update(self.get_option("old_name"), self.get_option_dict("name"))

        test_foreman_record(architecture, 'architecture',
            _("Architecture [ %s ] updated.") % self.get_option("old_name"),
            _("Could not update Architecture [ %s ].") % self.get_option("old_name")
        )


class Delete(ArchitectureAction):

    description = _('delete an architecture')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name', help=_("architecture name (required)"))

    def check_options(self, validator):
        validator.require('name')

    def run(self):
        self.api.destroy(self.get_option("name"))
        print _("Architecture [ %s ] deleted.") % self.get_option("name")
        return os.EX_OK

class Show(ArchitectureAction):

    description = _('show details about an architecture')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name', help=_("architecture name (required)"))

    def check_options(self, validator):
        validator.require('name')

    def run(self):
        arch = self.api.show(self.get_option('name'))
        arch = unnest_one(arch)

        batch_add_columns(self.printer, {'id': _("ID")}, {'name': _("Name")})

        self.printer.set_header(_("Architecture"))
        self.printer.print_item(arch)
        return os.EX_OK


# architecture command ------------------------------------------------------------

class Architecture(Command):

    description = _('Architecture specific actions in the katello server')


