#
# Katello User actions
# Copyright (c) 2012 Red Hat, Inc.
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

from katello.client.api.user_role import UserRoleAPI
from katello.client.api.permission import PermissionAPI
from katello.client.core.base import BaseAction, Command
from katello.client.lib.control import system_exit
from katello.client.lib.utils.data import test_record


# base user action -----------------------------------------------------

class UserRoleAction(BaseAction):

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

        self.printer.add_column('id', _("ID"))
        self.printer.add_column('name', _("Name"))

        self.printer.set_header(_("User Role List"))
        self.printer.print_items(roles)
        return os.EX_OK

# ------------------------------------------------------------------------------

class Create(UserRoleAction):

    description = _('create user role')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name', help=_("role name (required)"))
        parser.add_option('--description', dest='desc', help=_("role description"))

    def check_options(self, validator):
        validator.require('name')

    def run(self):
        name = self.get_option('name')
        desc = self.get_option('desc')

        role = self.api.create(name, desc)
        test_record(role,
            _("Successfully created user role [ %s ]") % name,
            _("Could not create user role [ %s ]") % name
        )


# ------------------------------------------------------------------------------

class Info(UserRoleAction):

    description = _('list information about user role')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name', help=_("user role name (required)"))
        parser.add_option('--permission_details', dest='perm_details', action='store_true',
            help=_("print details about each of role's permissions"))

    def check_options(self, validator):
        validator.require('name')

    @classmethod
    def getPermissions(cls, roleId):
        permApi = PermissionAPI()
        return permApi.permissions(roleId)

    def getLdapGroups(self, roleId):
        ldap_groups = self.api.ldap_groups(roleId)
        return [lg['ldap_group'] for lg in ldap_groups]

    @classmethod
    def formatPermission(cls, p, details=True):
        if details:
            verbs = ', '.join([v['verb'] for v in p['verbs']])
            tags  = ', '.join([t['formatted']['display_name'] for t in p['tags']])
            type_in  = p['resource_type']['name']
            return _("%(param_name)s\n\tfor: %(type_in)s\n\tverbs: %(verbs)s\n\ton: %(tags)s") \
                % {'param_name':p['name'], 'type_in':type_in, 'verbs':verbs, 'tags':tags}
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

        self.printer.add_column('id', _("ID"))
        self.printer.add_column('name', _("Name"))
        self.printer.add_column('description', _("Description"))
        self.printer.add_column('permissions', _("Permissions"), multiline=True)
        self.printer.add_column('ldap_groups', _("LDAP Groups"))

        self.printer.set_header(_("User Role Information"))
        self.printer.print_item(role)
        return os.EX_OK

# ------------------------------------------------------------------------------

class Delete(UserRoleAction):

    description = _('delete a user role')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name', help=_("user role name (required)"))

    def check_options(self, validator):
        validator.require('name')

    def run(self):
        name = self.get_option('name')

        role = self.get_role(name)

        self.api.delete(role['id'])
        print _("Successfully deleted user role [ %s ]") % name
        return os.EX_OK


# ------------------------------------------------------------------------------

class Update(UserRoleAction):

    description = _('update a role')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name', help=_("user role name (required)"))
        parser.add_option('--new_name', dest='new_name', help=_("new user role name"))
        parser.add_option('--description', dest='desc', help=_("role description"))

    def check_options(self, validator):
        validator.require('name')
        validator.require_at_least_one_of(('new_name', 'desc'))

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

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name', help=_("user role name (required)"))
        parser.add_option('--group_name', dest='group_name', help=_("new LDAP group name (required)"))

    def check_options(self, validator):
        validator.require(('name', 'group_name'))

    def run(self):
        name = self.get_option('name')
        group_name = self.get_option('group_name')

        role = self.get_role(name)

        self.api.add_ldap_group(role['id'], group_name)
        print _("Successfully added LDAP group [ %(group_name)s ] to the user role [ %(name)s ]") \
            % {'group_name':group_name, 'name':name}
        return os.EX_OK

# ------------------------------------------------------------------------------

class RemoveLdapGroup(UserRoleAction):

    description = _('remove LDAP group assigned to a role')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name', help=_("user role name (required)"))
        parser.add_option('--group_name', dest='group_name', help=_("LDAP group name to be removed (required)"))

    def check_options(self, validator):
        validator.require(('name', 'group_name'))

    def run(self):
        name = self.get_option('name')
        group_name = self.get_option('group_name')

        role = self.get_role(name)

        self.api.remove_ldap_group(role['id'], group_name)
        print _("Successfully removed LDAP group [ %(group_name)s ] from the user role [ %(name)s ]") \
            % {'group_name':group_name, 'name':name}
        return os.EX_OK

# user command ------------------------------------------------------------

class UserRole(Command):

    description = _('user role specific actions in the katello server')
