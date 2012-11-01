from unittest import TestCase
from mock import Mock

from katello.client.utils import printer
from katello.client.utils.printer import Printer, VerboseStrategy, GrepStrategy
from katello.client.utils.printer import indent_text, text_to_line, center_text, print_line, batch_add_columns, get_term_width
from katello.tests.test_utils import ColoredAssertionError, EasyMock

import os
import StringIO



class PrinterTestCase(TestCase):

    failureException = ColoredAssertionError


class PrinterTest(PrinterTestCase):

    def setUp(self):
        self.strategy = Mock()
        self.printer = Printer(self.strategy)

    def assert_calls(self, expected_header, expected_columns):
        self.printer.print_item({})
        self.strategy.print_item.assert_called_once_with(expected_header, expected_columns, {})
        self.printer.print_items({})
        self.strategy.print_items.assert_called_once_with(expected_header, expected_columns, {})

    def test_filter_columns_by_strategy(self):
        expected_columns = [{
            'attr_name': 'column_a',
            'name': 'A'
        }, {
            'attr_name': 'column_b',
            'name': 'B',
            'show_with': Mock
        }]
        columns_to_filter_out = [{
            'attr_name': 'column_c',
            'name': 'C',
            'show_with': VerboseStrategy
        }]

        for col in (expected_columns+columns_to_filter_out):
            self.printer.add_column(**col)
        self.assert_calls('', expected_columns)

    def test_all_columns_are_passed_to_strategy(self):
        expected_columns = [{
            'attr_name': 'column_a',
            'name': 'Important Column',
            'unknown_param': '???'
        }, {
            'attr_name': 'column_b',
            'name': 'Another Important Column',
            'formatter': Mock(),
            'item_formatter': Mock()
        }]

        for col in expected_columns:
            self.printer.add_column(**col)
        self.assert_calls('', expected_columns)


    def test_column_name_is_created_automatically(self):
        expected_column = {
            'attr_name': 'some_column',
            'name': 'Some Column'
        }
        self.printer.add_column('some_column')
        self.assert_calls('', [expected_column])

    def test_header_passed_to_strategy(self):
        self.printer.set_header("heading")
        self.assert_calls("heading", [])

    def test_disabled_header(self):
        self.printer = Printer(self.strategy, noheading=True)
        self.printer.set_header("heading")
        self.assert_calls(None, [])


class IndentationTest(PrinterTestCase):

    def test_indent_empty_string(self):
        self.assertEquals(indent_text(""), "\t")

    def test_indent_none(self):
        self.assertEquals(indent_text(None), "\tNone")

    def test_indent_single_line(self):
        self.assertEquals(indent_text("one"), "\tone")

    def test_indent_multiple_lines(self):
        self.assertEquals(indent_text("one\ntwo"), "\tone\n\ttwo")

    def test_indent_array(self):
        self.assertEquals(indent_text(["one", "two"]), "\tone\n\ttwo")

    def test_indent_empty_array(self):
        self.assertEquals(indent_text([]), "\t")

    def test_indent_with_custom_string(self):
        self.assertEquals(indent_text("one\ntwo", "##"), "##one\n##two")


class TextToLineTest(PrinterTestCase):

    def test_empty_string(self):
        self.assertEquals(text_to_line(""), "")

    def test_one_line(self):
        self.assertEquals(text_to_line("one"), "one")

    def test_multiple_lines(self):
        self.assertEquals(text_to_line("one\ntwo"), "one two")

    def test_empty_array(self):
        self.assertEquals(text_to_line([]), "")

    def test_array(self):
        self.assertEquals(text_to_line(["one", "two"]), "one two")

    def test_multiple_lines_with_custom_glue(self):
        self.assertEquals(text_to_line("one\ntwo", glue="##"), "one##two")


class CenterTextTest(PrinterTestCase):

    def test_empty_string(self):
        self.assertEquals(center_text("", 10), " "*5)

    def test_string_longer_than_width(self):
        self.assertEquals(center_text("#"*10, 5), "#"*10)

    def test_one_line_string(self):
        def error_msg(str_odd=True, width_odd=True):
            string = "Odd" if str_odd else "Even"
            width = "odd" if width_odd else "even"
            return "%s string on %s width centered incorrectly." % (string, width)

        self.assertEquals(center_text("AAAA",  11), "   AAAA    ".rstrip(), msg=error_msg(True, False))
        self.assertEquals(center_text("AAA",   11), "    AAA    ".rstrip(), msg=error_msg(False, False))
        self.assertEquals(center_text("AA",    11), "    AA     ".rstrip(), msg=error_msg(True, False))

        self.assertEquals(center_text("AAAA",  10), "   AAAA   ".rstrip(), msg=error_msg(True, True))
        self.assertEquals(center_text("AAA",   10), "   AAA    ".rstrip(), msg=error_msg(False, True))
        self.assertEquals(center_text("AA",    10), "    AA    ".rstrip(), msg=error_msg(True, True))

    def test_multiple_lines_string(self):
        self.assertEquals(center_text("AAA\nBBBBB", 7), "  AAA\n BBBBB")


class PrintLineTest(PrinterTestCase, EasyMock):

    def setUp(self):
        self.output = StringIO.StringIO()
        self.mock(printer, "get_term_width", 20)

    def tearDown(self):
        self.restore_mocks()
        self.output.close()

    def test_negative_width(self):
        print_line(-1, self.output)
        self.assertEquals(self.output.getvalue(), "\n")

    def test_zero_width(self):
        print_line(0, self.output)
        self.assertEquals(self.output.getvalue(), "-"*20 + "\n")

    def test_positive_width(self):
        print_line(5, self.output)
        self.assertEquals(self.output.getvalue(), "-"*5 + "\n")


class BatchAddColumnsTest(PrinterTestCase):

    def setUp(self):
        self.printer = Mock()

    def test_it_adds_columns(self):
        batch_add_columns(self.printer, "col_a", "col_b")
        self.printer.add_column.assert_any_call("col_a")
        self.printer.add_column.assert_any_call("col_b")


