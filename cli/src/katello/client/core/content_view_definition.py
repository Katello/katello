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

from katello.client.api.content_view_definition import ContentViewDefinitionAPI
from katello.client.cli.base import opt_parser_add_org
from katello.client.core.base import BaseAction, Command
from katello.client.api.utils import get_content_view, get_cv_definition, \
        get_filter, get_product, get_repo


# base content_view_definition action ----------------------------------------

class ContentViewDefinitionAction(BaseAction):

    def __init__(self):
        super(ContentViewDefinitionAction, self).__init__()
        self.api = ContentViewDefinitionAPI()
        self.def_api = ContentViewDefinitionAPI()

# cvd definition actions -----------------------------------------------------

class List(ContentViewDefinitionAction):

    description = _('list known content view definitions')

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)


    def check_options(self, validator):
        validator.require('org')

    def run(self):
        org_name    = self.get_option('org')
        defs = self.def_api.content_view_definitions_by_org(org_name)

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('label')
        self.printer.add_column('description', multiline=True)
        self.printer.add_column('organization', _('Org'))

        self.printer.set_header(_("Content View Definition List"))
        self.printer.print_items(defs)
        return os.EX_OK

class Publish(ContentViewDefinitionAction):

    description = _("create a content view from a definition")

    def setup_parser(self, parser):
        opt_parser_add_org(parser)
        parser.add_option('--definition', dest='definition',
                help=_("definition label eg: Database (required)"))
        parser.add_option('--name', dest='name',
                help=_("name to give published view (required)"))
        parser.add_option('--label', dest='label',
                help=_("label to give published view"))
        parser.add_option('--description', dest='description',
                help=_("label to give published view"))
        parser.add_option
    def check_options(self, validator):
        validator.require(('org', 'name', 'definition'))

    def run(self):
        org_name = self.get_option('org')
        label = self.get_option('label')
        name = self.get_option('name')
        def_label = self.get_option('definition')
        description = self.get_option('description')
        cvd = get_cv_definition(org_name, def_label)

        view = self.def_api.publish(org_name, cvd["id"], name, label, description )
        print _("Successfully published content view [ %s ]") % view['label']
        return os.EX_OK

class Info(ContentViewDefinitionAction):

    description = _('list a specific content view definition')

    def setup_parser(self, parser):
        opt_parser_add_org(parser)
        parser.add_option('--label', dest='label',
                help=_("definition label eg: foo.example.com (required)"))

    def check_options(self, validator):
        validator.require(('org', 'label'))

    def run(self):
        org_name = self.get_option('org')
        def_label = self.get_option('label')

        cvd = get_cv_definition(org_name, def_label)

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('label')
        self.printer.add_column('description', multiline=True)
        self.printer.add_column('organization', _('Org'))

        self.printer.set_header(_("Content View Definition Info"))
        self.printer.print_item(cvd)
        return os.EX_OK


class Create(ContentViewDefinitionAction):

    description = _('create an content view definition')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name',
                help=_("content view definition name eg: Database (required)"))
        opt_parser_add_org(parser, required=1)
        parser.add_option('--description', dest='description',
                help=_("definition description"))
        parser.add_option('--label', dest='label',
                help=_("definition label"))

    def check_options(self, validator):
        validator.require(('name', 'org'))


    def run(self):
        org_id      = self.get_option('org')
        name        = self.get_option('name')
        description = self.get_option('description')
        label       = self.get_option('label')

        self.def_api.create(org_id, name, label, description)
        print _("Successfully created content view definition [ %s ]") % name
        return os.EX_OK


class Update(ContentViewDefinitionAction):


    description =  _('update an content view definition')


    def setup_parser(self, parser):
        parser.add_option("--description", dest="description",
                help=_("content view description eg: foo's content view"))
        opt_parser_add_org(parser, required=1)
        parser.add_option('--view', dest='view',
                help=_("content view label (required)"))
        parser.add_option('--name', dest='name', help=_("content view name"))


    def check_options(self, validator):
        validator.require(('org', 'view'))


    def run(self):
        name         = self.get_option('name')
        description  = self.get_option('description')
        org_name     = self.get_option('org')
        def_label    = self.get_option('view')

        cvd = get_cv_definition(org_name, def_label)

        cvd = self.def_api.update(org_name, cvd["id"], name, description)
        print _("Successfully updated content_view [ %s ]") % cvd['name']
        return os.EX_OK



class Delete(ContentViewDefinitionAction):

    description = _('delete an content view definition')

    def setup_parser(self, parser):
        parser.add_option('--label', dest='label',
                help=_("content view label eg: foo.example.com (required)"))
        opt_parser_add_org(parser, required=1)

    def check_options(self, validator):
        validator.require(('label', 'org'))


    def run(self):
        org_name   = self.get_option('org')
        view_label = self.get_option('label')

        view = get_cv_definition(org_name, view_label)

        self.def_api.delete(view["id"])
        print _("Successfully deleted definition [ %s ]") % view_label
        return os.EX_OK


class AddRemoveFilter(ContentViewDefinitionAction):

    select_by_env = False
    addition = True

    @property
    def description(self):
        if self.addition:
            return _('add a filter to a content view definition')
        else:
            return _('remove a filter from a content view definition')


    def __init__(self, addition):
        super(AddRemoveFilter, self).__init__()
        self.addition = addition

    def setup_parser(self, parser):
        parser.add_option('--label', dest='label',
                help=_("definition label eg: Database (required)"))
        opt_parser_add_org(parser, required=1)
        parser.add_option('--filter', dest='filter',
                help=_("filter name (required)"))

    def check_options(self, validator):
        validator.require(('filter', 'org', 'label'))

    def run(self):
        org_name     = self.get_option('org')
        view_label   = self.get_option('label')
        filter_name  = self.get_option('filter')

        view = get_cv_definition(org_name, view_label)
        get_filter(org_name, filter_name)

        filters = self.def_api.filters(org_name, view['id'])
        filters = [f['name'] for f in filters]
        self.update_filters(org_name, view, filters, filter_name)
        return os.EX_OK

    def update_filters(self, org_name, cvd, filters, filter_name):
        if self.addition:
            filters.append(filter_name)
            message = _("Added filter [ %s ] to definition [ %s ]" % \
                    (filter_name, cvd["label"]))
        else:
            filters.remove(filter_name)
            message = _("Removed filter [ %s ] to definition [ %s ]" % \
                    (filter_name, cvd["label"]))

        self.def_api.update_filters(org_name, cvd['id'], filters)
        print message


class AddRemoveProduct(ContentViewDefinitionAction):

    select_by_env = False
    addition = True

    @property
    def description(self):
        if self.addition:
            return _('add a product to a content view definition')
        else:
            return _('remove a product from a content view definition')


    def __init__(self, addition):
        super(AddRemoveProduct, self).__init__()
        self.addition = addition

    def setup_parser(self, parser):
        parser.add_option('--label', dest='label',
                help=_("content view definition label eg: Database (required)"))
        opt_parser_add_org(parser, required=1)
        parser.add_option('--product', dest='product',
                help=_("product label (required)"))

    def check_options(self, validator):
        validator.require(('product', 'org', 'label'))

    def run(self):
        org_name       = self.get_option('org')
        view_label     = self.get_option('label')
        product_label  = self.get_option('product')

        view    = get_cv_definition(org_name, view_label)
        product = get_product(org_name, product_label)

        products = self.def_api.products(org_name, view['id'])
        products = [f['id'] for f in products]
        self.update_products(org_name, view, products, product)
        return os.EX_OK

    def update_products(self, org_name, cvd, products, product):
        if self.addition:
            products.append(product['id'])
            message = _("Added product [ %s ] to content view [ %s ]" % \
                    (product['label'], cvd["label"]))
        else:
            products.remove(product['id'])
            message = _("Removed product [ %s ] to content view [ %s ]" % \
                    (product['label'], cvd["label"]))

        self.def_api.update_products(org_name, cvd['id'], products)
        print message


class AddRemoveRepo(ContentViewDefinitionAction):

    select_by_env = False
    addition = True

    @property
    def description(self):
        if self.addition:
            return _('add a repo to a content view definition')
        else:
            return _('remove a repo from a content view definition')


    def __init__(self, addition):
        super(AddRemoveRepo, self).__init__()
        self.addition = addition

    def setup_parser(self, parser):
        parser.add_option('--label', dest='label',
                help=_("content view label eg: Database (required)"))
        opt_parser_add_org(parser, required=1)
        parser.add_option('--repo', dest='repo',
                help=_("repository name (required)"))
        parser.add_option('--product', dest='product',
                help=_("product label (required)"))

    def check_options(self, validator):
        validator.require(('repo', 'org', 'label', 'product'))

    def run(self):
        org_name       = self.get_option('org')
        view_label     = self.get_option('label')
        repo_name      = self.get_option('repo')
        product        = self.get_option('product')

        view = get_cv_definition(org_name, view_label)
        repo = get_repo(org_name, product, repo_name, None, None)

        repos = self.def_api.repos(org_name, view['id'])
        repos = [f['id'] for f in repos]
        self.update_repos(org_name, view, repos, repo)
        return os.EX_OK

    def update_repos(self, org_name, cvd, repos, repo):
        if self.addition:
            repos.append(repo["id"])
            message = _("Added repository [ %s ] to content view [ %s ]" % \
                    (repo["name"], cvd["label"]))
        else:
            repos.remove(repo["id"])
            message = _("Removed repository [ %s ] to content view [ %s ]" % \
                    (repo["name"], cvd["label"]))

        self.def_api.update_repos(org_name, cvd['id'], repos)
        print message


class AddRemoveContentView(ContentViewDefinitionAction):

    select_by_env = False
    addition = True

    @property
    def description(self):
        if self.addition:
            return _('add a content view to a content view definition')
        else:
            return _('remove a content view from a content view definition')


    def __init__(self, addition):
        super(AddRemoveContentView, self).__init__()
        self.addition = addition

    def setup_parser(self, parser):
        parser.add_option('--label', dest='label',
                help=_("definition label eg: Database (required)"))
        opt_parser_add_org(parser, required=1)
        parser.add_option('--content_view', dest='view',
                help=_("content view label (required)"))

    def check_options(self, validator):
        validator.require(('label', 'org', 'view'))

    def run(self):
        org_name           = self.get_option('org')
        def_label          = self.get_option('label')
        content_view_label = self.get_option('view')

        cvd = get_cv_definition(org_name, def_label)
        content_view = get_content_view(org_name, content_view_label)

        content_views = self.def_api.content_views(cvd['id'])
        content_views = [f['id'] for f in content_views]
        self.update_content_views(cvd, content_views, content_view)
        return os.EX_OK

    def update_content_views(self, cvd, content_views, content_view):
        if self.addition:
            content_views.append(content_view["id"])
            message = _("Added content view [ %s ] to content view [ %s ]" % \
                    (content_view["name"], cvd["label"]))
        else:
            content_views.remove(content_view["id"])
            message = _("Removed content view [ %s ] to content view [ %s ]" % \
                    (content_view["name"], cvd["label"]))

        self.def_api.update_content_views(cvd['id'], content_views)
        print message


# cvd def command ------------------------------------------------------------

class ContentViewDefinition(Command):

    description = _('content view definition actions for the katello server')
