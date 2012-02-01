import unittest
from copy import deepcopy
from mock import Mock

import katello.client.core.utils

class CLITestCase(unittest.TestCase):

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


    def mock_options(self):
        self.mock(self.action, 'get_option').side_effect = self.mocked_get_option

    def mocked_get_option(self, opt, default=None):
        return getattr(self.action.opts, opt, default)



class CLIActionTestCase(CLITestCase):

    _options = {}

    def mock_printer(self):
        printer = self.mock(self.action, 'printer')
        printer.setHeader = Mock()
        printer.addColumn = Mock()
        printer.printItem = Mock()
        printer.printItems = Mock()
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
