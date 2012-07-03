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
from gettext import gettext as _
import datetime

from katello.client.core import repo
from katello.client.api.product import ProductAPI
from katello.client.api.repo import RepoAPI
from katello.client.core.repo import format_sync_state, format_sync_time, ALLOWED_REPO_URL_SCHEMES
from katello.client.api.changeset import ChangesetAPI
from katello.client.config import Config
from katello.client.core.base import BaseAction, Command
from katello.client.api.utils import get_environment, get_provider, get_product, get_sync_plan, get_filter
from katello.client.core.utils import run_async_task_with_status, run_spinner_in_bg, wait_for_async_task, AsyncTask, format_task_errors
from katello.client.core.utils import ProgressBar
from katello.client.utils import printer

Config()



# base product action --------------------------------------------------------

class ProductAction(BaseAction):

    def __init__(self):
        super(ProductAction, self).__init__()
        self.api = ProductAPI()
        self.repoapi = RepoAPI()
        self.csapi = ChangesetAPI()


class SingleProductAction(ProductAction):

    select_by_env = False

    def setup_parser(self, parser):
        self.set_product_select_options(parser, self.select_by_env)

    def check_options(self, validator):
        self.check_product_select_options(validator)

    def set_product_select_options(self, parser, select_by_env=True):
        parser.add_option('--org', dest='org', help=_("organization name eg: foo.example.com (required)"))
        parser.add_option('--name', dest='name', help=_("product name (required)"))
        if select_by_env:
            parser.add_option('--environment', dest='env', help=_("environment name eg: production (default: Library)"))

    def check_product_select_options(self, validator):
        validator.require(('org', 'name'))


# product actions ------------------------------------------------------------


class SetSyncPlan(SingleProductAction):

    description = _('set a synchronization plan')
    select_by_env = False

    def setup_parser(self, parser):
        self.set_product_select_options(parser, self.select_by_env)
        parser.add_option('--plan', dest='plan', help=_("synchronization plan name (required)"))

    def check_options(self, validator):
        self.check_product_select_options(validator)
        validator.require('plan')

    def run(self):
        orgName  = self.get_option('org')
        prodName = self.get_option('name')
        planName = self.get_option('plan')

        prod = get_product(orgName, prodName)
        plan = get_sync_plan(orgName, planName)

        msg = self.api.set_sync_plan(orgName, prod['id'], plan['id'])
        print msg
        return os.EX_OK



class RemoveSyncPlan(SingleProductAction):

    description = _('unset a synchronization plan')
    select_by_env = False

    def run(self):
        orgName  = self.get_option('org')
        prodName = self.get_option('name')

        prod = get_product(orgName, prodName)

        msg = self.api.remove_sync_plan(orgName, prod['id'])
        print msg
        return os.EX_OK

class List(ProductAction):

    description = _('list known products')

    def setup_parser(self, parser):
        parser.add_option('--org', dest='org',
                       help=_("organization name eg: foo.example.com (required)"))
        parser.add_option('--environment', dest='env',
                       help=_('environment name eg: production (default: Library)'))
        parser.add_option('--provider', dest='prov',
                       help=_("provider name, lists provider's product in the Library"))
        parser.add_option('--all', dest='all', action='store_true',
                       help=_("list marketing products (hidden by default)"))

    def check_options(self, validator):
        validator.require('org')

    def run(self):
        org_name = self.get_option('org')
        env_name = self.get_option('env')
        prov_name = self.get_option('prov')
        all = self.get_option('all')

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('provider_id')
        self.printer.add_column('provider_name')
        self.printer.add_column('sync_plan_name')
        self.printer.add_column('last_sync', formatter=format_sync_time)
        self.printer.add_column('gpg_key_name', name=_("GPG key"))

        if prov_name:
            prov = get_provider(org_name, prov_name)

            self.printer.set_header(_("Product List For Provider %s") % (prov_name))
            prods = self.api.products_by_provider(prov["id"])

        else:
            env = get_environment(org_name, env_name)

            self.printer.set_header(_("Product List For Organization %s, Environment '%s'") % (org_name, env["name"]))
            prods = self.api.products_by_env(env['id'])

        # hide marketing products by default
        if not all:
            def isMarketingProduct(p):
                try:
                    return not p["marketing_product"]
                except:
                    return True
            prods = filter(isMarketingProduct, prods)

        self.printer.print_items(prods)
        return os.EX_OK


# ------------------------------------------------------------------------------
class Sync(SingleProductAction):

    description = _('synchronize a product')
    select_by_env = False

    def run(self):
        orgName     = self.get_option('org')
        prodName    = self.get_option('name')

        prod = get_product(orgName, prodName)

        task = AsyncTask(self.api.sync(orgName, prod["id"]))
        run_async_task_with_status(task, ProgressBar())

        if task.failed():
            errors = [t["result"]['errors'][0] for t in task.get_hashes() if t['state'] == 'error' and
                                                                             isinstance(t["result"], dict) and
                                                                             "errors" in t["result"]]
            print _("Product [ %s ] failed to sync: %s" % (prodName, errors))
            return os.EX_DATAERR
        elif task.cancelled():
            print _("Product [ %s ] synchronization cancelled" % prodName)
            return os.EX_DATAERR

        print _("Product [ %s ] synchronized" % prodName)
        return os.EX_OK

# ------------------------------------------------------------------------------
class CancelSync(SingleProductAction):

    description = _('cancel currently running synchronization')
    select_by_env = False

    def run(self):
        orgName     = self.get_option('org')
        prodName    = self.get_option('name')

        prod = get_product(orgName, prodName)

        msg = self.api.cancel_sync(orgName, prod["id"])
        print msg
        return os.EX_OK


# ------------------------------------------------------------------------------
class Status(SingleProductAction):

    description = _('status of product\'s synchronization')
    select_by_env = False

    def run(self):
        orgName     = self.get_option('org')
        prodName    = self.get_option('name')

        prod = get_product(orgName, prodName)

        task = AsyncTask(self.api.last_sync_status(orgName, prod['id']))

        if task.is_running():
            pkgsTotal = task.total_count()
            pkgsLeft = task.items_left()
            prod['progress'] = ("%d%% done (%d of %d packages downloaded)" % (task.get_progress()*100, pkgsTotal-pkgsLeft, pkgsTotal))

        #TODO: last errors?

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('provider_id')
        self.printer.add_column('provider_name')
        self.printer.add_column('last_sync', formatter=format_sync_time)
        self.printer.add_column('sync_state', formatter=format_sync_state)
        self.printer.add_column('progress', show_with=printer.VerboseStrategy)

        self.printer.set_header(_("Product Status"))
        self.printer.print_item(prod)
        return os.EX_OK


# ------------------------------------------------------------------------------
class Promote(SingleProductAction):

    description = _('promote a product to an environment\n(creates a temporary changeset with the product and promotes it)')
    select_by_env = True

    def check_options(self, validator):
        self.check_product_select_options(validator)
        validator.require('env')

    def run(self):
        orgName     = self.get_option('org')
        prodName    = self.get_option('name')
        envName     = self.get_option('env')

        env = get_environment(orgName, envName)
        prod = get_product(orgName, prodName)

        returnCode = os.EX_OK

        cset = self.csapi.create(orgName, env["id"], self.create_cs_name())
        try:
            self.csapi.add_content(cset["id"], "products", {'product_id': prod['id']})
            task = self.csapi.promote(cset["id"])
            task = AsyncTask(task)

            run_spinner_in_bg(wait_for_async_task, [task], message=_("Promoting the product, please wait... "))

            if task.succeeded():
                print _("Product [ %s ] promoted to environment [ %s ] " % (prodName, envName))
                returnCode = os.EX_OK
            else:
                print _("Product [ %s ] promotion failed: %s" % (prodName, format_task_errors(task.errors())) )
                returnCode = os.EX_DATAERR

        except Exception as e:
            #exception message is printed from action's main method
            raise e

        return returnCode

    def create_cs_name(self):
        curTime = datetime.datetime.now()
        return "product_promotion_"+str(curTime)

# ------------------------------------------------------------------------------
class Create(ProductAction):

    def __init__(self):
        super(Create, self).__init__()
        self.discoverRepos = repo.Discovery()

    description = _('create new product to a custom provider')

    def setup_parser(self, parser):
        parser.add_option('--org', dest='org',
                               help=_("organization name eg: foo.example.com (required)"))
        parser.add_option('--provider', dest='prov',
                               help=_("provider name (required)"))
        parser.add_option('--name', dest='name',
                               help=_("product name (required)"))
        parser.add_option("--description", dest="description",
                               help=_("product description"))
        parser.add_option("--url", dest="url", type="url", schemes=ALLOWED_REPO_URL_SCHEMES,
                               help=_("repository url eg: http://download.fedoraproject.org/pub/fedora/linux/releases/"))
        parser.add_option("--nodisc", action="store_true", dest="nodiscovery",
                               help=_("skip repository discovery"))
        parser.add_option("--assumeyes", action="store_true", dest="assumeyes",
                               help=_("assume yes; automatically create candidate repositories for discovered urls (optional)"))
        parser.add_option("--gpgkey", dest="gpgkey",
                               help=_("assign a gpg key; this key will be used for every new repository unless gpgkey or nogpgkey is specified for the repo"))


    def check_options(self, validator):
        validator.require(('org', 'prov', 'name'))

    def run(self):
        provName    = self.get_option('prov')
        orgName     = self.get_option('org')
        name        = self.get_option('name')
        description = self.get_option('description')
        url         = self.get_option('url')
        assumeyes   = self.get_option('assumeyes')
        nodiscovery = self.get_option('nodiscovery')
        gpgkey      = self.get_option('gpgkey')

        return self.create_product_with_repos(provName, orgName, name, description, url, assumeyes, nodiscovery, gpgkey)


    def create_product_with_repos(self, provName, orgName, name, description, url, assumeyes, nodiscovery, gpgkey):
        prov = get_provider(orgName, provName)

        prod = self.api.create(prov["id"], name, description, gpgkey)
        print _("Successfully created product [ %s ]") % name

        if url == None:
            return os.EX_OK

        if not nodiscovery:
            repourls = self.discoverRepos.discover_repositories(orgName, url)
            self.printer.set_header(_("Repository Urls discovered @ [%s]" % url))
            selectedurls = self.discoverRepos.select_repositories(repourls, assumeyes)
            self.discoverRepos.create_repositories(orgName, prod["id"], prod["name"], selectedurls)

        return os.EX_OK

# ------------------------------------------------------------------------------
class Update(SingleProductAction):

    description = _('update a product\'s attributes')

    def setup_parser(self, parser):
        self.set_product_select_options(parser, False)
        parser.add_option('--description', dest='description',
                              help=_("change description of the product"))
        parser.add_option('--gpgkey', dest='gpgkey',
                              help=_("assign a gpgkey to the product"))
        parser.add_option('--nogpgkey', dest='nogpgkey', action="store_true",
                              help=_("assign a gpgkey to the product"))
        parser.add_option('--recursive', action="store_true", dest='recursive',
                              help=_("assign the gpgpkey also to the product's repositories"))

    def check_options(self, validator):
        self.check_product_select_options(validator)

    def run(self):
        orgName     = self.get_option('org')
        prodName    = self.get_option('name')

        description = self.get_option('description')
        gpgkey = self.get_option('gpgkey')
        nogpgkey = self.get_option('nogpgkey')
        gpgkey_recursive = self.get_option('recursive')

        prod = get_product(orgName, prodName)

        prod = self.api.update(orgName, prod["id"], description, gpgkey, nogpgkey, gpgkey_recursive)
        print _("Successfully updated product [ %s ]") % prodName
        return os.EX_OK

# ------------------------------------------------------------------------------
class Delete(SingleProductAction):

    description = _('delete a product and its content')
    select_by_env = False

    def run(self):
        orgName  = self.get_option('org')
        prodName = self.get_option('name')
        product = get_product(orgName, prodName)

        msg = self.api.delete(orgName, product["id"])
        print msg
        return os.EX_OK


class ListFilters(SingleProductAction):

    description = _('list filters of a product')
    select_by_env = False

    def run(self):
        orgName     = self.get_option('org')
        prodName    = self.get_option('name')
        prod = get_product(orgName, prodName)

        filters = self.api.filters(orgName, prod['id'])
        self.printer.add_column('name')
        self.printer.add_column('description')
        self.printer.set_header(_("Product Filters"))
        self.printer.print_items(filters)


        return os.EX_OK


class AddRemoveFilter(SingleProductAction):

    select_by_env = False
    addition = True

    @property
    def description(self):
        if self.addition:
            return _('add a filter to a product')
        else:
            return _('remove a filter from a product')


    def __init__(self, addition):
        super(AddRemoveFilter, self).__init__()
        self.addition = addition

    def setup_parser(self, parser):
        self.set_product_select_options(parser, False)
        parser.add_option('--filter', dest='filter', help=_("filter name (required)"))

    def check_options(self, validator):
        self.check_product_select_options(validator)
        validator.require('filter')

    def run(self):
        org_name     = self.get_option('org')
        prod_name    = self.get_option('name')
        filter_name  = self.get_option('filter')

        prod = get_product(org_name, prod_name)
        get_filter(org_name, filter_name)

        filters = self.api.filters(org_name, prod['id'])
        filters = [f['name'] for f in filters]
        self.update_filters(org_name, prod, filters, filter_name)
        return os.EX_OK

    def update_filters(self, org_name, product, filters, filter_name):
        if self.addition:
            filters.append(filter_name)
            message = _("Added filter [ %s ] to product [ %s ]" % (filter_name, product["name"]))
        else:
            filters.remove(filter_name)
            message = _("Removed filter [ %s ] to product [ %s ]" % (filter_name, product["name"]))

        self.api.update_filters(org_name, product['id'], filters)
        print message



# product command ------------------------------------------------------------

class Product(Command):

    description = _('product specific actions in the katello server')
