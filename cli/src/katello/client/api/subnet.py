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


class SubnetAPI(KatelloAPI):


    def get(self, subnet_id):
        """
        Get a subnet

        :type  subnet_id: string
        :param subnet_id: <p>Subnet numeric identifier</p>
        """
        path = "/api/subnets/%s/" % str(subnet_id)
        return self.server.GET(path)[1]


    def list(self, queries=None):
        """
        List subnets

        :type  data['search']: string
        :param data['search']: <p>Filter results</p>

        :type  data['order']: string
        :param data['order']: <p>Sort results</p>
        """
        path = "/api/subnets"
        if queries:
            queries = slice_dict(queries, 'search', 'order')
        return self.server.GET(path, queries)[1]


    def create(self, data):
        """
        Create a subnet

        :type  data['name']: string
        :param data['name']: <p>Subnet name</p>

        :type  data['network']: string
        :param data['network']: <p>Subnet network</p>

        :type  data['mask']: string
        :param data['mask']: <p>Netmask for this subnet</p>

        :type  data['gateway']: string
        :param data['gateway']: <p>Primary DNS for this subnet</p>

        :type  data['dns_primary']: string
        :param data['dns_primary']: <p>Primary DNS for this subnet</p>

        :type  data['dns_secondary']: string
        :param data['dns_secondary']: <p>Secondary DNS for this subnet</p>

        :type  data['from']: string
        :param data['from']: <p>Starting IP Address for IP auto suggestion</p>

        :type  data['to']: string
        :param data['to']: <p>Ending IP Address for IP auto suggestion</p>

        :type  data['vlanid']: string
        :param data['vlanid']: <p>VLAN ID for this subnet</p>

        :type  data['domain_ids']: string
        :param data['domain_ids']: <p>Domains in which this subnet is part</p>

        :type  data['dhcp_id']: string
        :param data['dhcp_id']: <p>DHCP Proxy to use within this subnet</p>

        :type  data['tftp_id']: string
        :param data['tftp_id']: <p>TFTP Proxy to use within this subnet</p>

        :type  data['dns_id']: string
        :param data['dns_id']: <p>DNS Proxy to use within this subnet</p>
        """
        path = "/api/subnets"
        data = slice_dict(data, \
            'name', 'network', 'mask', 'gateway', 'dns_primary', \
            'dns_secondary', 'from', 'to', 'vlanid', 'domain_ids', \
            'dhcp_id', 'tftp_id', 'dns_id')
        return self.server.POST(path, {"subnet": data})[1]


    def update(self, subnet_id, data):
        """
        Update a subnet

        :type  subnet_id: string
        :param subnet_id: <p>Subnet numeric identifier</p>

        :type  data['name']: string
        :param data['name']: <p>Subnet name</p>

        :type  data['network']: string
        :param data['network']: <p>Subnet network</p>

        :type  data['mask']: string
        :param data['mask']: <p>Netmask for this subnet</p>

        :type  data['gateway']: string
        :param data['gateway']: <p>Primary DNS for this subnet</p>

        :type  data['dns_primary']: string
        :param data['dns_primary']: <p>Primary DNS for this subnet</p>

        :type  data['dns_secondary']: string
        :param data['dns_secondary']: <p>Secondary DNS for this subnet</p>

        :type  data['from']: string
        :param data['from']: <p>Starting IP Address for IP auto suggestion</p>

        :type  data['to']: string
        :param data['to']: <p>Ending IP Address for IP auto suggestion</p>

        :type  data['vlanid']: string
        :param data['vlanid']: <p>VLAN ID for this subnet</p>

        :type  data['domain_ids']: string
        :param data['domain_ids']: <p>Domains in which this subnet is part</p>

        :type  data['dhcp_id']: string
        :param data['dhcp_id']: <p>DHCP Proxy to use within this subnet</p>

        :type  data['tftp_id']: string
        :param data['tftp_id']: <p>TFTP Proxy to use within this subnet</p>

        :type  data['dns_id']: string
        :param data['dns_id']: <p>DNS Proxy to use within this subnet</p>
        """
        path = "/api/subnets/%s" % (subnet_id)
        data = slice_dict(data, \
            'name', 'network', 'mask', 'gateway', 'dns_primary', \
            'dns_secondary', 'from', 'to', 'vlanid', 'domain_ids', \
            'dhcp_id', 'tftp_id', 'dns_id')
        return self.server.PUT(path, {"subnet": data})[1]


    def destroy(self, subnet_id):
        """
        Destroy a subnet

        :type  subnet_id: string
        :param subnet_id: <p>Subnet numeric identifier</p>
        """
        path = "/api/subnets/%s" % (subnet_id)
        return self.server.DELETE(path)[1]


