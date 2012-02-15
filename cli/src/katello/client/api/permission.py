# -*- coding: utf-8 -*-
#
# Copyright © 2011 Red Hat, Inc.
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

from katello.client.api.base import KatelloAPI

class PermissionAPI(KatelloAPI):
    """
    Connection class to access Permissions
    """
    def create(self, roleId, name, description, type, verbs, tagIds, orgId = None):
        data = {
            "name": name,
            "description": description,
            "type": type,
            "verbs": verbs,
            "tags": tagIds,
            "organization_id": orgId
        }
        path = "/api/roles/%s/permissions/" % str(roleId)
        return self.server.POST(path, data)[1]

    def permissions(self, roleId, query={}):
        path = "/api/roles/%s/permissions/" % str(roleId)
        return self.server.GET(path, query)[1]

    def permission(self, roleId, permissionId):
        path = "/api/roles/%s/permissions/%s/" % (str(roleId), str(permissionId))
        return self.server.GET(path)[1]

    def permission_by_name(self, roleId, name):
        perms = self.permissions(roleId, {"name": name})
        if len(perms) >= 1:
            return perms[0]
        else:
            return None

    def delete(self, roleId, permissionId):
        path = "/api/roles/%s/permissions/%s" % (str(roleId), str(permissionId))
        return self.server.DELETE(path)[1]
