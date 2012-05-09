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
from katello.client.core.utils import test_record, format_date, system_exit
from katello.client.core.datetime_formatter import DateTimeFormatter, DateTimeFormatException
from katello.client.api.utils import get_sync_plan


Config()

# base sync_plan action --------------------------------------------------------

class SyncPlanAction(Action):

    interval_choices = ['none', 'hourly', 'daily', 'weekly']


    def __init__(self):
        super(SyncPlanAction, self).__init__()
        self.api = SyncPlanAPI()

    def parse_datetime(self, date, time):
        date = date.strip()
        time = time.strip()

        formatter = DateTimeFormatter()
        try:
            return formatter.build_datetime(date, time)
        except DateTimeFormatException, e:
            system_exit(os.EX_DATAERR, e.args[0])

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

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('description', multiline=True)
        self.printer.add_column('start_date', formatter=format_date)
        self.printer.add_column('interval')

        self.printer.set_header(_("Sync Plan List"))
        self.printer.print_items(plans)
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

        self.printer.add_column('id')
        self.printer.add_column('name')
        self.printer.add_column('description', multiline=True)
        self.printer.add_column('start_date', formatter=format_date)
        self.printer.add_column('interval')

        self.printer.set_header(_("Sync Plan Info"))
        self.printer.print_item(plan)

        return os.EX_OK


class Create(SyncPlanAction):

    description = _('create a synchronization plan')

    def setup_parser(self):
        self.parser.add_option('--name', dest='name', help=_("name of the sync plan (required)"))
        self.parser.add_option('--org', dest='org', help=_("organization name (required)"))
        self.parser.add_option("--description", dest="description", help=_("plan description"))
        self.parser.add_option('--interval', dest='interval',
            help=_("interval of recurring synchronizations (choices: [%s], default: none)") % ', '.join(self.interval_choices),
            default='none', choices=self.interval_choices)
        self.parser.add_option("--date", dest="date", help=_("date of first synchronization (required, format: YYYY-MM-DD)"))
        self.parser.add_option("--time", dest="time", help=_("time of first synchronization (format: HH:MM:SS, default: 00:00:00)"), default="00:00:00")

    def check_options(self):
        self.require_option('org')
        self.require_option('name')
        self.require_option('date')
        pass

    def run(self):
        name        = self.get_option('name')
        org_name    = self.get_option('org')
        description = self.get_option('description')
        interval    = self.get_option('interval')
        date        = self.get_option('date')
        time        = self.get_option('time')

        sync_date = self.parse_datetime(date, time)

        plan = self.api.create(org_name, name, sync_date, interval, description)
        test_record(plan,
            _("Successfully created synchronization plan [ %s ]") % name,
            _("Could not create synchronization plan [ %s ]") % name
        )


class Update(SyncPlanAction):

    description =  _('update a sync plan')

    def setup_parser(self):
        self.parser.add_option('--name', dest='name', help=_("name of the sync plan (required)"))
        self.parser.add_option('--new_name', dest='new_name', help=_("new sync plan name"))
        self.parser.add_option('--org', dest='org', help=_("organization name (required)"))
        self.parser.add_option("--description", dest="description", help=_("plan description"))
        self.parser.add_option('--interval', dest='interval',
            help=_("interval of recurring synchronizations (choices: [%s], default: none)") % ', '.join(self.interval_choices),
            default='none', choices=self.interval_choices)
        self.parser.add_option("--date", dest="date", help=_("date of first synchronization (format: YYYY-MM-DD)"))
        self.parser.add_option("--time", dest="time", help=_("time of first synchronization (format: HH:MM:SS)"))

    def check_options(self):
        self.require_option('org')
        self.require_option('name')
        if not (self.has_option('date') and self.has_option('time')):
            self.add_option_error(_('You have to specify both --date and --time'))

    def run(self):
        name        = self.get_option('name')
        new_name    = self.get_option('new_name')
        org_name    = self.get_option('org')
        description = self.get_option('description')
        interval    = self.get_option('interval')
        date        = self.get_option('date')
        time        = self.get_option('time')

        plan = get_sync_plan(org_name, name)

        if date != None and time != None:
            sync_date = self.parse_datetime(date, time)
        else:
            sync_date = None

        plan = self.api.update(org_name, plan["id"], new_name, sync_date, interval, description)
        print _("Successfully updated sync plan [ %s ]") % name
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

        self.api.delete(org_name, plan["id"])
        print _("Successfully deleted sync plan [ %s ]") % plan_name
        return os.EX_OK


# sync_plan command ------------------------------------------------------------

class SyncPlan(Command):

    description = _('synchronization plan specific actions in the katello server')
