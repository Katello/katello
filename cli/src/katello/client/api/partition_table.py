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

from urllib import quote

from katello.client.api.base import KatelloAPI
from katello.client.lib.utils.data import slice_dict


class PartitionTableAPI(KatelloAPI):

    @classmethod
    def __path(cls, table_id=None):
        if table_id is None:
            return "/api/partition_tables/"
        else:
            return "/api/partition_tables/%s/" % quote(str(table_id))


    def list(self, queries=None):
        """
        list partition table
        """
        return self.server.GET(self.__path(), queries)[1]


    def show(self, table_id):
        """
        show partition table

        :type  id: string
        :param id: partition table name
        """
        return self.server.GET(self.__path(table_id))[1]


    def create(self, data):
        """
        create partition table

        :type  data['name']: string
        :param data['name']:
        :type  data['layout']: string
        :param data['layout']:
        :type  data['os_family']: string
        :param data['os_family']:
        """
        data = slice_dict(data, 'name', 'layout', 'os_family')
        return self.server.POST(self.__path(), {"partition_table": data})[1]


    def update(self, table_id, data):
        """
        update partition table

        :type  id: string
        :param id: partition table name
        :type  data['name']: string
        :param data['name']:
        :type  data['layout']: string
        :param data['layout']:
        :type  data['os_family']: string
        :param data['os_family']:
        """
        data = slice_dict(data, 'name', 'layout', 'os_family')
        return self.server.PUT(self.__path(table_id), data)[1]


    def destroy(self, table_id):
        """
        destroy partition table

        :type  id: string
        :param id: partition table name
        """
        return self.server.DELETE(self.__path(table_id))[1]


