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
        :param resource_id: compute resource identifier
        """
        path = "/api/compute_resources/%s/" % str(resource_id)
        return self.server.GET(path)[1]


    def create(self, data):
        """
        :type name: string

        :type provider: string
        :param provider: Provider type, one of: Libvirt Ovirt EC2 Vmware Openstack Rackspace

        :type url: string
        :param url: URL for Libvirt, Ovirt, and Openstack

        :type description: string

        :type user: string
        :param user: Username for Ovirt, EC2, Vmware, Openstack. Access Key for EC2.

        :type password: string
        :param password: Password for Ovirt, EC2, Vmware, Openstack. Secret key for EC2

        :type uuid: string
        :param uuid: for Ovirt, Vmware Datacenter

        :type region: string
        :param region: for EC2 only

        :type tenant: string
        :param tenant: for Openstack only

        :type server: string
        :param server: for Vmware
        """

        path = "/api/compute_resources/"
        data = slice_dict(data,
            'name',
            'provider',
            'url',
            'description',
            'user',
            'password',
            'uuid',
            'region',
            'tenant',
            'server'
        )
        return self.server.POST(path, {'compute_resource': data})[1]
