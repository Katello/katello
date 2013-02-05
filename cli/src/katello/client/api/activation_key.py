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
from katello.client.lib.utils.data import update_dict_unless_none

class ActivationKeyAPI(KatelloAPI):

    def activation_keys_by_organization(self, orgId, keyName=None):
        path = "/api/organizations/%s/activation_keys/" % orgId
        return self.server.GET(path, {} if keyName == None else {"name": keyName})[1]

    def activation_keys_by_environment(self, envId):
        path = "/api/environments/%s/activation_keys/" % envId
        return self.server.GET(path)[1]

    def activation_key(self, orgId, keyId):
        path = "/api/organizations/%s/activation_keys/%s/" % (orgId, keyId)
        return self.server.GET(path)[1]

    def create(self, envId, name, description, usage_limit=-1, templateId=None, view_id=None):
        keyData = {
            "name": name,
            "description": description,
            "usage_limit": usage_limit
        }

        if templateId != None:
            keyData["system_template_id"] = templateId

        if view_id:
            keyData["content_view_id"] = view_id

        path = "/api/environments/%s/activation_keys/" % envId
        return self.server.POST(path, {'activation_key': keyData})[1]

    def update(self, orgId, keyId, environmentId, name, description, templateId, usage_limit, view_id):
        keyData = {}
        keyData = update_dict_unless_none(keyData, "environment_id", environmentId)
        keyData = update_dict_unless_none(keyData, "name", name)
        keyData = update_dict_unless_none(keyData, "description", description)
        keyData = update_dict_unless_none(keyData, "system_template_id", templateId)
        keyData = update_dict_unless_none(keyData, "usage_limit", usage_limit)
        keyData = update_dict_unless_none(keyData, "content_view_id", view_id)

        path = "/api/organizations/%s/activation_keys/%s/" % (orgId, keyId)

        return self.server.PUT(path, {'activation_key': keyData})[1]

    def add_pool(self, orgId, keyId, poolid):
        path = "/api/organizations/%s/activation_keys/%s/pools" % (orgId, keyId)
        attrs = { "poolid": poolid }
        return self.server.POST(path, attrs)[1]

    def remove_pool(self, orgId, keyId, poolid):
        path = "/api/organizations/%s/activation_keys/%s/pools/%s" % (orgId, keyId, poolid)
        return self.server.DELETE(path)[1]

    def delete(self, orgId, keyId):
        path = "/api/organizations/%s/activation_keys/%s/" % (orgId, keyId)
        return self.server.DELETE(path)[1]

    def add_system_group(self, org_name, activation_key_id, system_group_id):
        data = { 'activation_key' :
            { 'system_group_ids' : [system_group_id] }
        }
        path = "/api/organizations/%s/activation_keys/%s/system_groups/" % (org_name, activation_key_id)
        return self.server.POST(path, data)[1]

    def remove_system_group(self, org_name, activation_key_id, system_group_id):
        data = { 'activation_key' :
            { 'system_group_ids' : [system_group_id] }
        }
        path = "/api/organizations/%s/activation_keys/%s/system_groups/" % (org_name, activation_key_id)
        return self.server.DELETE(path, data)[1]
