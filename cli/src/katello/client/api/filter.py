# -*- coding: utf-8 -*-
#
# Copyright © 2013 Red Hat, Inc.
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

class FilterAPI(KatelloAPI):
    """
    Connection class to access content view filter calls
    """
    def filters_by_cvd_and_org(self, definition, org_id):
        path = "/api/organizations/%(org_id)s/content_view_definitions/%(definition)s/filters" % \
                                            dict(definition = u_str(definition), org_id = u_str(org_id))
        defs = self.server.GET(path)[1]
        return defs

    def get_filter_info(self, filter_name, definition, org_id):
        path = "/api/organizations/%(org_id)s/content_view_definitions/%(definition)s/filters/%(filter_name)s" % \
                                        dict(definition = u_str(definition), org_id = u_str(org_id), 
                                                filter_name = u_str(filter_name))
        filter_def = self.server.GET(path)[1]
        return filter_def

    def create(self, filter_name, definition, org_id):
        path = "/api/organizations/%(org_id)s/content_view_definitions/%(definition)s/filters" % \
                                        dict(definition = u_str(definition), org_id = u_str(org_id))
        params = {"filter": filter_name}
        return self.server.POST(path, params)[1]

    def delete(self, filter_name, definition, org_id):
        path = "/api/organizations/%(org_id)s/content_view_definitions/%(definition)s/filters/%(filter_name)s" % \
                                      dict(definition = u_str(definition), org_id = u_str(org_id), 
                                        filter_name = u_str(filter_name))
        return self.server.DELETE(path)[1]


    def products(self, filter_name, definition, org_id):
        path = "/api/organizations/%(org_id)s/content_view_definitions/" + \
                                        "%(definition)s/filters/%(filter_name)s/products"
        path = path % dict(org_id = u_str(org_id), definition = u_str(definition),
                             filter_name = u_str(filter_name))
        data = self.server.GET(path)[1]
        return data

    def update_products(self, filter_name, definition, org_id, products):
        path = "/api/organizations/%(org_id)s/content_view_definitions/" + \
                                        "%(definition)s/filters/%(filter_name)s/products"
        path = path % dict(org_id = u_str(org_id), definition = u_str(definition),
                         filter_name = u_str(filter_name))

        data = self.server.PUT(path, {"products": products})[1]
        return data

    def repos(self, filter_name, definition, org_id):
        path = "/api/organizations/%s/content_view_definitions/%s/filters/%s/repositories"\
                % (u_str(org_id), u_str(definition), u_str(filter_name))
        data = self.server.GET(path)[1]
        return data

    def update_repos(self, filter_name, definition, org_id, repos):
        path = "/api/organizations/%s/content_view_definitions/%s/filters/%s/repositories" \
                % (u_str(org_id), u_str(definition), u_str(filter_name))
        data = self.server.PUT(path, {"repos": repos})[1]
        return data