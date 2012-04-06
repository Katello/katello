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
import sys
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
        self.__output_mode = output_mode
        self.__columns = []
        self.__heading = ""
        self.__delim = delimiter


    def set_header(self, heading):
        self.__heading = heading

    def set_output_mode(self, output_mode):
        self.__output_mode = output_mode

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
            print self.__delim,
            for col in self.__columns:
                if col['show_in_grep']:

                    if col['attr_name'] in widths:
                        width = widths[col['attr_name']]
                    else:
                        width = 0

                    print col['name'].ljust(width),
                    print self.__delim,
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


    def add_column(self, attr_name, name = None, multiline = False, show_in_grep = True, time_format=False, value=''):
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

        self.__columns.append(col)


    def _print_item(self, item, indent=""):
        """
        Print item from a list on number of lines
        @type item: hash
        @param item: data to print
        @type indent: string
        @param indent: text that is prepended to every printed line in multiline mode
        """
        colWidth = self._minColumnWidth()
        print
        for col in self.__columns:
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


    def _print_itemGrep(self, item, widths={}):
        """
        Print item of a list on single line in grep mode
        @type item: hash
        @param item: data to print
        """
        print self.__delim,
        for col in self.__columns:
            #get defined width
            if col['attr_name'] in widths:
                width = widths[col['attr_name']]
            else:
                width = 0

            #skip missing attributes
            if not col['attr_name'] in item:
                print " " * width,
                print self.__delim,
                continue

            value = item[col['attr_name']]
            if not col['show_in_grep']:
                continue
            if col['multiline']:
                value = text_to_line(value)

            print u_str(value).ljust(width),
            print self.__delim,


    def _calculateGrepWidths(self, items):
        widths = {}
        #return widths
        for col in self.__columns:
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
        for col in self.__columns:
            width = len(u_str(col['name'])) if (len(u_str(col['name'])) > width) else width

        return width

    def _getRandomNumber(self):
        return 4 # guaranteed to be random


    def print_item(self, item, indent=""):
        """
        Print one data item
        @type item: hash
        @param item: data to print
        @type indent: string
        @param indent: text that is prepended to every printed line in multiline mode
        """
        if self.__output_mode == Printer.OUTPUT_FORCE_GREP:
            widths = self._calculateGrepWidths([item])
            self._printHeader(self.__heading, True, widths)
            self._print_itemGrep(item, widths)
            print
        else:
            self._printHeader(self.__heading, False)
            self._print_item(item, indent)
            print


    def print_items(self, items, indent=""):
        """
        Print collection of data items
        @type items: list of hashes
        @param items: list of data items to print
        @type indent: string
        @param indent: text that is prepended to every printed line in multiline mode
        """
        if self.__output_mode == Printer.OUTPUT_FORCE_VERBOSE:
            self._printHeader(self.__heading, False)
            for item in items:
                self._print_item(item, indent)
                print
        else:
            widths = self._calculateGrepWidths(items)
            self._printHeader(self.__heading, True, widths)
            for item in items:
                self._print_itemGrep(item, widths)
                print




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
