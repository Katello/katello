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
from pprint import pprint

class ProviderAPI(KatelloAPI):
    """
    Connection class to access repo specific calls
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
        path = "/api/providers/%s" % str(name)
        return self.server.DELETE(path)[1]


    def update(self, provId, name, description=None, url=None):

        provdata = {}
        provdata = self.update_dict(provdata, "name", name)
        provdata = self.update_dict(provdata, "description", description)
        provdata = self.update_dict(provdata, "repository_url", url)

        path = "/api/providers/%s" % str(provId)
        return self.server.PUT(path, {"provider": provdata})[1]


    def providers(self):
        path = "/api/providers/"
        providers = self.server.GET(path)[1]
        return providers


    def providers_by_org(self, orgId):
        path = "/api/organizations/%s/providers/" % str(orgId)
        providers = self.server.GET(path)[1]
        return providers


    def provider(self, provId):
        path = "/api/providers/%s" % str(provId)
        provider = self.server.GET(path)[1]
        return provider


    def provider_by_name(self, orgName, provName):
        path = "/api/organizations/%s/providers/" % str(orgName)
        providers = self.server.GET(path, {"name": provName})[1]
        if len(providers) > 0:
            return providers[0]
        else:
            return None


    def sync(self, provId):
        path = "/api/providers/%s/sync/" % str(provId)
        provider = self.server.POST(path)[1]
        return provider


    def import_manifest(self, provId, manifestFile):
        path = "/api/providers/%s/import_manifest" % str(provId)
        result = self.server.POST(path, {"import": manifestFile}, multipart=True)[1]
        return result
        
