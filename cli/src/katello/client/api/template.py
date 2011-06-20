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
from pprint import pprint

class TemplateAPI(KatelloAPI): 

    def templates(self):
        path = "/api/templates/"
        tpls = self.server.GET(path)[1]
        return tpls
        
        
    def template(self, tplId):
        path = "/api/templates/%s" % str(tplId)
        tpl = self.server.GET(path)[1]
        return tpl
        
        
    def template_by_name(self, envId, tplName):
        path = "/api/templates/"
        tpls = self.server.GET(path, {"name": tplName, "environment_id": envId})[1]
        if len(tpls) > 0:
            #show provides more information than index
            return self.template(tpls[0]["id"])
        else:
            return None
        
        
    def import_tpl(self, envId, name, description, tplFile):
        tplData = {
            "template_file": tplFile, 
            "template": {
                "name": name,
                "description": description
            },
            "environment_id": envId
        }
        
        path = "/api/templates/import"
        return self.server.POST(path, tplData, multipart=True)[1]
        
        
    def create(self, envId, name, description):
        tplData = {
            "template": {
                "name": name,
                "description": description
            },
            "environment_id": envId
        }
        
        path = "/api/templates/"
        return self.server.POST(path, tplData)[1]
        
        
    def update(self, tplId, newName, description=None):

        tplData = {}
        tplData = self.update_dict(tplData, "name", newName)
        tplData = self.update_dict(tplData, "description", description)

        tplData = {
            "template": tplData
        }

        path = "/api/templates/%s" % str(tplId)
        return self.server.PUT(path, tplData)[1]


    def update_content(self, tplId, actionName, params):
        action = {
            'do': actionName
        }
        action.update(params)
    
        path = "/api/templates/%s/update_content" % str(tplId)
        return self.server.PUT(path, action)[1]
        
    def delete(self, id):
        path = "/api/templates/%s" % str(id)
        return self.server.DELETE(path)[1]
        