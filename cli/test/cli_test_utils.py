import unittest
import os
import sys
from copy import deepcopy
from mock import Mock

import katello.client.core.utils
from katello.client.core.utils import SystemExitRequest
from katello.client.api.utils import ApiDataError
from katello.client.i18n_optparse import OptionParserExitError


class ColoredAssertionError(AssertionError):

    RED = '\033[31m'
    RESET = '\033[0;0m'

    def __init__(self, message):
        if sys.stderr.isatty():
            message = self.RED+message+self.RESET
        super(ColoredAssertionError, self).__init__(message)


class CLITestCase(unittest.TestCase):

    failureException = ColoredAssertionError

    _mocked_props = {}
    action = None
    module = None


    def mock_from_module(self, property_name, return_value=None):
        return self.mock(self.module, property_name, return_value)

    def mock(self, obj, property_name, return_value=None):
        #backup methods
        prop = getattr(obj, property_name)
        if not isinstance(prop, Mock):
            key = str(obj) + "#" + property_name
            #save only the original function, not mocks when it's called for second time on the same obj#property
            if not key in self._mocked_props:
                self._mocked_props[key] = (obj, prop, property_name)

        #mock the function
        m = Mock()
        m.return_value = deepcopy(return_value)
        setattr(obj, property_name, m)

        return m

    def restore_mocks(self):
        for key, (obj, prop, prop_name) in self._mocked_props.iteritems():
            setattr(obj, prop_name, prop)

    def set_action(self, action):
        self.action = action

    def set_module(self, module):
        self.module = module

    def tearDown(self):
        self.restore_mocks()

    def assertRaisesException(self, expected, test_case, *args, **kvargs):
        try:
            test_case(*args, **kvargs)
        except expected, e:
            return e
        else:
            raise self.failureException("{0} not raised".format(expected))


class CLIOptionTestCase(CLITestCase):

    allowed_options = []
    disallowed_options = []

    def mock_options(self):
        self.mock(self.action, 'get_option').side_effect = self.mocked_get_option

    def mock_parser(self):
        self.mock(self.action.parser, 'print_help')
        self.mock(self.action.parser, 'error').side_effect = OptionParserExitError

    def mocked_get_option(self, opt, default=None):
        return getattr(self.action.opts, opt, default)

    def assert_options_allowed(self, *options):
        if not self.options_pass(*options):
            self.fail("\nCombination of options (%s) was expected to be ALLOWED in action %s." % (', '.join(options), self.__get_action_name()))

    def assert_options_disallowed(self, *options):
        if self.options_pass(*options):
            self.fail("\nCombination of options (%s) was expected NOT to be allowed in action %s." % (', '.join(options), self.__get_action_name()))

    def options_pass(self, *options):
        self.mock(self.action, 'load_saved_options')
        try:
            self.action.process_options(list(options))
            return True
        except OptionParserExitError:
            return False

    def test_options(self):
        if self.__get_class_name(self) == "CLIOptionTestCase":
            return
        self.mock_parser()
        self.mock_options()
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

    def mock_printer(self):
        printer = self.mock(self.action, 'printer')
        printer.set_header = Mock()
        printer.add_column = Mock()
        printer.print_item = Mock()
        printer.print_items = Mock()
        return printer

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
