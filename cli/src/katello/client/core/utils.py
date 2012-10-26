# -*- coding: utf-8 -*-

# Copyright © 2012 Red Hat, Inc.
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

import os
import re
import sys
import time
import threading
from xml.utils import iso8601
from katello.client.api.task_status import TaskStatusAPI, SystemTaskStatusAPI
from katello.client.api.job import SystemGroupJobStatusAPI
from katello.client.config import Config

#  mode check -----------------------------------------------------------------
def get_katello_mode():
    Config()
    path = Config.parser.get('server', 'path') if Config.parser.has_option('server', 'path') else ''
    if "headpin" in path or "sam" in path:
        return "headpin"
    else:
        return "katello"

# server output validity ------------------------------------------------------
def is_valid_record(rec):
    """
    Checks if record returned from server has been saved.
    @type rec: Object
    @param rec: record returned from server
    @return True if record contains created_at field with value.
    """
    if type(rec)==type(dict()) and 'created_at' in rec:
        return (rec['created_at'] != None)
    elif type(rec)==type(dict()) and 'created' in rec:
        return (rec['created'] != None)
    else:
        return False

def test_record(rec, success_msg, failure_msg):
    """
    Test if a record is valid, and exit with a proper return code and a message.
    @type rec: dictionary
    @param rec: record returned from server
    @type success_msg: string
    @param success_msg: success message
    @type failure_msg: string
    @param failure_msg: failure message
    """
    if is_valid_record(rec):
        system_exit(os.EX_OK, success_msg)
    else:
        system_exit(os.EX_DATAERR, failure_msg)

def test_foreman_record(rec, key, success_msg, failure_msg):
    """
    Test if a foreman record is valid, and exit with a proper return code and a message.
    @type rec: dictionary
    @param rec: record returned from server
    @type key: string
    @param key: expected record key (eg config_template)
    @type success_msg: string
    @param success_msg: success message
    @type failure_msg: string
    @param failure_msg: failure message
    """
    if type(rec)==dict and key in rec:
        system_exit(os.EX_OK, success_msg)
    else:
        system_exit(os.EX_DATAERR, failure_msg)


def unnest(rec, *path):
    """
    Unnests inner values in a dictionary according to key path.
    If the rec is a tuple or a list then unnesting is applied
    to its items.
    Eg.
        >>> example_dict = {'a': {'b': {'c': 'the_value'}}}
        >>> unnest(example_dict, "a", "b")
        {'c': 'the_value'}

    @param rec: record to unnest
    @type rec: dict, list or tuple of dicts
    @param *path: key path in the dictionary
    @rtype: dict, list or tupple according to type of rec
    """
    if isinstance(rec, list):
        return [unnest(item, *path) for item in rec]
    elif isinstance(rec, tuple):
        return (unnest(item, *path) for item in rec)
    else:
        assert isinstance(rec, dict)
        return reduce(dict.get, path, rec)

def unnest_one(rec):
    """
    Unnest one level of a dict. Takes first key returned by .keys()
    and unnests the value saved in the dict for that key.
    If the rec is a tuple or a list then unnesting is applied
    to its items.
    Eg.
        >>> example_dict = {'a': {'b': {'c': 'the_value'}}}
        >>> unnest_one(example_dict)
        {'b': {'c': 'the_value'}}

    @param rec: record to unnest
    @type rec: dict, list or tuple of dicts
    @rtype: dict, list or tupple according to type of rec
    """
    if isinstance(rec, (list, tuple)):
        return unnest(rec, rec[0].keys()[0])
    else:
        assert isinstance(rec, dict)
        assert len(rec) > 0
        return unnest(rec, rec.keys()[0])

def update_dict_unless_none(d, key, value):
    """
    Update value for key in dictionary only if the value is not None.
    """
    if value != None:
        d[key] = value
    return d

# custom info -----------------------------------------------------------------
def stringify_custom_info(list_custom_info):
    arr = []
    for info in list_custom_info:
        arr.append("%s: %s" % (info["keyname"], info["value"]))

    return "[ %s ]"  % ", ".join(arr)

class SystemExitRequest(Exception):
    """
    Exception to indicate a system exit request. Introduced to
    The arguments are [0] the response status as an integer and
    [1] a list of error messages.
    """
    pass

# system exit -----------------------------------------------------------------
def system_exit(code, msgs=None):
    """
    Raise a system exit request exception with a return code and optional message(s).
    Saves a few lines of code. Exception is handled in command's main method. This
    allows not to exit the cli but only skip out of the command when running in shell mode.
    @type code: int
    @param code: code to return
    @type msgs: str or list or tuple of str's
    @param msgs: messages to display
    """
    assert msgs is None or isinstance(msgs, (basestring, list, tuple))
    lstMsgs = []
    if msgs:

        if isinstance(msgs, basestring):
            lstMsgs.append(msgs)
        elif isinstance(msgs, tuple):
            lstMsgs = list(msgs)
        else:
            lstMsgs = msgs

    raise SystemExitRequest(code, lstMsgs)

def parse_tokens(tokenstring):
    """
    Parse string as if it was command line parameters.
    @type tokenstring: string
    @param tokenstring: string with command line tokens
    @return List of tokens
    """
    from katello.client.cli.base import KatelloError

    tokens = []
    try:
        pattern = '--?\w+|=?"[^"]*"|=?\'[^\']*\'|=?[^\s]+'

        for tok in (re.findall(pattern, tokenstring)):

            if tok[0] == '=':
                tok = tok[1:]
            if tok[0] == '"' or tok[0] == "'":
                tok = tok[1:-1]

            tokens.append(tok)
        return tokens
    except Exception, e:
        raise KatelloError("Unable to parse options", e), None, sys.exc_info()[2]


def get_abs_path(path):
    """
    Return absolute path with .. and ~ resolved
    @type path: string
    @param path: relative path
    """
    path = os.path.expanduser(path)
    path = os.path.abspath(path)
    return path


def format_date(date, to_format="%Y/%m/%d %H:%M:%S"):
    """
    Format standard rails timestamp to more human readable format
    @type date: string
    @param date: arguments for the function
    @return string, formatted date
    """
    if not date:
        return ""
    t = iso8601.parse(date)
    return time.strftime(to_format, time.localtime(t))


def format_sync_errors(task):
    """
    Format errors in progress returned from AsyncTask
    @type errors: list
    @param errors: list of progress errors returned from AsyncTask.progress_errors()
    @return string, each error on one line
    """
    def format_progress_error(e):
        if "error" in e:
            if isinstance(e["error"], dict) and ("error" in e["error"]):
                return e["error"]["error"]
            else:
                return str(e["error"])

    def format_task_error(e):
        if isinstance(e, list) and len(e) > 0:
            return e[0]

    error_list = [format_progress_error(e) for e in task.progress_errors()]
    error_list += [format_task_error(e) for e in task.errors()]

    return "\n".join([e for e in error_list if e])


def format_task_errors(errors):
    """
    Format errors returned from AsyncTask
    @type errors: list
    @param errors: list of errors returned from AsyncTask.errors()
    @return string, each error on one line
    """
    error_list = [e[0] for e in errors if e[0]]
    return "\n".join(error_list)


class Spinner(threading.Thread):
    """
    Spinner shows nice cli "spinner" while function is executing.

    Each spinner instance can be started only once. Typical usage:

    s = Spinner()
    s.start()
    ...
    s.stop()
    s.join()
    """

    def __init__(self, msg=""):
        self._msg = msg
        threading.Thread.__init__(self)
        self._stopevent = threading.Event()

    def _putMessage(self):
        sys.stdout.write(self._msg)
        sys.stdout.flush()

    def _eraseMessage(self):
        l = len(self._msg)
        sys.stdout.write('\033['+ str(l) +'D')
        sys.stdout.write(' '*l)
        sys.stdout.write('\033['+ str(l) +'D')


    @classmethod
    def _putChar(cls, char):
        sys.stdout.write('[%s]' % char)
        sys.stdout.flush()

    @classmethod
    def _resetCaret(cls):
        #move the caret one character back
        sys.stdout.write('\033[3D')
        sys.stdout.flush()

    def _eraseSpinner(self):
        self._resetCaret()
        sys.stdout.write('   ')
        self._resetCaret()

    def run(self):
        self._putMessage()
        while True:
            for char in '/-\|':
                self._putChar(char)
                if self._stopevent.wait(0.1) or self._stopevent.is_set():
                    self._eraseSpinner()
                    self._eraseMessage()
                    return
                self._resetCaret()

    def stop(self):
        self._stopevent.set()

class ProgressBar(object):

    @classmethod
    def updateProgress(cls, progress_in):
        sys.stdout.write("\rProgress: [{0:50s}] {1:.1f}%".format('#' * int(progress_in * 50), progress_in * 100))
        sys.stdout.flush()

    @classmethod
    def done(cls):
        sys.stdout.write("\r{0:60s}\r".format(' '*70))


def run_spinner_in_bg(function, arguments=(), message=""):
    """
    Run spinner while a function is running.
    @type function: function
    @param function: function to run
    @type arguments: list
    @param arguments: arguments for the function
    @type message: string
    @param message: message to be temporarily displayed while the spinner is running.
    @return return value of the function
    """
    result = None

    t = Spinner(message)
    t.start()
    try:
        result = function(*arguments)
    finally:
        t.stop()
        t.join()
    return result


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
        return (len(filter(lambda t: t['state'] in ('error', 'timed out'), self._tasks)) > 0)

    def cancelled(self):
        return (len(filter(lambda t: t['state'] in ('cancelled', 'canceled'), self._tasks)) > 0)

    def succeeded(self):
        return not (self.failed() or self.cancelled())

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
        return task['state'] not in ('finished', 'error', 'timed out', 'canceled', 'not_synced')

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

    def get_result_description(self):
        return ", ".join([task["result_description"] for task in self._tasks])



def wait_for_async_task(task):
    if not isinstance(task, AsyncTask):
        task = AsyncTask(task)

    while task.is_running():
        time.sleep(1)
        task.update()
    return task.get_hashes()


def run_async_task_with_status(task, progressBar):
    if not isinstance(task, AsyncTask):
        task = AsyncTask(task)

    delay = 1
    while task.is_running():
        time.sleep(delay)
        task.update()
        progressBar.updateProgress(task.get_progress())

    progressBar.done()
    return task.get_hashes()


def progress(left, total):
    sizeLeft = float(left)
    sizeTotal = float(total)
    return 0.0 if total == 0 else (sizeTotal - sizeLeft) / sizeTotal

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

    def succeeded(self):
        return not (self.failed() or self.cancelled())

    def __str__(self):
        return object.__str__(self) + ' ' + str(self._tasks)

# SystemGroup representation for a job
class SystemGroupAsyncJob(AsyncJob):
    def __init__(self, org_id, system_group_id, job):
        AsyncJob.__init__(self, job)
        self.__org_id = org_id
        self.__system_group_id = system_group_id


    def status_api(self):
        return SystemGroupJobStatusAPI(self.__org_id, self.__system_group_id)

    def get_status_message(self):
        return ", ".join([job["status_message"] for job in self._tasks])

def convert_to_mime_type(type_in, default=None):
    availableMimeTypes = {
        'text': 'text/plain',
        'csv':  'text/csv',
        'html': 'text/html',
        'pdf':  'application/pdf'
    }

    return availableMimeTypes.get(type_in, availableMimeTypes.get(default))

def attachment_file_name(headers, default):
    contentDisposition = filter(lambda h: h[0].lower() == 'content-disposition', headers)

    if len(contentDisposition) > 0:
        filename = contentDisposition[0][1].split('filename=')
        if len(filename) < 2:
            return default
        if filename[1][0] == '"' or filename[1][0] == "'":
            return filename[1][1:-1]
        return filename

    return default

def save_report(report, filename):
    f = open(filename, 'w')
    f.write(report)
    f.close()


def slice_dict(orig_dict, *key_list, **kw_args):
    if kw_args.get('allow_none', True):
        return dict((key, orig_dict[key]) for key in key_list if key in orig_dict)
    else:
        return dict((key, orig_dict[key]) for key in key_list if key in orig_dict and orig_dict[key] is not None)
