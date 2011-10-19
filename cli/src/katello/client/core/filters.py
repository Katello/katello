#
# Katello User actions
# Copyright (c) 2010 Red Hat, Inc.
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
from gettext import gettext as _

from katello.client.api.filter import FilterAPI
from katello.client.config import Config
from katello.client.core.base import Action, Command
from katello.client.core.utils import is_valid_record

Config()

# -----------------------------------------------------------------

class FilterAction(Action):

    def __init__(self):
        super(FilterAction, self).__init__()
        self.api = FilterAPI()


# actions ---------------------------------------------------------

class List(FilterAction):
    description = _('list all filters')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                       help=_("organization name (required)"))

    def check_options(self):
        self.require_option('org')

    def run(self):
        org = self.get_option('org')
        
        filters = self.api.filters(org)        

        self.printer.addColumn('name')
        self.printer.addColumn('description')

        self.printer.setHeader(_("Filter List"))
        self.printer.printItems(filters)
        return os.EX_OK


class Create(FilterAction):
    description = _('create a filter')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                   help=_("organization name (required)"))
        self.parser.add_option('--name', dest='name',
                      help=_("filter name (required)"))
        self.parser.add_option('--description', dest='description',
                    help=_("description"))
        self.parser.add_option('--packages', dest='packages',
                    help=_("comma-separated list of package names/nvres"))


    def check_options(self):
        self.require_option('org')
        self.require_option('name')

    def run(self):
        org = self.get_option('org')
        name = self.get_option('name')
        description = self.get_option('description')        
        packages = [] if self.get_option('packages') == None else [p.strip() for p in self.get_option('packages').split(',')]
        
        new_filter = self.api.create(org, name, description, packages)

        if is_valid_record(new_filter):
            print _("Successfully created filter [ %s ]") % new_filter['name']
        else:
            print _("Could not create filter [ %s ]") % name
        return os.EX_OK
    

class Delete(FilterAction):
    description = _('delete a filter')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                   help=_("organization name (required)"))
        self.parser.add_option('--name', dest='name',
                      help=_("filter name (required)"))

    def check_options(self):
        self.require_option('org')
        self.require_option('name')

    def run(self):
        org = self.get_option('org')
        name = self.get_option('name')
        
        self.api.delete(org, name)
        print _("Successfully deleted org [ %s ]") % name
        return os.EX_OK
        
class Info(FilterAction):
    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                       help=_("organization name (required)"))
        self.parser.add_option('--name', dest='name',
                     help=_("filter name (required)"))

    def check_options(self):
        self.require_option('org')
        self.require_option('name')

    def run(self):
        org = self.get_option('org')
        name = self.get_option('name')

        filter_info = self.api.info(org, name)
        filter_info['package_list'] = ", ".join(filter_info["package_list"])

        self.printer.addColumn('name')
        self.printer.addColumn('description')
        self.printer.addColumn('package_list')

        self.printer.setHeader(_("Filter Information"))
        self.printer.printItem(filter_info)
        return os.EX_OK
        
class Filter(Command):

    description = _('filter specific actions in the katello server')
