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

import os
from katello.client.api.partition_table import PartitionTableAPI
from katello.client.core.base import BaseAction, Command
from katello.client.lib.control import system_exit
from katello.client.lib.utils.data import unnest_one
from katello.client.lib.utils.io import read_file
from katello.client.lib.ui.external_editor import Editor


# base partition table action --------------------------------------------------------

class PartitionTableAction(BaseAction):

    def __init__(self):
        super(PartitionTableAction, self).__init__()
        self.api = PartitionTableAPI()


class PartitionTableModifyingAction(PartitionTableAction):

    def _read_layout(self, path):
        if path:
            return self._input_from_file(path)
        else:
            return self._input_from_editor(self._get_initial_layout())

    @classmethod
    def _input_from_editor(cls, initial_layout):
        return Editor().open_text(initial_layout)

    @classmethod
    def _input_from_file(cls, path):
        try:
            return read_file(path)
        except IOError:
            system_exit(os.EX_IOERR, _("Can't read file %s") % path)

    #Disabling "Method could be a function"
    #The method is intended to be overriden by subclasses
    def _get_initial_layout(self): #pylint: disable=R0201
        return "# " + _("enter the partition layout here")


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

        self.printer.set_header(_("Partition tables"))
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

        self.printer.set_header(_("Partition table"))
        self.printer.print_item(table)


class Create(PartitionTableModifyingAction):

    description = _('create partition table')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name', help=_("partition table name (required)"))
        parser.add_option('--layout_file', dest='layout_file', help=_("path to file with partition layout definition"))
        parser.add_option('--os_family', dest='os_family', help=_("operating system family"))

    def check_options(self, validator):
        validator.require('name')

    def run(self):
        data = self.get_option_dict("name", "os_family")
        data['layout'] = self._read_layout(self.get_option('layout_file'))

        self.api.create(data)
        print _('Partition table [ %s ] created.') % self.get_option('name')


class Update(PartitionTableModifyingAction):

    description = _('update partition table')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='old_name', help=_("partition table name (required)"))
        parser.add_option('--new_name', dest='name', help=_("new partition table name"))
        parser.add_option('--layout_file', dest='layout_file', help=_("path to file with partition layout definition"))
        parser.add_option('--os_family', dest='os_family', help=_("operating system family"))

    def check_options(self, validator):
        validator.require('old_name')

    def _get_initial_layout(self):
        table = unnest_one(self.api.show(self.get_option('old_name')))
        return table['layout']

    def run(self):
        old_name = self.get_option('old_name')

        data = self.get_option_dict("name", "os_family")
        data['layout'] = self._read_layout(self.get_option('layout_file'))

        self.api.update(old_name, data)
        print _('Partition table [ %s ] updated.') % old_name


class Delete(PartitionTableAction):

    description = _('destroy partition table')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name', help=_("partition table name (required)"))

    def check_options(self, validator):
        validator.require('name')

    def run(self):
        self.api.destroy(self.get_option('name'))
        print _('Partition table [ %s ] deleted') % self.get_option('name')


# partition table command ------------------------------------------------------------

class PartitionTable(Command):

    description = _('partition table specific actions in the katello server')

