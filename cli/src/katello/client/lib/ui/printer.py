# -*- coding: utf-8 -*-

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

import fcntl
import termios
import struct
import sys
import unicodedata


from math import floor
from katello.client.lib.utils.encoding import u_str



class PrinterStrategy(object):
    """
    Strategy of formatting the data and printing them on the output.
    """

    def __init__(self, output=sys.stdout):
        super(PrinterStrategy, self).__init__()
        self._output = output

    def print_item(self, heading, columns, item):
        """
        Print one item

        :type heading: string
        :param heading: Title for the list of items
        :type columns: list of dicts
        :param columns: definition of columns
        :type item: dict
        :param item: data to be printed, one item
        """
        self.print_items(heading, columns, [item])

    def print_items(self, heading, columns, items):
        """
        Print list of items

        :type heading: string
        :param heading: Title for the list of items
        :type columns: list of dicts
        :param columns: definition of columns
        :type items: list of dicts
        :param items: data to be printed, list of items
        """
        pass

    @classmethod
    def _column_has_value(cls, column, item):
        """
        Tests whether there is any value to print in the column.
        It can be value either from the item or set explicitly
        in the column definition.

        :type column: dict
        :param column: column definition
        :type item: dict
        :param item: data to get the value from
        :rtype: bool
        """
        return (column['attr_name'] in item) or ('value' in column) or ('item_formatter' in column)

    @classmethod
    def _get_column_value(cls, column, item):
        """
        Returns string that should be displayed in the column.
        It's either a given value or attribute of the item. Formatters
        are applied if they are available.

        :type column: dict
        :param column: column definition
        :type item: dict
        :param item: data to get the value from
        :rtype: string
        """
        value = item.get(column['attr_name'], None)
        if value is None:
            value = column.get('value', None)
        value_format_func = column.get('formatter', column.get('value_formatter', None))
        item_format_func = column.get('item_formatter', None)

        if value_format_func is not None:
            value = value_format_func(value)
        elif item_format_func is not None:
            value = item_format_func(item)
        return value

    def _println(self, text=''):
        self._print(text + "\n")

    def _print(self, text=''):
        self._output.write(text)


class VerboseStrategy(PrinterStrategy):

    def print_items(self, heading, columns, items):
        """
        Print list of items

        :type heading: string
        :param heading: Title for the list of items
        :type columns: list of dicts
        :param columns: definition of columns
        :type items: list of dicts
        :param items: data to be printed, list of items
        """
        if heading is not None:
            self._print_header(heading)
        for item in items:
            self._print_item(item, columns)
            self._println()

    def _print_header(self, heading):
        """
        Print a fancy header to stdout.

        :type heading: string or list of strings
        :param heading: headers to be displayed
        """
        print_line(output=self._output)
        self._println(center_text(heading))
        print_line(output=self._output)


    def _print_item(self, item, columns):
        """
        Print one record.

        :type item: hash
        :param item: data to print
        :type columns: list of dicts
        :param columns: columns definition
        """
        self._println()
        for column in columns:
            if not self._column_has_value(column, item):
                continue

            value = self._get_column_value(column, item)

            if not column.get('multiline', False):
                col_width = self._max_label_width(columns)
                if not isinstance(value, (list, tuple)):
                    value = [value]
                for v in value:
                    self._println(("{0:<" + u_str(col_width) + "} : {1}").format(u_str(column['name']), u_str(v)))
            else:
                self._println(column['name'] + ":")
                self._println(indent_text(value, "    "))


    @classmethod
    def _max_label_width(cls, columns):
        """
        Returns maximum width of the column labels.

        :type columns: list of dicts
        :param columns: columns definition
        :rtype: int
        """
        width = 0
        for column in columns:
            current_width = unicode_len(_(column['name']))
            if (current_width > width):
                width = current_width
        return width


class GrepStrategy(PrinterStrategy):
    """
    Prints data into a grid that can be grepped easily.
    String to divide the columns can be set optionally.
    """

    def __init__(self, delimiter=None, output=sys.stdout):
        """
        :type delimiter: string
        :param delimiter: delimiter for dividing the grid columns
        :type noheading: boolean
        :param noheading: to suppress headings in the output
        """
        super(GrepStrategy, self).__init__(output)
        self.__delim = delimiter if delimiter else ""

    def print_items(self, heading, columns, items):
        """
        Print list of items

        :type heading: string
        :param heading: Title for the list of items
        :type columns: list of dicts
        :param columns: definition of columns
        :type items: list of dicts
        :param items: data to be printed, list of items
        """
        column_widths = self._calc_column_widths(items, columns)
        if heading is not None:
            self._print_header(heading, columns, column_widths)
        for item in items:
            self._print_item(item, columns, column_widths)
            self._println()

    def _print_header(self, heading, columns, column_widths):
        """
        Print a fancy header with column labels to stdout.

        :type heading: string or list of strings
        :param heading: headers to be displayed
        :type columns: list of dicts
        :param columns: columns definition
        :type column_widths: dict
        :param column_widths: dictionary that holds maximal widths of columns {attr_name -> width}
        """
        print_line(output=self._output)
        self._println(center_text(heading))

        self._println()
        for column in columns:
            width = column_widths.get(column['attr_name'], 0)

            if self.__delim:
                self._print(column['name'] + self.__delim)
            else:
                self._print(column['name'].ljust(width))
        print
        print_line(output=self._output)


    def _print_item(self, item, columns, column_widths):
        """
        Print item of a list on single line

        :type item: hash
        :param item: data to print
        :type columns: list of dicts
        :param columns: columns definition
        :type column_widths:
        :param column_widths:
        """
        for column in columns:
            #get defined width
            width = column_widths.get(column['attr_name'], 0)

            #skip missing attributes
            if not self._column_has_value(column, item):
                if self.__delim:
                    self._print(" " * width)
                else:
                    self._print(self.__delim)
                continue
            value = self._get_column_value(column, item)

            if column.get('multiline', False):
                value = text_to_line(value)
            value = u_str(value)

            if self.__delim:
                self._print('%s' % (value) + self.__delim)
            else:
                self._print('%s%s' % (value, ' '*(width-unicode_len((value)))))


    def _column_width(self, items, column):
        """
        Returns maximum width for the column to ensure that all the data
        and the label fits in.

        :type columns: list of dicts
        :param columns: columns definition
        :type column: dict
        :param column: column definition
        :rtype: int
        """
        width = unicode_len(column['name'])+1
        for column_value in [u_str(self._get_column_value(column, item)) for item in items]:
            new_width = unicode_len(column_value)
            if width <= new_width:
                width = new_width+1
        return width

    def _calc_column_widths(self, items, columns):
        """
        Counts and returns dictionary that holds maximal widths of all columns {attr_name -> width}

        :type items: list of dicts
        :param items: data to be printed
        :type columns: list of dicts
        :param columns: columns definition
        :rtype: dict
        """
        widths = {}
        for column in columns:
            widths[column['attr_name']] = self._column_width(items, column)
        return widths


class Printer:
    """
    Unified interface for printing data in CLI.
    """

    def __init__(self, strategy=None, noheading=False):
        """
        :type strategy: PrinterStrategy
        :param strategy: strategy that is used for formatting the output.
        """
        self.__printer_strategy = strategy
        self.__columns = []
        self.__heading = ""
        self.__nohead = noheading

    def set_header(self, heading):
        """
        Sets label for a fancy header that is printed above the data.

        :param heading:
        :type heading: string
        """
        self.__heading = heading

    def get_header(self):
        """
        Returns header or None when heading was disabled with an option.
        """
        if self.__nohead:
            return None
        else:
            return self.__heading

    def set_strategy(self, strategy):
        """
        Sets formatting strategy

        :type strategy: PrinterStrategy
        :param strategy: strategy that is used for formatting the output.
        """
        self.__printer_strategy = strategy

    def add_column(self, attr_name, name = None, **kwargs):
        """
        Add column of data thet will be displayed

        :type attr_name: string
        :param attr_name: key to data hash
        :type name: string
        :param name: label for the column. It is generated automatically from attr_name if it's not set.
        :type kwargs: dict
        :param kwargs: other parameters that are passed to the printer strategy
        """
        col = kwargs
        col['attr_name'] = attr_name
        col['name'] = _(self.__attr_to_name(attr_name)) if not name else name
        self.__columns.append(col)

    def print_item(self, item):
        """
        Print one record

        :type item: dict
        :param item: data to be printed
        """
        if not self.__printer_strategy:
            self.set_strategy(VerboseStrategy())
        self.__printer_strategy.print_item(self.get_header(), self.__filtered_columns(), item)

    def print_items(self, items):
        """
        Print list of records

        :type items: list of dicts
        :param items: data to be printed
        """
        if not self.__printer_strategy:
            self.set_strategy(GrepStrategy())
        self.__printer_strategy.print_items(self.get_header(), self.__filtered_columns(), items)

    @classmethod
    def __attr_to_name(cls, attr_name):
        """
        Convert attribute name to display name.
        oraganization_id -> Organization Id

        :type attr_name: string
        :param attr_name: attribute name
        :rtype: string
        """
        return " ".join([part[0].upper() + part[1:] for part in attr_name.split("_")])

    def __filtered_columns(self):
        """
        :return: list of columns that can be printed with current strategy
        :rtype: list of column definition dicts
        """
        filtered = []
        for column in self.__columns:
            allowed_strategies = column.get('show_with', (object))
            if isinstance(self.__printer_strategy, allowed_strategies):
                filtered.append(column)
        return filtered


def indent_text(text, indent="\t"):
    """
    Indents given text.

    :type text: string or list of strings
    :param text: text to be indented
    :type indent: string
    :param indent: value that is added at the beggining of each line of the text
    :rtype: string
    """
    if text is None:
        text = u_str(None)

    if isinstance(text, list):
        glue = "\n"+indent
        return indent+glue.join([u_str(l) for l in text])
    else:
        return indent_text(text.split("\n"), indent)


def text_to_line(text, glue=" "):
    """
    Squeezes a block of text to one line.

    :type text: string
    :param text: text to be processed
    :type glue: string
    :param glue: string used for joining lines of the text
    :rtype: string
    """
    if text is None:
        text = u_str(None)

    if isinstance(text, list):
        return glue.join(text)
    else:
        return glue.join(text.split("\n"))


def center_text(text, width=None):
    """
    Centers block of text in given width.

    :type text: string
    :param text: text to be processed
    :type width: int
    :param width: width of space the text should be centered to. If no width is given,
    full terminal size is used.
    :rtype: string
    """
    if not width:
        width = get_term_width()
    centered = []
    for line in text.split("\n"):
        len_line = unicode_len(line)
        if len_line < width:
            padding = int(floor((width - len_line) / 2.0))
        else:
            padding = 0
        centered.append(' ' * padding + line)
    return "\n".join(centered)


def print_line(width=None, output=sys.stdout):
    """
    Prints line of characters '-' to stdout

    :type width: int
    :param width: width of the line in characters. If no width is given,
    full terminal size is used.
    """
    if not width:
        width = get_term_width()
    print >> output, '-'*width


def get_term_width():
    """
    returns terminal width (tested only with Linux)

    :rtype: int
    """
    try:
        w = struct.unpack('HHHH',
            fcntl.ioctl(0, termios.TIOCGWINSZ,
            struct.pack('HHHH', 0, 0, 0, 0)))[1]
        w = int(w)
    except:  # pylint: disable=W0702
        w = 80
    return 80 if w == 0 else w


def unicode_len(text):
    """ return byte lenght of unicode character """
    return sum(1+(unicodedata.east_asian_width(c) in "WF") for c in u_str(text))

def batch_add_columns(printer, *cols, **kwargs):
    for c in cols:
        for key in c.keys(): # should only ever be one
            printer.add_column(key, c[key], **kwargs)
