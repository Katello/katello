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
from pprint import pprint

# output formatting -----------------------------------------------------------


class Printer:
    """
    Class for unified printing of the CLI output.
    """
    header_width = 45

    def __init__(self, grep):
        self._grep = grep
        self._columns = []

    def printHeader(self, *heading):
        """
        Print a fancy header to stdout.
        @type heading: string or list of strings
        @param heading: headers to be displayed
        """
        padding = 0
        print '+' + '-'*self.header_width + '+'
        for line in heading:
            if len(line) < self.header_width:
                padding = ((self.header_width - len(line)) / 2) - 1
            print ' ' * padding, line

        if self._grep:
            print
            for col in self._columns:
                if col['show_in_grep']:
                    print col['name'] + "\t",
            print
        print '+' + '-'*self.header_width + '+'


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
        return result


    def addColumn(self, attr_name, name = None, multiline = False, show_in_grep = True):
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
        """
        col = {}
        col['attr_name']    = attr_name
        col['multiline']    = multiline
        col['show_in_grep'] = show_in_grep
        if name == None:
            col['name'] = self._attrToName(attr_name)
        else:
            col['name'] = name

        self._columns.append(col)


    def _printItem(self, item, indent=""):
        """
        Print item of a list on number of lines
        @type item: hash
        @param item: data to print
        @type indent: string
        @param indent: text that is prepended to every printed line in multiline mode
        """
        for col in self._columns:
            #skip missing attributes
            if not item.has_key(col['attr_name']):
                continue

            value = item[col['attr_name']]
            if not col['multiline']:
                print indent+"%-15s \t%-25s" % (col['name'], value)
            else:
                print col['name']
                print indent_text(value, indent+"    ")


    def _printItemGrep(self, item):
        """
        Print item of a list on single line in grep mode
        @type item: hash
        @param item: data to print
        """
        for col in self._columns:
            #skip missing attributes
            if not item.has_key(col['attr_name']):
                print " \t",
                continue

            value = item[col['attr_name']]
            if not col['show_in_grep']:
                continue
            if col['multiline']:
                value = text_to_line(value)
            print "%s\t" % value,


    def printItem(self, item, indent=""):
        """
        Print one data item
        @type item: hash
        @param item: data to print
        @type indent: string
        @param indent: text that is prepended to every printed line in multiline mode
        """
        if self._grep:
            self._printItemGrep(item)
        else:
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
        for item in items:
            self.printItem(item, indent)


# server output validity ------------------------------------------------------
def is_valid_record(rec):
    """
    Checks if record returned from server has been saved.
    @type rec: Hash
    @param rec: record returned from server
    @return True if record contains created_at field with value.
    """
    if rec.has_key('created_at'):
        return (rec['created_at'] != None)

    elif rec.has_key('created'):
        return (rec['created'] != None)

    else:
        return False


# indent block of text --------------------------------------------------------
def indent_text(text, indent="\t"):
    if text == None:
        text = str(None)

    if isinstance(text, (list)):
        glue = "\n"+indent
        return indent+glue.join(text)
    else:
        return indent_text(text.split("\n"), indent)


# converts block of text to one line ------------------------------------------
def text_to_line(text, glue=" "):
    if text == None:
        text = str(None)

    if isinstance(text, (list)):
        return glue.join(text)
    else:
        return glue.join(text.split("\n"))


# system exit -----------------------------------------------------------------
def system_exit(code, msgs=None):
    """
    Exit with a code and optional message(s). Saves a few lines of code.
    @type code: int
    @param code: code to return
    @type msgs: str or list or tuple of str's
    @param msgs: messages to display
    """
    assert msgs is None or isinstance(msgs, (basestring, list, tuple))
    if msgs:
        if isinstance(msgs, basestring):
            msgs = (msgs,)
        if code == os.EX_OK:
            out = sys.stdout
        else:
            out = sys.stderr
        #out = sys.stdout if code == os.EX_OK else sys.stderr
        for msg in msgs:
            print >> out, msg
    sys.exit(code)


def parse_tokens(tokenstring):
    """
    Parse string as if it was command line parameters.
    @type tokenstring: string
    @param tokenstring: string with command line tokens
    @return List of tokens
    """
    tokens = []
    pattern = '--?\w+|=?"[^"]*"|=?\'[^\']*\'|=?[^\s]+'

    for tok in (re.findall(pattern, tokenstring)):

        if tok[0] == '=':
            tok = tok[1:]
        if tok[0] == '"' or tok[0] == "'":
            tok = tok[1:-1]

        tokens.append(tok)
    return tokens


def get_abs_path(path):
    """
    Return absolute path with .. and ~ resolved
    @type path: string
    @param path: relative path
    """
    path = os.path.expanduser(path)
    path = os.path.abspath(path)
    return path


def format_date(date):
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
    #TODO: implement
    return date


class Spinner(threading.Thread):

    def __init__(self, msg=""):
        self._msg = msg
        threading.Thread.__init__(self)

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
        self._stop = False

        self._putMessage()
        while True:
            for char in '/-\|':
                self._putChar(char)
                if self._stop:
                    self._eraseSpinner()
                    self._eraseMessage()
                    return
                time.sleep( 0.1 )
                self._resetCaret()

    def stop(self):
        self._stop = True


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
