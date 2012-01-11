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

class ProductAPI(KatelloAPI):
    """
    Connection class to access environment calls
    """
    def products_by_org(self, orgName, prodName=None):
        path = "/api/organizations/%s/products" % orgName
        products = self.server.GET(path, {"name": prodName} if prodName != None else {})[1]
        return products

    def products_by_env(self, envId):
        path = "/api/environments/%s/products" % envId
        products = self.server.GET(path)[1]
        return products

    def products_by_provider(self, provId, prodName=None):
        path = "/api/providers/%s/products/" % str(provId)
        products = self.server.GET(path, {"name": prodName} if prodName != None else {})[1]
        return products

    def product_by_name(self, orgName, prodName):
        path = "/api/organizations/%s/products" % orgName
        products = self.server.GET(path, {"name": prodName})[1]
        if len(products) > 0:
            return products[0]
        else:
            return None

    def create(self, provId, name, description):
        product = {
            "name": name,
            "description": description
        }

        path = "/api/providers/%s/product_create" % str(provId)
        result = self.server.POST(path, {"product": product})[1]
        return result

    def show(self, prodId):
        path = "/api/products/%s/" % prodId
        return self.server.GET(path)[1]

    def delete(self, prodId):
        path = "/api/products/%s/" % prodId
        return self.server.DELETE(path)[1]

    def sync(self, prodId):
        path = "/api/products/%s/sync" % prodId
        return self.server.POST(path)[1]

    def set_sync_plan(self, prodId, planId):
        return "Sync plan added"

    def remove_sync_plan(self, prodId, planId):
        return "Sync plan removed"

    def cancel_sync(self, prodId):
        path = "/api/products/%s/sync" % prodId
        return self.server.DELETE(path)[1]

    def last_sync_status(self, prodId):
        path = "/api/products/%s/sync" % prodId
        data = self.server.GET(path)[1]
        return data

    def update_filters(self, prodId, filters):
        path = "/api/products/%s/filters" % prodId
        data = self.server.PUT(path, {"filters": filters})[1]
        return data

    def filters(self, prodId):
        path = "/api/products/%s/filters" % prodId
        data = self.server.GET(path)[1]
        return data
