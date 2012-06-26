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

class SystemGroupJobStatusAPI(KatelloAPI):

    def __init__(self, org_id, system_group_id):
        self.__org_id = org_id
        self.__system_group_id = system_group_id
        
    def status(self, jobId):
        path = "/api/organizations/%s/system_groups/%s/history" % (self.__org_id, self.__system_group_id)
        jobs = {"job_id" : jobId}
        return self.server.GET(path, jobs)[1]
