#
# Katello System actions
# Copyright (c) 2012 Red Hat, Inc.
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

from katello.client.core.system import SystemAction

class BaseCustomInfo(SystemAction):
    """ Base class for all *CustomInfo classes with common code """

    def setup_parser(self, parser):
        super(BaseCustomInfo, self).setup_parser(parser)
        parser.add_option('--name', dest='name', help=_("System name (required)"))
        parser.add_option('--uuid', dest='uuid', help=constants.OPT_HELP_SYSTEM_UUID)
        parser.add_option('--keyname', dest='keyname', help=_("name to identify the custom info (required)"))

    def check_options(self, validator):
        validator.require('org')
        validator.require_at_least_one_of(('name', 'uuid'))
        validator.mutually_exclude('name', 'uuid')
        validator.mutually_exclude('environment', 'uuid')

class AddCustomInfo(SystemAction):
    description = _('add custom infomation to a system')

    def setup_parser(self, parser):
        super(AddCustomInfo, self).setup_parser(parser)
        parser.add_option('--value', dest='value', help=_("the custom info (required)"))

    def check_options(self, validator):
        super(AddCustomInfo, self).check_options(validator)
        validator.require(('org', 'keyname', 'value'))

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

        if response[keyname][0] == value:
            print _("Successfully added Custom Information [ %s : %s ] to System [ %s ]") % (keyname, value, ident)
        else:
            print _("Could not add Custom Information [ %s : %s ] to System [ %s ]") % (keyname, value, ident)

class ViewCustomInfo(SystemAction):

    description = _('view custom info attached to a system')

    def run(self):
        org_name = self.get_option('org')
        env_name = self.get_option('environment')
        sys_name = self.get_option('name')
        sys_uuid = self.get_option('uuid')
        keyname = self.get_option('keyname')

        system = get_system(org_name, sys_name, env_name, sys_uuid)

        custom_info_api = CustomInfoAPI()

        custom_info = custom_info_api.get_custom_info("system", system['id'], keyname)

        for k in sorted(custom_info.keys()):
            self.printer.add_column(k, k)

        if sys_uuid:
            self.printer.set_header(_("Custom Information For System [ %s ]") % sys_uuid)
        elif env_name is None:
            self.printer.set_header(_("Custom Information For System [ %s ] in Org [ %s ]") % (sys_name, org_name))
        else:
            self.printer.set_header(_("Custom Information For System [ %s ] in Environment [ %s ] in Org [ %s ]") % \
                (sys_name, env_name, org_name))
        self.printer.print_item(custom_info)


class UpdateCustomInfo(SystemAction):
    description = _("update custom info for a system")

    def setup_parser(self, parser):
        super(UpdateCustomInfo, self).setup_parser(parser)
        parser.add_option('--current-value', dest='current-value', help=_("old value to update"))
        parser.add_option('--new-value', dest='new-value', help=_("replacement value"))

    def check_options(self, validator):
        validator.require(('org', 'keyname', 'current-value', 'new-value'))
        validator.mutually_exclude('environment', 'uuid')

    def run(self):
        org_name = self.get_option('org')
        env_name = self.get_option('environment')
        sys_name = self.get_option('name')
        sys_uuid = self.get_option('uuid')
        keyname = self.get_option('keyname')
        current_value = self.get_option('current-value')
        new_value = self.get_option('new-value')

        system = get_system(org_name, sys_name, env_name, sys_uuid)

        custom_info_api = CustomInfoAPI()

        response = custom_info_api.update_custom_info("system", system['id'], keyname, current_value, new_value)

        ident = sys_uuid if sys_uuid else sys_name

        if response[keyname][0] == new_value:
            print _("Successfully updated Custom Information for System [ %s ]") % ident
        else:
            print _("Could not update Custom Information for System [ %s ]") % ident


class RemoveCustomInfo(SystemAction):
    description = _("remove custom info from a system")

    def setup_parser(self, parser):
        super(RemoveCustomInfo, self).setup_parser(parser)
        parser.add_option('--value', dest='value', help=_("value of the custom info"))

    def run(self):
        org_name = self.get_option('org')
        env_name = self.get_option('environment')
        sys_name = self.get_option('name')
        sys_uuid = self.get_option('uuid')
        keyname = self.get_option('keyname')
        value = self.get_option('value')

        system = get_system(org_name, sys_name, env_name, sys_uuid)

        custom_info_api = CustomInfoAPI()

        response = custom_info_api.remove_custom_info("system", system['id'], keyname, value)

        ident = sys_uuid if sys_uuid else sys_name

        if response:
            print _("Successfully removed Custom Information from System [ %s ]") % ident
        else:
            print _("Could not remove Custom Information from System [ %s ]") % ident
