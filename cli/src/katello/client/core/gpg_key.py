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
from gettext import gettext as _

from katello.client.api.gpg_key import GpgKeyAPI
from katello.client.cli.base import opt_parser_add_org
from katello.client.core.base import BaseAction, Command
from katello.client.core.utils import test_record, get_abs_path
from katello.client.utils import printer

from sys import stdin

class GpgKeyAction(BaseAction):

    def __init__(self):
        super(GpgKeyAction, self).__init__()
        self.api = GpgKeyAPI()

    def read_content(self, use_prompt):
        file = self.get_option('file')

        if file:
            with open(get_abs_path(file), "r") as f:
                content = f.read()
        elif use_prompt:
            print _("Enter content of the GPG key (finish input with CTRL+D):")
            content = stdin.read()
        else:
            content = None
        return content

    def get_key_id(self):
        orgName = self.get_option('org')
        keyName = self.get_option('name')

        keys = self.api.gpg_keys_by_organization(orgName, keyName)
        if len(keys) == 0:
            return
        else:
            return keys[0]["id"]



class List(GpgKeyAction):

    description = _('list all GPG keys')

    def setup_parser(self, parser):
        opt_parser_add_org(parser, required=1)

    def check_options(self, validator):
        validator.require('org')

    def run(self):
        orgName = self.get_option('org')

        gpg_keys = self.api.gpg_keys_by_organization(orgName)

        if not gpg_keys:
            print _("No GPG keys found in organization [ %s ]") % orgName

            return os.EX_OK

        self.printer.add_column('name')

        self.printer.set_header(_("GPG Key List"))
        self.printer.print_items(gpg_keys)
        return os.EX_OK


class Info(GpgKeyAction):

    description = _('show information about a GPG key')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name',
                               help=_("GPG key name (required)"))
        opt_parser_add_org(parser, required=1)

    def check_options(self, validator):
        validator.require(('name', 'org'))

    def run(self):
        keyName = self.get_option('name')
        key_id = self.get_key_id()
        if not key_id:
            print >> sys.stderr, _("Could not find GPG key [ %s ]") % keyName
            return os.EX_DATAERR

        key = self.api.gpg_key(key_id)
        key["products"] = "[ "+ ", ".join([product["name"] for product in key["products"]]) +" ]"
        key["repos"] = "[ "+ ", ".join([repo["product"]["name"] + " - " + repo["name"] for repo in key["repositories"]]) +" ]"
        key["content"] = "\n" + key["content"]

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('content', show_with=printer.VerboseStrategy)
        self.printer.add_column('products', multiline=True, show_with=printer.VerboseStrategy)
        self.printer.add_column('repos', multiline=True, show_with=printer.VerboseStrategy, name=_("Repositories"))

        self.printer.set_header(_("GPG Key Info"))
        self.printer.print_item(key)
        return os.EX_OK


class Create(GpgKeyAction):

    description = _('create a GPG key')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name',
                               help=_("GPG key name (required)"))
        opt_parser_add_org(parser, required=1)
        parser.add_option('--file', dest='file',
                               help=_("file with public GPG key, if not\
                                 specified, standard input will be used"))

    def check_options(self, validator):
        validator.require(('name', 'org'))

    def run(self):
        orgName = self.get_option('org')
        keyName = self.get_option('name')
        try:
            content = self.read_content(True)
        except IOError as (c,m):
            print m
            return os.EX_DATAERR

        key = self.api.create(orgName, keyName, content)
        test_record(key,
            _("Successfully created GPG key [ %s ]") % keyName,
            _("Could not create GPG key [ %s ]") % keyName
        )


class Update(GpgKeyAction):

    description = _('update a GPG key')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name',
                               help=_("GPG key name (required)"))
        opt_parser_add_org(parser, required=1)
        parser.add_option('--new_name', dest='new_name',
                              help=_("new template name"))
        parser.add_option('--file', dest='file',
                               help=_("file with public GPG key"))
        parser.add_option('--new_content', dest='new_content', action='store_true',
                               help=_("prompt for new content of the key"))


    def check_options(self, validator):
        validator.require(('name', 'org'))

    def run(self):
        orgName = self.get_option('org')
        keyName = self.get_option('name')
        newKeyName = self.get_option('new_name')

        try:
            content = self.read_content(self.get_option('new_content'))
        except IOError as (c,m):
            print m
            return os.EX_DATAERR

        key_id = self.get_key_id()
        if not key_id:
            print >> sys.stderr, _("Could not find GPG key [ %s ]") % keyName
            return os.EX_DATAERR

        key = self.api.update(key_id, newKeyName, content)
        test_record(key,
            _("Successfully updated GPG key [ %s ]") % keyName,
            _("Could not updated GPG key [ %s ]") % keyName
        )


class Delete(GpgKeyAction):

    description = _('delete a GPG key')

    def setup_parser(self, parser):
        parser.add_option('--name', dest='name',
                               help=_("GPG key name (required)"))
        opt_parser_add_org(parser, required=1)

    def check_options(self, validator):
        validator.require(('name', 'org'))

    def run(self):
        keyName = self.get_option('name')

        key_id = self.get_key_id()
        if not key_id:
            print >> sys.stderr, _("Could not find GPG key [ %s ]") % keyName
            return os.EX_DATAERR

        self.api.delete(key_id)
        print _("Successfully deleted GPG key [ %s ]") % keyName
        return os.EX_OK

class GpgKey(Command):
    description = _('GPG key specific actions in the katello server')
