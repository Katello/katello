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
from urlparse import urlparse

from katello.client.api.provider import ProviderAPI
from katello.client.server import ServerRequestError
from katello.client.config import Config
from katello.client.core.base import Action, Command
from katello.client.core.utils import is_valid_record, get_abs_path, run_async_task_with_status, run_spinner_in_bg, AsyncTask, format_sync_errors
from katello.client.core.repo import format_sync_state, format_sync_time
from katello.client.core.utils import ProgressBar
from katello.client.api.utils import get_provider


Config()


# base provider action =========================================================
class ProviderAction(Action):

    def __init__(self):
        super(ProviderAction, self).__init__()
        self.api = ProviderAPI()


class SingleProviderAction(ProviderAction):

    def setup_parser(self):
        self.parser.add_option('--name', dest='name',
                               help=_("provider name (required)"))
        self.parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))

    def check_options(self):
        self.require_option('name')
        self.require_option('org')



# provider actions =============================================================
class List(ProviderAction):

    description = _('list all known providers')


    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                               help=_("organization name (required)"))

    def check_options(self):
        self.require_option('org')

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
        if prov != None:
            self.printer.add_column('id')
            self.printer.add_column('name')
            self.printer.add_column('provider_type', 'Type')
            self.printer.add_column('repository_url', 'Url')
            self.printer.add_column('organization_id', 'Org Id')
            self.printer.add_column('description', multiline=True)

            self.printer.set_header(_("Provider Information"))
            self.printer.print_item(prov)
            return os.EX_OK
        else:
            return os.EX_DATAERR


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



    def setup_parser(self):
        self.parser.add_option('--name', dest='name',
                               help=_("provider name (required)"))
        self.parser.add_option("--description", dest="description",
                               help=_("provider description"))
        self.parser.add_option("--url", dest="url",
                               help=_("repository url eg: http://download.fedoraproject.org/pub/fedora/linux/releases/"))
        self.parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))

        if not self._create:
            self.parser.add_option('--new_name', dest='new_name',
                                  help=_("provider name"))


    def check_options(self):

        self.require_option('name')
        self.require_option('org')

        if self.has_option('url'):
            url = self.get_option('url')
            url_parsed = urlparse(url)
            if not url_parsed.scheme in ["http","https"]:                       # pylint: disable=E1101
                self.add_option_error(_('Option --url has to start with http:// or https://'))
            elif not url_parsed.netloc:                                         # pylint: disable=E1101
                self.add_option_error(_('Option --url is not in a valid format'))


    def create(self, name, orgName, description, url):
        prov = self.api.create(name, orgName, description, "Custom", url)
        if is_valid_record(prov):
            print _("Successfully created provider [ %s ]") % prov['name']
            return True
        else:
            print >> sys.stderr, _("Could not create provider [ %s ]") % prov['name']
            return False


    def update(self, name, orgName, newName, description, url):

        prov = get_provider(orgName, name)
        if prov != None:
            prov = self.api.update(prov["id"], newName, description, url)
            print _("Successfully updated provider [ %s ]") % prov['name']
            return True
        else:
            return False


    def run(self):
        name        = self.get_option('name')
        newName     = self.get_option('new_name')
        orgName     = self.get_option('org')
        description = self.get_option('description')
        url         = self.get_option('url')

        if self._create:
            if not self.create(name, orgName, description, url):
                return os.EX_DATAERR
        else:
            if not self.update(name, orgName, newName, description, url):
                return os.EX_DATAERR

        return os.EX_OK


# ==============================================================================
class Delete(SingleProviderAction):

    description = _('delete a provider')

    def run(self):
        provName = self.get_option('name')
        orgName  = self.get_option('org')

        prov = get_provider(orgName, provName)
        if prov != None:
            msg = self.api.delete(prov["id"])
            print msg
            return os.EX_OK
        else:
            return os.EX_DATAERR


# ==============================================================================
class Sync(SingleProviderAction):

    description = _('synchronize a provider')

    def run(self):
        provName = self.get_option('name')
        orgName  = self.get_option('org')
        return self.sync_provider(provName, orgName)

    def sync_provider(self, providerName, orgName):
        prov = get_provider(orgName, providerName)
        if prov == None:
            return os.EX_DATAERR

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
        if prov == None:
            return os.EX_DATAERR

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
        if prov == None:
            return os.EX_DATAERR

        task = AsyncTask(self.api.last_sync_status(prov['id']))

        prov['last_sync'] = format_sync_time(prov['last_sync'])
        prov['sync_state'] = format_sync_state(prov['sync_state'])

        if task.is_running():
            pkgsTotal = task.total_count()
            pkgsLeft = task.items_left()
            prov['progress'] = ("%d%% done (%d of %d packages downloaded)" % (task.get_progress()*100, pkgsTotal-pkgsLeft, pkgsTotal))

        #TODO: last errors?

        self.printer.add_column('id')
        self.printer.add_column('name')

        self.printer.add_column('last_sync')
        self.printer.add_column('sync_state')
        self.printer.add_column('progress', show_in_grep=False)

        self.printer.set_header(_("Provider Status"))
        self.printer.print_item(prov)
        return os.EX_OK


# ==============================================================================
class ImportManifest(SingleProviderAction):

    description = _('import a manifest file')


    def setup_parser(self):
        super(ImportManifest, self).setup_parser()
        self.parser.add_option("--file", dest="file",
                               help=_("path to the manifest file (required)"))
        self.parser.add_option("--force", dest="force", action="store_true",
                               help=_("force reimporting the manifest"))


    def check_options(self):
        super(ImportManifest, self).check_options()
        self.require_option('file')


    def run(self):
        provName = self.get_option('name')
        orgName  = self.get_option('org')
        manifestPath = self.get_option('file')
        force = self.get_option('force')

        try:
            f = open(get_abs_path(manifestPath))
        except:
            print _("File %s does not exist" % manifestPath)
            return os.EX_IOERR

        prov = get_provider(orgName, provName)
        if prov != None:
            try:
                response = run_spinner_in_bg(self.api.import_manifest, (prov["id"], f, force), message=_("Importing manifest, please wait... "))
            except ServerRequestError, re:
                if re.args[0] == 400 and "displayMessage" in re.args[1] and re.args[1]["displayMessage"] == "Import is older than existing data":
                    re.args[1]["displayMessage"] = "Import is older then existing data, please try with --force option to import manifest."
                raise re
            f.close()
            print response
            return os.EX_OK
        else:
            f.close()
            return os.EX_DATAERR

# ------------------------------------------------------------------------------
class RefreshProducts(SingleProviderAction):

    description = _('refresh provider\'s products repositories')

    def run(self):
        provName = self.get_option('name')
        orgName  = self.get_option('org')

        prov = get_provider(orgName, provName)
        if prov == None:
            return os.EX_DATAERR

        self.api.refresh_products(prov["id"])
        print _("Provider successfully refreshed [ %s ]") % prov['name']
        return os.EX_OK

# provider command =============================================================

class Provider(Command):

    description = _('provider specific actions in the katello server')
