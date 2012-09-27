#
# Katello User actions
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

import os

from katello.client.api.filter import FilterAPI
from katello.client.cli.base import opt_parser_add_org
from katello.client.core.base import BaseAction, Command
from katello.client.core.utils import test_record


# -----------------------------------------------------------------

class FilterAction(BaseAction):

    def __init__(self):
        super(FilterAction, self).__init__()
        self.api = FilterAPI()

# actions ---------------------------------------------------------

class List(FilterAction):
    description = _('list all filters')

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)

    def check_options(self, validator):
        validator.require('org')

    def run(self):
        org = self.get_option('org')

        filters = self.api.filters(org)

        self.printer.add_column('name')
        self.printer.add_column('description')

        self.printer.set_header(_("Filter List"))
        self.printer.print_items(filters)
        return os.EX_OK


class Create(FilterAction):
    description = _('create a filter')

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)
        parser.add_option('--name', dest='name',
                      help=_("filter name (required)"))
        parser.add_option('--description', dest='description',
                    help=_("description"))
        parser.add_option('--packages', dest='packages',
                    help=_("comma-separated list of package names/NVREAs"))


    def check_options(self, validator):
        validator.require(('org', 'name'))

    def run(self):
        org = self.get_option('org')
        name = self.get_option('name')
        description = self.get_option('description')
        packages = self.parse_packages(self.get_option('packages'))

        new_filter = self.api.create(org, name, description, packages)

        test_record(new_filter,
            _("Successfully created filter [ %s ]") % name,
            _("Could not create filter [ %s ]") % name
        )

    @classmethod
    def parse_packages(cls, packages):
        return ([] if packages == None else [p.strip() for p in packages.split(',')])

class Update(FilterAction):
  description = _('update a filter')

  def setup_parser(self, parser):
    opt_parser_add_org(parser, required=1)
    parser.add_option('--name', dest='name',
                help=_("filter existing name (required)"))
    parser.add_option('--new-name', dest='new_name',
                help=_("filter new name"))

  def check_options(self, validator):
    validator.require(('org', 'name', "new_name"))

  def run(self):
    org = self.get_option('org')
    name = self.get_option('name')
    new_name = self.get_option('new_name')

    filter = self.api.update(org, name, new_name)

    print _("Successfully updated filter [ %s ]") % filter["name"]
    return os.EX_OK

class Delete(FilterAction):
    description = _('delete a filter')

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)
        parser.add_option('--name', dest='name',
                      help=_("filter name (required)"))

    def check_options(self, validator):
        validator.require(('org', 'name'))

    def run(self):
        org = self.get_option('org')
        name = self.get_option('name')

        self.api.delete(org, name)
        print _("Successfully deleted filter [ %s ]") % name
        return os.EX_OK

class Info(FilterAction):
    description = _('filter info')

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)
        parser.add_option('--name', dest='name',
                     help=_("filter name (required)"))

    def check_options(self, validator):
        validator.require(('org', 'name'))

    def run(self):
        org = self.get_option('org')
        name = self.get_option('name')

        filter_info = self.api.info(org, name)

        self.printer.add_column('name')
        self.printer.add_column('description')
        self.printer.add_column('package_list', formatter=self.package_list_as_string)

        self.printer.set_header(_("Filter Information"))
        self.printer.print_item(filter_info)
        return os.EX_OK

    @classmethod
    def package_list_as_string(cls, package_list):
        return ", ".join(package_list)

class AddPackage(FilterAction):
    description = _('Add a package to filter')

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)
        parser.add_option('--name', dest='name',
                     help=_("filter name (required)"))
        parser.add_option('--package', dest='package_id',
                       help=_("package ID (required)"))

    def check_options(self, validator):
        validator.require(('org', 'name', 'package_id'))

    def run(self):
        org = self.get_option('org')
        name = self.get_option('name')
        package_id = self.get_option('package_id')

        filter_info = self.api.info(org, name)
        self.api.update_packages(org, name, filter_info["package_list"] + [package_id])

        print _("Successfully added package [ %s ] to filter [ %s ]") % (package_id, name)
        return os.EX_OK

class RemovePackage(FilterAction):
    description = _('Remove a package from filter')

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)
        parser.add_option('--name', dest='name',
                     help=_("filter name (required)"))
        parser.add_option('--package', dest='package_id',
                       help=_("package ID (required)"))

    def check_options(self, validator):
        validator.require(('org', 'name', 'package_id'))

    def run(self):
        org = self.get_option('org')
        name = self.get_option('name')
        package_id = self.get_option('package_id')

        filter_info = self.api.info(org, name)
        package_list = filter_info["package_list"]
        package_list.remove(package_id)

        self.api.update_packages(org, name, package_list)

        print _("Successfully removed package [ %s ] from filter [ %s ]") % (package_id, name)
        return os.EX_OK


class Filter(Command):

    description = _('filter specific actions in the katello server')
