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


class SmartProxyAPI(KatelloAPI):


    def list(self, queries=None):
        """
        list smart proxy

        :type  data['search']: string
        :param data['search']: Filter results

        :type  data['order']: string
        :param data['order']: Sort results
        """
        path = "/api/smart_proxies"
        queries = slice_dict(queries or {}, 'search', 'order')
        return self.server.GET(path, queries)[1]


    def show(self, proxy_id, queries=None):
        """
        show smart proxy

        :type  data['proxy_id']: string
        :param data['proxy_id']: domain name (no slashes)
        """
        path = "/api/smart_proxies/%s" % (proxy_id)
        queries = slice_dict(queries or {}, 'id')
        return self.server.GET(path, queries)[1]


    def create(self, data):
        """
        The fullname field is used for human readability in reports
        and other pages that refer to domains, and also available as
        an external node parameter

        :type  data['name']: string
        :param data['name']: The smart proxy name

        :type  data['url']: string
        :param data['url']: The smart proxy URL starting with 'http://' or 'https://'
        """
        path = "/api/smart_proxies"
        data = slice_dict(data, 'name', 'url')
        return self.server.POST(path, {"smart_proxy": data})[1]


    def update(self, proxy_id, data):
        """
        update smart proxy

        :type  data['proxy_id']: string
        :param data['proxy_id']: domain name (no slashes)

        :type  data['name']: string
        :param data['name']: The smart proxy name

        :type  data['url']: string
        :param data['url']: The smart proxy URL starting with 'http://' or 'https://'
        """
        path = "/api/smart_proxies/%s" % (proxy_id)
        data = slice_dict(data, 'name', 'url')
        return self.server.PUT(path, {"smart_proxy": data})[1]


    def destroy(self, proxy_id):
        """
        destroy smart proxy

        :type  data['proxy_id']: string
        :param data['proxy_id']: domain name (no slashes)
        """
        path = "/api/smart_proxies/%s" % (proxy_id)
        return self.server.DELETE(path)[1]


