#!/usr/bin/python
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
import urlparse
import time
from pprint import pprint
from gettext import gettext as _
from sets import Set

from katello.client.api.template import TemplateAPI
from katello.client.config import Config
from katello.client.core.base import Action, Command
from katello.client.core.utils import is_valid_record, get_abs_path, run_spinner_in_bg
from katello.client.api.utils import get_environment, get_template

_cfg = Config()


# base template action =========================================================
class TemplateAction(Action):

    def __init__(self):
        super(TemplateAction, self).__init__()
        self.api = TemplateAPI() 


    def get_parent_id(self, orgName, envName, parentName):
        parent = get_template(orgName, envName, parentName)
        if parent != None:
            return parent["id"]
        return None

# ==============================================================================
class List(TemplateAction):
  
    description = _('list all templates')
     
    def setup_parser(self):
        pass

    def check_options(self):
        pass

    def run(self):
        templates = self.api.templates()

        self.printer.addColumn('id')
        self.printer.addColumn('name')
        self.printer.addColumn('description', multiline=True)
        self.printer.addColumn('environment_id')
        self.printer.addColumn('parent_id')

        self.printer.printHeader(_("Template List"))
        self.printer.printItems(templates)
        return os.EX_OK


# ==============================================================================
class Info(TemplateAction):
  
    description = _('list information about a template')
     
    def setup_parser(self):
        self.parser.add_option('--name', dest='name',
                               help=_("template name (required)"))
        self.parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))
        self.parser.add_option('--environment', dest='env',
                               help=_("environment name eg: foo.example.com (locker by default)"))

    def check_options(self):
        self.require_option('name')
        self.require_option('org')

    def run(self):
        tplName = self.get_option('name')
        orgName = self.get_option('org')
        envName = self.get_option('env')
      
        template = get_template(orgName, envName, tplName)
        if template == None:
            return os.EX_OK
        
        template["errata"]   = "\n".join([e["erratum_id"] for e in template["errata"]])
        template["products"] = "\n".join([p["name"] for p in template["products"]])
        template["packages"] = "\n".join([p["package_name"] for p in template["packages"]])
        template["parameters"] = "\n".join([ key+":\t"+value for key, value in template["parameters"].iteritems() ])
        
        self.printer.addColumn('id')
        self.printer.addColumn('name')
        self.printer.addColumn('revision', show_in_grep=False)
        self.printer.addColumn('description', multiline=True)
        self.printer.addColumn('environment_id')
        self.printer.addColumn('parent_id')
        self.printer.addColumn('errata', multiline=True, show_in_grep=False)
        self.printer.addColumn('products', multiline=True, show_in_grep=False)
        self.printer.addColumn('packages', multiline=True, show_in_grep=False)
        self.printer.addColumn('parameters', multiline=True, show_in_grep=False)

        self.printer.printHeader(_("Template Info"))
        self.printer.printItem(template)
        return os.EX_OK

# ==============================================================================
class Import(TemplateAction):

    description = _('create a template file and import data')

    
    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))
        self.parser.add_option('--environment', dest='env',
                               help=_("environment name eg: foo.example.com (locker by default)"))
        self.parser.add_option("--file", dest="file",
                               help=_("path to the template file (required)"))
        self.parser.add_option("--description", dest="description",
                               help=_("provider description"))

    
    def check_options(self):
        self.require_option('org')
        self.require_option('file')

    
    def run(self):
        desc    = self.get_option('description')
        orgName = self.get_option('org')
        envName = self.get_option('env')
        tplPath = self.get_option('file')
    
        try:
            f = open(get_abs_path(tplPath))
        except:
            print _("File %s does not exist" % tplPath)
            return os.EX_IOERR
            
        env = get_environment(orgName, envName)
        if env != None:
            response = run_spinner_in_bg(self.api.import_tpl, (env["id"], desc, f), message=_("Importing template, please wait... "))
            print response
        
        f.close()
        return os.EX_OK

# ==============================================================================
class Create(TemplateAction):

    description = _('create an empty template file')

    
    def setup_parser(self):
        self.parser.add_option('--name', dest='name',
                               help=_("template name (required)"))
        self.parser.add_option('--parent', dest='parent',
                               help=_("name of the parent template"))
        self.parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))
        self.parser.add_option('--environment', dest='env',
                               help=_("environment name eg: foo.example.com (locker by default)"))
        self.parser.add_option("--description", dest="description",
                               help=_("template description"))

    
    def check_options(self):
        self.require_option('name')
        self.require_option('org')

    
    def run(self):
        name    = self.get_option('name')
        desc    = self.get_option('description')
        orgName = self.get_option('org')
        envName = self.get_option('env')
        parentName = self.get_option('parent')
        
            
        env = get_environment(orgName, envName)
        if env != None:
            if parentName != None:
              parentId = self.get_parent_id(orgName, env['name'] ,parentName)
            else:
              parentId = None
              
            template = self.api.create(env["id"], name, desc, parentId)
            if is_valid_record(template):
                print _("Successfully created template [ %s ]") % template['name']
            else:
                print _("Could not create template [ %s ]") % template['name']
        
        return os.EX_OK


# ==============================================================================
class Update(TemplateAction):
  
    description = _('updates name and description of a template')
     
    def setup_parser(self):
        self.parser.add_option('--name', dest='name',
                               help=_("template name (required)"))
        self.parser.add_option('--parent', dest='parent',
                               help=_("name of the parent template"))
        self.parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))
        self.parser.add_option('--environment', dest='env',
                               help=_("environment name eg: foo.example.com (locker by default)"))
        self.parser.add_option('--new_name', dest='new_name',
                               help=_("new template name"))
        self.parser.add_option("--description", dest="description",
                               help=_("template description"))
                               
    def check_options(self):
        self.require_option('name')
        self.require_option('org')

    def run(self):
        tplName = self.get_option('name')
        orgName = self.get_option('org')
        envName = self.get_option('env')
        newName = self.get_option('new_name')
        desc    = self.get_option('description')
        parentName = self.get_option('parent')
        

        template = get_template(orgName, envName, tplName)     
        if template != None:
            if parentName != None:
              parentId = self.get_parent_id(orgName, envName, parentName)
            else:
              parentId = None
            self.api.update(template["id"], newName, desc, parentId)
            print _("Successfully updated template [ %s ]") % template['name']
          
        return os.EX_OK
        
        
# ==============================================================================
class UpdateContent(TemplateAction):

    actions = {
      'add_product':    ['product'],
      'remove_product': ['product'],
      'add_package':    ['package'],
      'remove_package': ['package'],
      'add_erratum':    ['erratum'],
      'remove_erratum': ['erratum'],
      'add_parameter':  ['parameter', 'value'],
      'remove_kickstart_attr': ['erratum']
    }

    description = _('updates content of a template')


    def setup_parser(self):
        self.parser.add_option('--name', dest='name',
                               help=_("template name (required)"))
        self.parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))
        self.parser.add_option('--environment', dest='env',
                               help=_("environment name eg: foo.example.com (locker by default)"))
                               
        #add all actions
        actionParams = Set()
        for action, params in self.actions.iteritems():
            self.parser.add_option('--'+action, dest=action, action="store_true")
            #save action parameters
            actionParams.update(params)
                
        #add action parameters
        for param in actionParams:
            self.parser.add_option('--'+param, dest=param)

                               
    def check_options(self):
        self.require_option('name')
        self.require_option('org')
        
        self.selectedAction = None
        for action, params in self.actions.iteritems():
            if self.has_option(action):
                self.selectedAction = action
                for param in params:
                    self.require_option(param)
                return
        
        self.add_option_error(_("No action was set!"))


    def run(self):
        tplName = self.get_option('name')
        orgName = self.get_option('org')
        envName = self.get_option('env')

        
        template = get_template(orgName, envName, tplName)
        
        if template != None:
            updateParams = {}
            for paramName in self.actions[self.selectedAction]:
                updateParams[paramName] = self.get_option(paramName)
                
            msg = self.api.update_content(template["id"], self.selectedAction, updateParams)
            print msg
          
        return os.EX_OK
        

# ==============================================================================
class Delete(TemplateAction):
  
    description = _('deletes a template')
     
    def setup_parser(self):
        self.parser.add_option('--name', dest='name',
                               help=_("template name (required)"))
        self.parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))
        self.parser.add_option('--environment', dest='env',
                               help=_("environment name eg: foo.example.com (locker by default)"))

    def check_options(self):
        self.require_option('name')
        self.require_option('org')

    def run(self):
        tplName = self.get_option('name')
        orgName = self.get_option('org')
        envName = self.get_option('env')
      
        template = get_template(orgName, envName, tplName)
        if template != None:
            msg = self.api.delete(template["id"])
            print msg
          
        return os.EX_OK


# ==============================================================================
class Promote(TemplateAction):
  
    description = _('promotes template content to a successor environment')
     
    def setup_parser(self):
        self.parser.add_option('--name', dest='name',
                               help=_("template name (required)"))
        self.parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))
        self.parser.add_option('--environment', dest='env',
                               help=_("environment name eg: foo.example.com (locker by default)"))

    def check_options(self):
        self.require_option('name')
        self.require_option('org')

    def run(self):
        tplName = self.get_option('name')
        orgName = self.get_option('org')
        envName = self.get_option('env')
      
        template = get_template(orgName, envName, tplName)
        if template != None:
            response = run_spinner_in_bg(self.api.promote, (template["id"],), message=_("Promoting template, please wait... "))
            print _("Template [ %s ] promoted" % tplName)
          
        return os.EX_OK


# provider command =============================================================

class Template(Command):

    description = _('template specific actions in the katello server')