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
from katello.client.utils.encoding import u_str

class ContentViewDefinitionAPI(KatelloAPI):
    """
    Connection class to access content_view calls
    """
    def content_view_definitions_by_org(self, org_id):
        path = "/api/organizations/%s/content_view_definitions" % org_id
        defs = self.server.GET(path)[1]
        return defs

    def content_view_definition_by_label(self, org_id, label):
        path = "/api/organizations/%s/content_view_definitions/" % org_id
        defs = self.server.GET(path, {"label": label})[1]
        if len(defs) > 0:
            return defs[0]
        else:
            return None

    def show(self, org_id, cvd_id):
        path = "/api/organizations/%s/content_view_definitions/%s" % (org_id,
                cvd_id)
        cvd = self.server.GET(path)
        return cvd

    def create(self, org_id, name, label, description):
        cvd = {"label": label, "organization_id": org_id, "name": name}
        cvd = update_dict_unless_none(cvd, "description", description)

        path = "/api/organizations/%s/content_view_definitions/" % org_id
        params = {"content_view_definition": cvd}
        return self.server.POST(path, params)[1]


    def update(self, org, cvd_id, name, description):
        cvd = {"id": cvd_id}
        cvd = update_dict_unless_none(cvd, "name", name)
        cvd = update_dict_unless_none(cvd, "description", description)

        path = "/api/organizations/%s/content_view_definitions/%s" % \
                (org, cvd_id)
        return self.server.PUT(path, {"content_view_definition": cvd})[1]


    def delete(self, cvd_id):
        path = "/api/content_view_definitions/%s" % cvd_id
        return self.server.DELETE(path)[1]

    def publish(self, org_id, cvd_id):
        path = "/api/organizations/%s/content_view_definitions/%s/publish" % \
            (org_id, cvd_id)
        return self.server.GET(path)[1]

    def filters(self, org, cvd_id):
        path = "/api/organizations/%s/content_view_definitions/%s/filters" % \
                (u_str(org), u_str(cvd_id))
        data = self.server.GET(path)[1]
        return data

    def update_filters(self, org, cvd, filters):
        path = "/api/organizations/%s/content_view_definitions/%s/filters" % \
                (u_str(org), u_str(cvd))
        data = self.server.PUT(path, {"filters": filters})[1]
        return data

    def products(self, org, cvd_id):
        path = "/api/organizations/%s/content_view_definitions/%s/products" % \
                (u_str(org), u_str(cvd_id))
        data = self.server.GET(path)[1]
        return data

    def update_products(self, org, cvd, products):
        path = "/api/organizations/%s/content_view_definitions/%s/products" % \
                (u_str(org), u_str(cvd))
        data = self.server.PUT(path, {"products": products})[1]
        return data

    def repos(self, org, cvd_id):
        path = "/api/organizations/%s/content_view_definitions/%s/reposistories"\
                % (u_str(org), u_str(cvd_id))
        data = self.server.GET(path)[1]
        return data

    def update_repos(self, org, cvd, repos):
        path = "/api/organizations/%s/content_view_definitions/%s/repos" % \
                (u_str(org), u_str(cvd))
        data = self.server.PUT(path, {"repos": repos})[1]
        return data
