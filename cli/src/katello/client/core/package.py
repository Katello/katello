#
# Katello Repos actions
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

from katello.client.api.package import PackageAPI
from katello.client.cli.base import opt_parser_add_product, opt_parser_add_org, opt_parser_add_environment
from katello.client.core.base import BaseAction, Command
from katello.client.api.utils import get_repo
from katello.client.lib.ui import printer
from katello.client.lib.ui.printer import batch_add_columns


# base package action --------------------------------------------------------

class PackageAction(BaseAction):

    def __init__(self):
        super(PackageAction, self).__init__()
        self.api = PackageAPI()


# package actions ------------------------------------------------------------
class Info(PackageAction):

    description = _('list information about a package')

    def setup_parser(self, parser):
        # always provide --id option for create, even on registered clients
        parser.add_option('--id', dest='id',
                               help=_("package ID, string value (required)"))
        parser.add_option('--repo_id', dest='repo_id',
                      help=_("repository ID"))
        parser.add_option('--repo', dest='repo',
                      help=_("repository name (required)"))
        opt_parser_add_org(parser, required=1)
        opt_parser_add_environment(parser, default=_("Library"))
        opt_parser_add_product(parser)

    def check_options(self, validator):
        validator.require('id')
        if not validator.exists('repo_id'):
            validator.require(('repo', 'org'))
            validator.require_at_least_one_of(('product', 'product_label', 'product_id'))
            validator.mutually_exclude('product', 'product_label', 'product_id')

    def run(self):
        packId   = self.get_option('id')
        repoId   = self.get_option('repo_id')
        repoName = self.get_option('repo')
        orgName  = self.get_option('org')
        envName  = self.get_option('environment')
        prodName = self.get_option('product')
        prodLabel = self.get_option('product_label')
        prodId   = self.get_option('product_id')

        if not repoId:
            repo = get_repo(orgName, repoName, prodName, prodLabel, prodId, envName)
            repoId = repo["id"]

        pack = self.api.package(packId, repoId)

        batch_add_columns(self.printer, {'id': _("ID")}, {'name': _("Name")}, \
            {'filename': _("Filename")}, {'arch': _("Arch")}, {'release': _("Release")}, \
            {'version': _("Version")}, {'vendor': _("Vendor")})
        self.printer.add_column('download_url', _("Download URL"), show_with=printer.VerboseStrategy)
        batch_add_columns(self.printer, {'description': _("Description")}, \
            {'provides': _("Provides")}, {'requires': _("Requires")}, multiline=True, \
            show_with=printer.VerboseStrategy)

        self.printer.set_header(_("Package Information"))
        self.printer.print_item(pack)
        return os.EX_OK

# package actions ------------------------------------------------------------
class List(PackageAction):

    description = _('list packages in a repository')

    def setup_parser(self, parser):
        parser.add_option('--repo_id', dest='repo_id',
                      help=_("repository ID"))
        parser.add_option('--repo', dest='repo',
                      help=_("repository name (required)"))
        opt_parser_add_org(parser, required=1)
        opt_parser_add_environment(parser, default=_("Library"))
        opt_parser_add_product(parser)

    def check_options(self, validator):
        if not validator.exists('repo_id'):
            validator.require(('repo', 'org'))
            validator.require_at_least_one_of(('product', 'product_label', 'product_id'))
            validator.mutually_exclude('product', 'product_label', 'product_id')

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
        envName  = self.get_option('environment')
        prodName = self.get_option('product')
        prodLabel = self.get_option('product_label')
        prodId   = self.get_option('product_id')

        if not repoId:
            repo = get_repo(orgName, repoName, prodName, prodLabel, prodId, envName)
            if repo != None:
                repoId = repo["id"]

        return repoId

    def print_packages(self, packages):
        batch_add_columns(self.printer, {'id': _("ID")}, {'name': _("Name")}, {'filename': _("Filename")})
        self.printer.print_items(packages)



class Search(List):

    description = _('search packages in a repository')

    def setup_parser(self, parser):
        super(Search, self).setup_parser(parser)
        parser.add_option('--query', dest='query',
                      help=_("query string for searching packages, e.g. 'kernel*','kernel-3.3.0-4.el6.x86_64'"))

    def check_options(self, validator):
        super(Search, self).check_options(validator)
        validator.require('query')

    def run(self):
        repoId = self.get_repo_id()
        if not repoId:
            return os.EX_DATAERR
        query   = self.get_option('query')
        self.printer.set_header(_("Package List For Repo %(repoId)s and Query %(query)s") % \
            {'repoId':repoId, 'query':query})

        packages = self.api.search(query, repoId)
        self.print_packages(packages)
        return os.EX_OK


# package command ------------------------------------------------------------

class Package(Command):

    description = _('package specific actions in the katello server')
