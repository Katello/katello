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
from katello.client.lib.utils.data import update_dict_unless_none

class ContentViewDefinitionAPI(KatelloAPI):
    """
    Connection class to access content_view calls
    """
    def content_view_definitions_by_org(self, org_id):
        path = "/api/organizations/%s/content_view_definitions" % org_id
        defs = self.server.GET(path)[1]
        return defs

    def cvd_by_label_or_name_or_id(self, org_id, label=None, name=None,
                                   cvd_id=None):
        path = "/api/organizations/%s/content_view_definitions/" % org_id
        params = {}
        update_dict_unless_none(params, "name", name)
        update_dict_unless_none(params, "label", label)
        update_dict_unless_none(params, "id", cvd_id)
        defs = self.server.GET(path, params)[1]
        return defs

    def show(self, org_id, cvd_id):
        path = "/api/organizations/%s/content_view_definitions/%s" % (org_id,
                cvd_id)
        cvd = self.server.GET(path)
        return cvd

    def create(self, org_id, name, label, description, composite=False):
        cvd = {"label": label, "name": name}
        cvd = update_dict_unless_none(cvd, "description", description)
        if composite and composite != False:
            cvd["composite"] = True

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

    def publish(self, org_id, cvd_id, name, label=None, description=None):
        path = "/api/organizations/%s/content_view_definitions/%s/publish" % \
            (org_id, cvd_id)
        data = {"name":name}
        if label:
            data["label"] = label
        if description:
            data["description"] = description
        return self.server.POST(path, data)[1]

    def clone(self, org, cvd_id, name, label=None, description=None):
        cvd = dict(id=cvd_id)
        cvd = update_dict_unless_none(cvd, "name", name)
        cvd = update_dict_unless_none(cvd, "label", label)
        cvd = update_dict_unless_none(cvd, "description", description)

        path = "/api/organizations/%s/content_view_definitions/%s/clone" % \
            (org, cvd_id)
        return self.server.POST(path, dict(content_view_definition=cvd))[1]

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

    def all_products(self, org, cvd_id):
        path = "/api/organizations/%s/content_view_definitions/%s/products/all" % \
                (u_str(org), u_str(cvd_id))
        data = self.server.GET(path)[1]
        return data

    def repos(self, org, cvd_id):
        path = "/api/organizations/%s/content_view_definitions/%s/repositories"\
                % (u_str(org), u_str(cvd_id))
        data = self.server.GET(path)[1]
        return data

    def update_repos(self, org, cvd, repos):
        path = "/api/organizations/%s/content_view_definitions/%s/repositories" \
                % (u_str(org), u_str(cvd))
        data = self.server.PUT(path, {"repos": repos})[1]
        return data

    def content_views(self, cvd_id):
        path = "/api/content_view_definitions/%s/content_views" % cvd_id
        data = self.server.GET(path)[1]
        return data

    def update_content_views(self, cvd_id, views):
        path = "/api/content_view_definitions/%s/content_views" % cvd_id
        data = self.server.PUT(path, {"views": views})[1]
        return data
