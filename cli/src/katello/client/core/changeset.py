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
        
        

        
        
        
        
        
# changeset command ============================================================
class Changeset(Command):
    description = _('changeset specific actions in the katello server')
    