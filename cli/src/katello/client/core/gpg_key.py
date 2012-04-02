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
import sys
from gettext import gettext as _

from katello.client.api.gpg_key import GpgKeyAPI
from katello.client.core.base import Action, Command
from katello.client.core.utils import is_valid_record, get_abs_path

from sys import stdin

class GpgKeyAction(Action):

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

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))

    def check_options(self):
        self.require_option('org')

    def run(self):
        orgName = self.get_option('org')

        gpg_keys = self.api.gpg_keys_by_organization(orgName)

        if not gpg_keys:
            print _("No gpg keys found in organization [ %s ]") % orgName

            return os.EX_OK

        self.printer.addColumn('name')

        self.printer.setHeader(_("Gpg Key List"))
        self.printer.printItems(gpg_keys)
        return os.EX_OK


class Info(GpgKeyAction):

    description = _('show information about a gpg key')

    def setup_parser(self):
        self.parser.add_option('--name', dest='name',
                               help=_("activation key name (required)"))
        self.parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))

    def check_options(self):
        self.require_option('name')
        self.require_option('org')

    def run(self):
        keyName = self.get_option('name')
        key_id = self.get_key_id()
        if not key_id:
            print >> sys.stderr, _("Could not find gpg key [ %s ]") % keyName
            return os.EX_DATAERR

        key = self.api.gpg_key(key_id)
        key["products"] = "[ "+ ", ".join([product["name"] for product in key["products"]]) +" ]"
        key["repos"] = "[ "+ ", ".join([repo["product"]["name"] + " - " + repo["name"] for repo in key["repositories"]]) +" ]"
        key["content"] = "\n" + key["content"]

        self.printer.addColumn('id')
        self.printer.addColumn('name')
        self.printer.addColumn('content', show_in_grep=False)
        self.printer.addColumn('products', multiline=True, show_in_grep=False)
        self.printer.addColumn('repos', multiline=True, show_in_grep=False, name=_("Repositories"))

        self.printer.setHeader(_("Gpg Key Info"))
        self.printer.printItem(key)
        return os.EX_OK


class Create(GpgKeyAction):

    description = _('create a gpg key')

    def setup_parser(self):
        self.parser.add_option('--name', dest='name',
                               help=_("activation key name (required)"))
        self.parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))
        self.parser.add_option('--file', dest='file',
                               help=_("file with public GPG key, if not\
                                 specified, standard input will be used"))

    def check_options(self):
        self.require_option('name')
        self.require_option('org')

    def run(self):
        orgName = self.get_option('org')
        keyName = self.get_option('name')
        try:
            content = self.read_content(True)
        except IOError as (c,m):
            print m
            return os.EX_DATAERR


        key = self.api.create(orgName, keyName, content)
        if is_valid_record(key):
            print _("Successfully created gpg key [ %s ]") % key['name']
            return os.EX_OK
        else:
            print >> sys.stderr, _("Could not create gpg key [ %s ]") % keyName
            return os.EX_DATAERR



class Update(GpgKeyAction):

    description = _('update an activation key')

    def setup_parser(self):
        self.parser.add_option('--name', dest='name',
                               help=_("activation key name (required)"))
        self.parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))
        self.parser.add_option('--new_name', dest='new_name',
                              help=_("new template name"))
        self.parser.add_option('--file', dest='file',
                               help=_("file with public GPG key"))
        self.parser.add_option('--new_content', dest='new_content', action='store_true',
                               help=_("prompt for new content of the key"))


    def check_options(self):
        self.require_option('name')
        self.require_option('org')

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
            print >> sys.stderr, _("Could not find gpg key [ %s ]") % keyName
            return os.EX_DATAERR

        key = self.api.update(key_id, newKeyName, content)
        if is_valid_record(key):
            print _("Successfully updated gpg key [ %s ]") % key['name']
            return os.EX_OK
        else:
            print >> sys.stderr, _("Could not updated gpg key [ %s ]") % keyName
            return os.EX_DATAERR



class Delete(GpgKeyAction):

    description = _('delete an gpg key')

    def setup_parser(self):
        self.parser.add_option('--name', dest='name',
                               help=_("activation key name (required)"))
        self.parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))

    def check_options(self):
        self.require_option('name')
        self.require_option('org')

    def run(self):
        keyName = self.get_option('name')

        key_id = self.get_key_id()
        if not key_id:
            print >> sys.stderr, _("Could not find gpg key [ %s ]") % keyName
            return os.EX_DATAERR

        self.api.delete(key_id)
        print _("Successfully deleted gpg key [ %s ]") % keyName
        return os.EX_OK

class GpgKey(Command):
    description = _('GPG key specific actions in the katello server')
