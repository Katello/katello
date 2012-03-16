# -*- coding: utf-8 -*-

# Copyright © 2010 Red Hat, Inc.
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
import calendar
from xml.utils import iso8601
from katello.client.api.task_status import TaskStatusAPI, SystemTaskStatusAPI
from katello.client.utils.encoding import u_str


# output formatting -----------------------------------------------------------


class Printer:
    """
    Class for unified printing of the CLI output.
    """
    OUTPUT_FORCE_NONE = 0
    OUTPUT_FORCE_GREP = 1
    OUTPUT_FORCE_VERBOSE = 2

    def __init__(self, output_mode, delimiter=""):
        self._output_mode = output_mode
        self._columns = []
        self._heading = ""
        self._delim = delimiter


    def setHeader(self, heading):
        self._heading = heading

    def setOutputMode(self, output_mode):
        self._output_mode = output_mode

    def _printDivLine(self, width):
        print '-'*width

    def _printHeader(self, heading, grep_mode, widths={}):
        """
        Print a fancy header to stdout.
        @type heading: string or list of strings
        @param heading: headers to be displayed
        """
        padding = 0
        header_width = self._getTermWidth()

        self._printDivLine(header_width)
        for line in heading.split("\n"):
            if len(line) < header_width:
                padding = ((header_width - len(line)) / 2) - 1
            print ' ' * padding, line

        if grep_mode:
            print
            print self._delim,
            for col in self._columns:
                if col['show_in_grep']:

                    if col['attr_name'] in widths:
                        width = widths[col['attr_name']]
                    else:
                        width = 0

                    print col['name'].ljust(width),
                    print self._delim,
            print
        self._printDivLine(header_width)

    # returns terminal width (tested only with Linux)
    def _getTermWidth(self):
        try:
            import fcntl
            import termios
            import struct
            h, w, hp, wp = struct.unpack('HHHH',
                fcntl.ioctl(0, termios.TIOCGWINSZ,
                struct.pack('HHHH', 0, 0, 0, 0)))
            w = int(w)
            return 80 if w == 0 else w
        except:
            return 80

    def _attrToName(self, attr_name):
        """
        Convert attribute name to display name.
        oraganization_id -> Organization Id
        @type attr_name: string
        @param attr_name: attribute name
        """
        result = ''
        for part in attr_name.split("_"):
            result += part[0].upper() + part[1:] + ' '
        return result.strip()


    def addColumn(self, attr_name, name = None, multiline = False, show_in_grep = True, time_format=False, value=''):
        """
        Add column to display
        @type attr_name: string
        @param attr_name: key to data hash
        @type name: string
        @param name: display name of the column. It is automatically transformed from display name
        if not set.
        @type multiline: bool
        @param multiline: flag to mark multiline values
        @type show_in_grep: bool
        @param show_in_grep: flag to set whether the column should be displayed also in grep mode or not
        @type time_format: bool
        @param time_format: flag to set this column as a rails date string to be parsed
        @type value: string
        @param value: value that should be used rather than accessing the data hash
        """
        col = {}
        col['attr_name']    = attr_name
        col['multiline']    = multiline
        col['show_in_grep'] = show_in_grep
        col['time_format']  = time_format
        col['value']        = value
        if name == None:
            col['name'] = self._attrToName(attr_name)
        else:
            col['name'] = name

        self._columns.append(col)


    def _printItem(self, item, indent=""):
        """
        Print item from a list on number of lines
        @type item: hash
        @param item: data to print
        @type indent: string
        @param indent: text that is prepended to every printed line in multiline mode
        """
        colWidth = self._minColumnWidth()
        print
        for col in self._columns:
            #skip missing attributes
            if not col['attr_name'] in item:
                continue

            if len(u_str(col['value'])) > 0:
                value = col['value']
            else:
                value = item[col['attr_name']]
            if not col['multiline']:
                output = format_date(value) if col['time_format'] else value
                print ("{0:<" + u_str(colWidth + 1) + "} {1}").format(col['name'] + ":", output)
                # +1 to account for the : after the column name
            else:
                print indent+col['name']+":"
                print indent_text(value, indent+"    ")


    def _printItemGrep(self, item, widths={}):
        """
        Print item of a list on single line in grep mode
        @type item: hash
        @param item: data to print
        """
        print self._delim,
        for col in self._columns:
            #get defined width
            if col['attr_name'] in widths:
                width = widths[col['attr_name']]
            else:
                width = 0

            #skip missing attributes
            if not col['attr_name'] in item:
                print " " * width,
                print self._delim,
                continue

            value = item[col['attr_name']]
            if not col['show_in_grep']:
                continue
            if col['multiline']:
                value = text_to_line(value)

            print u_str(value).ljust(width),
            print self._delim,


    def _calculateGrepWidths(self, items):
        widths = {}
        #return widths
        for col in self._columns:
            key = col['attr_name']
            widths[key] = len(u_str(col['name']))+1
            for item in items:
                if not key in item: continue
                value = u_str(item[key])
                if widths[key] < len(value):
                    widths[key] = len(value)+1

        return widths


    def _minColumnWidth(self):
        width = 0
        for col in self._columns:
            width = len(u_str(col['name'])) if (len(u_str(col['name'])) > width) else width

        return width

    def _getRandomNumber(self):
        return 4 # guaranteed to be random


    def printItem(self, item, indent=""):
        """
        Print one data item
        @type item: hash
        @param item: data to print
        @type indent: string
        @param indent: text that is prepended to every printed line in multiline mode
        """
        if self._output_mode == Printer.OUTPUT_FORCE_GREP:
            widths = self._calculateGrepWidths([item])
            self._printHeader(self._heading, True, widths)
            self._printItemGrep(item, widths)
            print
        else:
            self._printHeader(self._heading, False)
            self._printItem(item, indent)
            print


    def printItems(self, items, indent=""):
        """
        Print collection of data items
        @type items: list of hashes
        @param items: list of data items to print
        @type indent: string
        @param indent: text that is prepended to every printed line in multiline mode
        """
        if self._output_mode == Printer.OUTPUT_FORCE_VERBOSE:
            self._printHeader(self._heading, False)
            for item in items:
                self._printItem(item, indent)
                print
        else:
            widths = self._calculateGrepWidths(items)
            self._printHeader(self._heading, True, widths)
            for item in items:
                self._printItemGrep(item, widths)
                print




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


# indent block of text --------------------------------------------------------
def indent_text(text, indent="\t"):
    if text == None:
        text = u_str(None)

    if isinstance(text, (list)):
        glue = "\n"+indent
        return indent+glue.join(text)
    else:
        return indent_text(text.split("\n"), indent)


# converts block of text to one line ------------------------------------------
def text_to_line(text, glue=" "):
    if text == None:
        text = u_str(None)

    if isinstance(text, (list)):
        return glue.join(text)
    else:
        return glue.join(text.split("\n"))


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
        raise KatelloError("Unable to parse options", e)


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
        if e.has_key("error"):
           if isinstance(e["error"], dict) and e["error"].has_key("error"):
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

    def _putChar(self, char):
        sys.stdout.write('[')
        sys.stdout.write(char)
        sys.stdout.write(']')
        sys.stdout.flush()

    def _resetCaret(self):
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

class ProgressBar():

    def updateProgress(self, progress):
        sys.stdout.write("\rProgress: [{0:50s}] {1:.1f}%".format('#' * int(progress * 50), progress * 100))
        sys.stdout.flush()

    def done(self):
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

    _tasks = []

    def __init__(self, task):
        if not isinstance(task, list):
            self._tasks = [task]
        else:
            self._tasks = task

    def status_api(self):
        return TaskStatusAPI()

    def update(self):
        self._tasks = [self.status_api().status(t['uuid']) for t in self._tasks]

    def get_progress(self):
        return progress(self.items_left(), self.total_count())

    def is_running(self):
        return (len(filter(lambda t: t['state'] not in ('finished', 'error', 'timed out', 'canceled', 'not_synced'), self._tasks)) > 0)

    def finished(self):
        return not self.is_running()

    def failed(self):
        return (len(filter(lambda t: t['state'] in ('error', 'timed out'), self._tasks)) > 0)

    def cancelled(self):
        return (len(filter(lambda t: t['state'] in ('cancelled', 'canceled'), self._tasks)) > 0)

    def succeeded(self):
        return not (self.failed() or self.cancelled())

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
        return [err for task in self._tasks if 'error_details' in task['progress'] for err in task['progress']['error_details']]

    def errors(self):
        return [task["result"]["errors"] for task in self._tasks if isinstance(task["result"], dict)]

    def _get_progress_sum(self, name):
        return sum([t['progress'][name] for t in self._tasks])

    def is_multiple(self):
        return self.subtask_count() > 1

    def get_hashes(self):
        return self._tasks

    def get_subtasks(self):
        return [AsyncTask(t) for t in self._tasks]

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

    delay = 1 if not task.is_multiple() else (1.0/task.subtask_count())
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


def convert_to_mime_type(type, default=None):
    availableMimeTypes = {
        'text': 'text/plain',
        'csv':  'text/csv',
        'html': 'text/html',
        'pdf':  'application/pdf'
    }

    return availableMimeTypes.get(type, availableMimeTypes.get(default))

def attachment_file_name(headers, default):
    contentDisposition = filter(lambda h: h[0].lower() == 'content-disposition', headers)

    if len(contentDisposition) >  0:
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
