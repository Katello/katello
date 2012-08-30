#
# Katello Organization actions
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
from katello.client.api.utils import get_role, get_permission
from katello.client.cli.base import opt_parser_add_org
from katello.client.core.utils import system_exit, test_record
from katello.client.utils.printer import GrepStrategy, VerboseStrategy
from katello.client.core.base import BaseAction, Command
from katello.client.utils import printer



# base permission action -------------------------------------------------------

class PermissionAction(BaseAction):

    def __init__(self):
        super(PermissionAction, self).__init__()
        self.user_role_api = UserRoleAPI()
        self.api = PermissionAPI()

    def getAvailablePermissions(self, orgName, scope=None):
        data = self.user_role_api.available_verbs(orgName)
        if scope == None:
            return data
        elif scope in data:
            return {scope: data[scope]}
        else:
            return {}

# permission actions -----------------------------------------------------------


class Create(PermissionAction):

    description = _('create a permission for a user role')

    def setup_parser(self, parser):
        parser.add_option('--user_role', dest='user_role', help=_("role name (required)"))
        parser.add_option('--name', dest='name', help=_("permission name (required)"))
        parser.add_option('--description', dest='desc', help=_("permission description"))
        opt_parser_add_org(parser)
        parser.add_option('--scope', dest='scope', help=_("scope of the permisson (required)"))
        parser.add_option('--verbs', dest='verbs', type="list", help=_("verbs for the permission"), default="")
        parser.add_option('--tags', dest='tags', type="list", help=_("tags for the permission"), default="")
        parser.add_option('--all_tags', action="store_true", dest='all_tags',
            help=_("use to set all tags"), default=False)

    def check_options(self, validator):
        validator.require(('user_role', 'name', 'scope'))
        if (self.get_option('all_tags')) and (len(self.get_option('tags')) > 0):
            system_exit(os.EX_DATAERR, _("Can not specify a set of tags and use --all_tags"))

    def tag_name_to_id_map(self, org_name, scope):
        permissions = self.getAvailablePermissions(org_name, scope)

        try:
            tag_map = {}
            for t in permissions[scope]['tags']:
                tag_map[t['display_name']] = t['name']
            return tag_map
        except KeyError, e:
            system_exit(os.EX_DATAERR, _("Invalid scope [ %s ]") % e[0])

    def tags_to_ids(self, tags, org_name, scope):
        tag_map = self.tag_name_to_id_map(org_name, scope)
        try:
            return [tag_map[t] for t in tags]
        except KeyError, e:
            system_exit(os.EX_DATAERR, _("Could not find tag [ %s ] in scope of [ %s ]") % (e[0], scope))


    def run(self):
        role_name = self.get_option('user_role')
        name = self.get_option('name')
        desc = self.get_option('desc')
        org_name = self.get_option('org')
        scope = self.get_option('scope')
        verbs = self.get_option('verbs')
        tags = self.get_option('tags')
        all_tags = self.get_option('all_tags')

        tag_ids = self.tags_to_ids(tags, org_name, scope)

        role = get_role(role_name)

        permission = self.api.create(role['id'], name, desc, scope, verbs, tag_ids, org_name, all_tags)
        test_record(permission,
            _("Successfully created permission [ %s ] for user role [ %s ]") % (name, role['name']),
            _("Could not create permission [ %s ]") % name
        )


class Delete(PermissionAction):

    description = _('delete a permission')

    def setup_parser(self, parser):
        parser.add_option('--user_role', dest='user_role', help=_("role name (required)"))
        parser.add_option('--name', dest='name', help=_("permission name (required)"))

    def check_options(self, validator):
        validator.require(('user_role', 'name'))

    def run(self):
        role_name = self.get_option('user_role')
        name = self.get_option('name')

        role = get_role(role_name)
        perm = get_permission(role_name, name)

        self.api.delete(role['id'], perm['id'])
        print _("Successfully deleted permission [ %s ] for role [ %s ]") % (name, role_name)
        return os.EX_OK


class List(PermissionAction):

    description = _('list permissions for a user role')

    def setup_parser(self, parser):
        parser.add_option('--user_role', dest='user_role', help=_("role name (required)"))

    def check_options(self, validator):
        validator.require('user_role')

    @classmethod
    def format_verbs(cls, verbs):
        return [v['verb'] for v in verbs]

    @classmethod
    def format_tags(cls, tags):
        return [t['formatted']['display_name'] for t in tags]

    def run(self):
        role_name = self.get_option('user_role')

        role = get_role(role_name)

        permissions = self.api.permissions(role['id'])

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('scope', item_formatter=lambda perm: perm['resource_type']['name'])
        self.printer.add_column('verbs', multiline=True, formatter=self.format_verbs)
        self.printer.add_column('tags', multiline=True, formatter=self.format_tags)

        self.printer.set_header(_("Permission List"))
        self.printer.print_items(permissions)
        return os.EX_OK


class ListAvailableVerbs(PermissionAction):

    description = _('list available scopes, verbs and tags that can be set in a permission')
    grep_mode = False

    def setup_parser(self, parser):
        opt_parser_add_org(parser)
        parser.add_option('--scope', dest='scope', help=_("filter listed results by scope"))

    def run(self):
        scope = self.get_option('scope')
        orgName = self.get_option('org')
        listGlobal = not self.has_option('org')

        self.set_output_mode()

        self.printer.add_column("scope")
        self.printer.add_column("available_verbs", multiline=True)
        if not listGlobal:
            self.printer.add_column("available_tags", multiline=True, show_with=printer.VerboseStrategy)

        permissions = self.getAvailablePermissions(orgName, scope)
        display_data = self.formatDisplayData(permissions, listGlobal)

        if scope:
            self.printer.set_header(_("Available verbs and tags for permission scope %s") % scope)
        else:
            self.printer.set_header(_("Available verbs"))
        self.printer.print_items(display_data)
        return os.EX_OK

    def set_output_mode(self):
        if self.has_option('grep'):
            self.grep_mode = True
        elif self.has_option('verbose'):
            self.grep_mode = False
        else:
            if self.has_option('scope'):
                self.printer.set_strategy(VerboseStrategy())
                self.grep_mode = False
            else:
                self.printer.set_strategy(GrepStrategy())
                self.grep_mode = True

    def formatMultilineRecord(self, lines):
        if len(lines) == 0:
            return _('None')
        elif self.grep_mode:
            return ", ".join(lines)
        else:
            return lines

    def formatVerb(self, verb):
        if self.grep_mode:
            return verb["name"]
        else:
            return ("%-20s (%s)" % (verb["name"], verb["display_name"]))

    @classmethod
    def formatTag(cls, tag):
        return tag["display_name"]

    def formatScope(self, scopeName, scopeData):
        verbs = [self.formatVerb(v) for v in scopeData["verbs"]]
        tags  = [self.formatTag(t) for t in scopeData["tags"]]

        item = {}
        item['scope'] = scopeName
        item['available_verbs'] = self.formatMultilineRecord(verbs)
        item['available_tags']  = self.formatMultilineRecord(tags)
        return item

    def formatDisplayData(self, permissions, listGlobal):
        data = []
        for scopeName in sorted(permissions.keys()):
            scopeData = permissions[scopeName]
            if listGlobal or not scopeData["global"]:
                data.append(self.formatScope(scopeName, scopeData))
        return data


# permission command -----------------------------------------------------------

class Permission(Command):

    description = _('permission pecific actions in the katello server')
