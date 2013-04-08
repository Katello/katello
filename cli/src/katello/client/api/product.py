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

    def product_by_name_or_label_or_id(self, orgName, prodName, prodLabel, prodId):
        params = {}
        update_dict_unless_none(params, "name", prodName)
        update_dict_unless_none(params, "label", prodLabel)
        update_dict_unless_none(params, "cp_id", prodId)
        path = "/api/organizations/%s/products" % u_str(orgName)
        products = self.server.GET(path, params)[1]
        return products

    def create(self, provId, name, label, description, gpgkey):
        product = {
            "name": name,
            "label": label,
            "description": description,
            "gpg_key_name": gpgkey
        }

        path = "/api/providers/%s/product_create" % u_str(provId)
        result = self.server.POST(path, {"product": product})[1]
        return result

    def update(self, orgName, prodId, description, gpgkey, nogpgkey, gpgkey_recursive):
        product = {}
        update_dict_unless_none(product, "description", description)
        update_dict_unless_none(product, "gpg_key_name", gpgkey)
        update_dict_unless_none(product, "recursive", gpgkey_recursive)
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

    def repository_sets(self, orgName, prodId):
        path = "/api/organizations/%s/products/%s/repository_sets" % (u_str(orgName), u_str(prodId))
        return self.server.GET(path)[1]
  
    def enable_repository_set(self, orgName, prodId, repoSetId):
        path = "/api/organizations/%s/products/%s/repository_sets/%s/enable" % (u_str(orgName), 
                         u_str(prodId), u_str(repoSetId))
        return self.server.POST(path)[1]

    def disable_repository_set(self, orgName, prodId, repoSetId):
        path = "/api/organizations/%s/products/%s/repository_sets/%s/disable" % (u_str(orgName),
                         u_str(prodId), u_str(repoSetId))
        return self.server.POST(path)[1]
