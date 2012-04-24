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
import sys
from gettext import gettext as _

from katello.client.api.user_role import UserRoleAPI
from katello.client.api.permission import PermissionAPI
from katello.client.config import Config
from katello.client.core.base import Action, Command
from katello.client.core.utils import is_valid_record, system_exit

Config()

# base user action -----------------------------------------------------

class UserRoleAction(Action):

    def __init__(self):
        super(UserRoleAction, self).__init__()
        self.api = UserRoleAPI()

    def get_role(self, name):
        role = self.api.role_by_name(name)
        if role == None:
            system_exit(os.EX_DATAERR, _("Cannot find user role [ %s ]") % name )
        return role

# user actions ---------------------------------------------------------

class List(UserRoleAction):

    description = _('list all known user roles')

    def run(self):
        roles = self.api.roles()

        self.printer.add_column('id')
        self.printer.add_column('name')

        self.printer.set_header(_("User Role List"))
        self.printer.print_items(roles)
        return os.EX_OK

# ------------------------------------------------------------------------------

class Create(UserRoleAction):

    description = _('create user role')

    def setup_parser(self):
        self.parser.add_option('--name', dest='name',help=_("role name (required)"))
        self.parser.add_option('--description', dest='desc', help=_("role description"))

    def check_options(self):
        self.require_option('name')

    def run(self):
        name = self.get_option('name')
        desc = self.get_option('desc')

        role = self.api.create(name, desc)
        if is_valid_record(role):
            print _("Successfully created user role [ %s ]") % role['name']
            return os.EX_OK
        else:
            print >> sys.stderr, _("Could not create user role [ %s ]") % name
            return os.EX_DATAERR

# ------------------------------------------------------------------------------

class Info(UserRoleAction):

    description = _('list information about user role')

    def setup_parser(self):
        self.parser.add_option('--name', dest='name', help=_("user role name (required)"))
        self.parser.add_option('--permission_details', dest='perm_details', action='store_true', help=_("print details about each of role's permissions"))

    def check_options(self):
        self.require_option('name')

    def getPermissions(self, roleId):
        permApi = PermissionAPI()
        return permApi.permissions(roleId)

    def getLdapGroups(self, roleId):
        ldap_groups = self.api.ldap_groups(roleId)
        return [lg['ldap_group'] for lg in ldap_groups]
        

    def formatPermission(self, p, details=True):
        if details:
            verbs = ', '.join([v['verb'] for v in p['verbs']])
            tags  = ', '.join([t['formatted']['display_name'] for t in p['tags']])
            type  = p['resource_type']['name']
            return _("%s\n\tfor: %s\n\tverbs: %s\n\ton: %s") % (p['name'], type, verbs, tags)
        else:
            return p['name']

    def run(self):
        name = self.get_option('name')
        permDetails = self.get_option('perm_details')

        role = self.get_role(name)
        permissions = self.getPermissions(role['id'])
        role['permissions'] = "\n".join([self.formatPermission(p, permDetails) for p in permissions])

        ldap_groups = self.getLdapGroups(role['id'])
        role['ldap_groups'] = ", ".join(ldap_groups)

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('description')
        self.printer.add_column('permissions', multiline=True)
        self.printer.add_column('ldap_groups')

        self.printer.set_header(_("User Role Information"))
        self.printer.print_item(role)
        return os.EX_OK

# ------------------------------------------------------------------------------

class Delete(UserRoleAction):

    description = _('delete a user role')

    def setup_parser(self):
        self.parser.add_option('--name', dest='name', help=_("user role name (required)"))

    def check_options(self):
        self.require_option('name')

    def run(self):
        name = self.get_option('name')

        role = self.get_role(name)

        self.api.delete(role['id'])
        print _("Successfully deleted user role [ %s ]") % name
        return os.EX_OK


# ------------------------------------------------------------------------------

class Update(UserRoleAction):

    description = _('update a role')

    def setup_parser(self):
        self.parser.add_option('--name', dest='name', help=_("user role name (required)"))
        self.parser.add_option('--new_name', dest='new_name', help=_("new user role name"))
        self.parser.add_option('--description', dest='desc', help=_("role description"))

    def check_options(self):
        self.require_option('name')
        if not self.has_option('new_name') and not self.has_option('desc'):
            self.add_option_error(_("Provide at least one parameter to update the user role"))

    def run(self):
        name = self.get_option('name')
        newName = self.get_option('new_name')
        desc = self.get_option('desc')

        role = self.get_role(name)

        self.api.update(role['id'], newName, desc)
        print _("Successfully updated user role [ %s ]") % name
        return os.EX_OK

# ------------------------------------------------------------------------------

class AddLdapGroup(UserRoleAction):

    description = _('assign LDAP group to a role')

    def setup_parser(self):
        self.parser.add_option('--name', dest='name', help=_("user role name (required)"))
        self.parser.add_option('--group_name', dest='group_name', help=_("new LDAP group name (required)"))

    def check_options(self):
        self.require_option('name')
        self.require_option('group_name')

    def run(self):
        name = self.get_option('name')
        group_name = self.get_option('group_name')

        role = self.get_role(name)

        user = self.api.add_ldap_group(role['id'], group_name)
        print _("Successfully added LDAP group [ %s ] to the user role [ %s ]") % (group_name, name)
        return os.EX_OK

# ------------------------------------------------------------------------------

class RemoveLdapGroup(UserRoleAction):

    description = _('remove LDAP group assigned to a role')

    def setup_parser(self):
        self.parser.add_option('--name', dest='name', help=_("user role name (required)"))
        self.parser.add_option('--group_name', dest='group_name', help=_("LDAP group name to be removed (required)"))

    def check_options(self):
        self.require_option('name')
        self.require_option('group_name')

    def run(self):
        name = self.get_option('name')
        group_name = self.get_option('group_name')

        role = self.get_role(name)

        user = self.api.remove_ldap_group(role['id'], group_name)
        print _("Successfully removed LDAP group [ %s ] from the user role [ %s ]") % (group_name, name)
        return os.EX_OK

# user command ------------------------------------------------------------

class UserRole(Command):

    description = _('user role specific actions in the katello server')
