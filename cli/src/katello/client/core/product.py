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
import datetime

from katello.client import constants
from katello.client.cli.base import opt_parser_add_org, opt_parser_add_environment
from katello.client.core import repo
from katello.client.core.repo import ALLOWED_REPO_URL_SCHEMES
from katello.client.core.base import BaseAction, Command
from katello.client.api.product import ProductAPI
from katello.client.api.repo import RepoAPI
from katello.client.api.changeset import ChangesetAPI
from katello.client.api.utils import get_environment, get_provider, get_product, get_sync_plan
from katello.client.lib.async import AsyncTask, evaluate_task_status
from katello.client.lib.ui import printer
from katello.client.lib.ui.formatters import format_sync_state, format_sync_time
from katello.client.lib.ui.progress import ProgressBar, run_async_task_with_status, run_spinner_in_bg
from katello.client.lib.ui.progress import wait_for_async_task
from katello.client.lib.ui.printer import batch_add_columns


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

    @classmethod
    def set_product_select_options(cls, parser, select_by_env=True):
        opt_parser_add_org(parser, required=1)
        parser.add_option('--name', dest='name', help=_("product name (require name, label or id)"))
        parser.add_option('--label', dest='label', help=_("product label (require name, label or id)"))
        parser.add_option('--id', dest='id', help=_("product id (require name, label or id)"))

        if select_by_env:
            opt_parser_add_environment(parser, default=_("Library"))

    @classmethod
    def check_product_select_options(cls, validator):
        validator.require('org')
        validator.require_at_least_one_of(('name', 'label', 'id'))
        validator.mutually_exclude('name', 'label', 'id')

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
        prodLabel = self.get_option('label')
        prodId   = self.get_option('id')
        planName = self.get_option('plan')

        prod = get_product(orgName, prodName, prodLabel, prodId)
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
        prodLabel = self.get_option('label')
        prodId   = self.get_option('id')


        prod = get_product(orgName, prodName, prodLabel, prodId)

        msg = self.api.remove_sync_plan(orgName, prod['id'])
        print msg
        return os.EX_OK

class List(ProductAction):

    description = _('list known products')

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)
        opt_parser_add_environment(parser, default=_("Library"))
        parser.add_option('--provider', dest='prov',
                       help=_("provider name, lists provider's product in the Library"))
        parser.add_option('--all', dest='all', action='store_true',
                       help=_("list marketing products (hidden by default)"))

    def check_options(self, validator):
        validator.require('org')

    def run(self):
        org_name = self.get_option('org')
        env_name = self.get_option('environment')
        prov_name = self.get_option('prov')
        all_opt = self.get_option('all')

        batch_add_columns(self.printer, {'id': _("ID")}, {'name': _("Name")}, \
            {'label': _("Label")}, {'provider_id': _("Provider ID")}, \
            {'provider_name': _("Provider Name")}, {'sync_plan_name': _("Sync Plan Name")})
        self.printer.add_column('last_sync', _("Last Sync"), formatter=format_sync_time)
        self.printer.add_column('gpg_key_name', _("GPG key"))

        if prov_name:
            prov = get_provider(org_name, prov_name)

            self.printer.set_header(_("Product List For Provider [ %s ]") % (prov_name))
            prods = self.api.products_by_provider(prov["id"])

        else:
            env = get_environment(org_name, env_name)

            self.printer.set_header(_("Product List For Organization %(org_name)s, Environment '%(env_name)s'") \
                % {'org_name':org_name, 'env_name':env["name"]})
            prods = self.api.products_by_env(env['id'])

        # hide marketing products by default
        if not all_opt:
            def isNotMarketingProduct(p):
                return not (("marketing_product" in p) and (p["marketing_product"]))
            prods = filter(isNotMarketingProduct, prods)

        self.printer.print_items(prods)

        return os.EX_OK


# ------------------------------------------------------------------------------
class Sync(SingleProductAction):

    description = _('synchronize a product')
    select_by_env = False

    def run(self):
        orgName     = self.get_option('org')
        prodName    = self.get_option('name')
        prodLabel   = self.get_option('label')
        prodId      = self.get_option('id')

        prod = get_product(orgName, prodName, prodLabel, prodId)

        task = AsyncTask(self.api.sync(orgName, prod["id"]))
        run_async_task_with_status(task, ProgressBar())

        return evaluate_task_status(task,
            failed =   _("Product [ %s ] failed to sync") % prod["name"],
            canceled = _("Product [ %s ] synchronization canceled") % prod["name"],
            ok =       _("Product [ %s ] synchronized") % prod["name"]
        )

# ------------------------------------------------------------------------------
class CancelSync(SingleProductAction):

    description = _('cancel currently running synchronization')
    select_by_env = False

    def run(self):
        orgName     = self.get_option('org')
        prodName    = self.get_option('name')
        prodLabel   = self.get_option('label')
        prodId      = self.get_option('id')

        prod = get_product(orgName, prodName, prodLabel, prodId)

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
        prodLabel   = self.get_option('label')
        prodId      = self.get_option('id')

        prod = get_product(orgName, prodName, prodLabel, prodId)

        task = AsyncTask(self.api.last_sync_status(orgName, prod['id']))

        if task.is_running():
            pkgsTotal = task.total_count()
            pkgsLeft = task.items_left()
            prod['progress'] = ("%d%% done (%d of %d packages downloaded)" %
                (task.get_progress()*100, pkgsTotal-pkgsLeft, pkgsTotal))

        #TODO: last errors?

        batch_add_columns(self.printer, {'id': _("ID")}, {'name': _("Name")}, \
            {'provider_id': _("Provider ID")}, {'provider_name': _("Provider Name")})
        self.printer.add_column('last_sync', _("Last Sync"), formatter=format_sync_time)
        self.printer.add_column('sync_state', _("Sync State"), formatter=format_sync_state)
        self.printer.add_column('progress', _("Progress"), show_with=printer.VerboseStrategy)

        self.printer.set_header(_("Product Status"))
        self.printer.print_item(prod)
        return os.EX_OK


# ------------------------------------------------------------------------------
class Promote(SingleProductAction):

    description = _('promote a product to an environment\n' +
        '(creates a temporary changeset with the product and promotes it)')
    select_by_env = True

    def check_options(self, validator):
        self.check_product_select_options(validator)
        validator.require('environment')

    def run(self):
        orgName     = self.get_option('org')
        prodName    = self.get_option('name')
        prodLabel   = self.get_option('label')
        prodId      = self.get_option('id')
        envName     = self.get_option('environment')

        env = get_environment(orgName, envName)
        prod = get_product(orgName, prodName, prodLabel, prodId)


        if not self.repoapi.repos_by_product(orgName, prod['id']):
            print _("Product [ %(prod_name)s ] has no repository") % {'prod_name':prod['name']}
            return os.EX_DATAERR

        cset = self.csapi.create(orgName, env["id"], self.create_cs_name(), constants.PROMOTION)

        self.csapi.add_content(cset["id"], "products", {'product_id': prod['id']})
        task = self.csapi.apply(cset["id"])
        task = AsyncTask(task)

        run_spinner_in_bg(wait_for_async_task, [task], message=_("Promoting the product, please wait... "))

        return evaluate_task_status(task,
            failed = _("Product [ %s ] promotion failed") % prod["name"],
            ok =     _("Product [ %(prod)s ] promoted to environment [ %(env)s ]") %
                {'prod':prod["name"], 'env':envName}
        )

    @classmethod
    def create_cs_name(cls):
        curTime = datetime.datetime.now()
        return "product_promotion_"+str(curTime)

# ------------------------------------------------------------------------------
class Create(ProductAction):

    def __init__(self):
        super(Create, self).__init__()
        self.discoverRepos = repo.Discovery()

    description = _('create new product to a custom provider')

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)
        parser.add_option('--provider', dest='prov',
            help=_("provider name (required)"))
        parser.add_option('--name', dest='name',
            help=_("product name (required)"))
        parser.add_option('--label', dest='label',
                               help=_("product label, ASCII identifier for the product with no" +
                                      " spaces eg: ACME_Product. (will be generated if not specified)"))
        parser.add_option("--description", dest="description",
            help=_("product description"))
        parser.add_option("--url", dest="url", type="url", schemes=ALLOWED_REPO_URL_SCHEMES,
            help=_("repository url eg: http://download.fedoraproject.org/pub/fedora/linux/releases/"))
        parser.add_option("--nodisc", action="store_true", dest="nodiscovery",
            help=_("skip repository discovery"))
        parser.add_option("--assumeyes", action="store_true", dest="assumeyes",
            help=_("assume yes; automatically create candidate repositories for discovered urls (optional)"))
        parser.add_option("--gpgkey", dest="gpgkey",
            help=_("assign a gpg key; this key will be used for every new repository unless gpgkey or nogpgkey"\
                " is specified for the repo"))


    def check_options(self, validator):
        validator.require(('org', 'prov', 'name'))

    def run(self):
        provName    = self.get_option('prov')
        orgName     = self.get_option('org')
        name        = self.get_option('name')
        label       = self.get_option('label')
        description = self.get_option('description')
        url         = self.get_option('url')
        assumeyes   = self.get_option('assumeyes')
        nodiscovery = self.get_option('nodiscovery')
        gpgkey      = self.get_option('gpgkey')

        return self.create_product_with_repos(provName, orgName, name, label,
                                              description, url, assumeyes, nodiscovery, gpgkey)


    def create_product_with_repos(self, provName, orgName, name, label, description,
                                  url, assumeyes, nodiscovery, gpgkey):
        prov = get_provider(orgName, provName)

        prod = self.api.create(prov["id"], name, label, description, gpgkey)
        print _("Successfully created product [ %s ]") % name

        if url == None:
            return os.EX_OK

        if not nodiscovery:
            repourls = self.discoverRepos.discover_repositories(prov['id'], url)
            self.printer.set_header(_("Repository Urls discovered @ [%s]" % url))
            selectedurls = self.discoverRepos.select_repositories(repourls, assumeyes)
            self.discoverRepos.create_repositories(orgName, prod["id"], prod["name"], prod["label"], selectedurls)

        return os.EX_OK
# ------------------------------------------------------------------------------
class ListRepositorySets(SingleProductAction):
    description = _('List repository sets for a Red Hat product')
    def setup_parser(self, parser):
        self.set_product_select_options(parser, False)

    def run(self):
        orgName     = self.get_option('org')
        prodName    = self.get_option('name')
        prodLabel   = self.get_option('label')
        prodId      = self.get_option('id')
        prod = get_product(orgName, prodName, prodLabel, prodId)
        sets = self.api.repository_sets(orgName, prod["id"])
        sets = sorted(sets, key=lambda k: k['name']) 

        batch_add_columns(self.printer, {'id': _("ID")}, {'name': _("Name")}, \
            {'katello_enabled': _("Enabled?")})
        self.printer.set_header(_("Repository Sets For Product [ %s ]") % (prod['name']))

        self.printer.print_items(sets)

        return os.EX_OK
        
class EnableRepositorySet(SingleProductAction):
    description = _('Enable a repository set for a Red Hat product')
    def setup_parser(self, parser):
        self.set_product_select_options(parser, False)
        parser.add_option('--set_name', dest='set_name',
                           help=_("name of the repository set to enable"))

    def check_options(self, validator):
        validator.require(('org', 'set_name'))

    def run(self):
        orgName     = self.get_option('org')
        prodName    = self.get_option('name')
        prodLabel   = self.get_option('label')
        prodId      = self.get_option('id')
        prod = get_product(orgName, prodName, prodLabel, prodId)
        set_name      = self.get_option('set_name')
      
        task = AsyncTask(self.api.enable_repository_set(orgName, prod['id'], set_name))
        task = run_spinner_in_bg(wait_for_async_task, [task],
                message=_("Enabling Repository Set..."))
        task = AsyncTask(task)
        return evaluate_task_status(task,
            failed = _("Repository enable [ %(set_name)s ] failed.") % 
                        {'set_name':set_name},
            ok = _("Repository Set [ %(set_name)s ] enabled.") % {'set_name':set_name}
        )

class DisableRepositorySet(SingleProductAction):
    description = _('Disable a repository set for a Red Hat product')
    def setup_parser(self, parser):
        self.set_product_select_options(parser, False)
        parser.add_option('--set_name', dest='set_name',
                           help=_("name of the repository set to disable"))

    def check_options(self, validator):
        validator.require(('org', 'set_name'))

    def run(self):
        orgName     = self.get_option('org')
        prodName    = self.get_option('name')
        prodLabel   = self.get_option('label')
        prodId      = self.get_option('id')
        prod = get_product(orgName, prodName, prodLabel, prodId)
        set_name      = self.get_option('set_name')

        task = AsyncTask(self.api.disable_repository_set(orgName, prod['id'], set_name))
        task = run_spinner_in_bg(wait_for_async_task, [task],
                message=_("Disabling Repository Set..."))
        task = AsyncTask(task)
        return evaluate_task_status(task,
            failed = _("Repository disable [ %(set_name)s ] failed.") % 
                        {'set_name':set_name},
            ok = _("Repository Set [ %(set_name)s ] disabled.") % {'set_name':set_name}
        )

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

    def run(self):
        orgName     = self.get_option('org')
        prodName    = self.get_option('name')
        prodLabel   = self.get_option('label')
        prodId      = self.get_option('id')

        description = self.get_option('description')
        gpgkey = self.get_option('gpgkey')
        nogpgkey = self.get_option('nogpgkey')
        gpgkey_recursive = self.get_option('recursive')

        prod = get_product(orgName, prodName, prodLabel, prodId)

        prod = self.api.update(orgName, prod["id"], description, gpgkey, nogpgkey, gpgkey_recursive)
        print _("Successfully updated product [ %s ]") % prod["name"]
        return os.EX_OK

# ------------------------------------------------------------------------------
class Delete(SingleProductAction):

    description = _('delete a product and its content')
    select_by_env = False

    def run(self):
        orgName  = self.get_option('org')
        prodName = self.get_option('name')
        prodLabel   = self.get_option('label')
        prodId      = self.get_option('id')

        product = get_product(orgName, prodName, prodLabel, prodId)

        msg = self.api.delete(orgName, product["id"])
        print msg
        return os.EX_OK

# product command ------------------------------------------------------------

class Product(Command):

    description = _('product specific actions in the katello server')
