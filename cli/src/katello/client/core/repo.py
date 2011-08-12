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
import time
import urlparse
from gettext import gettext as _

from katello.client import constants
from katello.client.core.utils import format_date
from katello.client.api.repo import RepoAPI
from katello.client.config import Config
from katello.client.core.base import Action, Command
from katello.client.api.utils import get_environment, get_product, get_repo
from katello.client.core.utils import system_exit, run_async_task_with_status, run_spinner_in_bg
from katello.client.core.utils import ProgressBar

try:
    import json
except ImportError:
    import simplejson as json

Config()

# base action ----------------------------------------------------------------

class RepoAction(Action):

    def __init__(self):
        super(RepoAction, self).__init__()
        self.api = RepoAPI()

    def format_sync_time(self, sync_time):
        if sync_time is None:
            return 'never'
        else:
            return str(format_date(sync_time[0:19], '%Y-%m-%dT%H:%M:%S'))
            #'2011-07-11T15:03:52+02:00

# actions --------------------------------------------------------------------


class Create(RepoAction):

    description = _('create a repository')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                               help=_("organization name eg: foo.example.com (required)"))
        self.parser.add_option('--name', dest='name',
                               help=_("repository name (required)"))
        self.parser.add_option("--url", dest="url",
                               help=_("root url to perform discovery of repositories eg: http://porkchop.devel.redhat.com/ (required)"))
        self.parser.add_option("--assumeyes", action="store_true", dest="assumeyes",
                               help=_("assume yes; automatically create candidate repositories for discovered urls (optional)"))
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
        assumeyes = self.get_option('assumeyes')
        prodName = self.get_option('prod')
        orgName  = self.get_option('org')

        repourls = self.discover_repositories(url)
        self.printer.setHeader(_("Repository Urls discovered @ [%s]" % url))
        selectedurls = self.select_repositories(repourls, assumeyes)

        prod = get_product(orgName, prodName)
        if prod != None:
            self.create_repositories(prod["cp_id"], name, selectedurls)

        return os.EX_OK

    def discover_repositories(self, url):
        print(_("Discovering repository urls, this could take some time..."))
        try:
            task = self.api.repo_discovery(url, 'yum')
        except Exception,e:
            system_exit(os.EX_DATAERR, _("Error: %s" % e))

        discoveryResult = run_spinner_in_bg(self.wait_for_discovery, [task])
        repourls = discoveryResult['result'] or []

        if not len(repourls):
            system_exit(os.EX_OK, "No repositories discovered @ url location [%s]" % url)

        return repourls
            
    def select_repositories(self, repourls, assumeyes):
        selection = Selection()
        if not assumeyes:
            proceed = ''
            num_selects = [str(i+1) for i in range(len(repourls))]
            select_range_str = constants.SELECTION_QUERY % len(repourls)
            while proceed.strip().lower() not in  ['q', 'y']:
                if not proceed.strip().lower() == 'h':
                    self.__print_urls(repourls, selection)
                proceed = raw_input(_("\nSelect urls for which candidate repos should be created; use `y` to confirm (h for help):"))
                select_val = proceed.strip().lower()
                if select_val == 'h':
                    print select_range_str
                elif select_val == 'a':
                    selection.add_selection(repourls)
                elif select_val in num_selects:
                    selection.add_selection([repourls[int(proceed.strip().lower())-1]])
                elif select_val == 'q':
                    selection = Selection()
                    system_exit(os.EX_OK, _("Operation aborted upon user request."))
                elif set(select_val.split(":")).issubset(num_selects):
                    lower, upper = tuple(select_val.split(":"))
                    selection.add_selection(repourls[int(lower)-1:int(upper)])
                elif select_val == 'c':
                    selection = Selection()
                elif select_val == 'y':
                    if not len(selection):
                        proceed = ''
                        continue
                    else:
                        break
                else:
                    continue
        else:
            #select all
            selection.add_selection(repourls)
            self.__print_urls(repourls, selection)
            
        return selection
        
    def create_repositories(self, productid, name, selectedurls):
        for repourl in selectedurls:
            parsedUrl = urlparse.urlparse(repourl)
            repoName = self.repository_name(name, parsedUrl.path)
            repo = self.api.create(productid, repoName, repourl)
            print _("Successfully created repository [ %s ]") % repoName
            
    def repository_name(self, name, parsedUrlPath):
        return "%s%s" % (name, parsedUrlPath.replace("/", "_"))
        
    def __print_urls(self, repourls, selectedurls):
        for index, url in enumerate(repourls):
            if url in selectedurls:
                print "(+)  [%s] %-5s" % (index+1, url)
            else:
                print "(-)  [%s] %-5s" % (index+1, url)

    def wait_for_discovery(self, discoveryTask):
        while discoveryTask['state'] not in ('finished', 'error', 'timed out', 'canceled'):
            time.sleep(0.25)
            discoveryTask = self.api.repo_discovery_status(discoveryTask['id'])

        return discoveryTask

        
class Selection(list):
    def add_selection(self, urls):
        for url in urls:
            if url not in self:
                self.append(url)
    

class Status(RepoAction):

    description = _('status information about a repository')

    def setup_parser(self):
        self.parser.add_option('--id', dest='id',
                               help=_("repo id, string value (required)"))

    def check_options(self):
        self.require_option('id')

    def run(self):
        repo_id = self.get_option('id')
        repo = self.api.repo(repo_id)

        repo['last_sync'] = self.format_sync_time(repo['last_sync'])

        self.printer.addColumn('id')
        self.printer.addColumn('package_count')
        self.printer.addColumn('last_sync')

        self.printer.setHeader(_("Repository Status"))
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
                return os.EX_DATAERR

        repo['url'] = repo['source']['url']
        repo['last_sync'] = self.format_sync_time(repo['last_sync'])

        self.printer.addColumn('id')
        self.printer.addColumn('name')
        self.printer.addColumn('package_count')
        self.printer.addColumn('arch', show_in_grep=False)
        self.printer.addColumn('url', show_in_grep=False)
        self.printer.addColumn('last_sync', show_in_grep=False)

        self.printer.setHeader(_("Information About Repo %s") % repoId)

        self.printer.printItem(repo)
        return os.EX_OK


class Sync(RepoAction):

    description = _('synchronize a repository')

    def setup_parser(self):
        self.parser.add_option('--id', dest='id',
                               help=_("repo id, string value (required)"))

    def check_options(self):
        self.require_option('id')

    def run(self):
        repo_id = self.get_option('id')
        async_task = self.api.sync(repo_id)
        
        result = run_async_task_with_status(async_task, ProgressBar())
        
        if result[0]['state'] == 'finished':    
            print _("Repo [ %s ] synced" % repo_id)
            return os.EX_OK
        else:
            print _("Repo [ %s ] failed to sync: %s" % (repo_id, json.loads(result["result"])['errors'][0]))
            return os.EX_DATAERR


class List(RepoAction):

    description = _('list repos within an organization')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
            help=_("organization name eg: ACME_Corporation (required)"))
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

        if prodName and envName:
            env  = get_environment(orgName, envName)
            prod = get_product(orgName, prodName)
            if env != None and prod != None:
                self.printer.setHeader(_("Repo List For Org %s Environment %s Product %s") % (orgName, env["name"], prodName))
                repos = self.api.repos_by_env_product(env["id"], prod["cp_id"])
                self.printer.printItems(repos)
        elif prodName:
            prod = get_product(orgName, prodName)
            if prod != None:
                self.printer.setHeader(_("Repo List for Product %s in Org %s ") % (prodName, orgName))
                repos = self.api.repos_by_product(prod["cp_id"])
                self.printer.printItems(repos)
        else:
            env  = get_environment(orgName, envName)
            if env != None:
                self.printer.setHeader(_("Repo List For Org %s Environment %s") % (orgName, env["name"]))
                repos = self.api.repos_by_org_env(orgName,  env["id"])
                self.printer.printItems(repos)            

        return os.EX_OK

# command --------------------------------------------------------------------

class Repo(Command):

    description = _('repo specific actions in the katello server')
