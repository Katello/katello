#
# Katello Organization actions
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

from katello.client.api.content_view import ContentViewAPI
from katello.client.api.content_view_definition import ContentViewDefinitionAPI
from katello.client.cli.base import opt_parser_add_org
from katello.client.core.base import BaseAction, Command
from katello.client.core.utils import test_record
from katello.client.api.utils import get_content_view, get_cv_definition, \
        get_filter

# base content_view action --------------------------------------------------------

class ContentViewAction(BaseAction):

    def __init__(self):
        super(ContentViewAction, self).__init__()
        self.api = ContentViewAPI()
        self.def_api = ContentViewDefinitionAPI()

# content_view actions ------------------------------------------------------------

class List(ContentViewAction):

    description = _('list known content_views')

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)

    def check_options(self, validator):
        validator.require('org')

    def run(self):
        org_name = self.get_option('org')

        views = self.def_api.content_view_definitions_by_org(org_name)
        views += self.api.content_views_by_org(org_name)

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('label')
        self.printer.add_column('description', multiline=True)
        self.printer.add_column('organization', _('Org'))
        self.printer.add_column('environments', _('Environments'))
        self.printer.add_column('published', _('Published'))

        self.printer.set_header(_("Content View List"))
        self.printer.print_items(views)
        return os.EX_OK

class Publish(ContentViewAction):

    description = _("create a content view from a definition")

    def setup_parser(self, parser):
        opt_parser_add_org(parser)
        parser.add_option('--definition', dest='label',
                help=_("definition label eg: Database (required)"))

    def check_options(self, validator):
        validator.require(('org', 'label'))

    def run(self):
        org_name = self.get_option('org')
        label = self.get_option('label')

        cvd = get_cv_definition(org_name, label)

        self.def_api.publish(org_name, cvd["id"])
        print _("Successfully published content view [ %s ]") % label
        return os.EX_OK


class Info(ContentViewAction):

    description = _('list a specific content_view')

    def setup_parser(self, parser):
        opt_parser_add_org(parser)
        parser.add_option('--label', dest='label',
                help=_("content_view label eg: foo.example.com (required)"))

    def check_options(self, validator):
        validator.require(('org', 'label'))

    def run(self):
        org_name = self.get_option('org')
        view_label = self.get_option('label')

        view = get_cv_definition(org_name, view_label)

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('label')
        self.printer.add_column('description', multiline=True)
        self.printer.add_column('organization', _('Org'))
        self.printer.add_column('environments', _('Environments'))

        self.printer.set_header(_("ContentView Info"))
        self.printer.print_item(view)
        return os.EX_OK



class Create(ContentViewAction):

    description = _('define an content view')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name',
                help=_("content view definition name eg: Database (required)"))
        opt_parser_add_org(parser, required=1)
        parser.add_option('--description', dest='description',
                help=_("definition description"))
        parser.add_option('--label', dest='label',
                help=_("definition label"))

    def check_options(self, validator):
        validator.require(('name', 'org'))


    def run(self):
        org_id      = self.get_option('org')
        name        = self.get_option('name')
        description = self.get_option('description')
        label       = self.get_option('label')

        self.def_api.create(org_id, name, label, description)
        print _("Successfully created content view definition [ %s ]") % name
        return os.EX_OK


class Update(ContentViewAction):


    description =  _('update an content_view')


    def setup_parser(self, parser):
        parser.add_option("--description", dest="description",
                help=_("content view description eg: foo's content view"))
        opt_parser_add_org(parser, required=1)
        parser.add_option('--view', dest='view',
                help=_("content view label (required)"))
        parser.add_option('--name', dest='name', help=_("content view name"))


    def check_options(self, validator):
        validator.require(('org', 'view'))


    def run(self):
        name         = self.get_option('name')
        description  = self.get_option('description')
        org_name     = self.get_option('org')
        def_label    = self.get_option('view')

        cvd = self.def_api.update(org_name, def_label, name, description)
        print _("Successfully updated content_view [ %s ]") % cvd['name']
        return os.EX_OK



class Delete(ContentViewAction):

    description = _('delete an content_view')

    def setup_parser(self, parser):
        parser.add_option('--label', dest='label',
                help=_("content view label eg: foo.example.com (required)"))
        opt_parser_add_org(parser, required=1)

    def check_options(self, validator):
        validator.require(('label', 'org'))


    def run(self):
        org_name   = self.get_option('org')
        view_label = self.get_option('label')

        view = get_cv_definition(org_name, view_label)

        self.def_api.delete(view["id"])
        print _("Successfully deleted definition [ %s ]") % view_label
        return os.EX_OK

class AddRemoveFilter(ContentViewAction):

    select_by_env = False
    addition = True

    @property
    def description(self):
        if self.addition:
            return _('add a filter to a content view')
        else:
            return _('remove a filter from a content view')


    def __init__(self, addition):
        super(AddRemoveFilter, self).__init__()
        self.addition = addition

    def setup_parser(self, parser):
        parser.add_option('--label', dest='label',
                help=_("content view label eg: Database (required)"))
        opt_parser_add_org(parser, required=1)
        parser.add_option('--filter', dest='filter',
                help=_("filter name (required)"))

    def check_options(self, validator):
        validator.require(('filter', 'org', 'label'))

    def run(self):
        org_name     = self.get_option('org')
        view_label   = self.get_option('label')
        filter_name  = self.get_option('filter')

        view = get_cv_definition(org_name, view_label)
        get_filter(org_name, filter_name)

        filters = self.def_api.filters(org_name, view['id'])
        filters = [f['name'] for f in filters]
        self.update_filters(org_name, view, filters, filter_name)
        return os.EX_OK

    def update_filters(self, org_name, cvd, filters, filter_name):
        if self.addition:
            filters.append(filter_name)
            message = _("Added filter [ %s ] to content view [ %s ]" % \
                    (filter_name, cvd["label"]))
        else:
            filters.remove(filter_name)
            message = _("Removed filter [ %s ] to content view [ %s ]" % \
                    (filter_name, cvd["label"]))

        self.def_api.update_filters(org_name, cvd['id'], filters)
        print message

# content_view command ------------------------------------------------------------

class ContentView(Command):

    description = _('content view specific actions for the katello server')
