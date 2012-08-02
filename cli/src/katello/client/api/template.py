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
from katello.client.utils.encoding import u_str

try:
    import json
except ImportError:
    import simplejson as json

class TemplateAPI(KatelloAPI):
    format_content_type = {'json': 'application/json', 'tdl':'application/tdl-xml'}

    def templates(self, envId):
        path = "/api/environments/%s/templates/" % u_str(envId)
        tpls = self.server.GET(path)[1]
        return tpls


    def template(self, tplId):
        path = "/api/templates/%s" % u_str(tplId)
        tpl = self.server.GET(path)[1]
        return tpl


    def template_by_name(self, envId, tplName):
        path = "/api/environments/%s/templates/" % u_str(envId)
        tpls = self.server.GET(path, {"name": tplName})[1]
        if len(tpls) > 0:
            #show provides more information than index
            return self.template(tpls[0]["id"])
        else:
            return None


    def import_tpl(self, envId, description, tplFile):
        tplData = {
            "template_file": tplFile,
            "template": {
                "description": description
            },
            "environment_id": envId
        }

        path = "/api/templates/import"
        return self.server.POST(path, tplData, multipart=True)[1]

    def validate_tpl(self, tplId, format):
        custom_headers = {'Accept': TemplateAPI.format_content_type[format]}
        path = "/api/templates/%s/validate" % tplId
        response = self.server.GET(path, custom_headers=custom_headers)[1]
        return response

    def export_tpl(self, tplId, format):
        custom_headers = {'Accept': TemplateAPI.format_content_type[format]}
        path = "/api/templates/%s/export" % tplId
        response = self.server.GET(path, custom_headers=custom_headers)[1]
        if isinstance(response, dict):
            response = json.dumps(response)
        return response

    def create(self, envId, name, description, parentId):
        tplData = {
            "name": name,
            "description": description
        }
        tplData = self.update_dict(tplData, "parent_id", parentId)
        tplData = {
            "template": tplData,
            "environment_id": envId
        }

        path = "/api/templates/"
        return self.server.POST(path, tplData)[1]


    def update(self, tplId, newName, description, parentId):

        tplData = {}
        tplData = self.update_dict(tplData, "name", newName)
        tplData = self.update_dict(tplData, "description", description)
        tplData = self.update_dict(tplData, "parent_id", parentId)

        tplData = {
            "template": tplData
        }

        path = "/api/templates/%s" % u_str(tplId)
        return self.server.PUT(path, tplData)[1]


    def add_content(self, tplId, contentType, attrs):
        path = "/api/templates/%s/%s/" % (u_str(tplId), contentType)
        return self.server.POST(path, attrs)[1]

    def remove_content(self, tplId, contentType, contentId):
        path = "/api/templates/%s/%s/%s/" % (u_str(tplId), contentType, u_str(contentId))
        return self.server.DELETE(path)[1]

    def promotion_status(self, task_id):
        path = "/api/tasks/%s" % u_str(task_id)
        return self.server.GET(path)[1]

    def delete(self, template_id):
        path = "/api/templates/%s" % u_str(template_id)
        return self.server.DELETE(path)[1]
