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
from optparse import OptionValueError

from katello.client import constants
from katello.client.api.changeset import ChangesetAPI
from katello.client.cli.base import opt_parser_add_org, opt_parser_add_environment
from katello.client.core.base import BaseAction, Command

from katello.client.api.utils import get_environment, get_changeset, get_repo, get_product, \
    get_content_view
from katello.client.lib.async import AsyncTask, evaluate_task_status
from katello.client.lib.ui.progress import run_spinner_in_bg, wait_for_async_task
from katello.client.lib.utils.data import test_record
from katello.client.lib.ui.formatters import format_date
from katello.client.lib.ui import printer
from katello.client.lib.utils.encoding import u_str
from katello.client.lib.ui.printer import batch_add_columns

# base changeset action ========================================================
class ChangesetAction(BaseAction):
    def __init__(self):
        super(ChangesetAction, self).__init__()
        self.api = ChangesetAPI()

# ==============================================================================
class List(ChangesetAction):
    description = _('list new changesets of an environment')

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)
        opt_parser_add_environment(parser, required=1)

    def check_options(self, validator):
        validator.require(('org', 'environment'))

    def run(self):
        orgName = self.get_option('org')
        envName = self.get_option('environment')
        verbose = self.get_option('verbose')

        env = get_environment(orgName, envName)
        changesets = self.api.changesets(orgName, env['id'])


        batch_add_columns(self.printer, {'id': _("ID")}, {'name': _("Name")}, {'action_type': _("Action Type")})
        self.printer.add_column('updated_at', _("Last Updated"), formatter=format_date)
        batch_add_columns(self.printer, {'state': _("State")}, \
            {'environment_id': _("Environment ID")}, {'environment_name': _("Environment Name")})
        if verbose:
            self.printer.add_column('description', _("Description"), multiline=True)

        self.printer.set_header(_("Changeset List"))
        self.printer.print_items(changesets)
        return os.EX_OK


# ==============================================================================
class Info(ChangesetAction):
    description = _('detailed information about a changeset')

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)
        opt_parser_add_environment(parser, required=1)
        parser.add_option('--name', dest='name', help=_("changeset name (required)"))
        parser.add_option('--dependencies', dest='deps', action='store_true',
                               help=_("will display dependent packages"))

    def check_options(self, validator):
        validator.require(('org', 'name', 'environment'))

    @classmethod
    def format_item_list(cls, key, items):
        return "\n".join([i[key] for i in items])

    def get_dependencies(self, cset_id):
        deps = self.api.dependencies(cset_id)
        return self.format_item_list('display_name', deps)

    def run(self):
        orgName = self.get_option('org')
        envName = self.get_option('environment')
        csName = self.get_option('name')
        displayDeps = self.has_option('deps')

        cset = get_changeset(orgName, envName, csName)

        cset['environment_name'] = envName

        cset["errata"] = self.format_item_list("display_name", cset["errata"])
        cset["products"] = self.format_item_list("name", cset["products"])
        cset["packages"] = self.format_item_list("display_name", cset["packages"])
        cset["repositories"] = self.format_item_list("name", cset["repos"])
        cset["content_views"] = self.format_item_list("label", cset["content_views"])
        cset["distributions"] = self.format_item_list("distribution_id", cset["distributions"])
        if displayDeps:
            cset["dependencies"] = self.get_dependencies(cset["id"])
        batch_add_columns(self.printer, {'id': _("ID")}, {'name': _("Name")}, {'action_type': _("Action Type")})
        self.printer.add_column('description', _("Description"), multiline=True, show_with=printer.VerboseStrategy)
        self.printer.add_column('updated_at', _("Last Updated"), formatter=format_date)
        batch_add_columns(self.printer, {'state': _("State")}, \
            {'environment_id': _("Environment ID")}, {'environment_name': _("Environment Name")})
        batch_add_columns(self.printer, {'errata': _("Errata")}, {'products': _("Products")}, \
            {'packages': _("Packages")}, {'repositories': _("Repositories")}, \
            {'distributions': _("Distributions")}, {'content_views': _("Content Views")}, \
            multiline=True, show_with=printer.VerboseStrategy)
        if displayDeps:
            self.printer.add_column('dependencies', _("Dependencies"), \
                multiline=True, show_with=printer.VerboseStrategy)

        self.printer.set_header(_("Changeset Info"))
        self.printer.print_item(cset)

        return os.EX_OK


# ==============================================================================
class Create(ChangesetAction):
    description = _('create a new changeset for an environment')

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)
        opt_parser_add_environment(parser, required=1)
        parser.add_option('--name', dest='name',
                               help=_("changeset name (required)"))
        parser.add_option('--description', dest='description',
                               help=_("changeset description"))
        parser.add_option('--promotion', dest='type_promotion', action="store_true", default=False,
                               help=constants.OPT_HELP_PROMOTION)
        parser.add_option('--deletion', dest='type_deletion', action="store_true", default=False,
                               help=constants.OPT_ERR_PROMOTION_OR_DELETE)



    def check_options(self, validator):
        validator.require(('org', 'name', 'environment'))

    def run(self):
        orgName = self.get_option('org')
        envName = self.get_option('environment')
        csName = self.get_option('name')
        csDescription = self.get_option('description')
        csType = constants.PROMOTION

        # Check for duplicate type flags
        if self.get_option('type_promotion') and self.get_option('type_deletion'):
            raise OptionValueError(constants.OPT_ERR_PROMOTION_OR_DELETE)
        if self.get_option('type_promotion'):
            csType = constants.PROMOTION
        elif self.get_option('type_deletion'):
            csType = constants.DELETION

        env = get_environment(orgName, envName)
        cset = self.api.create(orgName, env["id"], csName, csType, csDescription)
        test_record(cset,
            _("Successfully created changeset [ %(csName)s ] for environment [ %(env_name)s ]")
                % {'csName':csName, 'env_name':env["name"]},
            _("Could not create changeset [ %(csName)s ] for environment [ %(env_name)s ]")
                % {'csName':csName, 'env_name':env["name"]}
        )

        return os.EX_OK


# ==============================================================================
class UpdateContent(ChangesetAction):
    class PatchBuilder(object):
        @staticmethod
        def build_patch(action, itemBuilder, items):
            patch = {}
            patch['packages'] = [itemBuilder.package(i) for i in items[action + "_package"]]
            patch['errata'] = [itemBuilder.erratum(i) for i in items[action + "_erratum"]]
            patch['repositories'] = [itemBuilder.repo(i) for i in items[action + "_repo"]]

            patch['products'] = [itemBuilder.product(i) for i in (
                items[action + "_product"] + items[action + "_product_label"] +
                items[action + "_product_id"])]

            patch['content_views'] = [itemBuilder.content_view(i) for i in items[action + "_content_view"]]
            patch['distributions'] = [itemBuilder.distro(i) for i in items[action + "_distribution"]]
            return patch

    class PatchItemBuilder(object):
        def __init__(self, org_name, env_name, type_in):
            self.org_name = org_name
            self.env_name = env_name
            self.type = type_in
            # Use current env if we are doing a deletion otherwise use the prior
            if self.type == 'deletion':
                self.env_name = get_environment(org_name, env_name)['name']
            else:
                self.env_name = get_environment(org_name, env_name)['prior']

        @classmethod
        def product_options(cls, options):
            product = {'name': None, 'label': None, 'id': None}

            if 'product' in options:
                product['name'] = options['product']
            elif 'product_label' in options:
                product['label'] = options['product_label']
            elif 'product_id' in options:
                product['id'] = options['product_id']

            return product

        def product_id(self, options):
            prod_opts = self.product_options(options)

            # if the product name/label/id are all none...
            if (all(opt is None for opt in prod_opts.itervalues())):
                prod_opts['name'] = options['name']

            prod = get_product(self.org_name, prod_opts['name'], prod_opts['label'], prod_opts['id'])

            return prod['id']

        def repo_id(self, options):
            prod_opts = self.product_options(options)
            repo = get_repo(self.org_name, options['name'], prod_opts['name'],
                prod_opts['label'], prod_opts['id'], self.env_name)
            return repo['id']

        def content_view_id(self, options):
            view = get_content_view(self.org_name, options['label'])
            return view['id']

    class AddPatchItemBuilder(PatchItemBuilder):
        def package(self, options):
            return {
                'name': options['name'],
                'product_id': self.product_id(options)
            }

        def product(self, options):
            return {
                'product_id': self.product_id(options)
            }

        def erratum(self, options):
            return {
                'erratum_id': options['name'],
                'product_id': self.product_id(options)
            }

        def repo(self, options):
            return {
                'repository_id': self.repo_id(options),
                'product_id': self.product_id(options)
            }

        def content_view(self, options):
            return {
                'content_view_id': self.content_view_id(options)
            }

        def distro(self, options):
            return {
                'distribution_id': options['name'],
                'product_id': self.product_id(options)
            }


    class RemovePatchItemBuilder(PatchItemBuilder):
        def package(self, options):
            return {
                'content_id': options['name'],
                'product_id': self.product_id(options)
            }

        def product(self, options):
            return {
                'content_id': self.product_id(options)
            }

        def erratum(self, options):
            return {
                'content_id': options['name'],
                'product_id': self.product_id(options)
            }

        def repo(self, options):
            return {
                'content_id': self.repo_id(options),
                'product_id': self.product_id(options)
            }

        def content_view(self, options):
            return {
                'content_id': self.content_view_id(options)
            }

        def distro(self, options):
            return {
                'content_id': options['name'],
                'product_id': self.product_id(options)
            }


    productDependentContent = ['package', 'erratum', 'repo', 'distribution']
    productIndependentContent = ['product', 'product_label', 'product_id',
            'content_view']

    description = _('updates content of a changeset')

    def __init__(self):
        self.current_product = None
        self.current_product_option = None
        super(UpdateContent, self).__init__()
        self.items = {}


    # pylint: disable=W0613
    def _store_from_product(self, option, opt_str, value, parser):
        self.current_product = u_str(value)
        self.current_product_option = option.dest
        setattr(parser.values, option.dest, value)

    def _store_item_with_product(self, option, opt_str, value, parser):
        if (parser.values.from_product == None) and \
           (parser.values.from_product_label == None) and \
           (parser.values.from_product_id == None):
            raise OptionValueError(_("%s must be preceded by %s, %s or %s") %
                  (option, "--from_product", "--from_product_label", "--from_product_id"))

        if self.current_product_option == 'product_label':
            self.items[option.dest].append({"name": u_str(value), "product_label": self.current_product})
        elif self.current_product_option == 'product_id':
            self.items[option.dest].append({"name": u_str(value), "product_id": self.current_product})
        else:
            self.items[option.dest].append({"name": u_str(value), "product": self.current_product})


    def _store_item(self, option, opt_str, value, parser):
        if option.dest == 'add_product_label' or option.dest == 'remove_product_label':
            self.items[option.dest].append({"product_label": u_str(value)})
        elif option.dest == 'add_product_id' or option.dest == 'remove_product_id':
            self.items[option.dest].append({"product_id": u_str(value)})
        elif option.dest == "add_content_view" or option.dest == "remove_content_view":
            self.items[option.dest].append({"label": u_str(value)})
        else:
            self.items[option.dest].append({"name": u_str(value)})

        setattr(parser.values, option.dest, value)

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name',
                               help=_("changeset name (required)"))
        opt_parser_add_org(parser, required=1)
        opt_parser_add_environment(parser, required=1)
        parser.add_option('--description', dest='description',
                               help=_("changeset description"))
        parser.add_option('--new_name', dest='new_name',
                               help=_("new changeset name"))

        parser.add_option('--add_product', dest='add_product', type="string",
                               action="callback", callback=self._store_item,
                               help=_("product to add to the changeset, by name"))
        parser.add_option('--add_product_label', dest='add_product_label', type="string",
                               action="callback", callback=self._store_item,
                               help=_("product to add to the changeset, by label"))
        parser.add_option('--add_product_id', dest='add_product_id', type="string",
                               action="callback", callback=self._store_item,
                               help=_("product to add to the changeset, by id"))


        parser.add_option('--remove_product', dest='remove_product', type="string",
                               action="callback", callback=self._store_item,
                               help=_("product to remove from the changeset, by name"))
        parser.add_option('--remove_product_label', dest='remove_product_label', type="string",
                               action="callback", callback=self._store_item,
                               help=_("product to remove from the changeset, by label"))
        parser.add_option('--remove_product_id', dest='remove_product_id', type="string",
                               action="callback", callback=self._store_item,
                               help=_("product to remove from the changeset, by id"))

        parser.add_option('--add_content_view', dest='add_content_view', type="string",
                               action="callback", callback=self._store_item,
                               help=_("label of a content view to be added to the changeset"))
        parser.add_option('--remove_content_view', dest='remove_content_view', type="string",
                               action="callback", callback=self._store_item,
                               help=_("label of a content view to be removed from the changeset"))

        parser.add_option('--from_product', dest='from_product',
                               action="callback", callback=self._store_from_product, type="string",
                               help=_("determines product from which the packages/errata/repositories are picked"))
        parser.add_option('--from_product_label', dest='from_product_label',
                               action="callback", callback=self._store_from_product, type="string",
                               help=_("determines product from which the packages/errata/repositories are picked"))
        parser.add_option('--from_product_id', dest='from_product_id',
                               action="callback", callback=self._store_from_product, type="string",
                               help=_("determines product from which the packages/errata/repositories are picked"))

        for ct in self.productDependentContent:
            parser.add_option('--add_' + ct, dest='add_' + ct,
                                   action="callback", callback=self._store_item_with_product, type="string",
                                   help=_(ct + " to add to the changeset"))
            parser.add_option('--remove_' + ct, dest='remove_' + ct,
                                   action="callback", callback=self._store_item_with_product, type="string",
                                   help=_(ct + " to remove from the changeset"))
        self.reset_items()

    def reset_items(self):
        self.items = {}
        for ct in self.productDependentContent + self.productIndependentContent:
            self.items['add_' + ct] = []
            self.items['remove_' + ct] = []

    def check_options(self, validator):
        validator.require(('name', 'org', 'environment'))
        validator.mutually_exclude('add_product', 'add_product_label', 'add_product_id')
        validator.mutually_exclude('remove_product', 'remove_product_label', 'remove_product_id')
        validator.mutually_exclude('from_product', 'from_product_label', 'from_product_id')

    def run(self):
        #reset stored patch items (neccessary for shell mode)
        items = self.items.copy()
        self.reset_items()

        csName = self.get_option('name')
        orgName = self.get_option('org')
        envName = self.get_option('environment')
        csNewName = self.get_option('new_name')
        csDescription = self.get_option('description')

        cset = get_changeset(orgName, envName, csName)
        csType = cset['action_type']

        self.update(cset["id"], csNewName, csDescription)
        addPatch = self.PatchBuilder.build_patch('add',
            self.AddPatchItemBuilder(orgName, envName, csType), items)
        removePatch = self.PatchBuilder.build_patch('remove',
            self.RemovePatchItemBuilder(orgName, envName, csType), items)

        self.update_content(cset["id"], addPatch, self.api.add_content)
        self.update_content(cset["id"], removePatch, self.api.remove_content)

        print _("Successfully updated changeset [ %s ]") % csName
        return os.EX_OK


    def update(self, csId, newName, description):
        self.api.update(csId, newName, description)


    # pylint: disable=R0201
    def update_content(self, csId, patch, updateMethod):
        for contentType, items in patch.iteritems():
            for i in items:
                updateMethod(csId, contentType, i)


# ==============================================================================
class Delete(ChangesetAction):
    description = _('deletes a changeset')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name',
                               help=_("changeset name (required)"))
        opt_parser_add_org(parser, required=1)
        opt_parser_add_environment(parser, required=1)

    def check_options(self, validator):
        validator.require(('name', 'org', 'environment'))

    def run(self):
        csName = self.get_option('name')
        orgName = self.get_option('org')
        envName = self.get_option('environment')

        cset = get_changeset(orgName, envName, csName)

        msg = self.api.delete(cset["id"])
        print msg
        return os.EX_OK


# ==============================================================================
class Apply(ChangesetAction):
    description = _('applies a changeset based on the type (promotion, deletion)')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name',
                               help=_("changeset name (required)"))
        opt_parser_add_org(parser, required=1)
        opt_parser_add_environment(parser, required=1)

    def check_options(self, validator):
        validator.require(('name', 'org', 'environment'))

    def run(self):
        csName = self.get_option('name')
        orgName = self.get_option('org')
        envName = self.get_option('environment')

        cset = get_changeset(orgName, envName, csName)

        task = self.api.apply(cset["id"])
        task = AsyncTask(task)

        run_spinner_in_bg(wait_for_async_task, [task], message=_("Applying the changeset, please wait... "))

        return evaluate_task_status(task,
            failed = _("Changeset [ %s ] promotion failed") % csName,
            ok =     _("Changeset [ %s ] applied") % csName
        )

# ==============================================================================
class Promote(Apply):
    description = _('promotes a changeset to the next environment - DEPRECATED')

    def run(self):
        csName = self.get_option('name')
        orgName = self.get_option('org')
        envName = self.get_option('environment')

        # Block attempts to call this on deletion changesets, otherwise continue
        cset = get_changeset(orgName, envName, csName)
        if 'type' in cset and cset['type'] == constants.DELETION:
            print _("This is a deletion changeset and does not support promotion")
            return os.EX_DATAERR

        super(Promote, self).run()



# changeset command ============================================================
class Changeset(Command):
    description = _('changeset specific actions in the katello server')
