#
# Katello Organization actions
# Copyright 2013 Red Hat, Inc.
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

from katello.client.api.task_status import TaskStatusAPI
from katello.client.core.base import BaseAction, Command
from katello.client.api.utils import ApiDataError

# base task action ----------------------------------------------------------------

class TaskAction(BaseAction):

    def __init__(self):
        super(TaskAction, self).__init__()
        self.api = TaskStatusAPI()

# task actions --------------------------------------------------------------------

class Status(TaskAction):

    description = _("get a task's status")

    def setup_parser(self, parser):
        parser.add_option("--uuid", dest='uuid',
                          help=_("task uuid eg: c9668eda-096b-445d-b96d (required)"))

    def check_options(self, validator):
        validator.require(('uuid'))

    def run(self):
        uuid = self.get_option('uuid')

        task = self.api.status(uuid)
        if task is None:
            raise ApiDataError(_("Could not find task [ %s ].") % uuid)

        self.printer.add_column('uuid', _("UUID"))
        self.printer.add_column('state', _("State"))
        self.printer.add_column('progress', _("Progress"))
        self.printer.add_column('start_time', _("Start Time"))
        self.printer.add_column('finish_time', ("Finish Time"))
        self.printer.set_header(_("Task Status"))
        self.printer.print_item(task)
        return os.EX_OK

# task command --------------------------------------------------------------------

class Task(Command):

    description = _('commands for retrieving task information')
