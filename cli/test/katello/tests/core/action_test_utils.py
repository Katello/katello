import unittest
import os
from mock import Mock

from katello.tests.test_utils import ColoredAssertionError, EasyMock

import katello.client.core.utils
from katello.client.core.utils import SystemExitRequest
from katello.client.api.utils import ApiDataError
from katello.client.i18n_optparse import OptionParserExitError



class CLITestCase(unittest.TestCase, EasyMock):

    failureException = ColoredAssertionError

    action = None
    module = None

    def set_action(self, action):
        self.action = action

    def set_module(self, module):
        self.module = module

    def tearDown(self):
        self.restore_mocks()


class CLIOptionTestCase(CLITestCase):

    allowed_options = []
    disallowed_options = []

    def get_silent_parser(self):
        parser = self.action.create_parser()
        self.mock(parser, 'print_help')
        self.mock(parser, 'error').side_effect = OptionParserExitError
        return parser

    def assert_options_allowed(self, *options):
        if not self.__options_pass(*options):
            self.fail("\nCombination of options (%s) was expected to be ALLOWED in action %s." % (', '.join(options), self.__get_action_name()))

    def assert_options_disallowed(self, *options):
        if self.__options_pass(*options):
            self.fail("\nCombination of options (%s) was expected NOT to be allowed in action %s." % (', '.join(options), self.__get_action_name()))

    def __options_pass(self, *options):
        try:
            self.action.process_options(self.get_silent_parser(), list(options))
            return True
        except OptionParserExitError:
            return False

    def test_options(self):
        if self.__get_class_name(self) == "CLIOptionTestCase":
            return
        for options in self.allowed_options:
            self.assert_options_allowed(*options)
        for options in self.disallowed_options:
            self.assert_options_disallowed(*options)

    def __get_class_name(self, obj):
        name = str(obj.__class__)
        return name[name.rfind('.')+1:name.rfind('\'')]

    def __get_action_name(self):
        return self.__get_class_name(self.action)


class CLIActionTestCase(CLITestCase):

    _options = {}

    def get_silent_printer(self):
        printer = self.action.create_printer(None)
        printer.set_header = Mock()
        printer.add_column = Mock()
        printer.print_item = Mock()
        printer.print_items = Mock()
        return printer

    def mock_printer(self):
        self.mock(self.action, 'printer', self.get_silent_printer())

    def mock_options(self, options):
        self.mock(self.action, 'get_option').side_effect = self.mocked_get_option
        self._options = options

    def mocked_get_option(self, opt, default=None):
        try:
            return self._options[opt]
        except:
            return default

    def mock_spinner(self):
        spinner = Mock()
        self.mock(spinner, "start")
        self.mock(spinner, "stop")
        self.mock(spinner, "join")
        self.mock(katello.client.core.utils, "Spinner", spinner)

    def run_action(self, expected_return_code=None):
        if expected_return_code:
            self.assert_exits_with(expected_return_code)
        else:
            try:
                self.action.run()
            except SystemExitRequest, ex:
                pass

    def assert_exits_with(self, expected_return_code):
        ret_val = None
        try:
            ret_val = self.action.run()
        except SystemExitRequest, ex:
            self.assertEqual(ex.args[0], expected_return_code)
        except ApiDataError, ex:
            self.assertEqual(os.EX_DATAERR, expected_return_code)
        else:
            self.assertEqual(ret_val, expected_return_code)
