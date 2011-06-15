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
    def products_by_org(self, orgName):
        path = "/api/organizations/%s/products" % orgName
        products = self.server.GET(path)[1]
        return products

    def products_by_env(self, orgName, envName):
        path = "/api/organizations/%s/environments/%s/products" % (orgName, envName)
        products = self.server.GET(path)[1]
        return products

    def products_by_provider(self, provId):
        path = "/api/providers/%s/products/" % str(provId)
        products = self.server.GET(path)[1]
        return products

    def products(self):
        path = "/api/products"
        products = self.server.GET(path)[1]
        return products

    def product_by_name(self, orgName, prodName):
        path = "/api/organizations/%s/products" % orgName
        products = self.server.GET(path, {"name": prodName})[1]
        if len(products) > 0:
            return products[0]
        else:
            return None

    def create(self, provId, name, description, url):
        product = {
            "name": name,
            "description": description,
            "url": url
        }
      
        path = "/api/providers/%s/product_create" % str(provId)
        result = self.server.POST(path, {"product": product})[1]
        return result

    def sync(self, provId, prodName):
        pass
        #path = "/api/repositories/%s/sync" % id
        #data = self.server.POST(path)[1]
        #return data
        
        
        
        
        