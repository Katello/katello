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
from katello.client.api.utils import get_distributor
from katello.client.lib.utils.data import test_record
from katello.client.core.distributor import DistributorAction

class BaseDistributorCustomInfo(DistributorAction):
    """ Base class for all *CustomInfo classes related to Distributors with common code """

    def setup_parser(self, parser):
        super(BaseDistributorCustomInfo, self).setup_parser(parser)
        parser.add_option('--name', dest='name', help=_("Distributor name (required)"))
        parser.add_option('--uuid', dest='uuid', help=constants.OPT_HELP_DISTRIBUTOR_UUID)
        parser.add_option('--keyname', dest='keyname', help=_("name to identify the custom info (required)"))

    def check_options(self, validator):
        validator.require('org')
        validator.require_at_least_one_of(('name', 'uuid'))
        validator.mutually_exclude('name', 'uuid')
        validator.mutually_exclude('environment', 'uuid')
        validator.require('keyname')


class AddCustomInfo(BaseDistributorCustomInfo):
    description = _('add custom infomation to a distributor')

    def setup_parser(self, parser):
        super(AddCustomInfo, self).setup_parser(parser)
        parser.add_option('--value', dest='value', help=_("the custom info (required)"))

    def check_options(self, validator):
        super(AddCustomInfo, self).check_options(validator)
        validator.require(('org', 'keyname', 'value'))

    def run(self):
        org_name = self.get_option('org')
        env_name = self.get_option("environment")
        dist_name = self.get_option('name')
        dist_uuid = self.get_option('uuid')
        keyname = self.get_option('keyname')
        value = self.get_option('value')

        distributor = get_distributor(org_name, dist_name, env_name, dist_uuid)

        custom_info_api = CustomInfoAPI()

        response = custom_info_api.add_custom_info("distributor", distributor['id'], keyname, value)

        ident = dist_uuid if dist_uuid else dist_name

        test_record(response,
            _("Successfully added Custom Information [ %(keyname)s : %(value)s ] to Distributor [ %(ident)s ]") \
                % {'keyname':keyname, 'value':value, 'ident':ident},
            _("Could not add Custom Information [ %(keyname)s : %(value)s ] to Distributor [ %(ident)s ]") \
                % {'keyname':keyname, 'value':value, 'ident':ident}
        )


class UpdateCustomInfo(BaseDistributorCustomInfo):
    description = _("update custom info for a distributor")

    def setup_parser(self, parser):
        super(UpdateCustomInfo, self).setup_parser(parser)
        parser.add_option('--value', dest='value', help=_("replacement value"))

    def check_options(self, validator):
        validator.require(('org', 'keyname', 'value'))
        validator.mutually_exclude('environment', 'uuid')

    def run(self):
        org_name = self.get_option('org')
        env_name = self.get_option('environment')
        dist_name = self.get_option('name')
        dist_uuid = self.get_option('uuid')
        keyname = self.get_option('keyname')
        new_value = self.get_option('value')

        distributor = get_distributor(org_name, dist_name, env_name, dist_uuid)

        custom_info_api = CustomInfoAPI()

        response = custom_info_api.update_custom_info("distributor", distributor['id'], keyname, new_value)

        ident = dist_uuid if dist_uuid else dist_name

        test_record(response,
            _("Successfully updated Custom Information [ %(keyname)s ] for Distributor [ %(ident)s ]") \
                % {'keyname':keyname, 'ident':ident},
            _("Could not update Custom Information [ %(keyname)s ] for Distributor [ %(ident)s ]") \
                % {'keyname':keyname, 'ident':ident}
        )


class RemoveCustomInfo(BaseDistributorCustomInfo):
    description = _("remove custom info from a distributor")

    def setup_parser(self, parser):
        super(RemoveCustomInfo, self).setup_parser(parser)

    def run(self):
        org_name = self.get_option('org')
        env_name = self.get_option('environment')
        dist_name = self.get_option('name')
        dist_uuid = self.get_option('uuid')
        keyname = self.get_option('keyname')

        distributor = get_distributor(org_name, dist_name, env_name, dist_uuid)

        custom_info_api = CustomInfoAPI()

        response = custom_info_api.remove_custom_info("distributor", distributor['id'], keyname)

        ident = dist_uuid if dist_uuid else dist_name

        if len(response) == 0:
            print _("Successfully removed Custom Information from Distributor [ %s ]") % ident
        else:
            print _("Could not remove Custom Information from Distributor [ %s ]") % ident
