import unittest
from mock import Mock


class CLIActionTestCase(unittest.TestCase):
    
    _options = {}
    _mocked_props = {}
    action = None
    module = None

    def __init__(self, methodName='runTest'):
        super(CLIActionTestCase, self).__init__(methodName)

    def mock_options(self, options):
        self.action.get_option = Mock()
        self.action.get_option.side_effect = self.mocked_get_option

        self._options = options


    def mock_from_module(self, property_name, return_value=None):
        return self.mock(self.module, property_name, return_value)


    def mock(self, obj, property_name, return_value):
        #backup methods
        prop = getattr(obj, property_name)
        if not isinstance(prop, Mock) :
            key = str(obj) + "#" + property_name
            self._mocked_props[key] = (obj, prop, property_name)
        
        #mock the function
        m = Mock()
        if return_value != None:
            m.return_value = return_value
        setattr(obj, property_name, m)
        
        return m


    def restore_mocks(self):
        for key, (obj, prop, prop_name) in self._mocked_props.iteritems():
            setattr(obj, prop_name, prop)


    def set_action(self, action):
        self.action = action


    def set_module(self, module):
        self.module = module


    def mocked_get_option(self, opt, default=None):
        try:
            return self._options[opt]
        except:
            return default


