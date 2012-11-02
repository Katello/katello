from unittest import TestCase
from mock import Mock

from katello.client.utils import printer
from katello.client.utils.printer import Printer, VerboseStrategy, GrepStrategy
from katello.client.utils.printer import indent_text, text_to_line, center_text, print_line, get_term_width
from katello.tests.test_utils import ColoredAssertionError, EasyMock

import os
import StringIO

class PrintStrategyTest(EasyMock):

    failureException = ColoredAssertionError

    PRINTABLE_ITEM_A = {
        'id': 'A1',
        'name': 'name_a',
        'none': None
    }

    PRINTABLE_ITEM_B = {
        'id': 'B2',
        'name': 'name_b',
        'none': None
    }

    PRINTABLE_ITEMS = [
        PRINTABLE_ITEM_A,
        PRINTABLE_ITEM_B
    ]

    def setUp(self):
        self.output = StringIO.StringIO()
        self.mock(printer, "get_term_width", 20)
        self.strategy = self.create_strategy()

    def tearDown(self):
        self.output.close()
        self.restore_mocks()

    def create_strategy(self):
        raise NotImplemented()

    def fake_formatter(self, value):
        return '###'

    def print_it(self, columns, items, header="header"):
        self.strategy.print_item(header, columns, items)
        return self.output.getvalue()


class OutputStrategyTest(PrintStrategyTest):

    def test_value_is_printed(self):
        columns = [{'attr_name': 'id', 'name': 'Id'}]
        out = self.print_it(columns, self.PRINTABLE_ITEM_A)
        self.assertTrue(out.find('A1') >= 0)

    def test_none_value_is_printed(self):
        columns = [{'attr_name': 'none', 'name': 'Unknown'}]
        out = self.print_it(columns, self.PRINTABLE_ITEM_A)
        self.assertTrue(out.find('None') >= 0)

    def test_for_missing_value_is_printed(self):
        columns = [{'attr_name': 'none', 'name': 'Unknown'}]
        out = self.print_it(columns, self.PRINTABLE_ITEM_A)
        self.assertTrue(out.find('None') >= 0)

    def test_value_formatter_is_used(self):
        columns = [{'attr_name': 'id', 'name': 'Id', 'formatter': self.fake_formatter}]
        out = self.print_it(columns, self.PRINTABLE_ITEM_A)
        self.assertTrue(out.find('###') >= 0)
        self.assertTrue(out.find('A1') == -1)

    def test_item_formatter_is_used(self):
        columns = [{'attr_name': 'id', 'name': 'Id', 'item_formatter': self.fake_formatter}]
        out = self.print_it(columns, self.PRINTABLE_ITEM_A)
        self.assertTrue(out.find('###') >= 0)
        self.assertTrue(out.find('A1') == -1)


class DefaultValueStrategyTest(PrintStrategyTest):

    COLUMNS = [{'attr_name': 'id', 'name': 'Id', 'value': 'overriding_value'}]
    OWN_VALUE = 'overriding_value'

    def test_default_value_is_used_when_the_attr_is_missing(self):
        out = self.print_it(self.COLUMNS, {})
        self.assertTrue(out.find(self.OWN_VALUE) >= 0)

    def test_default_value_is_used_when_the_attr_is_none(self):
        out = self.print_it(self.COLUMNS, {'id': None})
        self.assertTrue(out.find(self.OWN_VALUE) >= 0)

    def test_default_value_isnt_used_when_the_attr_is_present(self):
        out = self.print_it(self.COLUMNS, self.PRINTABLE_ITEM_A)
        self.assertTrue(out.find(self.OWN_VALUE) < 0)


class MultipleOutputStrategyTest(PrintStrategyTest):

    def print_it(self, columns, items, header="header"):
        self.strategy.print_items(header, columns, items)
        return self.output.getvalue()

    def test_values_are_printed(self):
        columns = [{'attr_name': 'id', 'name': 'Id'}]
        out = self.print_it(columns, self.PRINTABLE_ITEMS)
        self.assertTrue(out.find('A1') >= 0)
        self.assertTrue(out.find('B2') >= 0)



class GrepStrategyTest():

    def create_strategy(self):
        return GrepStrategy(output=self.output)

class VerboseStrategyTest():

    def create_strategy(self):
        return VerboseStrategy(output=self.output)


class GrepOutputStrategyTest(GrepStrategyTest, OutputStrategyTest, TestCase):
    pass

class GrepDefaultValueStrategyTest(GrepStrategyTest, DefaultValueStrategyTest, TestCase):
    pass

class GrepMultipleOutputStrategyTest(GrepStrategyTest, MultipleOutputStrategyTest, TestCase):
    pass

class VerboseOutputStrategyTest(VerboseStrategyTest, OutputStrategyTest, TestCase):
    pass

class VerboseDefaultValueStrategyTest(VerboseStrategyTest, DefaultValueStrategyTest, TestCase):
    pass

class VerboseMultipleOutputStrategyTest(VerboseStrategyTest, MultipleOutputStrategyTest, TestCase):
    pass

