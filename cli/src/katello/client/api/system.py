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
from katello.client.api.utils import get_environment

class SystemAPI(KatelloAPI):
    """
    Connection class to access environment calls
    """
    def register(self, name, org, envName, cp_type):
        if envName is not None:
            environment = get_environment(org, envName)
            if environment is None:
                return None

            path = "/api/environments/%s/systems" % environment["id"]
        else:
            path = "/api/organizations/%s/systems" % org

        return self.server.POST(path, {
          "name": name,
          "cp_type": cp_type,
          "facts": {
            "distribution.name": "Fedora"
            }
          })[1]
    def unregister(self, system_id):
        path = "/api/systems/" + str(system_id)
        return self.server.DELETE(path)[1]

    def system(self, system_id):
        path = "/api/systems/%s" % system_id
        return self.server.GET(path)[1]

    def systems_by_org(self, orgId, query = {}):
        path = "/api/organizations/%s/systems" % orgId
        return self.server.GET(path, query)[1]

    def systems_by_env(self, orgId, envName, query = {}):
        environment = get_environment(orgId, envName)
        if environment is None:
            return None

        path = "/api/environments/%s/systems" % environment["id"]
        return self.server.GET(path, query)[1]
