# -*- coding: utf-8 -*-
#
# Katello User actions
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
import re

try:
    import json
except ImportError:
    import simplejson as json

from katello.client.lib.ui.formatters import format_sync_errors, format_sync_status
from katello.client.api.task_status import TaskStatusAPI, SystemTaskStatusAPI
from katello.client.api.job import SystemGroupJobStatusAPI


# Envelope around task status structure
#
#{'created_at': None,
# 'finish_time': '2011-08-23T09:07:33Z',
# 'organization_id': None,
# 'progress': {'error_details': [],
#              'items_left': 0,
#              'size_left': 0,
#              'total_count': 8,
#              'total_size': 17872},
# 'result': True,
# 'start_time': '2011-08-23T09:07:26Z',
# 'state': 'finished',
# 'updated_at': None,
# 'uuid': '52456711-cd67-11e0-af50-f0def13c24e5'}
class AsyncTask():

    def __init__(self, task):
        if not isinstance(task, list):
            self._tasks = [task]
        else:
            self._tasks = task

    @classmethod
    def status_api(cls):
        return TaskStatusAPI()

    def update(self):
        self._tasks = [self.status_api().status(t['uuid']) for t in self._tasks]

    def get_progress(self):
        """
        In case only one task is running, we get the progress by the number of finished/unfinished files.
        If more tasks are running (e.g. more repos being synced at the same time, this approach is not enough
        because we don't know the number of unfinished packages for pending repo synchronizations.
        Therefore we use the number of finished/unfinished tasks instead
        """
        if self.is_multiple():
            return progress(self.subtask_left(), self.subtask_count())
        else:
            return progress(self.items_left(), self.total_count())

    def is_running(self):
        return (len(filter(self._subtask_is_running, self._tasks)) > 0)

    def finished(self):
        return not self.is_running()

    def failed(self):
        return len([t for t in self._tasks if t['state'] in ('error', 'timed out', 'failed')])

    def canceled(self):
        return len([t for t in self._tasks if t['state'] in ('cancelled', 'canceled')])

    def succeeded(self):
        return not (self.failed() or self.canceled())

    def subtask_left(self):
        return len([1 for task in self._tasks if self._subtask_is_running(task)])

    def subtask_count(self):
        return len(self._tasks)

    def total_size(self):
        return self._get_progress_sum('total_size')

    def total_count(self):
        return self._get_progress_sum('total_count')

    def size_left(self):
        return self._get_progress_sum('size_left')

    def items_left(self):
        return self._get_progress_sum('items_left')

    def progress_errors(self):
        return [err for task in self._tasks if 'error_details' in task['progress'] \
            for err in task['progress']['error_details']]

    def errors(self):
        return [task["result"]["errors"] for task in self._tasks if isinstance(task["result"], dict)]

    def _get_progress_sum(self, name):
        return sum([t['progress'][name] for t in self._tasks])

    @classmethod
    def _subtask_is_running(cls, task):
        return task['state'] not in ('finished', 'failed', 'timed out', 'canceled', 'not_synced')

    def is_multiple(self):
        return self.subtask_count() > 1

    def get_hashes(self):
        return self._tasks

    def get_subtasks(self):
        return [AsyncTask(t) for t in self._tasks]

    def __str__(self):
        return object.__str__(self) + ' ' + str(self._tasks)


# Envelope around system task status structure. Besides the standard AsyncTask
# it has description and result_description specified
class SystemAsyncTask(AsyncTask):
    def status_api(self):
        return SystemTaskStatusAPI()

    def status_messages(self):
        return [task["result_description"] for task in self._tasks]


class ImportManifestAsyncTask(AsyncTask):

    @classmethod
    def __format_display_message(cls, task):
        """
        The message coming back with this task can contain stack trace and other unformatted
        data. The relevant user message is found and displayed.
        """
        message = ""
        for error in task.errors():
            # First element is message data, second is stack trace
            full_error_msg = error[0]

            # Resources::Candlepin::Owner: 409 Conflict {
            #   "displayMessage" : "Import is the same as existing data",
            #   "conflicts" : [ "MANIFEST_SAME" ]
            #   } (POST /candlepin/owners/Engineering/imports)

            m = re.match(".*Resources::Candlepin::Owner[^{]*(?P<json>{.*})[^}]*", full_error_msg, re.DOTALL)
            if m is not None:
                message += " " + json.loads(m.group("json"))['displayMessage']
            else:
                message += " " + full_error_msg
            return str(message)

    @classmethod
    def evaluate_task_status(cls, task, failed="", canceled="", ok=""):
        """
        Test task status and print the corresponding message

        :type failed: string
        :param failed: message that is printed when the task failed
        :type canceled: string
        :param canceled:  message that is printed when the task was cancelled
        :type ok: string
        :param ok:  message that is printed when the task went ok
        :return: EX_DATAERR on failure or cancel, otherwise EX_OK
        """
        evaluate_task_status(task, failed, canceled, ok,
            error_formatter=cls.__format_display_message,
            status_formatter=cls.__format_display_message
        )


def progress(left, total):
    size_left = float(left)
    size_total = float(total)
    return 0.0 if total == 0 else (size_total - size_left) / size_total


# Envelope around job structure.
#
# A job is essentially a container for a set of tasks.  For example,
# in the case of a system group action, when an action is scheduled,
# it will create 1 job and associate N tasks with that job (i.e. 1
# task for each system in the group).
#
# The job as modelled here is essentially the overall status of a
# given job.  The following is an example:
#
#  {'created_at': '2011-08-23T09:07:33Z',
#   'id': '40'
#   'pulp_id': 'b965b7de-733b-434c-a327-a18bbf22e796',
#   'parameters': {:packages=>["xterm"]},
#   'task_type': 'package_install',
#   'tasks', [{
#              'progress': '',
#              'result': '',
#              'finish_time': '',
#              'start_time': '',
#              'state': 'waiting',
#              'id': '57',
#              'uuid': 'f10f5978-c06b-11e1-9021-bc305ba6d5b4'
#             }],
#   'state', 'running',
#   'status_message: 'Installing package...',
#   'finish_time': ''}
class AsyncJob(AsyncTask):

    @classmethod
    def status_api(cls):
        # In the future, this could be used for a generic JobStatusAPI; however, for now the only
        # thing using the job APIs is System Groups.
        # return JobStatusAPI()
        return SystemGroupJobStatusAPI()

    def update(self):
        self._tasks = [self.status_api().status(j['id']) for j in self._tasks]



# SystemGroup representation for a job
class SystemGroupAsyncJob(AsyncJob):
    def __init__(self, org_id, system_group_id, job):
        AsyncJob.__init__(self, job)
        self.__org_id = org_id
        self.__system_group_id = system_group_id

    def status_api(self):
        return SystemGroupJobStatusAPI(self.__org_id, self.__system_group_id)

    def status_messages(self):
        return [job["status_message"] for job in self._tasks]



def evaluate_task_status(task, failed="", canceled="", ok="", error_formatter=None, status_formatter=None):
    """
    Test task status and print the corresponding message

    :type task: AsyncTask
    :type failed: string
    :param failed: message that is printed when the task failed
    :type canceled: string
    :param canceled:  message that is printed when the task was cancelled
    :type ok: string
    :param ok:  message that is printed when the task went ok
    :type error_formatter: function
    :param error_formatter: formatter function used in case of task failure, default is format_sync_errors
    :type status_formatter: function
    :param status_formatter: formatter function used when the task succeeds, default is format_sync_status
    :return: EX_DATAERR on failure or cancel, otherwise EX_OK
    """

    error_formatter = error_formatter or format_sync_errors
    status_formatter = status_formatter or format_sync_status

    if task.failed():
        print failed + ":" + error_formatter(task)
        return os.EX_DATAERR
    elif task.canceled():
        print canceled
        return os.EX_DATAERR
    else:
        if "status_messages" in dir(task):
            print ok + ":" + status_formatter(task)
        else:
            print ok
        return os.EX_OK


def evaluate_remote_action(task):
    evaluate_task_status(task,
        failed =   _("Remote action failed"),
        canceled = _("Remote action canceled"),
        ok =       _("Remote action finished")
    )
