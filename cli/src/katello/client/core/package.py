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

from katello.client.api.package import PackageAPI
from katello.client.config import Config
from katello.client.core.base import Action, Command
from katello.client.api.utils import get_repo
from katello.client.utils import printer

Config()

# base package action --------------------------------------------------------

class PackageAction(Action):

    def __init__(self):
        super(PackageAction, self).__init__()
        self.api = PackageAPI()


# package actions ------------------------------------------------------------
class Info(PackageAction):

    description = _('list information about a package')

    def setup_parser(self):
        # always provide --id option for create, even on registered clients
        self.parser.add_option('--id', dest='id',
                               help=_("package id, string value (required)"))
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
        self.require_option('id')
        if not self.has_option('repo_id'):
            self.require_option('repo')
            self.require_option('org')
            self.require_option('product')

    def run(self):
        packId   = self.get_option('id')
        repoId   = self.get_option('repo_id')
        repoName = self.get_option('repo')
        orgName  = self.get_option('org')
        envName  = self.get_option('env')
        prodName = self.get_option('product')

        if not repoId:
            repo = get_repo(orgName, prodName, repoName, envName)
            if repo == None:
                return os.EX_DATAERR
            repoId = repo["id"]

        pack = self.api.package(packId, repoId)

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('filename')
        self.printer.add_column('arch')
        self.printer.add_column('release')
        self.printer.add_column('version')
        self.printer.add_column('vendor')
        self.printer.add_column('download_url', show_with=printer.VerboseStrategy)
        self.printer.add_column('description', multiline=True, show_with=printer.VerboseStrategy)
        self.printer.add_column('provides', multiline=True, show_with=printer.VerboseStrategy)
        self.printer.add_column('requires', multiline=True, show_with=printer.VerboseStrategy)

        self.printer.set_header(_("Package Information"))
        self.printer.print_item(pack)
        return os.EX_OK

# package actions ------------------------------------------------------------
class List(PackageAction):

    description = _('list packages in a repository')

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
        repoId = self.get_repo_id()
        if not repoId:
            return os.EX_DATAERR

        self.printer.set_header(_("Package List For Repo %s") % repoId)

        packages = self.api.packages_by_repo(repoId)
        self.print_packages(packages)

        return os.EX_OK

    def get_repo_id(self):
        repoId   = self.get_option('repo_id')
        repoName = self.get_option('repo')
        orgName  = self.get_option('org')
        envName  = self.get_option('env')
        prodName = self.get_option('product')

        if not repoId:
            repo = get_repo(orgName, prodName, repoName, envName)
            if repo != None:
                repoId = repo["id"]

        return repoId

    def print_packages(self, packages):
        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('filename')
        self.printer.print_items(packages)



class Search(List):

    description = _('search packages in a repository')

    def setup_parser(self):
        super(Search, self).setup_parser()
        self.parser.add_option('--query', dest='query',
                      help=_("query string for searching packages, e.g. 'kernel*','kernel-3.3.0-4.el6.x86_64'"))

    def check_options(self):
        super(Search, self).check_options()
        self.require_option('query')

    def run(self):
        repoId = self.get_repo_id()
        if not repoId:
            return os.EX_DATAERR
        query   = self.get_option('query')
        self.printer.set_header(_("Package List For Repo %s and Query %s") % (repoId, query))

        packages = self.api.search(query, repoId)
        self.print_packages(packages)
        return os.EX_OK


# package command ------------------------------------------------------------

class Package(Command):

    description = _('package specific actions in the katello server')
