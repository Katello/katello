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
import time
from gettext import gettext as _
from sets import Set

from katello.client.api.activation_key import ActivationKeyAPI
from katello.client.api.template import TemplateAPI
from katello.client.config import Config
from katello.client.core.base import Action, Command
from katello.client.core.utils import system_exit, is_valid_record, get_abs_path, run_spinner_in_bg, wait_for_async_task
from katello.client.api.utils import get_environment, get_organization

class ActivationKeyAction(Action):

    def __init__(self):
        super(ActivationKeyAction, self).__init__()
        self.api = ActivationKeyAPI()
        
    def get_template_id(self, environmentId, templateName):
        if templateName != None:
            template_api = TemplateAPI()
            template = template_api.template_by_name(environmentId, templateName)
            if template == None:
                return None
            else:
                return template['id']
        else:
            return None
        

class List(ActivationKeyAction):

    description = _('list all activation keys')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))
        self.parser.add_option('--environment', dest='env',
                               help=_("environment name eg: dev (Locker by default)"))

    def check_options(self):
        self.require_option('org')

    def run(self):
        envName = self.get_option('env')
        orgName = self.get_option('org')

        keys = self.get_keys_for_organization(orgName) if envName == None else self.get_keys_for_environment(orgName, envName)

        if not keys:
            if envName == None:
                print _("No keys found in organization [ %s ]") % orgName
            else:
                print _("No keys found in organization [ %s ] environment [ %s ]") % (orgName, envName)
                
            return os.EX_OK
                        
        self.printer.addColumn('id')
        self.printer.addColumn('name')
        self.printer.addColumn('description', multiline=True)
        self.printer.addColumn('environment_id')
        self.printer.addColumn('system_template_id')

        self.printer.setHeader(_("Activation Key List"))
        self.printer.printItems(keys)
        return os.EX_OK
        
    def get_keys_for_organization(self, orgName):
        organization = get_organization(orgName)
        if not organization: return os.EX_DATAERR
        
        return self.api.activation_keys_by_organization(organization['cp_key'])
        
    def get_keys_for_environment(self, orgName, envName):
        environment = get_environment(orgName, envName)
        if not environment: return os.EX_DATAERR
        
        return self.api.activation_keys_by_environment(environment['id'])

class Info(ActivationKeyAction):

    description = _('show information about an activation key')

    def setup_parser(self):
        self.parser.add_option('--name', dest='name',
                               help=_("activation key name (required)"))
        self.parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))

    def check_options(self):
        self.require_option('name')
        self.require_option('org')

    def run(self):
        orgName = self.get_option('org')
        keyName = self.get_option('name')

        organization = get_organization(orgName)
        if not organization: return os.EX_DATAERR
        
        keys = self.api.activation_keys_by_organization(organization['cp_key'], keyName)
        if len(keys) == 0:
            return os.EX_DATAERR
            
        self.printer.addColumn('id')
        self.printer.addColumn('name')
        self.printer.addColumn('description', multiline=True)
        self.printer.addColumn('environment_id')
        self.printer.addColumn('system_template_id')

        self.printer.setHeader(_("Activation Key Info"))
        self.printer.printItem(keys[0])
        return os.EX_OK
        

class Create(ActivationKeyAction):

    description = _('create an activation key')
    
    def setup_parser(self):
        self.parser.add_option('--name', dest='name',
                               help=_("activation key name (required)"))
        self.parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))
        self.parser.add_option('--environment', dest='env',
                               help=_("environment name eg: dev (required)"))
        self.parser.add_option('--description', dest='description',
                               help=_("activation key description"))
        self.parser.add_option('--template', dest='template',
                               help=_("template name eg: servers"))

    def check_options(self):
        self.require_option('name')
        self.require_option('org')
        self.require_option('env')
        
    def run(self):
        orgName = self.get_option('org')
        envName = self.get_option('env')
        keyName = self.get_option('name')
        keyDescription = self.get_option('description')
        templateName = self.get_option('template')
        
        environment = get_environment(orgName, envName)
        if not environment: return os.EX_DATAERR
        
        templateId = self.get_template_id(environment['id'], templateName)
            
        key = self.api.create(environment['id'], keyName, keyDescription, templateId)
        if is_valid_record(key):
            print _("Successfully created activation key [ %s ]") % key['name']
            return os.EX_OK
        else:
            print _("Could not create activation key [ %s ]") % keyName
            return os.EX_DATAERR                
        
        

class Update(ActivationKeyAction):

    description = _('update an activation key')

    def setup_parser(self):
        self.parser.add_option('--name', dest='name',
                               help=_("activation key name (required)"))
        self.parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))
        self.parser.add_option('--environment', dest='env',
                               help=_("new environment name eg: dev"))
        self.parser.add_option('--new_name', dest='new_name',
                              help=_("new template name"))
        self.parser.add_option('--description', dest='description',
                               help=_("new description"))
        self.parser.add_option('--template', dest='template',
                               help=_("new template name eg: servers"))

    def check_options(self):
        self.require_option('name')
        self.require_option('org')
        
    def run(self):
        orgName = self.get_option('org')
        keyName = self.get_option('name')
        envName = self.get_option('env')
        newKeyName = self.get_option('new_name')        
        keyDescription = self.get_option('description')
        templateName = self.get_option('template')
        
        organization = get_organization(orgName)
        if not organization: return os.EX_DATAERR
        
        if envName != None:
            environment = get_environment(orgName, envName)
            if not environment: return os.EX_DATAERR
        else:
            environment = None
        
        keys = self.api.activation_keys_by_organization(organization['cp_key'], keyName)
        if len(keys) == 0:
            return os.EX_DATAERR
                    
        templateId = self.get_template_id(keys[0]['environment_id'], templateName)
        key = self.api.update(keys[0]['id'], environment['id'] if environment != None else None, newKeyName, keyDescription, templateId)
        if key != None:
            print _("Successfully updated activation key [ %s ]") % key['name']
            return os.EX_OK
        else:
            return os.EX_DATAERR                


class Delete(ActivationKeyAction):

    description = _('delete an activation key')

    def setup_parser(self):
        self.parser.add_option('--name', dest='name',
                               help=_("activation key name (required)"))
        self.parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))

    def check_options(self):
        self.require_option('name')
        self.require_option('org')

    def run(self):
        orgName = self.get_option('org')
        keyName = self.get_option('name')
        
        organization = get_organization(orgName)
        if not organization: return os.EX_DATAERR
        
        keys = self.api.activation_keys_by_organization(organization['cp_key'], keyName)
        if len(keys) == 0:
            return os.EX_DATAERR
        
        self.api.delete(keys[0]['id'])
        print _("Successfully deleted activation key [ %s ]") % keyName
        return os.EX_OK
        
class ActivationKey(Command):
    description = _('activation key specific actions in the katello server')
        
