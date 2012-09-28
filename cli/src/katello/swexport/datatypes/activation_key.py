#!/usr/bin/python
#
# This software is licensed to you under the GNU General Public License,
# version 2 (GPLv2). There is NO WARRANTY for this software, express or
# implied, including the implied warranties of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2
# along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

from katello.swexport.base_command import ExportBaseCommand, is_true
from katello.swexport.config import Config

class ActivationKey(ExportBaseCommand):

    def __init__(self):
        ExportBaseCommand.__init__(self, "activation_keys", "export activation keys")

        self.create_option('--include-disabled', 'set to true to include disabled fields', aliases=[],
            required=False, default=Config.values.activationkey.includedisabled)
        self.create_option('--default-environment', 'envrionment to assigne activation keys to', aliases=[],
            required=False, default=Config.values.activationkey.environment)

    def _add_data(self, key, data_list):
        data = {}
        key_name = key.get('key')
        usage_limit = key.get('usage_limit')
        if usage_limit == 0:
            usage_limit = -1

        data['name'] = key_name
        data['org_name'] = self._translate_org_name(key_name.partition('-')[0])
        data['description'] = key.get('description')
        data['usage_limit'] = usage_limit
        data['environment_name'] = self.options['default-environment']
        data['system_groups'] = self._get_groups(key.get('server_group_ids'))
        data_list.append(data)
        self._add_stat('actitvation keys exported')


    def _get_data(self):
        key_list = self.client.activationkey.listActivationKeys(self.key)
        data_list = []
        for key in key_list:
            if (key.get('disabled')):
                if is_true(self.options['include-disabled']):
                    self._add_data(key, data_list)
                else:
                    self._add_stat('disabled actitvation keys skipped')
            else:
                self._add_data(key, data_list)

        return data_list

    def _get_groups(self, id_list):
        groups = []
        for group_id in id_list:
            groups.append(self.client.systemgroup.getDetails(self.key, group_id).get('name'))

        return groups

    def _get_headers(self):
        return ["org_name", 'name', 'description', 'usage_limit', \
        'environment_name', 'system_groups']

    def _output_filename(self):
        return "activation_keys"




