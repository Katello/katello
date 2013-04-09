#
# Katello System actions
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
#

from katello.client import constants
from katello.client.api.custom_info import CustomInfoAPI
from katello.client.api.utils import get_system
from katello.client.lib.utils.data import test_record
from katello.client.core.system import SystemAction

class SystemCustomInfo(SystemAction):
    """ Base class for all *CustomInfo classes related to Systems with common code """

    def setup_parser(self, parser):
        super(SystemCustomInfo, self).setup_parser(parser)
        parser.add_option('--name', dest='name', help=_("System name (required)"))
        parser.add_option('--uuid', dest='uuid', help=constants.OPT_HELP_SYSTEM_UUID)
        parser.add_option('--keyname', dest='keyname', help=_("name to identify the custom info (required)"))

    def check_options(self, validator):
        validator.require('org')
        validator.require_at_least_one_of(('name', 'uuid'))
        validator.mutually_exclude('name', 'uuid')
        validator.mutually_exclude('environment', 'uuid')
        validator.require('keyname')


class AddSystemCustomInfo(SystemCustomInfo):
    description = _('add custom infomation to a system')

    def setup_parser(self, parser):
        super(AddSystemCustomInfo, self).setup_parser(parser)
        parser.add_option('--value', dest='value', help=_("the custom info"))

    def check_options(self, validator):
        super(AddSystemCustomInfo, self).check_options(validator)
        validator.require(('org', 'keyname'))

    def run(self):
        org_name = self.get_option('org')
        env_name = self.get_option("environment")
        sys_name = self.get_option('name')
        sys_uuid = self.get_option('uuid')
        keyname = self.get_option('keyname')
        value = self.get_option('value')

        system = get_system(org_name, sys_name, env_name, sys_uuid)

        custom_info_api = CustomInfoAPI()

        response = custom_info_api.add_custom_info("system", system['id'], keyname, value)

        ident = sys_uuid if sys_uuid else sys_name

        test_record(response,
            _("Successfully added Custom Information [ %(keyname)s : %(value)s ] to System [ %(ident)s ]") \
                % {'keyname':keyname, 'value':value, 'ident':ident},
            _("Could not add Custom Information [ %(keyname)s : %(value)s ] to System [ %(ident)s ]") \
                % {'keyname':keyname, 'value':value, 'ident':ident}
        )


class UpdateSystemCustomInfo(SystemCustomInfo):
    description = _("update custom info for a system")
    def setup_parser(self, parser):
        super(UpdateSystemCustomInfo, self).setup_parser(parser)
        parser.add_option('--value', dest='value', help=_("replacement value"))

    def check_options(self, validator):
        validator.require(('org', 'keyname', 'value'))
        validator.mutually_exclude('environment', 'uuid')

    def run(self):
        org_name = self.get_option('org')
        env_name = self.get_option('environment')
        sys_name = self.get_option('name')
        sys_uuid = self.get_option('uuid')
        keyname = self.get_option('keyname')
        new_value = self.get_option('value')

        system = get_system(org_name, sys_name, env_name, sys_uuid)

        custom_info_api = CustomInfoAPI()

        response = custom_info_api.update_custom_info("system", system['id'], keyname, new_value)

        ident = sys_uuid if sys_uuid else sys_name

        if response is not None:
            print _("Successfully updated Custom Information [ %(keyname)s ] for System [ %(ident)s ]") \
                % {'keyname':keyname, 'ident':ident}
        else:
            print _("Could not update Custom Information [ %(keyname)s ] for System [ %(ident)s ]") \
                % {'keyname':keyname, 'ident':ident}


class RemoveSystemCustomInfo(SystemCustomInfo):
    description = _("remove custom info from a system")

    def setup_parser(self, parser):
        super(RemoveSystemCustomInfo, self).setup_parser(parser)

    def run(self):
        org_name = self.get_option('org')
        env_name = self.get_option('environment')
        sys_name = self.get_option('name')
        sys_uuid = self.get_option('uuid')
        keyname = self.get_option('keyname')

        system = get_system(org_name, sys_name, env_name, sys_uuid)

        custom_info_api = CustomInfoAPI()

        response = custom_info_api.remove_custom_info("system", system['id'], keyname)

        ident = sys_uuid if sys_uuid else sys_name

        if response is not None:
            print _("Successfully removed Custom Information from System [ %s ]") % ident
        else:
            print _("Could not remove Custom Information from System [ %s ]") % ident
