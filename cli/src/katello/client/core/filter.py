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

from katello.client.api.content_view_definition import ContentViewDefinitionAPI
from katello.client.api.filter import FilterAPI
from katello.client.cli.base import opt_parser_add_org, opt_parser_add_product
from katello.client.core.base import BaseAction, Command
from katello.client.api.utils import get_repo, get_cv_definition, ApiDataError

# base filter action ----------------------------------------

class FilterAction(BaseAction):

    def __init__(self):
        super(FilterAction, self).__init__()
        self.api = FilterAPI()
        self.def_api = FilterAPI()

    @classmethod
    def _add_cvd_filter_opts(cls, parser):
        parser.add_option('--definition', dest='definition_name',
                help=_("content view definition name eg: def1"))
        parser.add_option('--definition_label', dest='definition_label',
                help=_("content view definition label eg: def1"))
        parser.add_option('--definition_id', dest='definition_id',
                help=_("content view definition id eg: 1"))

    @classmethod
    def _add_get_filter_opts(cls, parser):
        FilterAction._add_cvd_filter_opts(parser)
        parser.add_option('--name', dest='name',
                help=_("filter id eg: 'filter_foo'"))

    @classmethod
    def _add_filter_opts_check(cls, validator):
        validator.require('name')

    @classmethod
    def _add_cvd_opts_check(cls, validator):
        validator.require_at_least_one_of(('definition_name', 'definition_label', 'definition_id'))
        validator.mutually_exclude('definition_name', 'definition_label', 'definition_id')

# filter actions -----------------------------------------------------

class List(FilterAction):

    description = _('list known filters for a given content view definition')

    def setup_parser(self, parser):
        self._add_cvd_filter_opts(parser)
        opt_parser_add_org(parser, required=1)

    def check_options(self, validator):
        validator.require(('org'))
        self._add_cvd_opts_check(validator)

    def run(self):
        org_name = self.get_option('org')
        definition_label = self.get_option('definition_label')
        definition_name = self.get_option('definition_name')
        definition_id = self.get_option('definition_id')

        definition = get_cv_definition(org_name, definition_label,
                                       definition_name, definition_id)
        defs = self.def_api.filters_by_cvd_and_org(definition["id"], org_name)

        self.printer.add_column('id', _("ID"))
        self.printer.add_column('name', _("Name"))
        self.printer.add_column('content_view_definition_label', _("Content View Definition"))
        self.printer.add_column('organization', _('Org'))

        self.printer.set_header(_("Content View Definition Filters"))
        self.printer.print_items(defs)
        return os.EX_OK


class Info(FilterAction):
    description = _('list a specific filter')
    def setup_parser(self, parser):
        self._add_get_filter_opts(parser)
        opt_parser_add_org(parser, required=1)

    def check_options(self, validator):
        validator.require(('org', 'name'))
        self._add_cvd_opts_check(validator)

    def run(self):
        org_name = self.get_option('org')
        filter_name = self.get_option('name')
        definition_label = self.get_option('definition_label')
        definition_name = self.get_option('definition_name')
        definition_id = self.get_option('definition_id')

        definition = get_cv_definition(org_name, definition_label,
                                       definition_name, definition_id)

        cvd_filter = self.def_api.get_filter_info(filter_name,
                                                  definition["id"],
                                                  org_name)

        self.printer.add_column('id', _("ID"))
        self.printer.add_column('name', _("Name"))
        self.printer.add_column('content_view_definition_label', _("Content View Definition"))
        self.printer.add_column('organization', _('Org'))
        self.printer.add_column('products', _("Products"), multiline=True)
        self.printer.add_column('repos', _("Repos"), multiline=True)

        self.printer.set_header(_("Content View Definition Filter Info"))
        self.printer.print_item(cvd_filter)
        return os.EX_OK

class Create(FilterAction):
    description = _('create a filter')
    def setup_parser(self, parser):
        self._add_get_filter_opts(parser)
        opt_parser_add_org(parser, required=1)

    def check_options(self, validator):
        validator.require(('org', 'name'))
        self._add_cvd_opts_check(validator)

    def run(self):
        org_name = self.get_option('org')
        filter_name = self.get_option('name')
        definition_label = self.get_option('definition_label')
        definition_name = self.get_option('definition_name')
        definition_id = self.get_option('definition_id')

        definition = get_cv_definition(org_name, definition_label,
                                       definition_name, definition_id)

        self.def_api.create(filter_name, definition["id"], org_name)
        print _("Successfully created filter [ %s ]") % filter_name
        return os.EX_OK

class Delete(FilterAction):

    description = _('delete a filter')

    def setup_parser(self, parser):
        self._add_get_filter_opts(parser)
        opt_parser_add_org(parser, required=1)

    def check_options(self, validator):
        validator.require(('org', 'name'))
        self._add_cvd_opts_check(validator)

    def run(self):
        org_name = self.get_option('org')
        filter_name = self.get_option('name')
        definition_label = self.get_option('definition_label')
        definition_name = self.get_option('definition_name')
        definition_id = self.get_option('definition_id')

        definition = get_cv_definition(org_name, definition_label,
                                       definition_name, definition_id)
        self.def_api.delete(filter_name, definition["id"], org_name)

        print _("Successfully deleted filter [ %s ]") % filter_name
        return os.EX_OK

class AddRemoveProduct(FilterAction):
    addition = True

    @property
    def description(self):
        if self.addition:
            return _('add a product to a filter')
        else:
            return _('remove a product from a filter')

    def __init__(self, addition):
        super(AddRemoveProduct, self).__init__()
        self.addition = addition

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)
        opt_parser_add_product(parser, required=1)
        self._add_get_filter_opts(parser)

    def check_options(self, validator):
        validator.require(('org', 'name'))
        validator.require_at_least_one_of(('product', 'product_label', 'product_id'))
        validator.mutually_exclude('product', 'product_label', 'product_id')
        self._add_cvd_opts_check(validator)

    def run(self):
        org_name = self.get_option('org')
        filter_name = self.get_option('name')
        product_name = self.get_option('product')
        product_id = self.get_option('product_id')
        product_label = self.get_option('product_label')
        definition_label = self.get_option('definition_label')
        definition_name = self.get_option('definition_name')
        definition_id = self.get_option('definition_id')

        cvd_api = ContentViewDefinitionAPI()
        cvd = get_cv_definition(org_name, definition_label,
                                definition_name, definition_id)
        cvd_products = cvd_api.products(org_name, cvd["id"])

        product = self.identify_product(cvd, cvd_products, product_name, product_label, product_id)

        products = self.def_api.products(filter_name, cvd["id"], org_name)

        products = [f['id'] for f in products]

        self.update_products(org_name, cvd["id"], filter_name, products, product)
        return os.EX_OK

    def update_products(self, org_name, cvd, filter_name, products, product):
        if self.addition:
            products.append(product['id'])
            message = _("Added product [ %(prod)s ] to filter [ %(filter)s ]" % \
                        ({"prod": product['label'], "filter": filter_name}))
        else:
            products.remove(product['id'])
            message = _("Removed product [ %(prod)s ] from filter [ %(filter)s ]" %
                        ({"prod": product['label'], "filter": filter_name}))

        self.def_api.update_products(filter_name, cvd, org_name, products)
        print message

    def identify_product(self, definition, cvd_products, product_name, product_label, product_id):
        org_name = self.get_option('org')

        products = [prod for prod in cvd_products if prod["id"] == product_id \
                             or prod["name"] == product_name or prod["label"] == product_label]

        if len(products) > 1:
            raise ApiDataError(_("More than 1 product found with the name or label provided, "\
                                 "recommend using product id.  The product id may be retrieved "\
                                 "using the 'product list' command."))
        elif len(products) == 0:
            raise ApiDataError(_("Could not find product [ %s ] within organization [ %s ] and definition [%s] ") %
                               ((product_name or product_label or product_id), org_name, definition["name"]))

        return products[0]


class AddRemoveRepo(FilterAction):

    select_by_env = False
    addition = True

    @property
    def description(self):
        if self.addition:
            return _('add a repo to a filter')
        else:
            return _('remove a repo from a filter')

    def __init__(self, addition):
        super(AddRemoveRepo, self).__init__()
        self.addition = addition

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)
        parser.add_option('--repo', dest='repo',
                          help=_("repository name (required)"))
        parser.add_option('--product', dest='product',
                          help=_("product name (product name, label or id required)"))
        parser.add_option('--product_label', dest='product_label',
                          help=_("product label (product name, label or id required)"))
        parser.add_option('--product_id', dest='product_id',
                          help=_("product id (product name, label or id required)"))
        self._add_get_filter_opts(parser)

    def check_options(self, validator):
        validator.require(('repo', 'org', 'name'))
        validator.require_at_least_one_of(('product', 'product_label', 'product_id'))
        validator.mutually_exclude('product', 'product_label', 'product_id')
        self._add_cvd_opts_check(validator)

    def run(self):
        org_name = self.get_option('org')
        filter_name = self.get_option('name')
        repo_name = self.get_option('repo')
        product = self.get_option('product')
        product_label = self.get_option('product_label')
        product_id = self.get_option('product_id')
        definition_label = self.get_option('definition_label')
        definition_name = self.get_option('definition_name')
        definition_id = self.get_option('definition_id')

        definition = get_cv_definition(org_name, definition_label,
                                       definition_name, definition_id)

        repo = get_repo(org_name, repo_name, product, product_label, product_id)
        repos = self.def_api.repos(filter_name, definition["id"], org_name)
        repos = [f['id'] for f in repos]

        self.update_repos(org_name, definition["id"], filter_name, repos, repo)

        return os.EX_OK

    def update_repos(self, org_name, cvd, filter_name, repos, repo):
        if self.addition:
            repos.append(repo["id"])
            message = _("Added repository [ %s ] to filter [ %s ]" % \
                        (repo["name"], filter_name))
        else:
            repos.remove(repo["id"])
            message = _("Removed repository [ %s ] from filter [ %s ]" % \
                        (repo["name"], filter_name))

        self.def_api.update_repos(filter_name, cvd, org_name, repos)
        print message

class Filter(Command):

    description = _('content view definition filters actions for the katello server')
