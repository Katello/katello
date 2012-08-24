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
from gettext import gettext as _
from urlparse import urlparse

from katello.client.api.provider import ProviderAPI
from katello.client.cli.base import opt_parser_add_org
from katello.client.server import ServerRequestError
from katello.client.core.base import BaseAction, Command
from katello.client.core.utils import test_record, get_abs_path, run_async_task_with_status, run_spinner_in_bg, AsyncTask, format_sync_errors, system_exit
from katello.client.core.repo import format_sync_state, format_sync_time
from katello.client.core.utils import ProgressBar
from katello.client.api.utils import get_provider
from katello.client.utils import printer



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

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('provider_type', 'Type')
        self.printer.add_column('repository_url', 'Url')
        #self.printer.add_column('organization_id', 'Org Id')
        self.printer.add_column('description', multiline=True)

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

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('provider_type', 'Type')
        self.printer.add_column('repository_url', 'Url')
        self.printer.add_column('organization_id', 'Org Id')
        self.printer.add_column('description', multiline=True)

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

        if task.failed():
            errors = format_sync_errors(task)
            print _("Provider [ %s ] failed to sync: %s" % (providerName, errors))
            return os.EX_DATAERR
        elif task.cancelled():
            print _("Provider [ %s ] synchronization cancelled" % providerName)
            return os.EX_DATAERR

        print _("Provider [ %s ] synchronized" % providerName)
        return os.EX_OK


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
            prov['progress'] = (_("%d%% done (%d of %d packages downloaded)") % (task.get_progress()*100, pkgsTotal-pkgsLeft, pkgsTotal))

        #TODO: last errors?

        self.printer.add_column('id')
        self.printer.add_column('name')

        self.printer.add_column('last_sync', formatter=format_sync_time)
        self.printer.add_column('sync_state', formatter=format_sync_state)
        self.printer.add_column('progress', show_with=printer.VerboseStrategy)

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
        except:
            system_exit(os.EX_IOERR, _("File %s does not exist" % manifestPath))

        prov = get_provider(orgName, provName)

        try:
            response = run_spinner_in_bg(self.api.import_manifest, (prov["id"], f, force), message=_("Importing manifest, please wait... "))
        except ServerRequestError, re:
            if re.args[0] == 400 and "displayMessage" in re.args[1] and re.args[1]["displayMessage"] == "Import is older than existing data":
                re.args[1]["displayMessage"] = "Import is older then existing data, please try with --force option to import manifest."
            raise re
        f.close()
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
