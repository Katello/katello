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

class SyncPlanAPI(KatelloAPI):
    """
    Connection class to access SyncPlans
    """
    def create(self, org_id, name, sync_date, interval, description):
        data = {
            "name": name,
            "description": description,
            "interval": interval,
            "organization_id": orgId
        }
        path = "/api/organizations/%s/sync_plans/" % str(org_id)
        return self.server.POST(path, data)[1]

    def sync_plans(self, org_id, query={}):
        path = "/api/organizations/%s/sync_plans/" % str(org_id)
        return self.server.GET(path, query)[1]

    def sync_plan(self, org_id, plan_id):
        path = "/api/organizations/%s/sync_plans/%s/" % (str(org_id), str(plan_id))
        return self.server.GET(path)[1]

    def sync_plan_by_name(self, org_id, name):
        plans = self.sync_plans(org_id, {"name": name})
        if len(plans) >= 1:
            return plans[0]
        else:
            return None

    def delete(self, org_id, plan_id):
        path = "/api/organizations/%s/sync_plans/%s" % (str(org_id), str(plan_id))
        return self.server.DELETE(path)[1]
