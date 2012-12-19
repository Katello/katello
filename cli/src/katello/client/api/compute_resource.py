# -*- coding: utf-8 -*-
#
# Copyright © 2013 Red Hat, Inc.
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
from katello.client.core.utils import slice_dict

class ComputeResourceAPI(KatelloAPI):

    def index(self, queries = None):
        """
        :type queries: dict
        :param queries: queries for filtering compute resources
        """
        path = "/api/compute_resources/"
        return self.server.GET(path, queries)[1]


    def show(self, resource_id):
        """
        :type resource_id: string
        :param resource_id: architecture identifier
        """
        path = "/api/compute_resources/%s/" % str(resource_id)
        return self.server.GET(path)[1]
