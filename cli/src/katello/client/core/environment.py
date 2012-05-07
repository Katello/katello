#
# Katello Organization actions
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
import sys
from gettext import gettext as _

from katello.client.api.environment import EnvironmentAPI
from katello.client.config import Config
from katello.client.core.base import Action, Command
from katello.client.core.utils import test_record
from katello.client.api.utils import get_environment

Config()

# base environment action --------------------------------------------------------

class EnvironmentAction(Action):

    def __init__(self):
        super(EnvironmentAction, self).__init__()
        self.api = EnvironmentAPI()


    def get_prior_id(self, orgName, priorName):
        prior = get_environment(orgName, priorName)
        if prior != None:
            return prior["id"]
        return None

# environment actions ------------------------------------------------------------

class List(EnvironmentAction):

    description = _('list known environments')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                       help=_("organization name eg: foo.example.com (required)"))

    def check_options(self):
        self.require_option('org')

    def run(self):
        orgName = self.get_option('org')

        envs = self.api.environments_by_org(orgName)

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('description', multiline=True)
        self.printer.add_column('organization', _('Org'))
        self.printer.add_column('prior', _('Prior Environment'))

        self.printer.set_header(_("Environment List"))
        self.printer.print_items(envs)
        return os.EX_OK


class Info(EnvironmentAction):

    description = _('list a specific environment')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                       help=_("organization name eg: foo.example.com (required)"))
        self.parser.add_option('--name', dest='name',
                       help=_("environment name eg: foo.example.com (required)"))

    def check_options(self):
        self.require_option('org')
        self.require_option('name')

    def run(self):
        orgName = self.get_option('org')
        envName = self.get_option('name')

        env = get_environment(orgName, envName)

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('description', multiline=True)
        self.printer.add_column('organization', _('Org'))
        self.printer.add_column('prior', _('Prior Environment'))

        self.printer.set_header(_("Environment Info"))
        self.printer.print_item(env)
        return os.EX_OK



class Create(EnvironmentAction):

    description = _('create an environment')

    def setup_parser(self):
        self.parser.add_option("--description", dest="description",
                               help=_("environment description eg: foo's environment"))
        self.parser.add_option('--org', dest='org',
                               help=_("organization name eg: foo.example.com (required)"))
        self.parser.add_option('--name', dest='name',
                               help=_("environment name (required)"))
        self.parser.add_option('--prior', dest='prior',
                               help=_("name of prior environment (required)"))


    def check_options(self):
        self.require_option('org')
        self.require_option('name')
        self.require_option('prior')


    def run(self):
        name        = self.get_option('name')
        description = self.get_option('description')
        orgName     = self.get_option('org')
        priorName   = self.get_option('prior')
        env         = self.get_option('env')

        priorId = self.get_prior_id(orgName, priorName)

        env = self.api.create(orgName, name, description, priorId)
        test_record(env,
            _("Successfully created environment [ %s ]") % name,
            _("Could not create environment [ %s ]") % name
        )


class Update(EnvironmentAction):


    description =  _('update an environment')


    def setup_parser(self):
        self.parser.add_option("--description", dest="description",
                               help=_("environment description eg: foo's environment"))
        self.parser.add_option('--org', dest='org',
                               help=_("organization name eg: foo.example.com (required)"))
        self.parser.add_option('--prior', dest='prior',
                               help=_("name of prior environment"))
        self.parser.add_option('--name', dest='name',
                               help=_("environment name (required)"))


    def check_options(self):
        self.require_option('org')
        self.require_option('name')


    def run(self):
        envName     = self.get_option('name')
        description = self.get_option('description')
        orgName     = self.get_option('org')
        priorName   = self.get_option('prior')

        env = get_environment(orgName, envName)

        if priorName != None:
            priorId = self.get_prior_id(orgName, priorName)
        else:
            priorId = None
        env = self.api.update(orgName, env["id"], envName, description, priorId)
        print _("Successfully updated environment [ %s ]") % env['name']
        return os.EX_OK



class Delete(EnvironmentAction):

    description = _('delete an environment')

    def setup_parser(self):
        self.parser.add_option('--name', dest='name',
                               help=_("environment name eg: foo.example.com (required)"))
        self.parser.add_option('--org', dest='org',
                               help=_("organization name eg: foo.example.com (required)"))

    def check_options(self):
        self.require_option('name')
        self.require_option('org')


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
