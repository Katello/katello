#
# Katello Repos actions
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
import urlparse

from katello.client import constants
from katello.client.api.repo import RepoAPI
from katello.client.api.provider import ProviderAPI
from katello.client.api.utils import get_provider
from katello.client.api.utils import get_environment, get_product, get_repo
from katello.client.cli.base import opt_parser_add_product, opt_parser_add_org, opt_parser_add_environment
from katello.client.core.base import BaseAction, Command

from katello.client.lib.control import system_exit
from katello.client.lib.async import AsyncTask, evaluate_task_status
from katello.client.lib.utils.encoding import u_str
from katello.client.lib.ui import printer
from katello.client.lib.ui.printer import batch_add_columns
from katello.client.lib.ui.progress import ProgressBar, run_async_task_with_status, run_spinner_in_bg
from katello.client.lib.ui.progress import wait_for_async_task
from katello.client.lib.ui.formatters import format_sync_errors, format_sync_time, format_sync_state


ALLOWED_REPO_URL_SCHEMES = ("http", "https", "ftp", "file")



# base action ----------------------------------------------------------------

class RepoAction(BaseAction):

    def __init__(self):
        super(RepoAction, self).__init__()
        self.api = RepoAPI()

    @classmethod
    def get_groupid_param(cls, repo, param_name):
        param_name += ":"
        for gid in repo['groupid']:
            if gid.find(param_name) >= 0:
                return gid[len(param_name):]
        return None

class SingleRepoAction(RepoAction):

    select_by_env = False

    def setup_parser(self, parser):
        self.set_repo_select_options(parser, self.select_by_env)

    @classmethod
    def set_repo_select_options(cls, parser, select_by_env=True):
        parser.add_option('--id', dest='id', help=_("repository ID"))
        parser.add_option('--name', dest='name', help=_("repository name"))
        opt_parser_add_org(parser)
        opt_parser_add_product(parser)
        if select_by_env:
            opt_parser_add_environment(parser, default=_("Library"))

    @classmethod
    def check_options(cls, validator):
        if not validator.exists('id'):
            validator.require(('name', 'org'))
            validator.require_at_least_one_of(('product', 'product_label', 'product_id'))
            validator.mutually_exclude('product', 'product_label', 'product_id')

    def get_repo(self, includeDisabled=False):
        repoId   = self.get_option('id')
        repoName = self.get_option('name')
        orgName  = self.get_option('org')
        prodName = self.get_option('product')
        prodLabel = self.get_option('product_label')
        prodId   = self.get_option('product_id')

        if self.select_by_env:
            envName = self.get_option('environment')
        else:
            envName = None

        if repoId:
            repo = self.api.repo(repoId)
        else:
            repo = get_repo(orgName, repoName, prodName, prodLabel, prodId, envName, includeDisabled)

        return repo


# actions --------------------------------------------------------------------


class Create(RepoAction):

    description = _('create a repository at a specified URL')

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)
        parser.add_option('--name', dest='name',
            help=_("repository name to assign (required)"))

        parser.add_option('--label', dest='label',
                               help=_("repo label, ASCII identifier for the " +
                                      "repository with no spaces eg: custom-repo1"))
        parser.add_option("--url", dest="url", type="url", schemes=ALLOWED_REPO_URL_SCHEMES,
            help=_("url path to the repository (required)"))
        opt_parser_add_product(parser, required=1)
        parser.add_option('--gpgkey', dest='gpgkey',
            help=_("GPG key to be assigned to the repository; by default, the product's GPG key will be used."))
        parser.add_option('--nogpgkey', action='store_true',
            help=_("Don't assign a GPG key to the repository."))

    def check_options(self, validator):
        validator.require(('name', 'org', 'url'))
        validator.require_at_least_one_of(('product', 'product_label', 'product_id'))
        validator.mutually_exclude('product', 'product_label', 'product_id')

    def run(self):
        name     = self.get_option('name')
        label    = self.get_option('label')
        url      = self.get_option('url')
        prodName = self.get_option('product')
        prodLabel = self.get_option('product_label')
        prodId   = self.get_option('product_id')
        orgName  = self.get_option('org')
        gpgkey   = self.get_option('gpgkey')
        nogpgkey   = self.get_option('nogpgkey')

        product = get_product(orgName, prodName, prodLabel, prodId)
        self.api.create(orgName, product["id"], name, label, url, gpgkey, nogpgkey)
        print _("Successfully created repository [ %s ]") % name

        return os.EX_OK

class Discovery(RepoAction):  # pylint: disable=R0904
    #TODO: temporary pylint disable, we need to refactor the class later

    description = _('discovery repositories contained within a URL')
    provider_api = ProviderAPI()

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)
        parser.add_option('--provider', dest='provider',
            help=_("provider name (required)"))
        parser.add_option('--name', dest='name',
            help=_("repository name prefix to add to all the discovered repositories (required)"))
        parser.add_option('--label', dest='label',
                               help=_("repo label, ASCII identifier to add to " +
                                "all discovered repositories.  (will be generated if not specified)"))
        parser.add_option("--url", dest="url", type="url", schemes=ALLOWED_REPO_URL_SCHEMES,
            help=_("root url to perform discovery of repositories eg: http://katello.org/repos/ (required)"))
        parser.add_option("--assumeyes", action="store_true", dest="assumeyes",
            help=_("assume yes; automatically create candidate repositories for discovered urls (optional)"))
        opt_parser_add_product(parser, required=1)

    def check_options(self, validator):
        validator.require(('name', 'org', 'url', 'provider'))
        validator.require_at_least_one_of(('product', 'product_label', 'product_id'))
        validator.mutually_exclude('product', 'product_label', 'product_id')

    def run(self):
        name     = self.get_option('name')
        label    = self.get_option('label')
        url      = self.get_option('url')
        assumeyes = self.get_option('assumeyes')
        providerName   = self.get_option('provider')
        prodName = self.get_option('product')
        prodLabel = self.get_option('product_label')
        prodId   = self.get_option('product_id')
        orgName  = self.get_option('org')

        prov_id = get_provider(orgName, providerName)['id']
        repourls = self.discover_repositories(prov_id, url)
        self.printer.set_header(_("Repository Urls discovered @ [%s]" % url))
        selectedurls = self.select_repositories(repourls, assumeyes)

        product = get_product(orgName, prodName, prodLabel, prodId)
        self.create_repositories(orgName, product["id"], name, label, selectedurls)

        return os.EX_OK

    def discover_repositories(self, provider_id, url):
        print(_("Discovering repository urls, this could take some time..."))
        task = self.provider_api.repo_discovery(provider_id, url)

        run_spinner_in_bg(wait_for_async_task, [task])
        repourls = self.provider_api.provider(provider_id)['discovered_repos']

        if not len(repourls):
            system_exit(os.EX_OK, "No repositories discovered @ url location [%s]" % url)

        return repourls


    def select_repositories(self, repourls, assumeyes, our_raw_input = raw_input):
        selection = Selection()
        if not assumeyes:
            proceed = ''
            num_selects = [u_str(i+1) for i in range(len(repourls))]
            select_range_str = constants.SELECTION_QUERY % len(repourls)
            while proceed.strip().lower() not in  ['q', 'y']:
                if not proceed.strip().lower() == 'h':
                    self.__print_urls(repourls, selection)
                proceed = our_raw_input(
                    _("\nSelect urls for which candidate repos should be created; use `y` to confirm (h for help):"))
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

    def create_repositories(self, orgName, productid, name, label, selectedurls):
        for repourl in selectedurls:
            parsedUrl = urlparse.urlparse(repourl)
            repoName = self.repository_name(name, parsedUrl.path) # pylint: disable=E1101
            repoLabel = None
            if label:
                repoLabel = self.repository_name(label, parsedUrl.path) # pylint: disable=E1101
            self.api.create(orgName, productid, repoName, repoLabel, repourl, None, None)
            print _("Successfully created repository [ %s ]") % repoName

    @classmethod
    def repository_name(cls, name, parsedUrlPath):
        return "%s%s" % (name, parsedUrlPath.replace("/", "_"))

    @classmethod
    def __print_urls(cls, repourls, selectedurls):
        for index, url in enumerate(repourls):
            if url in selectedurls:
                print "(+)  [%s] %-5s" % (index+1, url)
            else:
                print "(-)  [%s] %-5s" % (index+1, url)


class Selection(list):
    def add_selection(self, urls):
        for url in urls:
            if url not in self:
                self.append(url)


class Status(SingleRepoAction):

    description = _('status information about a repository')
    select_by_env = True

    def run(self):
        repo = self.get_repo()

        task = AsyncTask(self.api.last_sync_status(repo['id']))

        if task.is_running():
            pkgsTotal = task.total_count()
            pkgsLeft = task.items_left()
            repo['progress'] = ("%(task_progress)d%% done (%(pkgs_count)d of %(pkgs_total)d packages downloaded)" %
                {'task_progress':task.get_progress()*100, 'pkgs_count':pkgsTotal-pkgsLeft, 'pkgs_total':pkgsTotal})

        repo['last_errors'] = format_sync_errors(task)

        self.printer.add_column('package_count', _("Package Count"))
        self.printer.add_column('last_sync', _("Last Sync"), formatter=format_sync_time)
        self.printer.add_column('sync_state', _("Sync State"), formatter=format_sync_state)
        if 'next_scheduled_sync' in repo:
            self.printer.add_column('next_scheduled_sync', _("Next Scheduled Sync"), formatter=format_sync_time)
        self.printer.add_column('progress', _("Progress"), show_with=printer.VerboseStrategy)
        self.printer.add_column('last_errors', _("Last Errors"), multiline=True, show_with=printer.VerboseStrategy)

        self.printer.set_header(_("Repository Status"))
        self.printer.print_item(repo)
        return os.EX_OK


class Info(SingleRepoAction):

    description = _('information about a repository')
    select_by_env = True

    def run(self):
        repo = self.get_repo(True)

        batch_add_columns(self.printer, {'id': _("ID")}, {'name': _("Name")}, \
            {'package_count': _("Package Count")})
        batch_add_columns(self.printer, {'arch': _("Arch")}, {'feed': _("URL")}, \
            show_with=printer.VerboseStrategy)
        self.printer.add_column('last_sync', _("Last Sync"), \
            show_with=printer.VerboseStrategy, formatter=format_sync_time)
        self.printer.add_column('sync_state', _("Progress"), \
            show_with=printer.VerboseStrategy, formatter=format_sync_state)
        self.printer.add_column('gpg_key_name', _("GPG Key"), \
            show_with=printer.VerboseStrategy)

        self.printer.set_header(_("Information About Repo %s") % repo['id'])

        self.printer.print_item(repo)
        return os.EX_OK

class Update(SingleRepoAction):

    description = _('updates repository attributes')
    select_by_env = True

    def setup_parser(self, parser):
        super(Update, self).setup_parser(parser)
        parser.add_option('--gpgkey', dest='gpgkey',
            help=_("GPG key to be assigned to the repository; by default, the product's GPG key will be used."))
        parser.add_option('--nogpgkey', action='store_true',
            help=_("Don't assign a GPG key to the repository."))

    def run(self):
        repo = self.get_repo(True)
        gpgkey   = self.get_option('gpgkey')
        nogpgkey   = self.get_option('nogpgkey')

        self.api.update(repo['id'], gpgkey, nogpgkey)
        print _("Successfully updated repository [ %s ]") % repo['name']
        return os.EX_OK


class Sync(SingleRepoAction):

    description = _('synchronize a repository')
    select_by_env = False

    def run(self):
        repo = self.get_repo()

        task = AsyncTask(self.api.sync(repo['id']))
        run_async_task_with_status(task, ProgressBar())

        return evaluate_task_status(task,
            failed =   _("Repo [ %s ] failed to sync") % repo["name"],
            canceled = _("Repo [ %s ] synchronization canceled") % repo["name"],
            ok =       _("Repo [ %s ] synchronized") % repo["name"]
        )


class CancelSync(SingleRepoAction):

    description = _('cancel currently running synchronization of a repository')
    select_by_env = False

    def run(self):
        repo = self.get_repo()

        msg = self.api.cancel_sync(repo['id'])
        print msg
        return os.EX_OK

class Enable(SingleRepoAction):

    @property
    def description(self):
        if self._enable:
            return _('enable a repository')
        else:
            return _('disable a repository')

    select_by_env = False

    def __init__(self, enable = True):
        self._enable = enable
        super(Enable, self).__init__()

    def run(self):
        repo = self.get_repo(True)

        msg = self.api.enable(repo["id"], self._enable)
        print msg

        return os.EX_OK


class List(RepoAction):

    description = _('list repos within an organization')

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)
        opt_parser_add_environment(parser, default=_("Library"))
        opt_parser_add_product(parser)
        parser.add_option('--include_disabled', action="store_true", dest='disabled',
            help=_("list also disabled repositories"))

    def check_options(self, validator):
        validator.require('org')
        validator.mutually_exclude('product', 'product_label', 'product_id')

    def run(self):
        orgName = self.get_option('org')
        envName = self.get_option('environment')
        prodName = self.get_option('product')
        prodLabel = self.get_option('product_label')
        prodId = self.get_option('product_id')
        listDisabled = self.has_option('disabled')

        batch_add_columns(self.printer, {'id': _("ID")}, {'name': _("Name")}, \
            {'label': _("Label")}, {'package_count': _("Package Count")})
        self.printer.add_column('last_sync', _("Last Sync"), formatter=format_sync_time)

        prodIncluded = prodName or prodLabel or prodId
        if prodIncluded and envName:
            env  = get_environment(orgName, envName)
            prod = get_product(orgName, prodName, prodLabel, prodId)

            self.printer.set_header(_("Repo List For Org %(org_name)s Environment %(env_name)s Product %(prodName)s") %
                {'org_name':orgName, 'env_name':env["name"], 'prodName':prodName})
            repos = self.api.repos_by_env_product(env["id"], prod["id"], None, listDisabled)
            self.printer.print_items(repos)

        elif prodIncluded:
            prod = get_product(orgName, prodName, prodLabel, prodId)
            self.printer.set_header(_("Repo List for Product %(prodName)s in Org %(orgName)s ") %
                {'prodName':prodName, 'orgName':orgName})
            repos = self.api.repos_by_product(orgName, prod["id"], listDisabled)
            self.printer.print_items(repos)

        else:
            env  = get_environment(orgName, envName)
            self.printer.set_header(_("Repo List For Org %(orgName)s Environment %(env_name)s") %
                {'orgName':orgName, 'env_name':env["name"]})
            repos = self.api.repos_by_org_env(orgName,  env["id"], listDisabled)
            self.printer.print_items(repos)

        return os.EX_OK


class Delete(SingleRepoAction):

    description = _('delete a repository')
    select_by_env = False

    def run(self):
        repo = self.get_repo()

        msg = self.api.delete(repo["id"])
        print msg
        return os.EX_OK

# command --------------------------------------------------------------------

class Repo(Command):

    description = _('repo specific actions in the katello server')
