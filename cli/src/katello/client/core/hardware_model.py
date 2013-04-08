# -*- coding: utf-8 -*-
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

from katello.client.api.hardware_model import HardwareModelAPI
from katello.client.core.base import BaseAction, Command
from katello.client.lib.utils.data import unnest_one


# base hardware model action --------------------------------------------------------

class HardwareModelAction(BaseAction):

    def __init__(self):
        super(HardwareModelAction, self).__init__()
        self.api = HardwareModelAPI()

class HardwareModelModifyingAction(HardwareModelAction):

    def setup_parser(self, parser):
        parser.add_option('--info', dest='info',
            help=_("General useful description, for example this kind of hardware "
            "needs a special BIOS setup"))
        parser.add_option('--vendor_class', dest='vendor_class',
            help=_("The class of the machine reported by the Open Boot Prom. "
            "This is primarily used by Sparc Solaris builds and can be left blank "
            "for other architectures."))
        parser.add_option('--hw_model', dest='hardware_model',
            help=_("The class of CPU supplied in this machine. This is primarily used "
            "by Sparc Solaris builds and can be left blank for other architectures."))


# hardware model actions ------------------------------------------------------------

class List(HardwareModelAction):

    description = _('list hardware model')

    def run(self):
        hw_models = unnest_one(self.api.list())
        self.printer.add_column('name', _('Name'))
        self.printer.add_column('vendor_class', _('Vendor class'))
        self.printer.add_column('hardware_model', _('HW model'))

        self.printer.set_header(_("Hardware Model"))
        self.printer.print_items(hw_models)


class Info(HardwareModelAction):

    description = _('show hardware model')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name', help=_("hardware model name (required)"))

    def check_options(self, validator):
        validator.require('name')

    def run(self):
        hw_model = self.api.show(self.get_option('name'))
        hw_model = unnest_one(hw_model)

        self.printer.add_column('name', _('Name'))
        self.printer.add_column('info', _('Info'), multiline=True)
        self.printer.add_column('vendor_class', _('Vendor class'))
        self.printer.add_column('hardware_model', _('HW model'))

        self.printer.set_header(_("Hardware Model"))
        self.printer.print_item(hw_model)


class Create(HardwareModelModifyingAction):

    description = _('create hardware model')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name', help=_("hardware model name (required)"))
        super(Create, self).setup_parser(parser)

    def check_options(self, validator):
        validator.require('name')

    def run(self):
        self.api.create(self.get_option_dict('name', 'info', 'vendor_class', 'hardware_model'))
        print _('Hardware Model [ %s ] created') % self.get_option('name')


class Update(HardwareModelModifyingAction):

    description = _('update hardware model')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='old_name', help=_("hardware model name (required)"))
        parser.add_option('--new_name', dest='name', help=_("new name for the hardware model"))
        super(Update, self).setup_parser(parser)

    def check_options(self, validator):
        validator.require('old_name')
        validator.require_at_least_one_of(('name', 'info', 'vendor_class', 'hardware_model'))

    def run(self):
        self.api.update(self.get_option('old_name'), self.get_option_dict())
        print _('Hardware Model [ %s ] updated') % self.get_option('old_name')


class Delete(HardwareModelAction):

    description = _('delete hardware model')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name', help=_("hardware model name (required)"))

    def check_options(self, validator):
        validator.require('name')

    def run(self):
        self.api.destroy(self.get_option('name'))
        print _('Hardware Model [ %s ] deleted.') % self.get_option('name')



# hardware model command ------------------------------------------------------------

class HardwareModel(Command):

    description = _('hardware model specific actions in the katello server')

