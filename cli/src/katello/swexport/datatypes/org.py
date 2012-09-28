#!/usr/bin/python
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

from katello.swexport.base_command import ExportBaseCommand

class Org(ExportBaseCommand):

    def __init__(self):
        ExportBaseCommand.__init__(self, "orgs", "export orgs")

    def _get_data(self):
        org_list = self.client.org.listOrgs(self.key)
        data_list = []
        for org in org_list:
            data = {}
            data['name'] = self._translate_org_name(org.get('id'))
            data['label'] = self._translate_org_label(org.get('id'))
            data['description'] = org.get('name')
            data_list.append(data)
            self._add_stat('orgs exported')
        return data_list

    def _get_headers(self):
        return ['name', 'label', 'description']

    def _output_filename(self):
        return "orgs"




