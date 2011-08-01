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

from katello.client.api.product import ProductAPI
from katello.client.config import Config
from katello.client.core.base import Action, Command
from katello.client.api.utils import get_environment, get_provider
from katello.client.core.utils import run_async_task_with_status
from katello.client.core.utils import ProgressBar

try:
    import json
except ImportError:
    import simplejson as json

_cfg = Config()

# base product action --------------------------------------------------------

class ProductAction(Action):

    def __init__(self):
        super(ProductAction, self).__init__()
        self.api = ProductAPI()


# product actions ------------------------------------------------------------

class List(ProductAction):

    description = _('list known products')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                       help=_("organization name eg: foo.example.com (required)"))
        self.parser.add_option('--environment', dest='env',
                       help=_("environment name in an organization eg: dev"))
        self.parser.add_option('--provider', dest='prov',
                       help=_("provider name"))


    def check_options(self):
        self.require_option('org')


    def run(self):
        org_name = self.get_option('org')
        env_name = self.get_option('env')
        prov_name = self.get_option('prov')

        if org_name and prov_name:
            prov = get_provider(org_name, prov_name)
            if prov == None:
                return os.EX_DATAERR
            self.printer.addColumn('id')
            self.printer.addColumn('cp_id')
            self.printer.addColumn('name')
            self.printer.addColumn('provider_id')

            self.printer.setHeader(_("Product List For Provider %s") % (prov_name))
            prods = self.api.products_by_provider(prov["id"])

        elif org_name:
            env = get_environment(org_name, env_name)
            if env == None:
                return os.EX_DATAERR
            self.printer.addColumn('id')
            self.printer.addColumn('cp_id')
            self.printer.addColumn('name')
            self.printer.addColumn('provider_id')
            self.printer.setHeader(_("Product List For Organization %s, Environment '%s'") % (org_name, env["name"]))
            prods = self.api.products_by_org(org_name)
        else:
            self.printer.addColumn('id', "Cp Id")
            self.printer.addColumn('name')
            self.printer.setHeader(_("Product List"))
            prods = self.api.products()

        self.printer.printItems(prods)
        return os.EX_OK


# ------------------------------------------------------------------------------
class Sync(ProductAction):

    description = _('synchronize a product')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                               help=_("organization name eg: foo.example.com (required)"))
        self.parser.add_option('--provider', dest='prov',
                               help=_("provider name (required)"))
        self.parser.add_option('--name', dest='name',
                               help=_("product name (required)"))

    def check_options(self):
        self.require_option('org')
        self.require_option('name')

    def run(self):
        orgName     = self.get_option('org')
        provName    = self.get_option('prov')
        name        = self.get_option('name')

        if provName != None:
            prov = self.get_provider(orgName, provName)
            
            if (prov == None):
                return os.EX_DATAERR
                
            prod = self.api.products_by_provider(prov['id'], name)
        else:
            prod = self.api.products_by_org(orgName, name)
            
        if (len(prod) == 0):
            return os.EX_DATAERR

        async_task = self.api.sync(prod[0]["cp_id"])
        result = run_async_task_with_status(async_task, ProgressBar())

        if len([t for t in result if t['state'] == 'error']) > 0:
            errors = [json.loads(t["result"])['errors'][0] for t in result if t['state'] == 'error']
            print _("Product [ %s ] failed to sync: %s" % (name, errors))
            return 1

        print _("Product [ %s ] synchronized" % name)
        return os.EX_OK


# ------------------------------------------------------------------------------
class Create(ProductAction):

    description = _('create new product to a custom provider')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                               help=_("organization name eg: foo.example.com (required)"))
        self.parser.add_option('--provider', dest='prov',
                               help=_("provider name (required)"))
        self.parser.add_option('--name', dest='name',
                               help=_("product name (required)"))
        self.parser.add_option("--description", dest="description",
                               help=_("product description"))
        self.parser.add_option("--url", dest="url",
                               help=_("product url eg: http://download.fedoraproject.org/pub/fedora/linux/releases/"))

    def check_options(self):
        self.require_option('org')
        self.require_option('prov', '--provider')
        self.require_option('name')

    def run(self):
        provName    = self.get_option('prov')
        orgName     = self.get_option('org')
        name        = self.get_option('name')
        description = self.get_option('description')
        url         = self.get_option('url')

        prov = get_provider(orgName, provName)
        if prov != None:
            self.api.create(prov["id"], name, description, url)
            print _("Successfully created product [ %s ]") % name
            return os.EX_OK
        else:
            return os.EX_DATAERR

# product command ------------------------------------------------------------

class Product(Command):

    description = _('product specific actions in the katello server')
