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

class CustomInfoAPI(KatelloAPI):
    """
    Connection class to access custom info calls
    """
    def add_custom_info(self, informable_type, informable_id, keyname, value):
        data = { 'keyname': keyname, 'value': value }
        path = "/api/custom_info/%s/%s" % (informable_type, informable_id)
        return self.server.POST(path, data)[1]

    def get_custom_info(self, informable_type, informable_id, keyname = None):
        if keyname:
            path = "/api/custom_info/%s/%s/%s" % (informable_type, informable_id, keyname)
        else:
            path = "/api/custom_info/%s/%s" % (informable_type, informable_id)
        return self.server.GET(path)[1]

    def update_custom_info(self, informable_type, informable_id, keyname, new_value):
        data = { 'value': new_value }
        path = "/api/custom_info/%s/%s/%s" % (informable_type, informable_id, keyname)
        return self.server.PUT(path, data)[1]

    def remove_custom_info(self, informable_type, informable_id, keyname):
        path = "/api/custom_info/%s/%s/%s" % (informable_type, informable_id, keyname)
        return self.server.DELETE(path)[1]
