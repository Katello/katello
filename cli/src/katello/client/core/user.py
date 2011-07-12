#!/usr/bin/python
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
import urlparse
from pprint import pprint
from gettext import gettext as _

from katello.client.api.user import UserAPI
from katello.client.config import Config
from katello.client.core.base import Action, Command
from katello.client.core.utils import is_valid_record

_cfg = Config()

# base user action -----------------------------------------------------

class UserAction(Action):

    def __init__(self):
        super(UserAction, self).__init__()
        self.api = UserAPI()


# user actions ---------------------------------------------------------

class List(UserAction):

    description = _('list all known users')

    def run(self):
        users = self.api.users()

        self.printer.addColumn('id')
        self.printer.addColumn('username')
        self.printer.addColumn('disabled')

        self.printer.setHeader(_("User List"))
        self.printer.printItems(users)
        return os.EX_OK

# ------------------------------------------------------------------------------

class Create(UserAction):

    description = _('create user')

    def setup_parser(self):
        self.parser.add_option('--username', dest='username',
                help=_("user name (required)"))
        self.parser.add_option('--password', dest='password',
                help=_("initial password (required)"))
        self.parser.add_option("--disabled", dest="disabled",
                help=_("disabled account (default is 'false')"))

    def check_options(self):
        self.require_option('username')
        self.require_option('password')

    def run(self):
        username = self.get_option('username')
        password = self.get_option('password')
        disabled = self.get_option('disabled')

        user = self.api.create(username, password, disabled)
        if is_valid_record(user):
            print _("Successfully created user [ %s ]") % user['username']
        else:
            print _("Could not create user [ %s ]") % user['username']
        return os.EX_OK

# ------------------------------------------------------------------------------

class Info(UserAction):

    description = _('list information about user')

    def setup_parser(self):
        self.parser.add_option('--username', dest='username',
                help=_("user name (required)"))

    def check_options(self):
        self.require_option('username')

    def run(self):
        username = self.get_option('username')

        users = self.api.users({"username": username})
        if len(users) != 1:
            print _("Cannot find user [ %s ]") % username
            return os.EX_DATAERR

        self.printer.addColumn('id')
        self.printer.addColumn('username')
        self.printer.addColumn('disabled')

        self.printer.setHeader(_("User Information"))
        self.printer.printItem(users[0])
        return os.EX_OK

# ------------------------------------------------------------------------------

class Delete(UserAction):

    description = _('delete user')

    def setup_parser(self):
        self.parser.add_option('--username', dest='username',
                help=_("user name (required)"))

    def check_options(self):
        self.require_option('username')

    def run(self):
        username = self.get_option('username')

        users = self.api.users({"username": username})
        if len(users) != 1:
            print _("Cannot find user [ %s ]") % username
            return os.EX_DATAERR

        self.api.delete(users[0]['id'])
        print _("Successfully deleted user [ %s ]") % username
        return os.EX_OK

# ------------------------------------------------------------------------------

class Update(UserAction):

    description = _('update an user')

    def setup_parser(self):
        self.parser.add_option('--username', dest='username',
                help=_("user name (required)"))
        self.parser.add_option('--password', dest='password',
                help=_("initial password"))
        self.parser.add_option("--disabled", dest="disabled",
                help=_("disabled account (default is 'false')"))

    def check_options(self):
        self.require_option('username')

    def run(self):
        username = self.get_option('username')
        password = self.get_option('password')
        disabled = self.get_option('disabled')

        users = self.api.users({"username": username})
        if len(users) != 1:
            print _("Cannot find user [ %s ]") % username
            return os.EX_DATAERR

        if password == None and disabled == None:
            print _("Provide at least one parameter to update user [ %s ]") % username
            return os.EX_DATAERR

        user = self.api.update(users[0]['id'], password, disabled)
        print _("Successfully updated user [ %s ]") % username
        return os.EX_OK


# user command ------------------------------------------------------------

class User(Command):

    description = _('user specific actions in the katello server')
