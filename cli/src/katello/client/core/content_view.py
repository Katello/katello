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
from katello.client.cli.base import opt_parser_add_org, \
        opt_parser_add_environment
from katello.client.core.base import BaseAction, Command
from katello.client.api.utils import get_cv_definition, get_environment, \
        get_content_view

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
        opt_parser_add_environment(parser)

    def check_options(self, validator):
        validator.require('org')

    def run(self):
        org_name    = self.get_option('org')
        env_name    = self.get_option('environment')

        env = get_environment(org_name, env_name) if env_name else None

        views = self.api.content_views_by_org(org_name, env)

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('label')
        self.printer.add_column('description', multiline=True)
        self.printer.add_column('organization', _('Org'))
        self.printer.add_column('environments', _('Environments'))

        self.printer.set_header(_("Content View List"))
        self.printer.print_items(views)
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

        view = get_content_view(org_name, view_label)

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('label')
        self.printer.add_column('description', multiline=True)
        self.printer.add_column('organization', _('Org'))
        self.printer.add_column('definition')
        self.printer.add_column('environments', _('Environments'))

        self.printer.set_header(_("ContentView Info"))
        self.printer.print_item(view)
        return os.EX_OK




# content_view command ------------------------------------------------------------

class ContentView(Command):

    description = _('content view specific actions for the katello server')
