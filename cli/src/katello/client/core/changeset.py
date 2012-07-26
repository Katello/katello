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
from optparse import OptionValueError

from katello.client.api.changeset import ChangesetAPI
from katello.client.config import Config
from katello.client.core.base import BaseAction, Command
from katello.client.core.utils import test_record, run_spinner_in_bg, format_date, wait_for_async_task, AsyncTask, format_task_errors
from katello.client.api.utils import get_environment, get_changeset, get_template, get_repo, get_product
from katello.client.utils import printer
from katello.client.utils.encoding import u_str

Config()


# base changeset action ========================================================
class ChangesetAction(BaseAction):
    def __init__(self):
        super(ChangesetAction, self).__init__()
        self.api = ChangesetAPI()

# ==============================================================================
class List(ChangesetAction):
    description = _('list new changesets of an environment')

    def setup_parser(self, parser):
        parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))
        parser.add_option('--environment', dest='env',
                               help=_("environment name (required)"))

    def check_options(self, validator):
        validator.require(('org', 'env'))

    def run(self):
        orgName = self.get_option('org')
        envName = self.get_option('env')
        verbose = self.get_option('verbose')

        env = get_environment(orgName, envName)
        changesets = self.api.changesets(orgName, env['id'])

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('type')
        self.printer.add_column('updated_at', formatter=format_date)
        self.printer.add_column('state')
        self.printer.add_column('environment_id')
        self.printer.add_column('environment_name')
        if verbose: self.printer.add_column('description', multiline=True)

        self.printer.set_header(_("Changeset List"))
        self.printer.print_items(changesets)
        return os.EX_OK


# ==============================================================================
class Info(ChangesetAction):
    description = _('detailed information about a changeset')

    def setup_parser(self, parser):
        parser.add_option('--org', dest='org', help=_("name of organization (required)"))
        parser.add_option('--environment', dest='env', help=_("environment name (required)"))
        parser.add_option('--name', dest='name', help=_("changeset name (required)"))
        parser.add_option('--dependencies', dest='deps', action='store_true',
                               help=_("will display dependent packages"))

    def check_options(self, validator):
        validator.require(('org', 'name', 'env'))

    def format_item_list(self, key, items):
        return "\n".join([i[key] for i in items])

    def get_dependencies(self, cset_id):
        deps = self.api.dependencies(cset_id)
        return self.format_item_list('display_name', deps)

    def run(self):
        orgName = self.get_option('org')
        envName = self.get_option('env')
        csName = self.get_option('name')
        displayDeps = self.has_option('deps')

        cset = get_changeset(orgName, envName, csName)

        cset['environment_name'] = envName

        cset["errata"] = self.format_item_list("display_name", cset["errata"])
        cset["products"] = self.format_item_list("name", cset["products"])
        cset["packages"] = self.format_item_list("display_name", cset["packages"])
        cset["repositories"] = self.format_item_list("name", cset["repos"])
        cset["system_templates"] = self.format_item_list("name", cset["system_templates"])
        cset["distributions"] = self.format_item_list("distribution_id", cset["distributions"])
        if displayDeps:
            cset["dependencies"] = self.get_dependencies(cset["id"])

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('type')
        self.printer.add_column('description', multiline=True, show_with=printer.VerboseStrategy)
        self.printer.add_column('updated_at', formatter=format_date)
        self.printer.add_column('state')
        self.printer.add_column('environment_id')
        self.printer.add_column('environment_name')
        self.printer.add_column('errata', multiline=True, show_with=printer.VerboseStrategy)
        self.printer.add_column('products', multiline=True, show_with=printer.VerboseStrategy)
        self.printer.add_column('packages', multiline=True, show_with=printer.VerboseStrategy)
        self.printer.add_column('repositories', multiline=True, show_with=printer.VerboseStrategy)
        self.printer.add_column('system_templates', multiline=True, show_with=printer.VerboseStrategy)
        self.printer.add_column('distributions', multiline=True, show_with=printer.VerboseStrategy)
        if displayDeps:
            self.printer.add_column('dependencies', multiline=True, show_with=printer.VerboseStrategy)

        self.printer.set_header(_("Changeset Info"))
        self.printer.print_item(cset)

        return os.EX_OK


# ==============================================================================
class Create(ChangesetAction):
    description = _('create a new changeset for an environment')

    def setup_parser(self, parser):
        parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))
        parser.add_option('--environment', dest='env',
                               help=_("environment name (required)"))
        parser.add_option('--name', dest='name',
                               help=_("changeset name (required)"))
        parser.add_option('--description', dest='description',
                               help=_("changeset description"))
        parser.add_option('--promotion', dest='type_promotion', action="store_true", default=False,
                               help=_("changeset type promotion: pushes changes to the next environment [DEFAULT]"))
        parser.add_option('--deletion', dest='type_deletion', action="store_true", default=False,
                               help=_("changeset type deletion: deletes items in changeset from current environment"))



    def check_options(self, validator):
        validator.require(('org', 'name', 'env'))

    def run(self):
        orgName = self.get_option('org')
        envName = self.get_option('env')
        csName = self.get_option('name')
        csDescription = self.get_option('description')
        csType = 'PROMOTION'

        # Check for duplicate type flags
        if self.get_option('type_promotion') and self.get_option('type_deletion'):
            raise OptionValueError(_("specify either --promotion or --deletion but not both"))
        if self.get_option('type_promotion'):
            csType = 'PROMOTION'
        elif self.get_option('type_deletion'):
            csType = 'DELETION'

        env = get_environment(orgName, envName)
        cset = self.api.create(orgName, env["id"], csName, csType, csDescription)
        test_record(cset,
            _("Successfully created changeset [ %s ] for environment [ %s ]") % (csName, env["name"]),
            _("Could not create changeset [ %s ] for environment [ %s ]") % (csName, env["name"])
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
            patch['products'] = [itemBuilder.product(i) for i in items[action + "_product"]]
            patch['templates'] = [itemBuilder.template(i) for i in items[action + "_template"]]
            patch['distributions'] = [itemBuilder.distro(i) for i in items[action + "_distribution"]]
            return patch

    class PatchItemBuilder(object):
        def __init__(self, org_name, env_name):
            self.org_name = org_name
            self.env_name = env_name
            self.prior_env_name = get_environment(org_name, env_name)['prior']


        def product_id(self, options):
            if 'product' in options:
                prod_name = options['product']
            else:
                prod_name = options['name']

            prod = get_product(self.org_name, prod_name)
            return prod['id']

        def repo_id(self, options):
            repo = get_repo(self.org_name, options['product'], options['name'], self.prior_env_name)
            return repo['id']

        def template_id(self, options):
            tpl = get_template(self.org_name, self.prior_env_name, options['name'])
            return tpl['id']


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

        def template(self, options):
            return {
                'template_id': self.template_id(options)
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

        def template(self, options):
            return {
                'content_id': self.template_id(options)
            }

        def distro(self, options):
            return {
                'content_id': options['name'],
                'product_id': self.product_id(options)
            }


    productDependentContent = ['package', 'erratum', 'repo', 'distribution']
    productIndependentContent = ['product', 'template']

    description = _('updates content of a changeset')

    def __init__(self):
        self.current_product = None
        super(UpdateContent, self).__init__()


    def store_from_product(self, option, opt_str, value, parser):
        self.current_product = u_str(value)
        parser.values.from_product = True

    def store_item_with_product(self, option, opt_str, value, parser):
        if parser.values.from_product == None:
            raise OptionValueError(_("%s must be preceded by %s") % (option, "--from_product"))

        self.items[option.dest].append({"name": u_str(value), "product": self.current_product})

    def store_item(self, option, opt_str, value, parser):
        self.items[option.dest].append({"name": u_str(value)})

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name',
                               help=_("changeset name (required)"))
        parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))
        parser.add_option('--environment', dest='env',
                               help=_("environment name (required)"))
        parser.add_option('--description', dest='description',
                               help=_("changeset description"))
        parser.add_option('--new_name', dest='new_name',
                               help=_("new changeset name"))
        parser.add_option('--add_product', dest='add_product', type="string",
                               action="callback", callback=self.store_item,
                               help=_("product to add to the changeset"))
        parser.add_option('--remove_product', dest='remove_product', type="string",
                               action="callback", callback=self.store_item,
                               help=_("product to remove from the changeset"))
        parser.add_option('--add_template', dest='add_template', type="string",
                               action="callback", callback=self.store_item,
                               help=_("name of a template to be added to the changeset"))
        parser.add_option('--remove_template', dest='remove_template', type="string",
                               action="callback", callback=self.store_item,
                               help=_("name of a template to be removed from the changeset"))
        parser.add_option('--from_product', dest='from_product',
                               action="callback", callback=self.store_from_product, type="string",
                               help=_("determines product from which the packages/errata/repositories are picked"))

        for ct in self.productDependentContent:
            parser.add_option('--add_' + ct, dest='add_' + ct,
                                   action="callback", callback=self.store_item_with_product, type="string",
                                   help=_(ct + " to add to the changeset"))
            parser.add_option('--remove_' + ct, dest='remove_' + ct,
                                   action="callback", callback=self.store_item_with_product, type="string",
                                   help=_(ct + " to remove from the changeset"))
        self.reset_items()

    def reset_items(self):
        self.items = {}
        for ct in self.productDependentContent + self.productIndependentContent:
            self.items['add_' + ct] = []
            self.items['remove_' + ct] = []

    def check_options(self, validator):
        validator.require(('name', 'org', 'env'))

    def run(self):
        #reset stored patch items (neccessary for shell mode)
        items = self.items.copy()
        self.reset_items()

        csName = self.get_option('name')
        orgName = self.get_option('org')
        envName = self.get_option('env')
        csNewName = self.get_option('new_name')
        csDescription = self.get_option('description')

        cset = get_changeset(orgName, envName, csName)

        self.update(cset["id"], csNewName, csDescription)
        addPatch = self.PatchBuilder.build_patch('add', self.AddPatchItemBuilder(orgName, envName), items)
        removePatch = self.PatchBuilder.build_patch('remove', self.RemovePatchItemBuilder(orgName, envName), items)
        self.update_content(cset["id"], addPatch, self.api.add_content)
        self.update_content(cset["id"], removePatch, self.api.remove_content)

        print _("Successfully updated changeset [ %s ]") % csName
        return os.EX_OK


    def update(self, csId, newName, description):
        self.api.update(csId, newName, description)


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
        parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))
        parser.add_option('--environment', dest='env',
                               help=_("environment name (required)"))

    def check_options(self, validator):
        validator.require(('name', 'org', 'env'))

    def run(self):
        csName = self.get_option('name')
        orgName = self.get_option('org')
        envName = self.get_option('env')

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
        parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))
        parser.add_option('--environment', dest='env',
                               help=_("environment name (required)"))

    def check_options(self, validator):
        validator.require(('name', 'org', 'env'))

    def run(self):
        csName = self.get_option('name')
        orgName = self.get_option('org')
        envName = self.get_option('env')

        cset = get_changeset(orgName, envName, csName)

        task = self.api.promote(cset["id"])
        task = AsyncTask(task)

        run_spinner_in_bg(wait_for_async_task, [task], message=_("Promoting the changeset, please wait... "))

        if task.succeeded():
            print _("Changeset [ %s ] promoted" % csName)
            return os.EX_OK
        else:
            print _("Changeset [ %s ] promotion failed: %s" % (csName, format_task_errors(task.errors())))
            return os.EX_DATAERR


# changeset command ============================================================
class Changeset(Command):
    description = _('changeset specific actions in the katello server')
