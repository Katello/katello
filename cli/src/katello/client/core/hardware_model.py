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

from katello.client.api.hardware_model import HardwareModelAPI
from katello.client.core.base import BaseAction, Command
from katello.client.core.utils import unnest_one


# base hardware model action --------------------------------------------------------

class HardwareModelAction(BaseAction):

    def __init__(self):
        super(HardwareModelAction, self).__init__()
        self.api = HardwareModelAPI()

# hardware model actions ------------------------------------------------------------

class List(HardwareModelAction):

    description = _('list hardware model')

    def setup_parser(self, parser):
        pass

    def check_options(self, validator):
        pass

    def run(self):
        hw_models = unnest_one(self.api.list())
        self.printer.add_column('name')
        self.printer.add_column('vendor_class')
        self.printer.add_column('hardware_model')

        self.printer.set_header(_("Hardware Model"))
        self.printer.print_items(hw_models)


# hardware model command ------------------------------------------------------------

class HardwareModel(Command):

    description = _('hardware model specific actions in the katello server')

