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
import sys

from katello.client.api.provider import ProviderAPI
from katello.client.cli.base import opt_parser_add_org
from katello.client.server import ServerRequestError
from katello.client.core.base import BaseAction, Command
from katello.client.lib.ui.progress import run_async_task_with_status, run_spinner_in_bg, wait_for_async_task
from katello.client.lib.control import system_exit
from katello.client.lib.async import AsyncTask, ImportManifestAsyncTask, evaluate_task_status
from katello.client.lib.utils.io import get_abs_path
from katello.client.lib.utils.data import test_record
from katello.client.lib.ui.formatters import format_sync_state, format_sync_time
from katello.client.lib.ui.progress import ProgressBar
from katello.client.lib.ui import printer
from katello.client.api.utils import get_provider



# base provider action =========================================================
class ProviderAction(BaseAction):

    def __init__(self):
        super(ProviderAction, self).__init__()
        self.api = ProviderAPI()


class SingleProviderAction(ProviderAction):

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name',
                               help=_("provider name (required)"))
        opt_parser_add_org(parser, required=1)

    def check_options(self, validator):
        validator.require('name')
        validator.require('org')



# provider actions =============================================================
class List(ProviderAction):

    description = _('list all known providers')


    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)

    def check_options(self, validator):
        validator.require('org')

    def run(self):
        orgName = self.get_option('org')

        provs = self.api.providers_by_org(orgName)

        self.printer.add_column('id', _("ID"))
        self.printer.add_column('name', _("Name"))
        self.printer.add_column('provider_type', _("Type"))
        self.printer.add_column('repository_url', _("URL"))
        #self.printer.add_column('organization_id', _("Org ID"))
        self.printer.add_column('description', _("Description"), multiline=True)

        self.printer.set_header(_("Provider List"))
        self.printer.print_items(provs)
        return os.EX_OK


# ==============================================================================
class Info(SingleProviderAction):

    description = _('list information about a provider')

    def run(self):
        provName = self.get_option('name')
        orgName  = self.get_option('org')

        prov = get_provider(orgName, provName)

        self.printer.add_column('id', _("ID"))
        self.printer.add_column('name', _("Name"))
        self.printer.add_column('provider_type', _("Type"))
        self.printer.add_column('repository_url', _("URL"))
        self.printer.add_column('organization_id', _("Org ID"))
        self.printer.add_column('description', _("Description"), multiline=True)

        self.printer.set_header(_("Provider Information"))
        self.printer.print_item(prov)
        return os.EX_OK



# ==============================================================================
class Update(ProviderAction):

    @property
    def description(self):
        if self._create:
            return _('create a provider')
        else:
            return _('update a provider')


    def __init__(self, create = False):
        self._create = create
        super(Update, self).__init__()



    def setup_parser(self, parser):
        parser.add_option('--name', dest='name',
            help=_("provider name (required)"))
        parser.add_option("--description", dest="description",
            help=_("provider description"))
        parser.add_option("--url", dest="url", type="url",
            help=_("repository url eg: http://download.fedoraproject.org/pub/fedora/linux/releases/"))
        opt_parser_add_org(parser, required=1)

        if not self._create:
            parser.add_option('--new_name', dest='new_name',
                                  help=_("provider name"))


    def check_options(self, validator):
        validator.require(('name', 'org'))


    def create(self, name, orgName, description, url):
        prov = self.api.create(name, orgName, description, "Custom", url)
        test_record(prov,
            _("Successfully created provider [ %s ]") % name,
            _("Could not create provider [ %s ]") % name
        )


    def update(self, name, orgName, newName, description, url):
        prov = get_provider(orgName, name)
        prov = self.api.update(prov["id"], newName, description, url)
        system_exit(os.EX_OK, _("Successfully updated provider [ %s ]") % prov['name'])

    def run(self):
        name        = self.get_option('name')
        newName     = self.get_option('new_name')
        orgName     = self.get_option('org')
        description = self.get_option('description')
        url         = self.get_option('url')

        if self._create:
            self.create(name, orgName, description, url)
        else:
            self.update(name, orgName, newName, description, url)


# ==============================================================================
class Delete(SingleProviderAction):

    description = _('delete a provider')

    def run(self):
        provName = self.get_option('name')
        orgName  = self.get_option('org')

        prov = get_provider(orgName, provName)

        msg = self.api.delete(prov["id"])
        print msg
        return os.EX_OK


# ==============================================================================
class Sync(SingleProviderAction):

    description = _('synchronize a provider')

    def run(self):
        provName = self.get_option('name')
        orgName  = self.get_option('org')
        return self.sync_provider(provName, orgName)

    def sync_provider(self, providerName, orgName):
        prov = get_provider(orgName, providerName)

        task = AsyncTask(self.api.sync(prov["id"]))
        run_async_task_with_status(task, ProgressBar())

        return evaluate_task_status(task,
            failed =   _("Provider [ %s ] failed to sync") % providerName,
            canceled = _("Provider [ %s ] synchronization canceled") % providerName,
            ok =       _("Provider [ %s ] synchronized") % providerName
        )



class CancelSync(SingleProviderAction):

    description = _('cancel currently running synchronization')

    def run(self):
        provName = self.get_option('name')
        orgName  = self.get_option('org')

        prov = get_provider(orgName, provName)

        msg = self.api.cancel_sync(prov["id"])
        print msg

        return os.EX_OK


# ------------------------------------------------------------------------------
class Status(SingleProviderAction):

    description = _('status of provider\'s synchronization')

    def run(self):
        provName = self.get_option('name')
        orgName  = self.get_option('org')

        prov = get_provider(orgName, provName)

        task = AsyncTask(self.api.last_sync_status(prov['id']))

        if task.is_running():
            pkgsTotal = task.total_count()
            pkgsLeft = task.items_left()
            prov['progress'] = (_("%(task_progress)d%% done (%(pkgsCount)d of %(pkgsTotal)d packages downloaded)") % \
                {'task_progress':task.get_progress()*100, 'pkgsCount':pkgsTotal-pkgsLeft, 'pkgsTotal':pkgsTotal})

        #TODO: last errors?

        self.printer.add_column('id', _("ID"))
        self.printer.add_column('name', _("Name"))

        self.printer.add_column('last_sync', _("Last Sync"), formatter=format_sync_time)
        self.printer.add_column('sync_state', _("Sync State"), formatter=format_sync_state)
        self.printer.add_column('progress', _("Progress"), show_with=printer.VerboseStrategy)

        self.printer.set_header(_("Provider Status"))
        self.printer.print_item(prov)
        return os.EX_OK


# ==============================================================================
class ImportManifest(SingleProviderAction):

    description = _('import a manifest file')


    def setup_parser(self, parser):
        super(ImportManifest, self).setup_parser(parser)
        parser.add_option("--file", dest="file",
                               help=_("path to the manifest file (required)"))
        parser.add_option("--force", dest="force", action="store_true",
                               help=_("force reimporting the manifest"))


    def check_options(self, validator):
        super(ImportManifest, self).check_options(validator)
        validator.require('file')


    def run(self):
        provName = self.get_option('name')
        orgName  = self.get_option('org')
        manifestPath = self.get_option('file')
        force = self.get_option('force')

        try:
            f = open(get_abs_path(manifestPath))
        except IOError:
            system_exit(os.EX_IOERR, _("File %s does not exist") % manifestPath)

        prov = get_provider(orgName, provName)

        task = ImportManifestAsyncTask(self.api.import_manifest(prov["id"], f, force))
        run_spinner_in_bg(wait_for_async_task, [task], message=_("Importing manifest, please wait... "))

        return ImportManifestAsyncTask.evaluate_task_status(task,
            failed =   _("Provider [ %s ] failed to import manifest") % provName,
            canceled = _("Provider [ %s ] canceled manifest import") % provName,
            ok =       _("Provider [ %s ] manifest import complete") % provName
        )


# ==============================================================================
class DeleteManifest(SingleProviderAction):

    description = _('delete an imported manifest')

    def run(self):
        provName = self.get_option('name')
        orgName  = self.get_option('org')

        prov = get_provider(orgName, provName)

        try:
            response = run_spinner_in_bg(self.api.delete_manifest, [prov["id"]],
                message=_("Deleting manifest, please wait... "))
        except ServerRequestError, re:
            raise re, None, sys.exc_info()[2]
        print response
        return os.EX_OK


# ------------------------------------------------------------------------------
class RefreshProducts(SingleProviderAction):

    description = _('refresh provider\'s products repositories')

    def run(self):
        provName = self.get_option('name')
        orgName  = self.get_option('org')

        prov = get_provider(orgName, provName)

        self.api.refresh_products(prov["id"])
        print _("Provider successfully refreshed [ %s ]") % prov['name']
        return os.EX_OK

# provider command =============================================================

class Provider(Command):

    description = _('provider specific actions in the katello server')
