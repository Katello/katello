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


class SystemGroupAPI(KatelloAPI):
    """
    Connection class to access environment calls
    """
    def system_groups(self, org_id, query={}):
        path = "/api/organizations/%s/system_groups" % org_id
        return self.server.GET(path, query)[1]

    def system_group(self, org_id, system_group_id, query={}):
        path = "/api/organizations/%s/system_groups/%s" % (org_id, system_group_id)
        return self.server.GET(path, query)[1]

    def system_group_history(self, org_id, system_group_id, job_id=None):
        if job_id == None:
            path = "/api/organizations/%s/system_groups/%s/history" % (org_id, system_group_id)
        else:
            path = "/api/organizations/%s/system_groups/%s/history/%s" % (org_id, system_group_id, job_id)

        return self.server.GET(path)[1]

    def system_group_by_name(self, org_id, system_group_name, query={}):
        path = "/api/organizations/%s/system_groups/" % org_id
        system_group = self.server.GET(path, {"name": system_group_name})[1]
        if len(system_group) > 0:
            return self.system_group(org_id, system_group[0]["id"])
        else:
            return None

    def system_group_systems(self, org_id, system_group_id, query={}):
        path = "/api/organizations/%s/system_groups/%s/systems" % (org_id, system_group_id)
        return self.server.GET(path, query)[1]

    def lock(self, org_id, system_group_id, query={}):
        path = "/api/organizations/%s/system_groups/%s/lock" % (org_id, system_group_id)
        return self.server.POST(path, query)[1]

    def unlock(self, org_id, system_group_id, query={}):
        path = "/api/organizations/%s/system_groups/%s/unlock" % (org_id, system_group_id)
        return self.server.POST(path, query)[1]

    def create(self, org_id, name, description, max_systems):
        data = {
            "system_group" : {
                "name": name,
                "description": description,
                "max_systems": max_systems
            }
        }

        path = "/api/organizations/%s/system_groups/" % (org_id)
        return self.server.POST(path, data)[1]

    def update(self, org_id, system_group_id, name, description, max_systems):
        data = {}
        data = self.update_dict(data, "name", name)
        data = self.update_dict(data, "description", description)
        data = self.update_dict(data, "max_systems", max_systems)
        data = { "system_group" : data }

        path = "/api/organizations/%s/system_groups/%s" % (org_id, system_group_id)
        return self.server.PUT(path, data)[1]

    def delete(self, org_id, system_group_id, delete_systems):
        if delete_systems:
            path = "/api/organizations/%s/system_groups/%s/destroy_systems" % (u_str(org_id), u_str(system_group_id))
        else:
            path = "/api/organizations/%s/system_groups/%s" % (u_str(org_id), u_str(system_group_id))

        return self.server.DELETE(path)[1]

    def add_systems(self, org_id, system_group_id, system_ids):
        data = {
            "system_group" : {
                "system_ids": system_ids,
            }
        }

        path = "/api/organizations/%s/system_groups/%s/add_systems" % (org_id, system_group_id)
        return self.server.POST(path, data)[1]

    def remove_systems(self, org_id, system_group_id, system_ids):
        data = {
            "system_group" : {
                "system_ids": system_ids,
            }
        }

        path = "/api/organizations/%s/system_groups/%s/remove_systems" % (org_id, system_group_id)
        return self.server.POST(path, data)[1]

    def install_packages(self, org_id, system_group_id, packages):
        path = "/api/organizations/%s/system_groups/%s/packages" % (org_id, system_group_id)
        return self.server.POST(path, {"packages": packages})[1]

    def update_packages(self, org_id, system_group_id, packages):
        path = "/api/organizations/%s/system_groups/%s/packages" % (org_id, system_group_id)
        return self.server.PUT(path, {"packages": packages})[1]

    def remove_packages(self, org_id, system_group_id, packages):
        path = "/api/organizations/%s/system_groups/%s/packages" % (org_id, system_group_id)
        return self.server.DELETE(path, {"packages": packages})[1]

    def install_package_groups(self, org_id, system_group_id, packages):
        path = "/api/organizations/%s/system_groups/%s/packages" % (org_id, system_group_id)
        return self.server.POST(path, {"groups": packages})[1]

    def update_package_groups(self, org_id, system_group_id, packages):
        path = "/api/organizations/%s/system_groups/%s/packages" % (org_id, system_group_id)
        return self.server.PUT(path, {"groups": packages})[1]

    def remove_package_groups(self, org_id, system_group_id, packages):
        path = "/api/organizations/%s/system_groups/%s/packages" % (org_id, system_group_id)
        return self.server.DELETE(path, {"groups": packages})[1]

    def errata(self, org_id, system_group_id, type=None):
        path = "/api/organizations/%s/system_groups/%s/errata" % (org_id, system_group_id)

        params = {}
        if type is not None:
            params['type'] = type

        return self.server.GET(path, params)[1]

    def install_errata(self, org_id, system_group_id, errata):
        path = "/api/organizations/%s/system_groups/%s/errata" % (org_id, system_group_id)
        return self.server.POST(path, {"errata_ids": errata})[1]
