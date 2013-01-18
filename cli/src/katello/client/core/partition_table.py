# -*- coding: utf-8 -*-
#
# Katello Organization actions
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


from katello.client.api.partition_table import PartitionTableAPI
from katello.client.core.base import BaseAction, Command
from katello.client.core.utils import unnest_one


# base partition table action --------------------------------------------------------

class PartitionTableAction(BaseAction):

    def __init__(self):
        super(PartitionTableAction, self).__init__()
        self.api = PartitionTableAPI()

# partition table actions ------------------------------------------------------------


class List(PartitionTableAction):

    description = _('list partition table')

    def setup_parser(self, parser):
        pass

    def check_options(self, validator):
        pass

    def run(self):
        tables = unnest_one(self.api.list())
        self.printer.add_column('name', _('Name'))
        self.printer.add_column('os_family', _('OS Family'))

        self.printer.set_header(_("Partition Tables"))
        self.printer.print_items(tables)


class Info(PartitionTableAction):

    description = _('show partition table')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name', help=_("partition table name (required)"))

    def check_options(self, validator):
        validator.require('name')

    def run(self):
        table = unnest_one(self.api.show(self.get_option('name')))
        self.printer.add_column('name', _('Name'))
        self.printer.add_column('os_family', _('OS Family'))
        self.printer.add_column('layout', multiline=True)

        self.printer.set_header(_("Partition Table"))
        self.printer.print_item(table)


# partition table command ------------------------------------------------------------

class PartitionTable(Command):

    description = _('partition table specific actions in the katello server')

