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
    get_product, get_repo
from katello.client.lib.async import AsyncTask, evaluate_task_status
from katello.client.lib.ui.progress import run_spinner_in_bg, wait_for_async_task


# base content_view_definition action ----------------------------------------

class ContentViewDefinitionAction(BaseAction):

    def __init__(self):
        super(ContentViewDefinitionAction, self).__init__()
        self.api = ContentViewDefinitionAPI()
        self.def_api = ContentViewDefinitionAPI()

    @classmethod
    def _add_get_cvd_opts(cls, parser):
        parser.add_option('--label', dest='label',
                help=_("definition label eg: def1"))
        parser.add_option('--id', dest='id',
                help=_("definition id eg: 42"))
        parser.add_option('--name', dest='name',
                help=_("definition name eg: def1"))

    @classmethod
    def _add_get_cvd_opts_check(cls, validator):
        validator.require_at_least_one_of(('name', 'label', 'id'))
        validator.mutually_exclude('name', 'label', 'id')

# cvd definition actions -----------------------------------------------------

class List(ContentViewDefinitionAction):

    description = _('list known content view definitions')

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)


    def check_options(self, validator):
        validator.require('org')

    def run(self):
        org_name = self.get_option('org')
        defs = self.def_api.content_view_definitions_by_org(org_name)

        self.printer.add_column('id', _("ID"))
        self.printer.add_column('name', _("Name"))
        self.printer.add_column('label', _("Label"))
        self.printer.add_column('description', _("Description"), multiline=True)
        self.printer.add_column('organization', _('Org'))

        self.printer.set_header(_("Content View Definition List"))
        self.printer.print_items(defs)
        return os.EX_OK


class Publish(ContentViewDefinitionAction):

    description = _("create a content view from a definition")

    def setup_parser(self, parser):
        opt_parser_add_org(parser)
        self._add_get_cvd_opts(parser)
        parser.add_option('--view_name', dest='view_name',
                          help=_("name to give published view (required)"))
        parser.add_option('--view_label', dest='view_label',
                          help=_("label to give published view"))
        parser.add_option('--description', dest='description',
                          help=_("description to give published view"))
        parser.add_option('--async', dest='async', action='store_true',
                          help=_("publish the view asynchronously"))

    def check_options(self, validator):
        validator.require(('org', 'view_name'))
        self._add_get_cvd_opts_check(validator)

    def run(self):
        org_name    = self.get_option('org')
        label       = self.get_option('label')
        name        = self.get_option('name')
        def_id      = self.get_option('id')
        view_label  = self.get_option('view_label')
        view_name   = self.get_option('view_name')
        description = self.get_option('description')
        async       = self.get_option('async')
        cvd         = get_cv_definition(org_name, label, name, def_id)


        task = self.def_api.publish(org_name, cvd["id"], view_name, view_label, description)

        if not async:
            task = AsyncTask(task)
            run_spinner_in_bg(wait_for_async_task, [task],
                              message=_("Publishing content view, please wait..."))

            return evaluate_task_status(task,
                ok =     _("Content view [ %s ] published successfully.") % name,
                failed = _("Content view [ %s ] failed to be promoted") % name
            )

        else:
            print _("Publish task [ %s ] was successfully created.") % task['uuid']
            return os.EX_OK



class Info(ContentViewDefinitionAction):

    description = _('list a specific content view definition')

    def setup_parser(self, parser):
        opt_parser_add_org(parser)
        self._add_get_cvd_opts(parser)

    def check_options(self, validator):
        validator.require(('org'))
        self._add_get_cvd_opts_check(validator)

    def run(self):
        org_name = self.get_option('org')
        def_label = self.get_option('label')
        def_name = self.get_option('name')
        def_id = self.get_option('id')

        cvd = get_cv_definition(org_name, def_label, def_name, def_id)

        self.printer.add_column('id', _("ID"))
        self.printer.add_column('name', _("Name"))
        self.printer.add_column('label', _("Label"))
        self.printer.add_column('description', _("Description"), multiline=True)
        self.printer.add_column('organization', _('Org'))
        self.printer.add_column('content_views', _('Published Views'), multiline=True)
        self.printer.add_column('components', _('Component Views'), multiline=True)
        self.printer.add_column('products', _("Products"), multiline=True)
        self.printer.add_column('repos', _("Repos"), multiline=True)

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
        parser.add_option('--label', dest='label',
                help=_("content view definition label (required)"))
        parser.add_option('--name', dest='name', help=_("content view name"))


    def check_options(self, validator):
        validator.require(('org', 'label'))

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
        opt_parser_add_org(parser, required=1)
        self._add_get_cvd_opts(parser)

    def check_options(self, validator):
        validator.require(('org'))
        self._add_get_cvd_opts_check(validator)

    def run(self):
        org_name   = self.get_option('org')
        def_label  = self.get_option('label')
        def_name   = self.get_option('name')
        def_id     = self.get_option('id')

        cvd = get_cv_definition(org_name, def_label, def_name, def_id)

        self.def_api.delete(cvd["id"])
        print _("Successfully deleted definition [ %s ]") % def_label
        return os.EX_OK


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
        opt_parser_add_org(parser, required=1)
        parser.add_option('--product', dest='product',
                          help=_("product name (product name, label or id required)"))
        parser.add_option('--product_label', dest='product_label',
                          help=_("product label (product name, label or id required)"))
        parser.add_option('--product_id', dest='product_id',
                          help=_("product id (product name, label or id required)"))
        self._add_get_cvd_opts(parser)

    def check_options(self, validator):
        validator.require('org')
        self._add_get_cvd_opts_check(validator)
        validator.require_at_least_one_of(('product', 'product_label', 'product_id'))
        validator.mutually_exclude('product', 'product_label', 'product_id')

    def run(self):
        org_name      = self.get_option('org')
        def_label     = self.get_option('label')
        def_name      = self.get_option('name')
        def_id        = self.get_option('id')
        product_name  = self.get_option('product')
        product_id    = self.get_option('product_id')
        product_label = self.get_option('product_label')

        view    = get_cv_definition(org_name, def_label, def_name, def_id)
        product = get_product(org_name, product_name, product_label, product_id)

        products = self.def_api.products(org_name, view['id'])
        products = [f['id'] for f in products]
        self.update_products(org_name, view, products, product)
        return os.EX_OK

    def update_products(self, org_name, cvd, products, product):
        if self.addition:
            products.append(product['id'])
            message = _("Added product [ %(prod)s ] to definition [ %(def)s ]" % \
                        ({"prod": product['label'], "def": cvd["label"]}))
        else:
            products.remove(product['id'])
            message = _("Removed product [ %(prod)s ] to definition [ %(def)s ]" % \
                        ({"prod": product['label'], "def": cvd["label"]}))

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
        opt_parser_add_org(parser, required=1)
        parser.add_option('--repo', dest='repo',
                          help=_("repository name (required)"))
        parser.add_option('--product', dest='product',
                          help=_("product name (product name, label or id required)"))
        parser.add_option('--product_label', dest='product_label',
                          help=_("product label (product name, label or id required)"))
        parser.add_option('--product_id', dest='product_id',
                          help=_("product id (product name, label or id required)"))
        self._add_get_cvd_opts(parser)

    def check_options(self, validator):
        validator.require(('repo', 'org', 'product'))
        self._add_get_cvd_opts_check(validator)

    def run(self):
        org_name       = self.get_option('org')
        def_label      = self.get_option('label')
        def_name       = self.get_option('name')
        def_id         = self.get_option('id')
        repo_name      = self.get_option('repo')
        product        = self.get_option('product')
        product_label  = self.get_option('product_label')
        product_id     = self.get_option('product_id')

        view = get_cv_definition(org_name, def_label, def_name, def_id)
        repo = get_repo(org_name, repo_name, product, product_label, product_id)

        repos = self.def_api.repos(org_name, view['id'])
        repos = [f['id'] for f in repos]
        self.update_repos(org_name, view, repos, repo)
        return os.EX_OK

    def update_repos(self, org_name, cvd, repos, repo):
        if self.addition:
            repos.append(repo["id"])
            message = _("Added repository [ %(repo)s ] to definition [ %(def)s ]" % \
                        ({"repo": repo["name"], "def": cvd["label"]}))
        else:
            repos.remove(repo["id"])
            message = _("Removed repository [ %(repo)s ] to definition [ %(def)s ]" % \
                        ({"repo": repo["name"], "def": cvd["label"]}))

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
        self._add_get_cvd_opts(parser)
        opt_parser_add_org(parser, required=1)
        parser.add_option('--view_label', dest='view_label',
                help=_("content view label"))
        parser.add_option('--view_id', dest='view_id',
                help=_("content view id"))
        parser.add_option('--view_name', dest='view_name',
                help=_("content view name"))

    def check_options(self, validator):
        self._add_get_cvd_opts_check(validator)
        validator.require(('org'))
        validator.require_at_least_one_of(('view_name', 'view_label',
                                           'view_id'))
        validator.mutually_exclude(('view_name', 'view_label', 'view_id'))

    def run(self):
        org_name           = self.get_option('org')
        def_label          = self.get_option('label')
        def_name           = self.get_option('name')
        def_id             = self.get_option('id')
        content_view_label = self.get_option('view_label')
        content_view_name  = self.get_option('view_name')
        content_view_id    = self.get_option('view_id')

        cvd = get_cv_definition(org_name, def_label, def_name, def_id)
        content_view = get_content_view(org_name, content_view_label, content_view_name,
                                        content_view_id)

        content_views = self.def_api.content_views(cvd['id'])
        content_views = [f['id'] for f in content_views]
        self.update_content_views(cvd, content_views, content_view)
        return os.EX_OK

    def update_content_views(self, cvd, content_views, content_view):
        if self.addition:
            content_views.append(content_view["id"])
            message = _("Added content view [ %(view)s ] to definition [ %(def)s ]" % \
                        ({"def": content_view["name"], "view": cvd["label"]}))
        else:
            content_views.remove(content_view["id"])
            message = _("Removed content view [ %(view)s ] to content view [ %(def)s ]" % \
                        ({"def": content_view["name"], "view": cvd["label"]}))

        self.def_api.update_content_views(cvd['id'], content_views)
        print message


# cvd def command ------------------------------------------------------------

class ContentViewDefinition(Command):

    description = _('content view definition actions for the katello server')
