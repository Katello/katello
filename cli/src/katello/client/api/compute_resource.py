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

class ComputeResourceAPI(KatelloAPI):

    @classmethod
    def __path(cls, resource_id=None):
        if resource_id is None:
            return "/api/compute_resources/"
        else:
            return "/api/compute_resources/%s/" % str(resource_id)


    def index(self, queries=None):
        """
        :type queries: dict
        :param queries: queries for filtering compute resources
        """
        return self.server.GET(self.__path(), queries)[1]


    def show(self, resource_id):
        """
        :type resource_id: string
        :param resource_id: compute resource identifier
        """
        return self.server.GET(self.__path(resource_id))[1]


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
        return self.server.POST(self.__path(), {'compute_resource': data})[1]


    def update(self, resource_id, data):
        """
        :type resource_id: string
        :param resource_id: compute resource identifier

        :type data['name']: string

        :type data['provider']: string
        :param data['provider']: Provider type, one of: Libvirt Ovirt EC2 Vmware Openstack Rackspace

        :type data['url']: string
        :param data['url']: URL for Libvirt, Ovirt, and Openstack

        :type data['description']: string

        :type data['user']: string
        :param data['user']: Username for Ovirt, EC2, Vmware, Openstack. Access Key for EC2.

        :type data['password']: string
        :param data['password']: Password for Ovirt, EC2, Vmware, Openstack. Secret key for EC2

        :type data['uuid']: string
        :param data['uuid']: for Ovirt, Vmware Datacenter

        :type data['region']: string
        :param data['region']: for EC2 only

        :type data['tenant']: string
        :param data['tenant']: for Openstack only

        :type data['server']: string
        :param data['server']: for Vmware
        """
        data = slice_dict(data,
            'name',
            'url',
            'description',
            'user',
            'password',
            'uuid',
            'region',
            'tenant',
            'server'
        )
        return self.server.PUT(self.__path(resource_id), {'compute_resource': data})[1]


    def destroy(self, resource_id):
        """
        :type resource_id: string
        :param resource_id: resource identifier
        """
        return self.server.DELETE(self.__path(resource_id))[1]
