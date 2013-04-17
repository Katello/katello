# -*- coding: utf-8 -*-
#
# Copyright 2013 Red Hat, Inc.
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
from katello.client.lib.utils.encoding import u_str

# pylint: disable=R0904
class DistributorAPI(KatelloAPI):
    """
    Connection class to access environment calls
    """
    def create(self, name, org, environment_id, cp_type='candlepin'):
        if environment_id is not None:
            path = "/api/environments/%s/distributors" % environment_id
        else:
            path = "/api/organizations/%s/distributors" % org
        distdata = {
            "distributor": {
                "name": name,
                "cp_type": cp_type
            }
        }

        return self.server.POST(path, distdata)[1]

    def delete(self, distributor_uuid):
        path = "/api/distributors/" + u_str(distributor_uuid)
        return self.server.DELETE(path)[1]

    def export_manifest(self, distributor_uuid):
        path = "/api/distributors/%s/export" % distributor_uuid
        return self.server.GET(path)[1]

    def subscribe(self, distributor_id, pool, quantity):
        path = "/api/distributors/%s/subscriptions" % distributor_id
        data = {
            "pool": pool,
            "quantity": quantity
        }
        return self.server.POST(path, data)[1]

    def subscriptions(self, distributor_id):
        path = "/api/distributors/%s/subscriptions" % distributor_id
        return self.server.GET(path)[1]

    def available_pools(self, distributor_id):
        params = {}

        path = "/api/distributors/%s/pools" % distributor_id

        return self.server.GET(path, params)[1]

    def unsubscribe(self, distributor_id, entitlement):
        path = "/api/distributors/%s/subscriptions/%s" % (distributor_id, entitlement)
        return self.server.DELETE(path)[1]

    def unsubscribe_by_serial(self, distributor_id, serial):
        path = "/api/distributors/%s/subscriptions/serials/%s" % (distributor_id, serial)
        return self.server.DELETE(path)[1]

    def unsubscribe_all(self, distributor_id):
        path = "/api/distributors/%s/subscriptions/" % distributor_id
        return self.server.DELETE(path)[1]

    def distributor(self, distributor_id):
        path = "/api/distributors/%s" % distributor_id
        return self.server.GET(path)[1]

    def update(self, distributor_id, params = None):
        path = "/api/distributors/%s" % distributor_id
        params = { "distributor": params}
        return self.server.PUT(path, params)[1]

    def distributor_by_name(self, orgName, distName):
        path = "/api/organizations/%s/distributors/" % orgName
        distributors = self.server.GET(path, {"name": distName})[1]
        if len(distributors) > 0:
            return distributors[0]
        else:
            return None

    def distributors_by_org(self, orgId, query = None):
        path = "/api/organizations/%s/distributors" % orgId
        return self.server.GET(path, query)[1]

    def distributors_by_env(self, environment_id, query = None):
        path = "/api/environments/%s/distributors" % environment_id
        return self.server.GET(path, query)[1]
