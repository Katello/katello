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

class PackageAPI(KatelloAPI):
    """
    Connection class to access package calls
    """
    def package(self, packageId, repoId):
        path = "/api/repositories/%s/packages/%s" % (repoId, packageId)
        pack = self.server.GET(path)[1]
        return pack

    def packages_by_repo(self, repoId):
        path = "/api/repositories/%s/packages" % repoId
        pack_list = self.server.GET(path)[1]
        return pack_list

    def search(self, query, repoId):
        path = "/api/repositories/%s/packages/search" % repoId
        pack_list = self.server.GET(path, {"search": query})[1]
        return pack_list
