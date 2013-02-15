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
import sys
from optparse import OptionValueError

from katello.client.api.template import TemplateAPI
from katello.client.api.utils import get_library, get_environment, get_template, get_repo
from katello.client.cli.base import opt_parser_add_org, opt_parser_add_environment
from katello.client.core.base import BaseAction, Command
from katello.client.lib.control import system_exit
from katello.client.lib.utils.io import get_abs_path
from katello.client.lib.utils.data import test_record
from katello.client.lib.utils.encoding import u_str
from katello.client.lib.ui import printer
from katello.client.lib.ui.progress import run_spinner_in_bg
from katello.client.lib.ui.printer import batch_add_columns



# base template action =========================================================
class TemplateAction(BaseAction):

    def __init__(self):
        super(TemplateAction, self).__init__()
        self.api = TemplateAPI()

    @classmethod
    def get_parent_id(cls, orgName, envName, parentName):
        parent = get_template(orgName, envName, parentName)
        if parent != None:
            return parent["id"]
        system_exit(os.EX_DATAERR)

# ==============================================================================
class List(TemplateAction):

    description = _('list all templates')

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)
        opt_parser_add_environment(parser, default=_("Library"))

    def check_options(self, validator):
        validator.require('org')

    def run(self):
        envName = self.get_option('environment')
        orgName = self.get_option('org')

        environment = get_environment(orgName, envName)
        templates = self.api.templates(environment["id"])

        if not templates:
            print _("No templates found in environment [ %s ]") % environment["name"]
            return os.EX_OK
        self.printer.add_column('id', _("ID"))
        self.printer.add_column('name', _("Name"))
        self.printer.add_column('description', _("Description"), multiline=True)
        self.printer.add_column('environment_id', _("Environment ID"))
        self.printer.add_column('parent_id', _("Parent ID"))

        self.printer.set_header(_("Template List"))
        self.printer.print_items(templates)
        return os.EX_OK


# ==============================================================================
class Info(TemplateAction):

    description = _('list information about a template')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name',
                               help=_("template name (required)"))
        opt_parser_add_org(parser, required=1)
        opt_parser_add_environment(parser, default=_("Library"))

    def check_options(self, validator):
        validator.require(('name', 'org'))

    def run(self):
        tplName = self.get_option('name')
        orgName = self.get_option('org')
        envName = self.get_option('environment')

        template = get_template(orgName, envName, tplName)

        template["products"]     = [p["name"] for p in template["products"]]
        template["repositories"] = [r["name"] for r in template["repositories"]]
        template["packages"]   = [self._build_nvrea(p) for p in template["packages"]]
        template["parameters"] = [key+":\t"+value for key, value in template["parameters"].iteritems()]
        template["package_groups"] = [p["name"] for p in template["package_groups"]]
        template["package_group_categories"] = [p["name"] for p in template["pg_categories"]]


        batch_add_columns(self.printer, {'id': _("ID")}, {'name': _("Name")})
        self.printer.add_column('revision', _("Revision"), show_with=printer.VerboseStrategy)
        self.printer.add_column('description', _("Description"), multiline=True)
        self.printer.add_column('environment_id', _("Environment ID"))
        self.printer.add_column('parent_id', _("Parent ID"))
        batch_add_columns(self.printer, {'errata': _("Errata")}, {'products': _("Products")}, \
            {'repositories': _("Repositories")}, {'packages': _("Packages")}, \
            {'parameters': _("Parameters")}, {'package_groups': _("Package Groups")}, \
            {'package_group_categories': _("Package Group Categories")}, multiline=True, \
            show_with=printer.VerboseStrategy)
        self.printer.set_header(_("Template Info"))
        self.printer.print_item(template)
        return os.EX_OK


    @classmethod
    def _build_nvrea(cls, package):

        if package['version'] != None and package['release'] != None:
            nvrea = '-'.join((package['package_name'], package['version'], package['release']))
            if package['arch'] != None:
                nvrea = nvrea +'.'+ package['arch']
            if package['epoch'] != None:
                nvrea = package['epoch'] +':'+ nvrea
            return nvrea

        else:
            return package['package_name']



# ==============================================================================
class Import(TemplateAction):

    description = _('create a template file and import data')


    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)
        parser.add_option("--file", dest="file",
                               help=_("path to the template file (required)"))
        parser.add_option("--description", dest="description",
                               help=_("provider description"))


    def check_options(self, validator):
        validator.require(('org', 'file'))


    def run(self):
        desc    = self.get_option('description')
        orgName = self.get_option('org')
        tplPath = self.get_option('file')

        env = get_library(orgName)

        try:
            f = self.open_file(tplPath)
        except IOError:
            print _("File [ %s ] does not exist" % tplPath)
            return os.EX_IOERR

        response = run_spinner_in_bg(self.api.import_tpl, (env["id"], desc, f),
            message=_("Importing template, please wait... "))
        print response
        f.close()
        return os.EX_OK

    @classmethod
    def open_file(cls, path):
        return open(get_abs_path(path))

# ==============================================================================
class Export(TemplateAction):

    description = _('export the template into the file')
    supported_formats = ['json', 'tdl']

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name',
                               help=_("template name (required)"))
        opt_parser_add_org(parser, required=1)
        opt_parser_add_environment(parser, required=1)
        parser.add_option("--file", dest="file",
            help=_("path to the template file (required)"))
        parser.add_option("--format", dest="format", choices=self.supported_formats,
            help=_("format of the export, possible values: %s, default: json") % self.supported_formats)


    def check_options(self, validator):
        validator.require(('name', 'org', 'file', 'environment'))

    def run(self):
        tplName = self.get_option('name')
        orgName = self.get_option('org')
        envName = self.get_option('environment')
        format_in  = self.get_option('format') or "json"
        tplPath = self.get_option('file')

        template = get_template(orgName, envName, tplName)

        try:
            f = self.open_file(tplPath)
        except IOError:
            print >> sys.stderr, _("Could not create file [ %s ]") % tplPath
            return os.EX_IOERR

        self.api.validate_tpl(template["id"], format_in)
        response = run_spinner_in_bg(self.api.export_tpl, (template["id"], format_in),
            message=_("Exporting template, please wait... "))
        f.write(response)
        f.close()
        print _("Template was exported successfully to file [ %s ]") % tplPath
        return os.EX_OK

    @classmethod
    def open_file(cls, path):
        return open(get_abs_path(path),"w")


# ==============================================================================
class Create(TemplateAction):

    description = _('create an empty template file')


    def setup_parser(self, parser):
        parser.add_option('--name', dest='name',
                               help=_("template name (required)"))
        parser.add_option('--parent', dest='parent',
                               help=_("name of the parent template"))
        opt_parser_add_org(parser, required=1)
        parser.add_option("--description", dest="description",
                               help=_("template description"))


    def check_options(self, validator):
        validator.require(('name', 'org'))


    def run(self):
        name    = self.get_option('name')
        desc    = self.get_option('description')
        orgName = self.get_option('org')
        parentName = self.get_option('parent')

        env = get_library(orgName)

        if parentName != None:
            parentId = self.get_parent_id(orgName, env['name'], parentName)
        else:
            parentId = None

        template = self.api.create(env["id"], name, desc, parentId)
        test_record(template,
            _("Successfully created template [ %s ]") % name,
            _("Could not create template [ %s ]") % name
        )



# ==============================================================================
class Update(TemplateAction):

    description = _('updates name and description of a template')

    def __init__(self):
        self.current_parameter = None
        self._resetParameters()
        super(Update, self).__init__()
        self.current_product = None
        self.current_product_option = None

    # pylint: disable=W0613
    def _store_parameter_name(self, option, opt_str, value, parser):
        self.current_parameter = u_str(value)
        self.items['add_parameters'][value] = None

    def _store_parameter_value(self, option, opt_str, value, parser):
        if self.current_parameter == None:
            raise OptionValueError(_("each %(option)s must be preceeded by %(paramater)s") \
                % {'option':option, 'parameter':"--add_parameter"} )

        self.items['add_parameters'][self.current_parameter] = u_str(value)
        self.current_parameter = None

    def _store_from_product(self, option, opt_str, value, parser):
        self.current_product = u_str(value)
        self.current_product_option = option.dest
        setattr(parser.values, option.dest, value)

    def _store_item_with_product(self, option, opt_str, value, parser):
        if (parser.values.from_product == None) and \
           (parser.values.from_product_label == None) and \
           (parser.values.from_product_id == None):
            raise OptionValueError(_("%(option)s must be preceded by %(from_product)s, \
                %(from_product_label)s or %(from_product_id)s") 
                    % {'option':option, 'from_product':"--from_product",
                    'from_product_label':"--from_product_label", 'from_product_id':"--from_product_id"})

        if self.current_product_option == 'from_product_label':
            self.items[option.dest].append({"name": u_str(value), "from_product_label": self.current_product})
        elif self.current_product_option == 'from_product_id':
            self.items[option.dest].append({"name": u_str(value), "from_product_id": self.current_product})
        else:
            self.items[option.dest].append({"name": u_str(value), "from_product": self.current_product})

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name', help=_("template name (required)"))
        parser.add_option('--parent', dest='parent', help=_("name of the parent template"))
        opt_parser_add_org(parser, required=1)
        parser.add_option('--new_name', dest='new_name', help=_("new template name"))
        parser.add_option("--description", dest="description", help=_("template description"))

        #bz 799149
        #parser.add_option('--add_product', dest='add_products', action="append", help=_("name of the product"))
        #parser.add_option('--remove_product', dest='remove_products', action="append", help=_("name of the product"))

        parser.add_option('--add_package', dest='add_packages', action="append", help=_("name of the package"))
        parser.add_option('--remove_package', dest='remove_packages', action="append", help=_("name of the package"))

        parser.add_option('--add_parameter', dest='add_parameters', action="callback",
            callback=self._store_parameter_name, type="string",
            help=_("name of the parameter, %s must follow") % "--value")
        parser.add_option('--value', dest='value', action="callback", callback=self._store_parameter_value,
            type="string", help=_("value of the parameter"))
        parser.add_option('--remove_parameter', dest='remove_parameters', action="append",
            help=_("name of the parameter"))

        parser.add_option('--add_package_group', dest='add_pgs', action="append", help=_("name of the package group"))
        parser.add_option('--remove_package_group', dest='remove_pgs', action="append",
            help=_("name of the package group"))

        parser.add_option('--add_package_group_category', dest='add_pg_categories', action="append",
            help=_("name of the package group category"))
        parser.add_option('--remove_package_group_category', dest='remove_pg_categories', action="append",
            help=_("name of the package group category"))

        parser.add_option('--add_distribution', dest='add_distributions', action="append", help=_("distribution ID"))
        parser.add_option('--remove_distribution', dest='remove_distributions', action="append",
            help=_("distribution ID"))

        parser.add_option('--from_product', dest='from_product',
            action="callback", callback=self._store_from_product, type="string",
            help=_("determines product from which the repositories are picked"))
        parser.add_option('--from_product_label', dest='from_product_label',
            action="callback", callback=self._store_from_product, type="string",
            help=_("determines product from which the repositories are picked"))
        parser.add_option('--from_product_id', dest='from_product_id',
            action="callback", callback=self._store_from_product, type="string",
            help=_("determines product from which the repositories are picked"))

        parser.add_option('--add_repository', dest='add_repository', action="callback",
            callback=self._store_item_with_product, type="string",
            help=_("repository to be added to the template"))
        parser.add_option('--remove_repository', dest='remove_repository', action="callback",
            callback=self._store_item_with_product, type="string",
            help=_("repository to be removed from the template"))
        self._resetParameters()


    def check_options(self, validator):
        validator.require(('name', 'org'))
        validator.mutually_exclude('from_product', 'from_product_label', 'from_product_id')

        #check for missing values
        for k, v in self.items['add_parameters'].iteritems():
            if v is None:
                validator.add_option_error(_("missing value for parameter [ %s ]") % k)

    def _resetParameters(self):
        # pylint: disable=W0201
        self.items = {}
        self.items['add_parameters'] = {}
        self.items['add_repository'] = []
        self.items['remove_repository'] = []

    def getContent(self):
        orgName = self.get_option('org')
        items = self.items.copy()
        self._resetParameters()

        content = {}

        content['+packages'] = self.get_option('add_packages') or []
        content['-packages'] = self.get_option('remove_packages') or []

        content['+pgs'] = self.get_option('add_pgs') or []
        content['-pgs'] = self.get_option('remove_pgs') or []

        content['+pg_categories'] = self.get_option('add_pg_categories') or []
        content['-pg_categories'] = self.get_option('remove_pg_categories') or []

        content['+parameters'] = items['add_parameters'].copy()
        content['-parameters'] = self.get_option('remove_parameters') or []

        content['+distros'] = self.get_option('add_distributions') or []
        content['-distros'] = self.get_option('remove_distributions') or []

        content['+repos'] = items['add_repository']
        content['+repos'] = self._repoNamesToIds(orgName, content['+repos'])
        content['-repos'] = items['remove_repository']
        content['-repos'] = self._repoNamesToIds(orgName, content['-repos'])
        return content


    def run(self):
        tplName = self.get_option('name')
        orgName = self.get_option('org')
        newName = self.get_option('new_name')
        desc    = self.get_option('description')
        parentName = self.get_option('parent')
        content = self.getContent()

        env = get_library(orgName)
        template = get_template(orgName, env["name"], tplName)

        if parentName != None:
            parentId = self.get_parent_id(orgName, env["name"], parentName)
        else:
            parentId = None

        run_spinner_in_bg(self.updateTemplate, [template["id"], newName, desc, parentId],
            _("Updating the template, please wait... "))
        run_spinner_in_bg(self.updateContent,  [template["id"], content], _("Updating the template, please wait... "))
        print _("Successfully updated template [ %s ]") % template['name']
        return os.EX_OK


    @classmethod
    def _repoNamesToIds(cls, orgName, repos):
        ids = []
        for rec in repos:
            prodName = None
            prodLabel = None
            prodId = None

            if 'from_product' in rec:
                prodName = rec['from_product']
            elif 'from_product_label' in rec:
                prodLabel = rec['from_product_label']
            elif 'from_product_id' in rec:
                prodId = rec['from_product_id']

            repo = get_repo(orgName, rec['name'], prodName, prodLabel, prodId)
            ids.append(repo['id'])
        return ids


    def updateTemplate(self, tplId, name, desc, parentId):
        self.api.update(tplId, name, desc, parentId)


    def updateContent(self, tplId, content):


        for p in content['-packages']:
            self.api.remove_content(tplId, 'packages', p)
        for p in content['+packages']:
            self.api.add_content(tplId, 'packages', {'name': p})

        for p in content['-pgs']:
            self.api.remove_content(tplId, 'package_groups', p)
        for p in content['+pgs']:
            self.api.add_content(tplId, 'package_groups', {'name': p})

        for p in content['-pg_categories']:
            self.api.remove_content(tplId, 'package_group_categories', p)
        for p in content['+pg_categories']:
            self.api.add_content(tplId, 'package_group_categories', {'name': p})

        for p in content['-parameters']:
            self.api.remove_content(tplId, 'parameters', p)
        for p, v in content['+parameters'].iteritems():
            self.api.add_content(tplId, 'parameters', {'name': p, 'value': v})

        for p in content['-distros']:
            self.api.remove_content(tplId, 'distributions', p)
        for p in content['+distros']:
            self.api.add_content(tplId, 'distributions', {'id': p})

        for p in content['-repos']:
            self.api.remove_content(tplId, 'repositories', p)
        for p in content['+repos']:
            self.api.add_content(tplId, 'repositories', {'id': p})


# ==============================================================================
class Delete(TemplateAction):

    description = _('deletes a template')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name',
                               help=_("template name (required)"))
        opt_parser_add_org(parser, required=1)
        opt_parser_add_environment(parser)

    def check_options(self, validator):
        validator.require(('name', 'org'))

    def run(self):
        tplName = self.get_option('name')
        orgName = self.get_option('org')
        envName = self.get_option('environment')

        template = get_template(orgName, envName, tplName)
        msg = self.api.delete(template["id"])
        print msg
        return os.EX_OK


# provider command =============================================================

class Template(Command):

    description = _('template specific actions in the katello server')
