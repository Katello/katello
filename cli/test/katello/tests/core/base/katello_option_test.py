from unittest import TestCase
from mock import Mock

from katello.client.i18n_optparse import OptionParser, OptionParserExitError
from katello.client.core.base import KatelloOption
from cli_test_utils import ColoredAssertionError

class KatelloOptionTestCase(TestCase):

    failureException = ColoredAssertionError

    def setup_parser(self):
        self.parser = OptionParser(option_class=KatelloOption)
        self.parser.error = Mock()
        self.parser.error.side_effect = OptionParserExitError()
        return self.parser

    def assert_args_valid(self, cli_arguments):
        cli_arguments = self.__ensure_iterable(cli_arguments)
        try:
            self.opts, self.args = self.parser.parse_args(cli_arguments)
        except OptionParserExitError, opee:
            self.fail("The option parser should accept arguments [ %s ]" % ", ".join(cli_arguments) )

    def assert_args_invalid(self, cli_arguments):
        cli_arguments = self.__ensure_iterable(cli_arguments)
        try:
            self.opts, self.args = self.parser.parse_args(cli_arguments)
            self.fail("The option parser should NOT accept arguments [ %s ]" % ", ".join(cli_arguments) )
        except OptionParserExitError, opee:
            pass

    def get_option(self, dest):
        return getattr(self.opts, dest)


    def __ensure_iterable(self, var):
        if not isinstance(var, (tuple, list)):
            return [var]
        else:
            return var


class BoolOptionTest(KatelloOptionTestCase):

    def setUp(self):
        self.setup_parser()
        self.parser.add_option("--opt", type="bool", dest="opt")

    def test_it_accepts_true(self):
        for arg in ["True", "true", "TRUE"]:
            self.assert_args_valid("--opt="+arg)
            self.assertTrue(self.get_option("opt"))

    def test_it_accepts_false(self):
        for arg in ["False", "false", "FALSE"]:
            self.assert_args_valid("--opt="+arg)
            self.assertFalse(self.get_option("opt"))

    def test_it_does_not_accept_empty_value(self):
        self.assert_args_invalid("--opt=")


class ListOptionTest(KatelloOptionTestCase):

    def __test_with_args(self, args, expected_len, delim=None):
        self.setup_parser()
        self.parser.add_option("--opt", type="list", dest="opt", delimiter=delim)

        self.assert_args_valid(args)
        self.assertTrue(isinstance(self.get_option("opt"), list))
        self.assertEquals(len(self.get_option("opt")), expected_len)

    def test_it_accepts_list(self):
        self.__test_with_args("--opt=item1,item2,item3", 3)

    def test_it_accepts_single_item(self):
        self.__test_with_args("--opt=item1", 1)

    def test_it_accepts_empty_value(self):
        self.__test_with_args("--opt=", 0)

    def test_it_accepts_list_with_given_delimiter(self):
        self.__test_with_args("--opt=item1#item2#item3", 3, delim="#")

    def test_it_accepts_single_item_with_given_delimiter(self):
        self.__test_with_args("--opt=item1", 1, delim="#")

    def test_it_accepts_empty_value_with_given_delimiter(self):
        self.__test_with_args("--opt=", 0, delim="#")


class UrlOptionTest(KatelloOptionTestCase):

    def setUp(self):
        self.setup_parser()
        self.parser.add_option("--opt", type="url", dest="opt")
        self.parser.add_option("--opt2", type="url", dest="opt2", schemes=["abc"])

    def test_it_accepts_http_by_default(self):
        self.assert_args_valid("--opt=http://walrus.org/a/b/c/")

    def test_it_accepts_https_by_default(self):
        self.assert_args_valid("--opt=https://walrus.org/a/b/c/")

    def test_it_does_not_accept_non_urls(self):
        self.assert_args_invalid("--opt2=some_string")

    def test_it_accepts_custom_schemes(self):
        self.assert_args_valid("--opt2=abc://walrus.org/a/b/c/")

    def test_it_does_not_accept_disabled_schemes(self):
        self.assert_args_invalid("--opt2=http://walrus.org/a/b/c/")
