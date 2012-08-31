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
from katello.client.core.utils import update_dict_unless_none

class GpgKeyAPI(KatelloAPI):

    def gpg_keys_by_organization(self, orgId, keyName=None):
        path = "/api/organizations/%s/gpg_keys/" % orgId
        return self.server.GET(path, {} if keyName == None else {"name": keyName})[1]

    def gpg_key(self, keyId):
        path = "/api/gpg_keys/%s/" % keyId
        return self.server.GET(path)[1]

    def create(self, orgName, name, content):
        keyData = {
            "name": name,
            "content": content
        }

        path = "/api/organizations/%s/gpg_keys" % orgName
        return self.server.POST(path, {'gpg_key': keyData})[1]

    def update(self, keyId, name, content):
        keyData = {}
        keyData = update_dict_unless_none(keyData, "name", name)
        keyData = update_dict_unless_none(keyData, "content", content)

        path = "/api/gpg_keys/%s/" % keyId
        return self.server.PUT(path, {'gpg_key': keyData})[1]

    def delete(self, keyId):
        path = "/api/gpg_keys/%s/" % keyId
        return self.server.DELETE(path)[1]
