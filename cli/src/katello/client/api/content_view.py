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
from katello.client.lib.utils.data import update_dict_unless_none

class ContentViewAPI(KatelloAPI):
    """
    Connection class to access content_view calls
    """
    def content_views_by_org(self, org_id, env=None):
        path = "/api/organizations/%s/content_views" % org_id
        params = {"environment_id": env["id"]} if env else {}
        views = self.server.GET(path, params)[1]
        return views

    def views_by_label_name_or_id(self, org_id, label=None, name=None, vid=None):
        params = {}
        update_dict_unless_none(params, "name", name)
        update_dict_unless_none(params, "label", label)
        update_dict_unless_none(params, "id", vid)
        path = "/api/organizations/%s/content_views" % org_id
        views = self.server.GET(path, params)[1]
        return views

    def show(self, org_name, view_id, environment_id=None):
        path = "/api/organizations/%s/content_views/%s" % (org_name, view_id)
        params = {"environment_id": environment_id}
        view = self.server.GET(path, params)[1]
        return view

    def content_view_by_label(self, org_id, view_label):
        path = "/api/organizations/%s/content_views/" % (org_id)
        views = self.server.GET(path, {"label": view_label})[1]
        if len(views) > 0:
            return views[0]
        else:
            return None

    def update(self, org_id, cv_id, label, description):
        view = {}
        view = update_dict_unless_none(view, "label", label)
        view = update_dict_unless_none(view, "description", description)

        path = "/api/organizations/%s/content_views/%s" % (org_id, cv_id)
        return self.server.PUT(path, {"content_view": view})[1]

    def delete(self, org_id, cv_id):
        path = "/api/organizations/%s/content_views/%s" % (org_id, cv_id)
        return self.server.DELETE(path)[1]

    def promote(self, cv_id, env_id):
        path = "/api/content_views/%s/promote" % cv_id
        params = {"environment_id": env_id}
        return self.server.POST(path, params)[1]

    def refresh(self, cv_id):
        path = "/api/content_views/%s/refresh" % cv_id
        return self.server.POST(path, {})[1]
