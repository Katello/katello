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

class FilterAPI(KatelloAPI):
    """
    Connection class to access Filter Data
    """
    def filters(self, org):
        path = "/api/organizations/%s/filters" % u_str(org)
        return self.server.GET(path)[1]

    def create(self, org, name, description, filter_list):
        data = {"name": name,
                   "description": description,
                   "package_list": filter_list}
        path = "/api/organizations/%s/filters" % u_str(org)
        return self.server.POST(path, data)[1]

    def delete(self, org, name):
        path = "/api/organizations/%s/filters/%s" % (u_str(org), u_str(name))
        return self.server.DELETE(path)[1]

    def info(self, org, name):
        path = "/api/organizations/%s/filters/%s" % (u_str(org), u_str(name))
        return self.server.GET(path)[1]

    def update_packages(self, org, name, package_list):
        path = "/api/organizations/%s/filters/%s" % (u_str(org), u_str(name))
        return self.server.PUT(path, {'packages': package_list})[1]
