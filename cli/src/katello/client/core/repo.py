#!/usr/bin/python
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
import urlparse
from gettext import gettext as _
from pprint import pprint

from katello.client.core.utils import is_valid_record, format_date
from katello.client.api.repo import RepoAPI
from katello.client.api.environment import EnvironmentAPI
from katello.client.config import Config
from katello.client.core.base import Action, Command
from katello.client.api.utils import get_environment, get_product, get_repo

_cfg = Config()

# base action ----------------------------------------------------------------

class RepoAction(Action):

    def __init__(self):
        super(RepoAction, self).__init__()
        self.api = RepoAPI()

    def format_sync_time(self, sync_time):
        if sync_time is None:
            return 'never'
        else:
            return str(format_date(sync_time))

# actions --------------------------------------------------------------------


class Create(RepoAction):

    description = _('create a repository')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                               help=_("organization name eg: foo.example.com (required)"))
        self.parser.add_option('--name', dest='name',
                               help=_("repository name (required)"))
        self.parser.add_option("--url", dest="url",
                               help=_("repository url eg: http://download.fedoraproject.org/pub/fedora/linux/releases/ (required)"))
        self.parser.add_option('--product', dest='prod',
                               help=_("product name (required)"))

    def check_options(self):
        self.require_option('org')
        self.require_option('name')
        self.require_option('url')
        self.require_option('prod', '--product')

    def run(self):
        name     = self.get_option('name')
        url      = self.get_option('url')
        prodName = self.get_option('prod')
        orgName  = self.get_option('org')

        prod = get_product(orgName, prodName)
        if prod != None:
          
            repo = self.api.create(prod["cp_id"], name, url)
            print _("Successfully created repository [ %s ]") % name
                
        return os.EX_OK


class Status(RepoAction):

    description = _('status information about a repository')

    def setup_parser(self):
        self.parser.add_option('--id', dest='id',
                               help=_("repo id, string value (required)"))

    def check_options(self):
        self.require_option('id')

    def run(self):
        id = self.get_option('id')
        repo = self.api.repo(id)

        repo['last_sync'] = self.format_sync_time(repo['last_sync'])

        self.printer.addColumn('id')
        self.printer.addColumn('package_count')
        self.printer.addColumn('last_sync')

        self.printer.printHeader(_("Repository Status"))
        self.printer.printItem(repo)
        return os.EX_OK


class Info(RepoAction):

    description = _('information about a repository')

    def setup_parser(self):
        self.parser.add_option('--repo_id', dest='repo_id',
                      help=_("repository id"))
        self.parser.add_option('--repo', dest='repo',
                      help=_("repository name"))
        self.parser.add_option('--org', dest='org',
                      help=_("organization name eg: foo.example.com"))
        self.parser.add_option('--environment', dest='env',
                      help=_("environment name eg: production (default: locker)"))
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

        if repoId:
            repo = self.api.repo(repoId)
        else:
            repo = get_repo(orgName, prodName, repoName, envName)
            if repo == None:
                return os.EX_OK
                
        repo['url'] = repo['source']['url']
        repo['last_sync'] = self.format_sync_time(repo['last_sync'])

        self.printer.addColumn('id')
        self.printer.addColumn('name')
        self.printer.addColumn('package_count')
        self.printer.addColumn('arch', show_in_grep=False)
        self.printer.addColumn('url', show_in_grep=False)
        self.printer.addColumn('last_sync', show_in_grep=False)

        self.printer.printHeader(_("Information About Repo %s") % repoId)

        self.printer.printItem(repo)


class Sync(RepoAction):

    description = _('synchronize a repository')

    def setup_parser(self):
        self.parser.add_option('--id', dest='id',
                               help=_("repo id, string value (required)"))

    def check_options(self):
        self.require_option('id')

    def run(self):
        id = self.get_option('id')
        msg = self.api.sync(id)

        print msg
        return os.EX_OK


class List(RepoAction):

    description = _('list repos within an organization')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
            help=_("organization name eg: foo.example.com (required)"))
        self.parser.add_option('--environment', dest='env',
            help=_("environment name eg: production (default: locker)"))
        self.parser.add_option('--product', dest='product',
            help=_("product name eg: fedora-14"))

    def check_options(self):
        self.require_option('org')

    def run(self):
        orgName = self.get_option('org')
        envName = self.get_option('env')
        prodName = self.get_option('product')

        self.printer.addColumn('id')
        self.printer.addColumn('name')
        self.printer.addColumn('package_count')

        if prodName:
            env  = get_environment(orgName, envName)
            prod = get_product(orgName, prodName)
            if env != None and prod != None:
                
                self.printer.printHeader(_("Repo List for Product %s in Org %s Environment %s") % (prodName, orgName, env["name"]))
                repos = self.api.repos_by_org_env_product(orgName, env["id"], prod["cp_id"])
                self.printer.printItems(repos)
                
        else:
            env  = get_environment(orgName, envName)
            if env != None:
                self.printer.printHeader(_("Repo List For Org %s Environment %s") % (orgName, env["name"]))
                repos = self.api.repos_by_org_env(orgName,  env["id"])
                self.printer.printItems(repos)
        
        return os.EX_OK


# command --------------------------------------------------------------------

class Repo(Command):

    description = _('repo specific actions in the katello server')
