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

from katello.client.api.activation_key import ActivationKeyAPI
from katello.client.api.template import TemplateAPI
from katello.client.api.system_group import SystemGroupAPI
from katello.client.core.base import BaseAction, Command, ImportAction
from katello.client.core.utils import test_record, to_array
from katello.client.utils import printer
from katello.client.api.utils import get_environment
from katello.client.cli.base import OptionException, opt_parser_add_org, opt_parser_add_environment
from katello.client.server import ServerRequestError

class ActivationKeyAction(BaseAction):

    def __init__(self):
        super(ActivationKeyAction, self).__init__()
        self.api = ActivationKeyAPI()

    @classmethod
    def get_template_id(cls, environmentId, templateName):
        if templateName != None:
            template_api = TemplateAPI()
            template = template_api.template_by_name(environmentId, templateName)
            if template == None:
                raise OptionException()
            else:
                return template['id']
        else:
            return None


class List(ActivationKeyAction):

    description = _('list all activation keys')

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)
        opt_parser_add_environment(parser, default=_("Library"))

    def check_options(self, validator):
        validator.require('org')

    def run(self):
        envName = self.get_option('environment')
        orgName = self.get_option('org')

        keys = self.get_keys_for_organization(orgName) \
            if envName == None else self.get_keys_for_environment(orgName, envName)

        if not keys:
            if envName == None:
                print _("No keys found in organization [ %s ]") % orgName
            else:
                print _("No keys found in organization [ %s ] environment [ %s ]") % (orgName, envName)

            return os.EX_OK

        for k in keys:
            if k['usage_limit'] is None or k['usage_limit'] == -1:
                k['usage'] = str(k['usage_count'])
            else:
                k['usage'] = str(k['usage_count']) + '/' + str(k['usage_limit'])

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('description', multiline=True)
        self.printer.add_column('usage')
        self.printer.add_column('environment_id')
        self.printer.add_column('system_template_id')

        self.printer.set_header(_("Activation Key List"))
        self.printer.print_items(keys)
        return os.EX_OK

    def get_keys_for_organization(self, orgName):
        return self.api.activation_keys_by_organization(orgName)

    def get_keys_for_environment(self, orgName, envName):
        environment = get_environment(orgName, envName)
        return self.api.activation_keys_by_environment(environment['id'])

class Info(ActivationKeyAction):

    description = _('show information about an activation key')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name',
                               help=_("activation key name (required)"))
        opt_parser_add_org(parser, required=1)

    def check_options(self, validator):
        validator.require(('name', 'org'))

    def run(self):
        orgName = self.get_option('org')
        keyName = self.get_option('name')

        keys = self.api.activation_keys_by_organization(orgName, keyName)

        if len(keys) == 0:
            print >> sys.stderr, _("Could not find activation key [ %s ]") % keyName
            return os.EX_DATAERR
        for akey in keys:
            akey["pools"] = "[ "+ ", ".join([pool["cp_id"] for pool in akey["pools"]]) +" ]"

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('description', multiline=True)
        self.printer.add_column('usage_limit', value_formatter=lambda x: "unlimited" if x == -1 else x)
        self.printer.add_column('environment_id')
        self.printer.add_column('system_template_id')
        self.printer.add_column('pools', multiline=True, show_with=printer.VerboseStrategy)

        self.printer.set_header(_("Activation Key Info"))
        self.printer.print_item(keys[0])
        return os.EX_OK


# ------------------------------------------------------------------------------
class ImportActivationKeys(ImportAction):

    description = _('import a set of activation keys into the katello server')

    def __init__(self):
        super(ImportActivationKeys, self).__init__()
        self.api = ActivationKeyAPI()
        self.cached_envs = {}
        self.cached_groups = {}

    def _output_filename(self):
        return "activation_keys"

    def _retrieve_environment(self, orgName, envName):
        key = "%s-%s" % (orgName, envName)
        env = None
        if key in self.cached_envs:
            env = self.cached_envs[key]
        else:
            env = get_environment(orgName, envName)
            self.cached_envs[key] = env

        return env

    def _retrieve_system_group(self, orgName, groupName):
        key = "%s-%s" % (orgName, groupName)
        group = None
        if key in self.cached_groups:
            group = self.cached_groups[key]
        else:
            group = SystemGroupAPI().system_group_by_name(orgName, groupName)
            self.cached_groups[key] = group

        return group


    def _do_import(self):
        for row in self.import_file:
            name = row['name']
            orgName = row['org_name']
            key = None
            try:
                keys = self.api.activation_keys_by_organization(orgName, name)
                if len(keys) == 1:
                    key = keys[0]
                elif len(keys) > 1:
                    self._add_error("Found multiple keys with name %s" % (name))
                    break
            except ServerRequestError, e:
                if e.return_code == 404:
                    pass
                else:
                    raise e

            try:
                environment = self._retrieve_environment(orgName, row['environment_name'])
                templateId = None
                if len(row['template_id']) > 0:
                    templateId = ActivationKeyAction.get_template_id(environment['id'], row['template_id'])

                if key:
                    key = self.api.update(orgName, key['id'], environment['id'], row['name'], row['description'], \
                        templateId, row['usage_limit'])
                    self._add_stat("activation keys updated")
                else:
                    key = self.api.create(environment['id'], row['name'], row['description'], \
                        row['usage_limit'], templateId)
                    self._add_stat("activation keys created")

                for groupName in to_array(row['system_groups']):
                    group = self._retrieve_system_group(orgName, groupName)
                    if group == None:
                        self._add_error("No group name %s found when importing key %s" % (groupName, row['name']))
                    else:
                        self.api.add_system_group(orgName, key["id"], group['id'])
            except ServerRequestError, e:
                self._add_error("Skipping activation key %s with exception: %s" % (name, e))
                break
            except Exception, e:
                self._add_error("Skipping activation key %s with exception: %s" % (name, e))
                break


class Create(ActivationKeyAction):

    description = _('create an activation key')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name',
                               help=_("activation key name (required)"))
        opt_parser_add_org(parser, required=1)
        opt_parser_add_environment(parser, required=1)
        parser.add_option('--description', dest='description',
                               help=_("activation key description"))
        parser.add_option('--template', dest='template',
                               help=_("template name eg: servers"))
        parser.add_option('--limit', dest='usage_limit', type="int",
                               help=_("usage limit (unlimited by default)"))

    def check_options(self, validator):
        validator.require(('name', 'org', 'environment'))

    def run(self):
        orgName = self.get_option('org')
        envName = self.get_option('environment')
        keyName = self.get_option('name')
        keyDescription = self.get_option('description')
        templateName = self.get_option('template')
        usageLimit = self.get_option('usage_limit')

        if usageLimit is None:
            usageLimit = -1
        else:
            if int(usageLimit) <= 0:
                print >> sys.stderr, _("Usage limit [ %s ] must be higher than one") % usageLimit
                return os.EX_DATAERR

        environment = get_environment(orgName, envName)

        try:
            templateId = self.get_template_id(environment['id'], templateName)
        except OptionException:
            print >> sys.stderr, _("Couldn't find template '%s'") % templateName
            return os.EX_DATAERR

        key = self.api.create(environment['id'], keyName, keyDescription, usageLimit, templateId)
        test_record(key,
            _("Successfully created activation key [ %s ]") % keyName,
            _("Could not create activation key [ %s ]") % keyName
        )



class Update(ActivationKeyAction):

    description = _('update an activation key')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name',
                               help=_("activation key name (required)"))
        opt_parser_add_org(parser, required=1)
        parser.add_option('--environment', dest='env',
                               help=_("new environment name e.g.: dev"))
        parser.add_option('--new_name', dest='new_name',
                              help=_("new template name"))
        parser.add_option('--description', dest='description',
                               help=_("new description"))
        parser.add_option('--template', dest='template',
                               help=_("new template name eg: servers"))
        parser.add_option('--limit', dest='usage_limit',
                               help=_("usage limit (set -1 for no limit)"))

        parser.add_option('--add_subscription', dest='add_poolid', action='append',
                               help=_("add a pool to the activation key"))
        parser.add_option('--remove_subscription', dest='remove_poolid', action='append',
                               help=_("remove a pool from the activation key"))

    def check_options(self, validator):
        validator.require(('name', 'org'))

    def run(self):
        orgName = self.get_option('org')
        keyName = self.get_option('name')
        envName = self.get_option('env')
        newKeyName = self.get_option('new_name')
        keyDescription = self.get_option('description')
        templateName = self.get_option('template')
        usageLimit = self.get_option('usage_limit')
        add_poolids = self.get_option('add_poolid') or []
        remove_poolids = self.get_option('remove_poolid') or []

        if envName != None:
            environment = get_environment(orgName, envName)
        else:
            environment = None

        keys = self.api.activation_keys_by_organization(orgName, keyName)
        if len(keys) == 0:
            return os.EX_DATAERR
        key = keys[0]

        try:
            templateId = self.get_template_id(key['environment_id'], templateName)
        except OptionException:
            print >> sys.stderr, _("Couldn't find template '%s'") % (templateName)
            return os.EX_DATAERR

        key = self.api.update(orgName, key['id'], environment['id'] if environment != None else None,
            newKeyName, keyDescription, templateId, usageLimit)

        for poolid in add_poolids:
            self.api.add_pool(orgName, key['id'], poolid)
        for poolid in remove_poolids:
            self.api.remove_pool(orgName, key['id'], poolid)

        if key != None:
            print _("Successfully updated activation key [ %s ]") % key['name']
            return os.EX_OK
        else:
            return os.EX_DATAERR


class Delete(ActivationKeyAction):

    description = _('delete an activation key')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name',
                               help=_("activation key name (required)"))
        opt_parser_add_org(parser, required=1)

    def check_options(self, validator):
        validator.require(('name', 'org'))

    def run(self):
        orgName = self.get_option('org')
        keyName = self.get_option('name')

        keys = self.api.activation_keys_by_organization(orgName, keyName)
        if len(keys) == 0:
            #TODO: not found?
            return os.EX_DATAERR

        self.api.delete(orgName, keys[0]['id'])
        print _("Successfully deleted activation key [ %s ]") % keyName
        return os.EX_OK


class BaseSystemGroup(ActivationKeyAction):
    """ Base class for AddSystemGroup and RemoveSystemGroup """

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name',
                               help=_("activation key name (required)"))
        opt_parser_add_org(parser, required=1)
        parser.add_option('--system_group', dest='system_group_name',
                              help=_("system group name (required)"))

    def check_options(self, validator):
        validator.require(('org', 'name', 'system_group_name'))

    def _fetch_org_key_group(self):
        """ return array (org_name, activation_key, system_group) based on command line options """
        org_name = self.get_option('org')
        name = self.get_option('name')
        system_group_name = self.get_option('system_group_name')

        activation_key = self.api.activation_keys_by_organization(org_name, name)

        if activation_key:
            activation_key = activation_key[0]
        else:
            print >> sys.stderr, _("Could not find activation key [ %s ]") % name
            return None, None, None

        system_group = SystemGroupAPI().system_groups(org_name, { 'name' : system_group_name})

        if system_group:
            system_group = system_group[0]
        else:
            print >> sys.stderr, _("Could not find system group [ %s ]") % system_group_name
            return None, None, None

        return org_name, activation_key, system_group

class AddSystemGroup(BaseSystemGroup):

    description = _('add system group to an activation key')

    def run(self):
        org_name, activation_key, system_group = self._fetch_org_key_group()
        if (not activation_key) and (not system_group):
            return os.EX_DATAERR

        activation_key = self.api.add_system_group(org_name, activation_key["id"], system_group['id'])

        if activation_key:
            print _("Successfully added system group to activation key [ %s ]") % activation_key['name']
            return os.EX_OK
        else:
            print >> sys.stderr, _("Unknown error occurred.")
            return os.EX_DATAERR


class RemoveSystemGroup(BaseSystemGroup):

    description = _('remove system groups to a system')

    def run(self):
        org_name, activation_key, system_group = self._fetch_org_key_group()
        if (not activation_key) and (not system_group):
            return os.EX_DATAERR

        activation_key = self.api.remove_system_group(org_name, activation_key["id"], system_group['id'])

        if activation_key:
            print _("Successfully removed system group from activation key [ %s ]") % activation_key['name']
            return os.EX_OK
        else:
            print >> sys.stderr, _("Unknown error occurred.")
            return os.EX_DATAERR


class ActivationKey(Command):
    description = _('activation key specific actions in the katello server')
