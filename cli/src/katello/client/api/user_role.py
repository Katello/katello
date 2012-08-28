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

class UserRoleAPI(KatelloAPI):
    """
    Connection class to access User Data
    """
    def create(self, name, description):
        data = {
            "name": name,
            "description": description
        }
        path = "/api/roles/"
        return self.server.POST(path, {"role": data})[1]

    def roles(self, query=None):
        path = "/api/roles/"
        return self.server.GET(path, query)[1]

    def role(self, role_id):
        path = "/api/roles/%s" % u_str(role_id)
        return self.server.GET(path)[1]

    def role_by_name(self, name):
        roles = self.roles({"name": name})
        if len(roles) >= 1:
            return roles[0]
        else:
            return None

    def delete(self, role_id):
        path = "/api/roles/%s" % u_str(role_id)
        return self.server.DELETE(path)[1]

    def update(self, role_id, name, desc):
        data = {}
        data = self.update_dict(data, "name", name)
        data = self.update_dict(data, "description", desc)
        path = "/api/roles/%s" % u_str(role_id)
        return self.server.PUT(path, {"role": data})[1]

    def available_verbs(self, orgName):
        data = {}
        data = self.update_dict(data, "organization_id", orgName)
        path = "/api/roles/available_verbs/"
        return self.server.GET(path, data)[1]

    def add_ldap_group(self, role_id, group_name):
        data = {}
        data = self.update_dict(data, "name", group_name)
        path = "/api/roles/%s/ldap_groups/" % u_str(role_id)
        return self.server.POST(path, data)[1]

    def remove_ldap_group(self, role_id, group_name):
        data = {}
        path = "/api/roles/%s/ldap_groups/%s" % (u_str(role_id), u_str(group_name))
        return self.server.DELETE(path, data)[1]

    def ldap_groups(self, role_id):
        path = "/api/roles/%s/ldap_groups/" % u_str(role_id)
        return self.server.GET(path)[1]
