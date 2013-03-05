#
# Katello Organization actions
# Copyright (c) 2013 Red Hat, Inc.
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

# base filter action ----------------------------------------

class FilterAction(BaseAction):

    def __init__(self):
        super(FilterAction, self).__init__()
        self.api = FilterAPI()
        self.def_api = FilterAPI()

    @classmethod
    def _add_cvd_filter_opts(cls, parser):
        parser.add_option('--definition', dest='definition',
                help=_("content view definition label eg: def1"))

    @classmethod
    def _add_get_filter_opts(cls, parser):
        FilterAction._add_cvd_filter_opts(parser)
        parser.add_option('--filter', dest='filter_name',
                help=_("filter id eg: 'filter_foo'"))
    
    @classmethod
    def _add_get_filter_opts_check(cls, validator):
        validator.require('definition')

# filter actions -----------------------------------------------------

class List(FilterAction):

    description = _('list known filters for a given content view definition')

    def setup_parser(self, parser):
        self._add_cvd_filter_opts(parser)
        opt_parser_add_org(parser, required=1)


    def check_options(self, validator):
        validator.require(('org', 'definition'))

    def run(self):
        org_label = self.get_option('org')
        definition = self.get_option('definition')
        defs = self.def_api.filters_by_cvd_and_org(definition, org_label)

        self.printer.add_column('id', _("ID"))
        self.printer.add_column('name', _("Name"))
        self.printer.add_column('content_view_definition_label', _("Content View Definition"))
        self.printer.add_column('organization', _('Org'))

        self.printer.set_header(_("Content View Definition Filters"))
        self.printer.print_items(defs)
        return os.EX_OK


class Info(FilterAction):
    description = _('list a specific filter')
    def setup_parser(self, parser):
        self._add_get_filter_opts(parser)
        opt_parser_add_org(parser, required=1)


    def check_options(self, validator):
        validator.require(('org', 'definition', 'filter_name'))

    def run(self):
        org_label = self.get_option('org')
        definition = self.get_option('definition')
        filter_name = self.get_option('filter_name')
        cvd_filter = self.def_api.get_filter_info(filter_name, definition, org_label)
        self.printer.add_column('id', _("ID"))
        self.printer.add_column('name', _("Name"))
        self.printer.add_column('content_view_definition_label', _("Content View Definition"))
        self.printer.add_column('organization', _('Org'))
        # TODO: we want to add details about the
        # repos associated to this filter
        # and also a nice listing of rules.
        # self.printer.add_column('repos', _('Repos'))
        # self.printer.add_column('rules', _('Rules'))  

        self.printer.set_header(_("Content View Definition Filter Info"))
        self.printer.print_item(cvd_filter)
        return os.EX_OK

class Create(FilterAction):
    description = _('create a filter')
    def setup_parser(self, parser):
        self._add_get_filter_opts(parser)
        opt_parser_add_org(parser, required=1)

    def check_options(self, validator):
        validator.require(('org', 'definition', 'filter_name'))

    def run(self):
        org_label = self.get_option('org')
        filter_name = self.get_option('filter_name')
        definition = self.get_option('definition')
        self.def_api.create(filter_name, definition, org_label)
        print _("Successfully created filter [ %s ]") % filter_name
        return os.EX_OK

class Delete(FilterAction):

    description = _('delete a filter')

    def setup_parser(self, parser):
        self._add_get_filter_opts(parser)
        opt_parser_add_org(parser, required=1)

    def check_options(self, validator):
        validator.require(('org', 'definition', 'filter_name'))
        
    def run(self):
        org_label = self.get_option('org')
        filter_name = self.get_option('filter_name')
        definition = self.get_option('definition')
        self.def_api.delete(filter_name, definition, org_label)
        print _("Successfully deleted filter [ %s ]") % filter_name
        return os.EX_OK

# Filter command ------------------------------------------------------------

class Filter(Command):

    description = _('content view definition filters actions for the katello server')
