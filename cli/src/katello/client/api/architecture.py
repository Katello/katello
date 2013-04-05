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
from katello.client.lib.utils.data import slice_dict

class ArchitectureAPI(KatelloAPI):

    def index(self, queries = None):
        """
        :type queries: dict
        :param queries: queries for filtering the architectures
        """
        path = "/api/architectures/"
        return self.server.GET(path, queries)[1]

    def show(self, arch_id):
        """
        :type arch_id: string
        :param arch_id: architecture identifier
        """
        path = "/api/architectures/%s/" % str(arch_id)
        return self.server.GET(path)[1]

    def create(self, data):
        """
        :type data['name']: string
        """
        path = "/api/architectures/"
        data = slice_dict(data, 'name')
        return self.server.POST(path, {'architecture': data})[1]

    def update(self, arch_id, data):
        """
        :type arch_id: string
        :param arch_id: architecture identifier
        :type data['name']: string
        """
        path = "/api/architectures/%s/" % str(arch_id)
        data = slice_dict(data, 'name')
        return self.server.PUT(path, {'architecture': data})[1]

    def destroy(self, arch_id):
        """
        :type arch_id: string
        :param arch_id: architecture identifier
        """
        path = "/api/architectures/%s/" % str(arch_id)
        return self.server.DELETE(path)[1]


