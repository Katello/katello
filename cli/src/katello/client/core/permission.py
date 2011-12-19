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
from katello.client.core.utils import Printer
from katello.client.config import Config
from katello.client.core.base import Action, Command


Config()



# base permission action -------------------------------------------------------

class PermissionAction(Action):

    def __init__(self):
        super(PermissionAction, self).__init__()
        self.api = UserRoleAPI()

    def getPermissions(self, orgName, scope=None):
        data = self.api.available_verbs(orgName)
        if scope == None:
            return data
        elif scope in data:
            return {scope: data[scope]}
        else:
            return {}



class SinglePermissionAction(PermissionAction):


    def setup_parser(self):
        pass

    def check_options(self):
        pass



# permission actions -----------------------------------------------------------

class ListAvailableVerbs(PermissionAction):

    description = _('list available scopes, verbs and tags that can be set in a permission')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org', help=_("organization name eg: foo.example.com,\nlists organization specific verbs"))
        self.parser.add_option('--global', dest='global', action="store_true", help=_("list scopes and verbs available globally"))
        self.parser.add_option('--scope', dest='scope', help=_("filter listed results by scope"))

    def check_options(self):
        if not self.has_option('global'):
            self.require_option('org')

    def run(self):
        scope = self.get_option('scope')
        listGlobal = self.has_option('global')
        if not listGlobal:
            orgName = self.get_option('org')
        else:
            orgName = None


        self.setOutputMode()

        self.printer.addColumn("scope")
        self.printer.addColumn("available_verbs", multiline=True)
        self.printer.addColumn("available_tags", multiline=True, show_in_grep=False)

        permissions = self.getPermissions(orgName, scope)
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
