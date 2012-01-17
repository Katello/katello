#
# Katello Organization actions
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
import datetime

from katello.client.api.user_role import UserRoleAPI
from katello.client.api.permission import PermissionAPI
from katello.client.api.utils import get_role, get_organization, get_permission
from katello.client.core.utils import Printer, system_exit, is_valid_record
from katello.client.config import Config
from katello.client.core.base import Action, Command


Config()



# base permission action -------------------------------------------------------

class PermissionAction(Action):

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

    def setup_parser(self):
        self.parser.add_option('--user_role', dest='user_role',help=_("role name (required)"))
        self.parser.add_option('--name', dest='name',help=_("permission name (required)"))
        self.parser.add_option('--description', dest='desc', help=_("permission description"))
        self.parser.add_option('--org', dest='org', help=_("organization name"))
        self.parser.add_option('--scope', dest='scope', help=_("scope of the permisson (required)"))
        self.parser.add_option('--verbs', dest='verbs', help=_("verbs for the permission"), default="")
        self.parser.add_option('--tags', dest='tags', help=_("tags for the permission"), default="")

    def check_options(self):
        self.require_option('user_role')
        self.require_option('name')
        self.require_option('scope')

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

    def split_options(self, opts):
        if opts == "":
            return []
        else:
            return opts.split(",")


    def run(self):
        role_name = self.get_option('user_role')
        name = self.get_option('name')
        desc = self.get_option('desc')
        org_name = self.get_option('org')
        scope = self.get_option('scope')
        verbs = self.split_options(self.get_option('verbs'))
        tags = self.split_options(self.get_option('tags'))

        tag_ids = self.tags_to_ids(tags, org_name, scope)

        role = get_role(role_name)
        if role == None:
            return os.EX_DATAERR

        permission = self.api.create(role['id'], name, desc, scope, verbs, tag_ids, org_name)
        if is_valid_record(permission):
            print _("Successfully created permission [ %s ] for user role [ %s ]") % (name, role['name'])
            return os.EX_OK
        else:
            print _("Could not create permission [ %s ]") % name
            return os.EX_DATAERR


class Delete(PermissionAction):

    description = _('delete a permission')

    def setup_parser(self):
        self.parser.add_option('--user_role', dest='user_role',help=_("role name (required)"))
        self.parser.add_option('--name', dest='name',help=_("permission name (required)"))

    def check_options(self):
        self.require_option('user_role')
        self.require_option('name')

    def run(self):
        role_name = self.get_option('user_role')
        name = self.get_option('name')

        role = get_role(role_name)
        if role == None:
            return os.EX_DATAERR
        perm = get_permission(role_name, name)
        if perm == None:
            return os.EX_DATAERR

        self.api.delete(role['id'], perm['id'])
        print _("Successfully deleted permission [ %s ] for role [ %s ]") % (name, role_name)
        return os.EX_OK


class List(PermissionAction):

    description = _('list permissions for a user role')

    def setup_parser(self):
        self.parser.add_option('--user_role', dest='user_role',help=_("role name (required)"))

    def check_options(self):
        self.require_option('user_role')

    def format_verbs(self, verbs):
        return [v['verb'] for v in verbs]

    def format_tags(self, tags):
        return [t['formatted']['display_name'] for t in tags]

    def format_permission(self, permission):
        permission['scope'] = permission['resource_type']['name']
        permission['verbs'] = self.format_verbs(permission['verbs'])
        permission['tags'] = self.format_tags(permission['tags'])
        return permission

    def run(self):
        role_name = self.get_option('user_role')

        role = get_role(role_name)
        if role == None:
            return os.EX_DATAERR

        permissions = self.api.permissions(role['id'])
        display_permissons = []
        for p in permissions:
            display_permissons.append(self.format_permission(p))

        self.printer.addColumn('id')
        self.printer.addColumn('name')
        self.printer.addColumn('scope')
        self.printer.addColumn('verbs', multiline=True)
        self.printer.addColumn('tags', multiline=True)

        self.printer.setHeader(_("Permission List"))
        self.printer.printItems(display_permissons)
        return os.EX_OK


class ListAvailableVerbs(PermissionAction):

    description = _('list available scopes, verbs and tags that can be set in a permission')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org', help=_("organization name eg: foo.example.com,\nlists organization specific verbs"))
        self.parser.add_option('--scope', dest='scope', help=_("filter listed results by scope"))

    def run(self):
        scope = self.get_option('scope')
        orgName = self.get_option('org')
        listGlobal = not self.has_option('org')

        self.setOutputMode()

        self.printer.addColumn("scope")
        self.printer.addColumn("available_verbs", multiline=True)
        if not listGlobal:
            self.printer.addColumn("available_tags", multiline=True, show_in_grep=False)

        permissions = self.getAvailablePermissions(orgName, scope)
        display_data = self.formatDisplayData(permissions, listGlobal)

        if scope:
            self.printer.setHeader(_("Available verbs and tags for permission scope %s") % scope)
        else:
            self.printer.setHeader(_("Available verbs"))
        self.printer.printItems(display_data)
        return os.EX_OK

    def setOutputMode(self):
        if self.output_mode() == Printer.OUTPUT_FORCE_NONE:
            if self.has_option('scope'):
                self.printer.setOutputMode(Printer.OUTPUT_FORCE_VERBOSE)
                self.grepMode = False
            else:
                self.printer.setOutputMode(Printer.OUTPUT_FORCE_GREP)
                self.grepMode = True

    def formatMultilineRecord(self, lines):
        if len(lines) == 0:
            return _('None')
        elif self.grepMode:
            return ", ".join(lines)
        else:
            return lines

    def formatVerb(self, verb):
        if self.grepMode:
            return verb["name"]
        else:
            return ("%-20s (%s)" % (verb["name"], verb["display_name"]))

    def formatTag(self, tag):
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
