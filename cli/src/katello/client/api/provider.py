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
from katello.client.utils.encoding import u_str

class ProviderAPI(KatelloAPI):
    """
    Connection class to access provider specific calls
    """
    def create(self, name, orgName, description=None, pType=None, url=None):
        provdata = {
            "provider": {
                "name": name,
                "description": description,
                "provider_type": pType
            },
            "organization_id": orgName
        }
        provdata["provider"] = self.update_dict(provdata["provider"], "repository_url", url)

        path = "/api/providers/"
        return self.server.POST(path, provdata)[1]


    def delete(self, name):
        path = "/api/providers/%s" % u_str(name)
        return self.server.DELETE(path)[1]


    def update(self, provId, name, description=None, url=None):

        provdata = {}
        provdata = self.update_dict(provdata, "name", name)
        provdata = self.update_dict(provdata, "description", description)
        provdata = self.update_dict(provdata, "repository_url", url)

        path = "/api/providers/%s" % u_str(provId)
        return self.server.PUT(path, {"provider": provdata})[1]


    def providers_by_org(self, orgId):
        path = "/api/organizations/%s/providers/" % u_str(orgId)
        providers = self.server.GET(path)[1]
        return providers


    def provider(self, provId):
        path = "/api/providers/%s" % u_str(provId)
        provider = self.server.GET(path)[1]
        return provider


    def provider_by_name(self, orgName, provName):
        path = "/api/organizations/%s/providers/" % orgName
        providers = self.server.GET(path, {"name": provName})[1]
        if len(providers) > 0:
            return providers[0]
        else:
            return None


    def sync(self, provId):
        path = "/api/providers/%s/sync/" % u_str(provId)
        provider = self.server.POST(path)[1]
        return provider


    def cancel_sync(self, provId):
        path = "/api/providers/%s/sync/" % u_str(provId)
        provider = self.server.DELETE(path)[1]
        return provider


    def last_sync_status(self, provId):
        path = "/api/providers/%s/sync" % provId
        data = self.server.GET(path)[1]
        return data


    def import_manifest(self, provId, manifestFile, force=False):
        path = "/api/providers/%s/import_manifest" % u_str(provId)
        params = {"import": manifestFile}
        if force: params["force"] = "true"
        result = self.server.POST(path, params, multipart=True)[1]
        return result

    def refresh_products(self, provId):

        path = "/api/providers/%s/refresh_products" % u_str(provId)
        return self.server.POST(path, {})[1]
