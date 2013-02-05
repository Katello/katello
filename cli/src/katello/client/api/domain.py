#
# Copyright (c) 2012 Red Hat, Inc.
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

class DomainAPI(KatelloAPI):


    def list(self, queries):
        """
        list domain

        :type  queries['search']: string
        :param queries['search']: Filter results

        :type  queries['order']: string
        :param queries['order']: Sort results
        """
        path = "/api/domains"
        queries = slice_dict(queries, 'search', 'order', allow_none=False)
        return self.server.GET(path, queries)[1]


    def show(self, domain_id):
        """
        show domain

        :type domain_id: string
        """
        path = "/api/domains/%s" % str(domain_id)
        return self.server.GET(path)[1]


    def create(self, data):
        """
        The fullname< field is used for human readability in reports
        and other pages that refer to domains, and also available
        as an external node parameter


        :type  data['name']: string
        :param data['name']: The full DNS Domain name

        :type  data['fullname']: string
        :param data['fullname']: Full name describing the domain

        :type  data['dns_id']: string
        :param data['dns_id']: DNS Proxy to use within this domain

        :type  data['domain_parameters_attributes']: string
        :param data['domain_parameters_attributes']: Array of parameters (name, value)
        """
        path = "/api/domains"
        data = slice_dict(data, 'name', 'fullname', 'dns_id')
        return self.server.POST(path, {"domain": data})[1]


    def update(self, domain_id, data):
        """
        update domain

        :type  domain_id: string

        :type  data['name']: string
        :param data['name']: The full DNS Domain name

        :type  data['fullname']: string
        :param data['fullname']: Full name describing the domain

        :type  data['dns_id']: string
        :param data['dns_id']: DNS Proxy to use within this domain

        :type  data['domain_parameters_attributes']: string
        :param data['domain_parameters_attributes']: Array of parameters (name, value)
        """
        path = "/api/domains/%s" % str(domain_id)
        data = slice_dict(data, 'name', 'fullname', 'dns_id')
        return self.server.PUT(path, {"domain": data})[1]


    def destroy(self, domain_id):
        """
        destroy domain
        """
        path = "/api/domains/%s" % (domain_id)
        return self.server.DELETE(path)[1]
