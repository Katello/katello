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
from katello.client.utils.encoding import u_str

class ChangesetAPI(KatelloAPI):

    def changesets(self, orgName, envId):
        path = "/api/organizations/%s/environments/%s/changesets/" % (orgName, envId)
        csets = self.server.GET(path)[1]
        return csets

    def changeset(self, csId):
        path = "/api/changesets/%s" % csId
        cset = self.server.GET(path)[1]
        return cset

    def changeset_by_name(self, orgName, envId, csName):
        path = "/api/organizations/%s/environments/%s/changesets/" % (orgName, envId)
        csets = self.server.GET(path, {"name": csName})[1]
        if len(csets) > 0:
            return self.changeset(csets[0]["id"])
        else:
            return None

    def create(self, orgName, envId, name, description=None):
        data = {
            "changeset": {
                "name": name,
                "description": description
            }
        }
        path = "/api/organizations/%s/environments/%s/changesets/" % (orgName, envId)
        return self.server.POST(path, data)[1]

    def update(self, csId, newName, description):
        data = {}
        data = self.update_dict(data, "name", newName)
        data = self.update_dict(data, "description", description)

        path = "/api/changesets/%s" % csId
        return self.server.PUT(path, {"changeset": data})[1]

    def delete(self, csId):
        path = "/api/changesets/%s" % (csId)
        return self.server.DELETE(path)[1]

    def dependencies(self, csId):
        path = "/api/changesets/%s/dependencies" % csId
        deps = self.server.GET(path)[1]
        return deps

    def promote(self, csId):
        path = "/api/changesets/%s/promote" % (csId)
        return self.server.POST(path)[1]

    def update_content(self, csId, patch):
        data = {
            'patch': patch
        }

        path = "/api/changesets/%s" % (csId)
        return self.server.PUT(path, data)[1]

    def add_content(self, csId, contentType, attrs):
        path = "/api/changesets/%s/%s/" % (u_str(csId), contentType)
        return self.server.POST(path, attrs)[1]

    def remove_content(self, csId, contentType, attrs):
        path = "/api/changesets/%s/%s/%s/" % (u_str(csId), contentType, u_str(attrs['content_id']))
        return self.server.DELETE(path, attrs)[1]
