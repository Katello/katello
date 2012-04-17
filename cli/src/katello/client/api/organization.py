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

class OrganizationAPI(KatelloAPI):
    """
    Connection class to access Organization Data
    """
    def create(self, name, description):
        orgdata = {"name": name,
                   "description": description}
        path = "/api/organizations/"
        return self.server.POST(path, orgdata)[1]

    def delete(self, name):
        path = "/api/organizations/%s" % u_str(name)
        return self.server.DELETE(path)[1]

    def update(self, name, description):

        orgdata = {}
        orgdata = self.update_dict(orgdata, "description", description)

        path = "/api/organizations/%s" % u_str(name)
        return self.server.PUT(path, {"organization": orgdata})[1]

    def organizations(self):
        path = "/api/organizations/"
        orgs = self.server.GET(path)[1]
        return orgs

    def organization(self, name):
        path = "/api/organizations/%s" % u_str(name)
        org = self.server.GET(path)[1]
        return org

    def uebercert(self, name, regenerate=False):
        path = "/api/organizations/%s/uebercert" % u_str(name)
        return self.server.GET(path, {'regenerate':regenerate})[1]

    def pools(self, name):
        path = "/api/owners/%s/pools" % u_str(name)
        return self.server.GET(path)[1]
