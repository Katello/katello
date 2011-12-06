#
# Katello User actions
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

from katello.client.api.user_role import UserRoleAPI
from katello.client.config import Config
from katello.client.core.base import Action, Command
from katello.client.core.utils import is_valid_record, convert_to_mime_type, attachment_file_name, save_report

Config()

# base user action -----------------------------------------------------

class UserRoleAction(Action):

    def __init__(self):
        super(UserRoleAction, self).__init__()
        self.api = UserRoleAPI()


# user actions ---------------------------------------------------------

class List(UserRoleAction):

    description = _('list all known user roles')

    def run(self):
        roles = self.api.roles()

        self.printer.addColumn('id')
        self.printer.addColumn('name')

        self.printer.setHeader(_("User Role List"))
        self.printer.printItems(roles)
        return os.EX_OK

# user command ------------------------------------------------------------

class UserRole(Command):

    description = _('user role specific actions in the katello server')
