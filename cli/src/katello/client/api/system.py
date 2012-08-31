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

# pylint: disable=R0904
class SystemAPI(KatelloAPI):
    """
    Connection class to access environment calls
    """
    def register(self, name, org, environment_id, activation_keys, cp_type, release=None, sla=None, facts=None):
        if environment_id is not None:
            path = "/api/environments/%s/systems" % environment_id
        else:
            path = "/api/organizations/%s/systems" % org
        facts_with_defaults = { "distribution.name": "Unknown", "cpu.cpu_socket(s)": "1" }
        if facts is not None:
            facts_with_defaults.update(facts)
        sysdata = {
            "name": name,
            "cp_type": cp_type,
            "serviceLevel": sla,
            "facts": facts_with_defaults
        }
        if activation_keys:
            sysdata["activation_keys"] = activation_keys
        if release:
            sysdata["releaseVer"] = release

        return self.server.POST(path, sysdata)[1]

    def unregister(self, system_uuid):
        path = "/api/systems/" + u_str(system_uuid)
        return self.server.DELETE(path)[1]

    def subscribe(self, system_id, pool, quantity):
        path = "/api/systems/%s/subscriptions" % system_id
        data = {
            "pool": pool,
            "quantity": quantity
        }
        return self.server.POST(path, data)[1]

    def subscriptions(self, system_id):
        path = "/api/systems/%s/subscriptions" % system_id
        return self.server.GET(path)[1]

    def available_pools(self, system_id, match_system=False, match_installed=False, no_overlap=False):
        params = {}
        self.update_dict(params, "match_system", match_system)
        self.update_dict(params, "match_installed", match_installed)
        self.update_dict(params, "no_overlap", no_overlap)

        path = "/api/systems/%s/pools" % system_id

        return self.server.GET(path, params)[1]

    def unsubscribe(self, system_id, entitlement):
        path = "/api/systems/%s/subscriptions/%s" % (system_id, entitlement)
        return self.server.DELETE(path)[1]

    def unsubscribe_by_serial(self, system_id, serial):
        path = "/api/systems/%s/subscriptions/serials/%s" % (system_id, serial)
        return self.server.DELETE(path)[1]

    def unsubscribe_all(self, system_id):
        path = "/api/systems/%s/subscriptions/" % system_id
        return self.server.DELETE(path)[1]

    def system(self, system_id):
        path = "/api/systems/%s" % system_id
        return self.server.GET(path)[1]

    def tasks(self, org_name, environment_id, system_name = None, system_uuid = None):
        params = {}
        self.update_dict(params, "environment_id", environment_id)
        if system_name:
            self.update_dict(params, "system_name", system_name)
        if system_uuid:
            self.update_dict(params, "system_uuid", system_uuid)

        path = "/api/organizations/%s/systems/tasks" % org_name
        return self.server.GET(path, params)[1]

    def packages(self, system_id):
        path = "/api/systems/%s/packages" % system_id
        return self.server.GET(path)[1]

    def releases_for_system(self, system_id):
        path = "/api/systems/%s/releases" % system_id
        return self.server.GET(path)[1]

    def releases_for_environment(self, env_id):
        path = "/api/environments/%s/releases" % env_id
        return self.server.GET(path)[1]

    def update(self, system_id, params = None):
        path = "/api/systems/%s" % system_id
        return self.server.PUT(path, params)[1]

    def install_packages(self, system_id, packages):
        path = "/api/systems/%s/packages" % system_id
        return self.server.POST(path, {"packages": packages})[1]

    def remove_packages(self, system_id, packages):
        path = "/api/systems/%s/packages" % system_id
        return self.server.DELETE(path, {"packages": packages})[1]

    def update_packages(self, system_id, packages):
        path = "/api/systems/%s/packages" % system_id
        return self.server.PUT(path, {"packages": packages})[1]

    def install_package_groups(self, system_id, packages):
        path = "/api/systems/%s/packages" % system_id
        return self.server.POST(path, {"groups": packages})[1]

    def remove_package_groups(self, system_id, packages):
        path = "/api/systems/%s/packages" % system_id
        return self.server.DELETE(path, {"groups": packages})[1]

    def systems_by_org(self, orgId, query = None):
        path = "/api/organizations/%s/systems" % orgId
        return self.server.GET(path, query)[1]

    def systems_by_env(self, environment_id, query = None):
        path = "/api/environments/%s/systems" % environment_id
        return self.server.GET(path, query)[1]

    def errata(self, system_id):
        path = "/api/systems/%s/errata" % system_id
        return self.server.GET(path)[1]

    def report_by_org(self, orgId, format_in):
        path = "/api/organizations/%s/systems/report" % orgId
        to_return = self.server.GET(path, custom_headers={"Accept": format_in})
        return (to_return[1], to_return[2])

    def report_by_env(self, env_id, format_in):
        path = "/api/environments/%s/systems/report" % env_id
        to_return = self.server.GET(path, custom_headers={"Accept": format_in})
        return (to_return[1], to_return[2])

    def add_system_groups(self, system_id, system_group_ids):
        data = { 'system' : {
                    'system_group_ids' : system_group_ids
            }
        }
        path = "/api/systems/%s/system_groups/" % system_id
        return self.server.POST(path, data)[1]

    def remove_system_groups(self, system_id, system_group_ids):
        data = { 'system' : {
                    'system_group_ids' : system_group_ids
            }
        }
        path = "/api/systems/%s/system_groups/" % system_id
        return self.server.DELETE(path, data)[1]

    def remove_consumer_deletion_record(self, uuid):
        path = "/api/consumers/%s/deletionrecord" % uuid
        return self.server.DELETE(path)[1]
