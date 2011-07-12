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

from katello.client.api.changeset import ChangesetAPI
from katello.client.config import Config
from katello.client.core.base import Action, Command
from katello.client.core.utils import is_valid_record, get_abs_path, run_spinner_in_bg, format_date
from katello.client.api.utils import get_environment, get_changeset

_cfg = Config()


# base changeset action ========================================================
class ChangesetAction(Action): 

    def __init__(self):
        super(ChangesetAction, self).__init__()
        self.api = ChangesetAPI()
        
# ==============================================================================
class List(ChangesetAction):

    description = _('list new changesets of an environment')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))
        self.parser.add_option('--environment', dest='env',
                               help=_("environment name (Locker by default)"))

    def check_options(self):
        self.require_option('org')

    def run(self):
        orgName = self.get_option('org')
        envName = self.get_option('env')
        
        env = get_environment(orgName, envName)
        if env == None:
            return os.EX_DATAERR

        
        changesets = self.api.changesets(orgName, env['id'])
        for cs in changesets:
            cs['updated_at'] = format_date(cs['updated_at'])

        self.printer.addColumn('id')
        self.printer.addColumn('name')
        self.printer.addColumn('updated_at')

        self.printer.setHeader(_("Changeset List"))
        self.printer.printItems(changesets)
        return os.EX_OK
        
        
# ==============================================================================
class Info(ChangesetAction):

    description = _('list new changesets of an environment')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))
        self.parser.add_option('--environment', dest='env',
                               help=_("environment name (Locker by default)"))
        self.parser.add_option('--name', dest='name',
                               help=_("changeset name (required)"))
                               
    def check_options(self):
        self.require_option('org')
        self.require_option('name')

    def run(self):
        orgName = self.get_option('org')
        envName = self.get_option('env')
        csName = self.get_option('name')
        
        cset = get_changeset(orgName, envName, csName)
        if cset == None:
            return os.EX_DATAERR

        cset['updated_at'] = format_date(cset['updated_at'])

        cset["errata"]   = "\n".join([e["display_name"] for e in cset["errata"]])
        cset["products"] = "\n".join([p["name"] for p in cset["products"]])
        cset["packages"] = "\n".join([p["display_name"] for p in cset["packages"]])
        cset["repositories"] = "\n".join([r["display_name"] for r in cset["repos"]])

        self.printer.addColumn('id')
        self.printer.addColumn('name')
        self.printer.addColumn('updated_at')
        self.printer.addColumn('errata', multiline=True, show_in_grep=False)
        self.printer.addColumn('products', multiline=True, show_in_grep=False)
        self.printer.addColumn('packages', multiline=True, show_in_grep=False)
        self.printer.addColumn('repositories', multiline=True, show_in_grep=False)
        
        self.printer.setHeader(_("Changeset Info"))
        self.printer.printItem(cset)
        return os.EX_OK
        
        
# ==============================================================================
class UpdateContent(ChangesetAction):
    
    content_types = [
      'product',
      'package',
      'erratum',
      'repo'
    ]
    
    description = _('updates content of a changeset')


    def setup_parser(self):
        self.parser.add_option('--name', dest='name',
                               help=_("changeset name (required)"))
        self.parser.add_option('--org', dest='org',
                               help=_("name of organization (required)"))
        self.parser.add_option('--environment', dest='env',
                               help=_("environment name (Locker by default)"))
                   
        for ct in self.content_types:
            self.parser.add_option('--add_'+ct, dest='add_'+ct,
                                action='append',
                                help=_(ct+" to add to the changeset"))
            self.parser.add_option('--remove_'+ct, dest='remove_'+ct,
                                action='append',
                                help=_(ct+" to remove from the changeset"))


    def check_options(self):
        self.require_option('name')
        self.require_option('org')


    def run(self):
        csName  = self.get_option('name')
        orgName = self.get_option('org')
        envName = self.get_option('env')

        cset = get_changeset(orgName, envName, csName)
        if cset == None:
            return os.EX_DATAERR
        
        patch = {}
        patch['packages'] = self.build_patch('+', self.get_option('add_package')) + self.build_patch('-', self.get_option('remove_package'))
        patch['errata']   = self.build_patch('+', self.get_option('add_erratum')) + self.build_patch('-', self.get_option('remove_erratum'))
        patch['repos']    = self.build_patch('+', self.get_option('add_repo'))    + self.build_patch('-', self.get_option('remove_repo'))
        patch['products'] = self.build_patch('+', self.get_option('add_product')) + self.build_patch('-', self.get_option('remove_product'))

        msg = self.api.update_content(orgName, cset["environment_id"], cset["id"], patch)
        print _("Successfully updated changeset [ %s ]") % csName
        return os.EX_OK
        
        
    def build_patch(self, action, items):
        result = []
        
        if items == None:
            return result
        
        for i in items:
            result.append(action+i)
        return result
    
        
# changeset command ============================================================
class Changeset(Command):
    description = _('changeset specific actions in the katello server')
    