# -*- coding: utf-8 -*-
#
# Copyright © 2012 Red Hat, Inc.
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
from katello.client.core.utils import update_dict_unless_none

class ContentViewAPI(KatelloAPI):
    """
    Connection class to access content_view calls
    """
    def content_views_by_org(self, org_id):
        path = "/api/organizations/%s/content_views" % org_id
        envs = self.server.GET(path)[1]
        return envs


    def content_view_by_org(self, org_id, env_id):
        path = "/api/organizations/%s/content_views/%s" % (org_id, env_id)
        env = self.server.GET(path)[1]
        return env


    def content_view_by_name(self, org_id, env_name):
        path = "/api/organizations/%s/content_views/" % (org_id)
        envs = self.server.GET(path, {"name": env_name})[1]
        if len(envs) > 0:
            return envs[0]
        else:
            return None

    def library_by_org(self, org_id):
        path = "/api/organizations/%s/content_views/" % (org_id)
        envs = self.server.GET(path, {"library": "true"})[1]
        if len(envs) > 0:
            return envs[0]
        else:
            return None


    def create(self, org_id, name, description, environment_id):
        envdata = {"name": name}
        envdata = update_dict_unless_none(envdata, "description", description)
        envdata = update_dict_unless_none(envdata, "environment", environment_id)

        path = "/api/organizations/%s/content_views/" % org_id
        return self.server.POST(path, {"content_view": envdata})[1]


    def update(self, org_id, cv_id, name, description):

        envdata = {}
        envdata = update_dict_unless_none(envdata, "name", name)
        envdata = update_dict_unless_none(envdata, "description", description)

        path = "/api/organizations/%s/content_views/%s" % (org_id, cv_id)
        return self.server.PUT(path, {"content_view": envdata})[1]


    def delete(self, org_id, cv_id):
        path = "/api/organizations/%s/content_views/%s" % (org_id, cv_id)
        return self.server.DELETE(path)[1]
