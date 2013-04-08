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

import sys
import time
import threading
from katello.client.lib.async import AsyncTask


class ProgressBar(object):

    @classmethod
    def update_progress(cls, progress_in):
        sys.stdout.write("\rProgress: [{0:50s}] {1:.1f}%".format('#' * int(progress_in * 50), progress_in * 100))
        sys.stdout.flush()

    @classmethod
    def done(cls):
        sys.stdout.write("\r{0:60s}\r".format(' '*70))


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

    def _put_message(self):
        sys.stdout.write(self._msg)
        sys.stdout.flush()

    def _erase_message(self):
        l = len(self._msg)
        sys.stdout.write('\033['+ str(l) +'D') # pylint: disable=E0012,W1401
        sys.stdout.write(' '*l)
        sys.stdout.write('\033['+ str(l) +'D') # pylint: disable=E0012,W1401


    @classmethod
    def _put_char(cls, char):
        sys.stdout.write('[%s]' % char)
        sys.stdout.flush()

    @classmethod
    def _reset_caret(cls):
        #move the caret one character back
        sys.stdout.write('\033[3D') # pylint: disable=E0012,W1401
        sys.stdout.flush()

    def _erase_spinner(self):
        self._reset_caret()
        sys.stdout.write('   ')
        self._reset_caret()

    def run(self):
        self._put_message()
        while True:
            for char in '/-\|': # pylint: disable=E0012,W1401
                self._put_char(char)
                if self._stopevent.wait(0.1) or self._stopevent.is_set():
                    self._erase_spinner()
                    self._erase_message()
                    return
                self._reset_caret()

    def stop(self):
        self._stopevent.set()


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


def wait_for_async_task(task, delay=1):
    if not isinstance(task, AsyncTask):
        task = AsyncTask(task)

    while task.is_running():
        time.sleep(delay)
        task.update()
    return task.get_hashes()


def run_async_task_with_status(task, progress_bar, delay=1):
    if not isinstance(task, AsyncTask):
        task = AsyncTask(task)

    while task.is_running():
        time.sleep(delay)
        task.update()
        progress_bar.update_progress(task.get_progress())

    progress_bar.done()
    return task.get_hashes()
