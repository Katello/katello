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

from katello.client.api.base import KatelloAPI

# pylint: disable=R0904
class RepoAPI(KatelloAPI):
    """
    Connection class to access repositories
    """
    def create(self, orgName, prod_id, name, url, gpgkey, nogpgkey):
        repodata = {
                    "organization_id": orgName,
                    "product_id": prod_id,
                    "name": name,
                    "url": url}
        self.update_dict(repodata, "gpg_key_name", gpgkey)
        if nogpgkey:
            repodata["gpg_key_name"] = ""

        path = "/api/repositories/"
        return self.server.POST(path, repodata)[1]

    def update(self, repo_id, gpgkey, nogpgkey):
        repodata = {}
        self.update_dict(repodata, "gpg_key_name", gpgkey)
        if nogpgkey:
            repodata["gpg_key_name"] = ""
        path = "/api/repositories/%s/" % repo_id
        return self.server.PUT(path, {"repository": repodata })[1]

    def repos_by_org_env(self, orgName, envId, includeDisabled=False):
        data = {
            "include_disabled": includeDisabled
        }
        path = "/api/organizations/%s/environments/%s/repositories" % (orgName, envId)
        result_list = self.server.GET(path, data)[1]
        return result_list

    def repos_by_env_product(self, envId, productId, name=None, includeDisabled=False):
        path = "/api/environments/%s/products/%s/repositories" % (envId, productId)

        search_params = {
            "include_disabled": includeDisabled
        }
        if name != None:
            search_params['name'] = name

        result_list = self.server.GET(path, search_params)[1]
        return result_list

    def repos_by_product(self, orgName, productId, includeDisabled=False):
        path = "/api/organizations/%s/products/%s/repositories" % (orgName, productId)
        data = {
            "include_disabled": includeDisabled
        }
        result_list = self.server.GET(path, data)[1]
        return result_list

    def repo(self, repo_id):
        path = "/api/repositories/%s/" % repo_id
        data = self.server.GET(path)[1]
        return data


    def enable(self, repo_id, enable=True):
        data = {"enable": enable}
        path = "/api/repositories/%s/enable/" % repo_id
        return self.server.POST(path, data)[1]

    def delete(self, repoId):
        path = "/api/repositories/%s/" % repoId
        return self.server.DELETE(path)[1]

    def sync(self, repo_id):
        path = "/api/repositories/%s/sync" % repo_id
        data = self.server.POST(path)[1]
        return data

    def cancel_sync(self, repo_id):
        path = "/api/repositories/%s/sync" % repo_id
        data = self.server.DELETE(path)[1]
        return data

    def last_sync_status(self, repo_id):
        path = "/api/repositories/%s/sync" % repo_id
        data = self.server.GET(path)[1]
        return data

    def repo_discovery(self, org_name, url, repotype):
        discoverydata = {"url": url, "type": repotype}
        path = "/api/organizations/%s/repositories/discovery" % org_name
        return self.server.POST(path, discoverydata)[1]

    def repo_discovery_status(self, discoveryTaskId):
        path = "/api/repositories/discovery/%s" % discoveryTaskId
        return self.server.GET(path)[1]

    def packagegroups(self, repoid):
        path = "/api/repositories/%s/package_groups" % repoid
        return self.server.GET(path)[1]

    def packagegroup_by_id(self, repoid, groupId):
        path = "/api/repositories/%s/package_groups/" % repoid
        groups = self.server.GET(path, {"group_id": groupId})[1]
        if len(groups) == 0:
            return None
        else:
            return groups[0]

    def packagegroupcategories(self, repoid):
        path = "/api/repositories/%s/package_group_categories/" % repoid
        return self.server.GET(path)[1]

    def packagegroupcategory_by_id(self, repoid, categoryId):
        path = "/api/repositories/%s/package_group_categories/" % repoid
        categories = self.server.GET(path, {"category_id": categoryId})[1]
        if len(categories) == 0:
            return None
        else:
            return categories[0]

    def update_filters(self, repo_id, filters):
        path = "/api/repositories/%s/filters" % repo_id
        return self.server.PUT(path, {"filters": filters})[1]

    def filters(self, repo_id, inherit=False):
        path = "/api/repositories/%s/filters" % repo_id
        return self.server.GET(path, {"inherit": inherit})[1]
