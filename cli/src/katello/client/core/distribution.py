#
# Katello Repos actions
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

from katello.client.api.distribution import DistributionAPI
from katello.client.config import Config
from katello.client.core.base import Action, Command
from katello.client.api.utils import get_repo

Config()

# base action ----------------------------------------------------------------

class DistributionAction(Action):

    def __init__(self):
        super(DistributionAction, self).__init__()
        self.api = DistributionAPI()


# actions --------------------------------------------------------------------

class List(DistributionAction):

    description = _('list distributions in a repository')

    def setup_parser(self):
        self.parser.add_option('--repo_id', dest='repo_id',
                      help=_("repository id"))
        self.parser.add_option('--repo', dest='repo',
                      help=_("repository name"))
        self.parser.add_option('--org', dest='org',
                      help=_("organization name eg: foo.example.com"))
        self.parser.add_option('--environment', dest='env',
                      help=_("environment name eg: production (default: Library)"))
        self.parser.add_option('--product', dest='product',
                      help=_("product name eg: fedora-14"))

    def check_options(self):
        if not self.has_option('repo_id'):
            self.require_option('repo')
            self.require_option('org')
            self.require_option('product')

    def run(self):
        repoId   = self.get_option('repo_id')
        repoName = self.get_option('repo')
        orgName  = self.get_option('org')
        envName  = self.get_option('env')
        prodName = self.get_option('product')

        self.printer.addColumn('id')
        self.printer.addColumn('description')
        self.printer.addColumn('files', multiline=True, show_in_grep=False)

        if not repoId:
            repo = get_repo(orgName, prodName, repoName, envName)
            if repo == None:
                return os.EX_DATAERR
            repoId = repo["id"]


        self.printer.setHeader(_("Distribution List For Repo %s") % repoId)

        distributions = self.api.distributions_by_repo(repoId)

        self.printer.printItems(distributions)
        return os.EX_OK


# ------------------------------------------------------------------------------

class Info(DistributionAction):

    description = _('list information about a distribution')

    def setup_parser(self):
        # always provide --id option for create, even on registered clients
        self.parser.add_option('--repo_id', dest='repo_id',
                      help=_("repository id (required)"))
        self.parser.add_option('--id', dest='id',
                               help=_("distribution id eg: ks-rh-noarch (required)"))

    def check_options(self):
        self.require_option('repo_id')
        self.require_option('id')

    def run(self):
        repoId  = self.get_option('repo_id')
        dist_id = self.get_option('id')

        data = self.api.distribution(repoId, dist_id)

        self.printer.addColumn('id')
        self.printer.addColumn('description')
        self.printer.addColumn('family')
        self.printer.addColumn('variant')
        self.printer.addColumn('version')
        self.printer.addColumn('files', multiline=True, show_in_grep=False)

        self.printer.setHeader(_("Distribution Information"))

        self.printer.printItem(data)
        return os.EX_OK


# command --------------------------------------------------------------------

class Distribution(Command):

    description = _('repo specific actions in the katello server')
