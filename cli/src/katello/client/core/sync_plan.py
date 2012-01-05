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
from gettext import gettext as _

from katello.client.api.sync_plan import SyncPlanAPI
from katello.client.config import Config
from katello.client.core.base import Action, Command
from katello.client.core.utils import is_valid_record, format_date
from katello.client.api.utils import get_sync_plan

Config()

# base sync_plan action --------------------------------------------------------

class SyncPlanAction(Action):

    def __init__(self):
        super(SyncPlanAction, self).__init__()
        self.api = SyncPlanAPI()

# sync_plan actions ------------------------------------------------------------

class List(SyncPlanAction):

    description = _('list known sync_plans')

    def setup_parser(self):
        self.parser.add_option('--org', dest='org', help=_("organization name eg: foo.example.com (required)"))

    def check_options(self):
        self.require_option('org')

    def run(self):
        org_name = self.get_option('org')

        plans = self.api.sync_plans(org_name)
        for p in plans:
            p['start_date'] = format_date(p['sync_date'])

        self.printer.addColumn('id')
        self.printer.addColumn('name')
        self.printer.addColumn('description', multiline=True)
        self.printer.addColumn('start_date')
        self.printer.addColumn('interval')

        self.printer.setHeader(_("Sync Plan List"))
        self.printer.printItems(plans)
        return os.EX_OK


class Info(SyncPlanAction):

    description = _('print info about a sync plan')

    def setup_parser(self):
        self.parser.add_option('--name', dest='name', help=_("name of the sync plan (required)"))
        self.parser.add_option('--org', dest='org', help=_("organization name (required)"))

    def check_options(self):
        self.require_option('name')
        self.require_option('org')

    def run(self):
        org_name = self.get_option('org')
        plan_name = self.get_option('name')

        plan = get_sync_plan(org_name, plan_name)
        if plan == None:
            return os.EX_DATAERR

        plan['start_date'] = format_date(plan['sync_date'])
        self.printer.addColumn('id')
        self.printer.addColumn('name')
        self.printer.addColumn('description', multiline=True)
        self.printer.addColumn('start_date')
        self.printer.addColumn('interval')

        self.printer.setHeader(_("Sync Plan Info"))
        self.printer.printItem(plan)

        return os.EX_OK


class Delete(SyncPlanAction):

    description = _('delete a sync plan')

    def setup_parser(self):
        self.parser.add_option('--name', dest='name', help=_("name of the sync plan (required)"))
        self.parser.add_option('--org', dest='org', help=_("organization name (required)"))

    def check_options(self):
        self.require_option('name')
        self.require_option('org')

    def run(self):
        org_name = self.get_option('org')
        plan_name = self.get_option('name')

        plan = get_sync_plan(org_name, plan_name)
        if plan == None:
            return os.EX_DATAERR

        self.api.delete(org_name, plan["id"])
        print _("Successfully deleted sync plan [ %s ]") % plan_name
        return os.EX_OK


# environment command ------------------------------------------------------------

class SyncPlan(Command):

    description = _('synchronization plan specific actions in the katello server')
