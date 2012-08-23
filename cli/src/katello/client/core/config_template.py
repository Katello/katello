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
from gettext import gettext as _

from katello.client.api.config_template import ConfigTemplateAPI
from katello.client.config import Config
from katello.client.core.base import BaseAction, Command
from katello.client.core.utils import test_record, unnest_one

Config()

# base config template action --------------------------------------------------------

class ConfigTemplateAction(BaseAction):

    def __init__(self):
        super(ConfigTemplateAction, self).__init__()
        self.api = ConfigTemplateAPI()

# config template actions ------------------------------------------------------------

class List(ConfigTemplateAction):

    description = _('list config template')

    def setup_parser(self, parser):
        parser.add_option('--search', dest='search', help=_("filter results"))
        # order not working - there is a bug in scoped-search which foreman uses
        parser.add_option('--order', dest='order', help=_("sort results"))

    def check_options(self, validator):
        pass

    def run(self):
        data = self.get_option_dict('order','search')
        configtemplates = self.api.list(data)
        if configtemplates:
            configtemplates = unnest_one(configtemplates)

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('snippet')

        self.printer.set_header(_("Config Template"))
        self.printer.print_items(configtemplates)

class Info(ConfigTemplateAction):

    description = _('show information about a config template')

    def setup_parser(self, parser):
        parser.add_option('--id', dest='id', help=_("config template id or name"))

    def check_options(self, validator):
        validator.require('id')

    def run(self):
        configtemplate = self.api.show(self.get_option('id'))
        configtemplate = unnest_one(configtemplate)

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('snippet')

        if not configtemplate.get('snippet'):
            configtemplate['Template Kind'] = "%s (Id: %d)" % (configtemplate['kind'], configtemplate['kind_id'])
            self.printer.add_column('Template Kind')

        if configtemplate.get('template_combinations'):
            content = []
            for combo in configtemplate.get('template_combinations'):
                combo = unnest_one(combo)
                content.append("%s / %s (Id: %d)" % (combo['hostgroup_id'], combo['environment_id'], combo['id']))
                # key = "Hostgroup / Environment id %d" % combo['id']
            configtemplate['Hostgroup/Environment combinations'] = ', '.join(content)
            self.printer.add_column('Hostgroup/Environment combinations')

        if configtemplate.get('operatingsystems'):
            content = []
            for system in configtemplate.get('operatingsystems'):
                system = unnest_one(system)
                content.append("%s (Id: %d)" % (system['name'], system['id']))
            configtemplate['Operating Systems'] = ', '.join(content)
            self.printer.add_column('Operating Systems')

        self.printer.add_column('template')

        self.printer.set_header(_("Config Template"))
        self.printer.print_item(configtemplate)

class Create(ConfigTemplateAction):

    description = _('create config template')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name', help=_("template name (required)"))
        parser.add_option('--template', dest='template', help=_("template body (required)"))
        parser.add_option('--snippet', dest='snippet', help=_("is it snippet?"))
        parser.add_option('--audit_comment', dest='audit_comment', help=_(""))
        parser.add_option('--template_kind_id', dest='template_kind_id', help=_("not relevant for snippet"))
        parser.add_option('--template_combinations_attributes', dest='template_combinations_attributes', help=_("Array of template combinations (hostgroup_id, environment_id)"))
        parser.add_option('--operatingsystem_ids', dest='operatingsystem_ids', help=_("Array of operating systems ID to associate the template with"))

    def check_options(self, validator):
        validator.require('name')
        validator.require('template')

    def run(self):
        data = self.get_option_dict('name','template','snippet','audit_comment',
          'template_kind_id','template_combinations_attributes','operatingsystem_ids')

        ctemplate = self.api.create(data)

        if type(ctemplate)==type(dict()) and 'config_template' in ctemplate:
            return _("Successfully created Config Template [ %s ]") % data['name']
        else:
            return _("Could not create Config Template [ %s ]") % data['name']

class Update(ConfigTemplateAction):

    description = _('update config template')

    def setup_parser(self, parser):
        parser.add_option('--id', dest='id', help=_("template id or name"))
        parser.add_option('--name', dest='name', help=_("template new name"))
        parser.add_option('--template', dest='template', help=_(""))
        parser.add_option('--snippet', dest='snippet', help=_(""))
        parser.add_option('--audit_comment', dest='audit_comment', help=_(""))
        parser.add_option('--template_kind_id', dest='template_kind_id', help=_(""))
        parser.add_option('--template_combinations_attributes', dest='template_combinations_attributes', help=_(""))
        parser.add_option('--operatingsystem_ids', dest='operatingsystem_ids', help=_(""))

    def check_options(self, validator):
        validator.require('id')

    def run(self):
        template_id = self.get_option('id')
        data = self.get_option_dict('name','template','snippet','audit_comment',
          'template_kind_id','template_combinations_attributes','operatingsystem_ids')

        ctemplate = self.api.update(template_id, data)

        if type(ctemplate)==type(dict()) and 'config_template' in ctemplate:
            return _("Successfully updated Config Template [ id = %s ]") % template_id
        else:
            return _("Could not update Config Template [ id = %s ]") % template_id

class Delete(ConfigTemplateAction):

    description = _('delete config template')

    def setup_parser(self, parser):
        parser.add_option('--id', dest='id', help=_("config template id or name"))

    def check_options(self, validator):
        validator.require('id')
        pass

    def run(self):
        template_id = self.get_option('id')

        configtemplate = self.api.destroy(template_id)
        print _('Successfuly deleted Config Template [ %s ]') % template_id

class Build_Pxe_Default(ConfigTemplateAction):

    description = _('build pxe default')

    def setup_parser(self, parser):
      pass

    def check_options(self, validator):
        pass

    def run(self):
        configtemplate = self.api.build_pxe_default()
        print _('Success')

# TODO: do we need this? To use it we have to know Audit id and there is no way how to get it
# through foreman api at this time
# class Revision(ConfigTemplateAction):
#     description = _('config template revision')
#     def setup_parser(self, parser):
#         parser.add_option('--version', dest='version', help=_("template version - audit id"))
#     def check_options(self, validator):
#         validator.require('version')
#     def run(self):
#         data = self.get_option_dict('version')
#         configtemplate = self.api.revision(data)
#         print configtemplate

# config template command ------------------------------------------------------------

class ConfigTemplate(Command):
    description = _('config template specific actions in the katello server')

