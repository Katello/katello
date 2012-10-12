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
from katello.client.api.utils import get_environment


# base content_view action --------------------------------------------------------

class ContentViewAction(BaseAction):

    def __init__(self):
        super(ContentViewAction, self).__init__()
        self.api = ContentViewAPI()
        self.def_api = ContentViewDefinitionAPI()

    @classmethod
    def get_environment_id(cls, org_name, env_name):
        env = get_environment(org_name, env_name)
        return env["id"]

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

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('description', multiline=True)
        self.printer.add_column('organization', _('Org'))
        self.printer.add_column('environment', _('Environment'))

        self.printer.set_header(_("Content View List"))
        self.printer.print_items(views)
        return os.EX_OK


class Info(ContentViewAction):

    description = _('list a specific content_view')

    def setup_parser(self, parser):
        opt_parser_add_org(parser)
        parser.add_option('--name', dest='name',
                help=_("content_view name eg: foo.example.com (required)"))

    def check_options(self, validator):
        validator.require(('org', 'name'))

    def run(self):
        org_name = self.get_option('org')
        viewName = self.get_option('name')

        view = get_content_view(org_name, viewName)

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('description', multiline=True)
        self.printer.add_column('organization', _('Org'))
        self.printer.add_column('environment', _('Environment'))

        self.printer.set_header(_("ContentView Info"))
        self.printer.print_item(view)
        return os.EX_OK



class Create(ContentViewAction):

    description = _('create an content_view')

    def setup_parser(self, parser):
        parser.add_option("--description", dest="description",
                help=_("content_view description eg: foo's content_view"))
        opt_parser_add_org(parser, required=1)
        parser.add_option('--name', dest='name',
                help=_("content_view name (required)"))
        parser.add_option('--env', dest='env',
                help=_("name of environment (required)"))


    def check_options(self, validator):
        validator.require(('org', 'name', 'env'))


    def run(self):
        name        = self.get_option('name')
        description = self.get_option('description')
        org_name     = self.get_option('org')
        env_name   = self.get_option('env')

        env_id = self.get_environment_id(org_name, env_name)

        view = self.api.create(org_name, name, description, env_id)
        test_record(view,
            _("Successfully created content_view [ %s ]") % name,
            _("Could not create content_view [ %s ]") % name
        )


class Update(ContentViewAction):


    description =  _('update an content_view')


    def setup_parser(self, parser):
        parser.add_option("--description", dest="description", 
                help=_("content view description eg: foo's content view"))
        opt_parser_add_org(parser, required=1)
        parser.add_option('--name', dest='name',
                help=_("content view name (required)"))


    def check_options(self, validator):
        validator.require(('org', 'name'))


    def run(self):
        viewName     = self.get_option('name')
        description = self.get_option('description')
        org_name     = self.get_option('org')
        env_name   = self.get_option('env')

        view = get_content_view(org_name, viewName)

        if env_name != None:
            env_id = self.get_environment_id(org_name, env_name)
        else:
            env_id = None
        view = self.api.update(org_name, view["id"], viewName, description, 
                env_id)
        print _("Successfully updated content_view [ %s ]") % view['name']
        return os.EX_OK



class Delete(ContentViewAction):

    description = _('delete an content_view')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name',
                help=_("content view name eg: foo.example.com (required)"))
        opt_parser_add_org(parser, required=1)

    def check_options(self, validator):
        validator.require(('name', 'org'))


    def run(self):
        org_name     = self.get_option('org')
        viewName     = self.get_option('name')

        view = get_content_view(org_name, viewName)

        self.api.delete(org_name, view["id"])
        print _("Successfully deleted content view [ %s ]") % viewName
        return os.EX_OK



# content_view command ------------------------------------------------------------

class ContentView(Command):

    description = _('content view specific actions for the katello server')
