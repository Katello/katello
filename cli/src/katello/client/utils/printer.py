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
import pdb
from gettext import gettext as _
from pprint import pprint
from katello.client.utils.encoding import u_str



class PrinterStrategy:

    def print_item(self, heading, columns, item):
        self.print_items(heading, columns, [item])

    def print_items(self, heading, columns, items):
        pass

    def _get_column_value(self, column, item):
        value = item.get(column['attr_name'], column.get('value', None))
        value_format_func = column.get('formatter', column.get('value_formatter', None))
        item_format_func = column.get('item_formatter', None)

        if value_format_func and value:
            value = value_format_func(value)
        elif item_format_func:
            value = item_format_func(item)
        return value

class VerboseStrategy(PrinterStrategy):

    def print_items(self, heading, columns, items):
        """
        """
        self._print_header(heading)
        for item in items:
            self._print_item(item, columns)
            print

    def _print_header(self, heading):
        """
        Print a fancy header to stdout.
        @type heading: string or list of strings
        @param heading: headers to be displayed
        """
        print_line()
        print center_text(heading)
        print_line()

    def _print_item(self, item, columns):
        """
        """
        print
        for column in columns:
            value = self._get_column_value(column, item)
            #skip missing attributes
            if not value:
                continue

            if not column.get('multiline', False):
                col_width = self._column_width(columns)
                print ("{0:<" + u_str(col_width + 1) + "} {1}").format(u_str(column['name'])+":", u_str(value))
                # +1 to account for the : after the column name
            else:
                print column['name']+":"
                print indent_text(value, "    ")

    def _column_width(self, columns):
        """
        """
        width = 0
        for column in columns:
            current_width = len(_(column['name']))
            width = current_width if (current_width > width) else width
        return width


class GrepStrategy(PrinterStrategy):

    def __init__(self, delimiter=None):
        """
        """
        self.__delim = delimiter if delimiter else ""

    def print_items(self, heading, columns, items):
        """
        """
        column_widths = self._calc_column_widths(items, columns)
        self._print_header(heading, columns, column_widths)
        for item in items:
            self._print_item(item, columns, column_widths)
            print

    def _print_header(self, heading, columns, column_widths):
        """
        Print a fancy header to stdout.
        @type heading: string or list of strings
        @param heading: headers to be displayed
        """
        print_line()
        print center_text(heading)

        print
        print self.__delim,
        for column in columns:
            width = column_widths.get(column['attr_name'], 0)

            print column['name'].ljust(width),
            print self.__delim,
        print
        print_line()

    def _print_item(self, item, columns, column_widths):
        """
        Print item of a list on single line
        @type item: hash
        @param item: data to print
        """
        print self.__delim,
        for column in columns:
            #get defined width
            width = column_widths.get(column['attr_name'], 0)

            #skip missing attributes
            value = self._get_column_value(column, item)
            if not value:
                print " " * width,
                print self.__delim,
                continue

            if column.get('multiline', False):
                value = text_to_line(value)

            print u_str(value).ljust(width),
            print self.__delim,

    def _column_width(self, items, column):
        """
        """
        key = column['attr_name']
        width = len(column['name'])+1
        for column_value in [u_str(self._get_column_value(column, item)) for item in items]:
            if width <= len(column_value):
                width = len(column_value)+1
        return width

    def _calc_column_widths(self, items, columns):
        """
        """
        widths = {}
        for column in columns:
            widths[column['attr_name']] = self._column_width(items, column)
        return widths


class Printer:
    """
    Class for unified printing of the CLI output.
    """

    def __init__(self, strategy=None):
        self.__printer_strategy = strategy
        self.__columns = []
        self.__heading = ""

    def set_header(self, heading):
        """
        """
        self.__heading = heading

    def set_strategy(self, strategy):
        """
        """
        self.__printer_strategy = strategy

    def add_column(self, attr_name, name = None, **kwargs):
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
        @type value: string
        @param value: value that should be used rather than accessing the data hash
        """
        col = kwargs
        col['attr_name'] = attr_name
        col['name'] = _(self.__attr_to_name(attr_name)) if not name else name
        self.__columns.append(col)

    def print_item(self, item):
        """
        """
        if not self.__printer_strategy:
            self.set_strategy(VerboseStrategy())
        self.__printer_strategy.print_item(self.__heading, self.__filtered_columns(), item)

    def print_items(self, items):
        """
        """
        if not self.__printer_strategy:
            self.set_strategy(GrepStrategy())
        self.__printer_strategy.print_items(self.__heading, self.__filtered_columns(), items)

    def __attr_to_name(self, attr_name):
        """
        Convert attribute name to display name.
        oraganization_id -> Organization Id
        @type attr_name: string
        @param attr_name: attribute name
        """
        return " ".join([part[0].upper() + part[1:] for part in attr_name.split("_")])

    def __filtered_columns(self):
        """
        """
        filtered = []
        for column in self.__columns:
            allowed_strategies = column.get('show_with', (object))
            if isinstance(self.__printer_strategy, allowed_strategies):
                filtered.append(column)
        return filtered



# indent block of text --------------------------------------------------------
def indent_text(text, indent="\t"):
    """
    """
    if not text:
        text = u_str(None)

    if isinstance(text, (list)):
        glue = "\n"+indent
        return indent+glue.join(text)
    else:
        return indent_text(text.split("\n"), indent)


# converts block of text to one line ------------------------------------------
def text_to_line(text, glue=" "):
    """
    """
    if not text:
        text = u_str(None)

    if isinstance(text, (list)):
        return glue.join(text)
    else:
        return glue.join(text.split("\n"))


def center_text(text, width = None):
    """
    """
    if not width:
        width = get_term_width()
    centered = []
    for line in text.split("\n"):
        if len(line) < width:
            padding = ((width - len(line)) / 2) - 1
        else:
            padding = 0
        centered.append(' ' * padding + line)
    return "\n".join(centered)


def print_line(width = None):
    """
    """
    if not width:
        width = get_term_width()
    print '-'*width


def get_term_width():
    """
    returns terminal width (tested only with Linux)
    """
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

