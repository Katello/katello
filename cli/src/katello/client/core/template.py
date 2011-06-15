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
                               help=_("environment name eg: foo.example.com (required)"))

    def check_options(self):
        self.require_option('name')
        self.require_option('org')

    def run(self):
        tplName = self.get_option('name')
        orgName = self.get_option('org')
        envName = self.get_option('env')
      
        template = get_template(orgName, envName, tplName)
        
        template["errata"]   = "\n".join([e["id"] for e in template["errata"]])
        template["products"] = "\n".join([p["name"] for p in template["products"]])
        template["packages"] = "\n".join([p["id"] for p in template["packages"]])
        
        self.printer.addColumn('id')
        self.printer.addColumn('name')
        self.printer.addColumn('description', multiline=True)
        self.printer.addColumn('environment_id')
        self.printer.addColumn('errata', multiline=True, show_in_grep=False)
        self.printer.addColumn('products', multiline=True, show_in_grep=False)
        self.printer.addColumn('packages', multiline=True, show_in_grep=False)

        self.printer.printHeader(_("Template Info"))
        self.printer.printItem(template)
        return os.EX_OK

# ==============================================================================
class Create(TemplateAction):

    description = _('import a template file')

    
    def setup_parser(self):
        self.parser.add_option('--name', dest='name',
                               help=_("template name (required)"))
        self.parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))
        self.parser.add_option('--environment', dest='env',
                               help=_("environment name eg: foo.example.com (required)"))
        self.parser.add_option("--file", dest="file",
                               help=_("path to the template file (required)"))
        self.parser.add_option("--description", dest="description",
                               help=_("provider description"))

    
    def check_options(self):
        self.require_option('name')
        self.require_option('org')
        self.require_option('file')

    
    def run(self):
        name    = self.get_option('name')
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
            response = run_spinner_in_bg(self.api.import_tpl, (env["id"], name, desc, f), message=_("Importing template, please wait... "))
            print response
        
        f.close()
        return os.EX_OK

# provider command =============================================================

class Template(Command):

    description = _('template specific actions in the katello server')