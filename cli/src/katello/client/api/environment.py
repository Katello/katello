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

class EnvironmentAPI(KatelloAPI):
    """
    Connection class to access environment calls
    """
    def environments_by_org(self, orgId):
        path = "/api/organizations/%s/environments" % orgId
        envs = self.server.GET(path)[1]
        return envs


    def environment_by_org(self, orgId, envId):
        path = "/api/organizations/%s/environments/%s" % (orgId, envId)
        env = self.server.GET(path)[1]
        return env


    def environment_by_name(self, orgId, envName):
        path = "/api/organizations/%s/environments/" % (orgId)
        envs = self.server.GET(path, {"name": envName})[1]
        if len(envs) > 0:
            return envs[0]
        else:
            return None

    def library_by_org(self, orgId):
        path = "/api/organizations/%s/environments/" % (orgId)
        envs = self.server.GET(path, {"library": "true"})[1]
        if len(envs) > 0:
            return envs[0]
        else:
            return None


    def create(self, orgId, name, description, priorId):
        envdata = {"name": name}
        envdata = self.update_dict(envdata, "description", description)
        envdata = self.update_dict(envdata, "prior", priorId)

        path = "/api/organizations/%s/environments/" % orgId
        return self.server.POST(path, {"environment": envdata})[1]


    def update(self, orgId, envId, name, description, priorId):

        envdata = {}
        envdata = self.update_dict(envdata, "name", name)
        envdata = self.update_dict(envdata, "description", description)
        envdata = self.update_dict(envdata, "prior", priorId)

        path = "/api/organizations/%s/environments/%s" % (orgId, envId)
        return self.server.PUT(path, {"environment": envdata})[1]


    def delete(self, orgId, envId):
        path = "/api/organizations/%s/environments/%s" % (orgId, envId)
        return self.server.DELETE(path)[1]
