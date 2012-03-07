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

class ProductAPI(KatelloAPI):
    """
    Connection class to access environment calls
    """
    def products_by_org(self, orgName, prodName=None):
        path = "/api/organizations/%s/products" % u_str(orgName)
        products = self.server.GET(path, {"name": prodName} if prodName != None else {})[1]
        return products

    def products_by_env(self, envId):
        path = "/api/environments/%s/products" % u_str(envId)
        products = self.server.GET(path)[1]
        return products

    def products_by_provider(self, provId, prodName=None):
        path = "/api/providers/%s/products/" % u_str(provId)
        products = self.server.GET(path, {"name": prodName} if prodName != None else {})[1]
        return products

    def product_by_name(self, orgName, prodName):
        path = "/api/organizations/%s/products" % u_str(orgName)
        products = self.server.GET(path, {"name": prodName})[1]
        if len(products) > 0:
            return products[0]
        else:
            return None

    def create(self, provId, name, description, gpgkey):
        product = {
            "name": name,
            "description": description,
            "gpg_key_name": gpgkey
        }

        path = "/api/providers/%s/product_create" % u_str(provId)
        result = self.server.POST(path, {"product": product})[1]
        return result

    def update(self, orgName, prodId, description, gpgkey, nogpgkey, gpgkey_recursive):
        product = {}
        self.update_dict(product, "description", description)
        self.update_dict(product, "gpg_key_name", gpgkey)
        self.update_dict(product, "recursive", gpgkey_recursive)
        if nogpgkey:
            product["gpg_key_name"] = ""

        path = "/api/organizations/%s/products/%s/" % (u_str(orgName), u_str(prodId))
        result = self.server.PUT(path, {"product": product})[1]
        return result


    def show(self, orgName, prodId):
        path = "/api/organizations/%s/products/%s/" % (u_str(orgName), u_str(prodId))
        return self.server.GET(path)[1]

    def delete(self, orgName, prodId):
        path = "/api/organizations/%s/products/%s/" % (u_str(orgName), u_str(prodId))
        return self.server.DELETE(path)[1]

    def sync(self, orgName, prodId):
        path = "/api/organizations/%s/products/%s/sync" % (u_str(orgName), u_str(prodId))
        return self.server.POST(path)[1]

    def set_sync_plan(self, orgName, prodId, planId):
        path = "/api/organizations/%s/products/%s/sync_plan" % (u_str(orgName), u_str(prodId))
        return self.server.POST(path, {"plan_id": planId})[1]

    def remove_sync_plan(self, orgName, prodId):
        path = "/api/organizations/%s/products/%s/sync_plan" % (u_str(orgName), u_str(prodId))
        return self.server.DELETE(path)[1]

    def cancel_sync(self, orgName, prodId):
        path = "/api/organizations/%s/products/%s/sync" % (u_str(orgName), u_str(prodId))
        return self.server.DELETE(path)[1]

    def last_sync_status(self, orgName, prodId):
        path = "/api/organizations/%s/products/%s/sync" % (u_str(orgName), u_str(prodId))
        data = self.server.GET(path)[1]
        return data

    def update_filters(self, orgName, prodId, filters):
        path = "/api/organizations/%s/products/%s/filters" % (u_str(orgName), u_str(prodId))
        data = self.server.PUT(path, {"filters": filters})[1]
        return data

    def filters(self, orgName, prodId):
        path = "/api/organizations/%s/products/%s/filters" % (u_str(orgName), u_str(prodId))
        data = self.server.GET(path)[1]
        return data
