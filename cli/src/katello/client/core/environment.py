#
# Katello Organization actions
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

import os

from katello.client.api.environment import EnvironmentAPI
from katello.client.cli.base import opt_parser_add_org
from katello.client.core.base import BaseAction, Command
from katello.client.lib.utils.data import test_record
from katello.client.api.utils import get_environment
from katello.client.lib.ui.printer import batch_add_columns


# base environment action --------------------------------------------------------

class EnvironmentAction(BaseAction):

    def __init__(self):
        super(EnvironmentAction, self).__init__()
        self.api = EnvironmentAPI()

    @classmethod
    def get_prior_id(cls, orgName, priorName):
        prior = get_environment(orgName, priorName)
        return prior["id"]

# environment actions ------------------------------------------------------------

class List(EnvironmentAction):

    description = _('list known environments')

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)

    def check_options(self, validator):
        validator.require('org')

    def run(self):
        orgName = self.get_option('org')

        envs = self.api.environments_by_org(orgName)

        batch_add_columns(self.printer, {'id': _("ID")}, {'name': _("Name")}, {'label': _("Label")})
        self.printer.add_column('description', _("Description"), multiline=True)
        self.printer.add_column('organization', _('Org'))
        self.printer.add_column('prior', _("Prior Environment"))

        self.printer.set_header(_("Environment List"))
        self.printer.print_items(envs)
        return os.EX_OK


class Info(EnvironmentAction):

    description = _('list a specific environment')

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)
        parser.add_option('--name', dest='name',
                       help=_("environment name eg: foo.example.com (required)"))

    def check_options(self, validator):
        validator.require(('org', 'name'))

    def run(self):
        orgName = self.get_option('org')
        envName = self.get_option('name')

        env = get_environment(orgName, envName)

        self.printer.add_column('id', _("ID"))
        self.printer.add_column('name', _("Name"))
        self.printer.add_column('description', _("Description"), multiline=True)
        self.printer.add_column('organization', _("Org"))
        self.printer.add_column('prior', _("Prior Environment"))

        self.printer.set_header(_("Environment Info"))
        self.printer.print_item(env)
        return os.EX_OK



class Create(EnvironmentAction):

    description = _('create an environment')

    def setup_parser(self, parser):
        parser.add_option("--description", dest="description",
                               help=_("environment description eg: foo's environment"))
        opt_parser_add_org(parser, required=1)
        parser.add_option('--name', dest='name',
                               help=_("environment name (required)"))
        parser.add_option('--label', dest='label',
                               help=_("environment label, ASCII identifier for the environment " +
                                      "with no spaces eg: Dev_One (will be generated if not specified)"))
        parser.add_option('--prior', dest='prior',
                               help=_("name of prior environment (required)"))


    def check_options(self, validator):
        validator.require(('org', 'name', 'prior'))


    def run(self):
        name        = self.get_option('name')
        label       = self.get_option('label')
        description = self.get_option('description')
        orgName     = self.get_option('org')
        priorName   = self.get_option('prior')

        priorId = self.get_prior_id(orgName, priorName)

        env = self.api.create(orgName, name, label, description, priorId)
        test_record(env,
            _("Successfully created environment [ %s ]") % name,
            _("Could not create environment [ %s ]") % name
        )


class Update(EnvironmentAction):


    description =  _('update an environment')


    def setup_parser(self, parser):
        parser.add_option("--description", dest="description",
                               help=_("environment description eg: foo's environment"))
        opt_parser_add_org(parser, required=1)
        parser.add_option('--prior', dest='prior',
                               help=_("name of prior environment"))
        parser.add_option('--name', dest='name',
                               help=_("environment name (required)"))
        parser.add_option('--new-name', dest='new-name',
                               help=_("new environment name"))


    def check_options(self, validator):
        validator.require(('org', 'name'))


    def run(self):
        envName     = self.get_option('name')
        description = self.get_option('description')
        orgName     = self.get_option('org')
        priorName   = self.get_option('prior')
        newName     = self.get_option('new-name')

        env = get_environment(orgName, envName)

        if priorName != None:
            priorId = self.get_prior_id(orgName, priorName)
        else:
            priorId = None

        if newName != None:
            envName = newName

        env = self.api.update(orgName, env["id"], envName, description, priorId)
        print _("Successfully updated environment [ %s ]") % env['name']
        return os.EX_OK



class Delete(EnvironmentAction):

    description = _('delete an environment')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name',
                               help=_("environment name eg: foo.example.com (required)"))
        opt_parser_add_org(parser, required=1)

    def check_options(self, validator):
        validator.require(('name', 'org'))


    def run(self):
        orgName     = self.get_option('org')
        envName     = self.get_option('name')

        env = get_environment(orgName, envName)

        self.api.delete(orgName, env["id"])
        print _("Successfully deleted environment [ %s ]") % envName
        return os.EX_OK



# environment command ------------------------------------------------------------

class Environment(Command):

    description = _('environment specific actions in the katello server')
