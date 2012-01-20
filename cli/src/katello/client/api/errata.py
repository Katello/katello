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

class ErrataAPI(KatelloAPI):

    def errata_filter(self, repo_id=None, environment_id=None, prod_id=None, type=None, severity=None):
        path = "/api/errata"
        params = {}
        if not repo_id == None:
            params['repoid'] = repo_id
        if not environment_id == None:
            params['environment_id'] = environment_id
        if not prod_id == None:
            params['product_id'] = prod_id
        if not type == None:
            params['type'] = type
        if not severity == None:
            params['severity'] = severity
        pack = self.server.GET(path, params)[1]
        return pack

    """
    Connection class to access errata calls
    """
    def errata_by_repo(self, repoId, type=None):
        path = "/api/repositories/%s/errata" % repoId
        params = {}
        if not type == None:
            params['type'] = type
        pack = self.server.GET(path, params)[1]
        return pack

    def errata(self, errata_id, repoId):
        path = "/api/repositories/%s/errata/%s/" % (repoId, errata_id)
        pack = self.server.GET(path)[1]
        return pack
