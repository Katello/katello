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


def slice(d, *key_list):
    return dict((k, d.get(k)) for k in key_list)

class ArchitectureAPI(KatelloAPI):


    def index(self, queries = None):
        """
        """
        path = "/api/architectures/"
        return self.server.GET(path, queries)[1]

    def show(self, id):
        """
        """
        path = "/api/architectures/%s/" % (id)
        return self.server.GET(path)[1]

    def create(self, data):
        """
        @type data['name']: string
        @param data['name']:
        """
        path = "/api/architectures/"
        data = slice(data, 'name')
        return self.server.POST(path, {'architecture': data})[1]

    def update(self, id, data):
        """
        @type data['name']: string
        @param data['name']:
        """
        path = "/api/architectures/%s/" % (id)
        data = slice(data, 'name')
        return self.server.PUT(path, {'architecture': data})[1]

    def destroy(self, id):
        """
        """
        path = "/api/architectures/%s/" % (id)
        return self.server.DELETE(path)[1]


