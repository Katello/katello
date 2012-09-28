#!/usr/bin/python
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

from katello.swexport.base_command import ExportBaseCommand

class SystemGroup(ExportBaseCommand):

    def __init__(self):
        ExportBaseCommand.__init__(self, "system_groups", "export system groups")
        self.create_option('--org-id',
            'If provided, only filter out those groups which match the org id',
            aliases=['-o'],
            required=False)

    def _get_data(self):
        group_list = self.client.systemgroup.listAllGroups(self.key)
        data_list = []
        for group in group_list:
            filter_org = self.options['org-id']
            if filter_org:
                if (filter_org == group.get('org_id')):
                    self._add_group(group, data_list)
                else:
                    self._add_note("Skipping group %s" % group.get('name'))
                    self._add_stat('groups skipped')
            else:
                self._add_group(group, data_list)

        return data_list

    def _add_group(self, group, data_list):
        data = {}
        data['name'] = group.get('name')
        data['description'] = group.get('description')
        data['org_name'] = self._translate_org_name(group.get('org_id'))
        data['max_systems'] = '-1'
        data_list.append(data)
        self._add_stat('groups exported')


    def _get_headers(self):
        return ['name', 'description', 'org_name', 'max_systems']

    def _output_filename(self):
        return "system_groups"




