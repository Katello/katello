import sys
from copy import deepcopy
from mock import Mock



class ColoredAssertionError(AssertionError):

    RED = '\033[31m'
    RESET = '\033[0;0m'

    def __init__(self, message):
        if sys.stderr.isatty():
            message = self.RED+message+self.RESET
        super(ColoredAssertionError, self).__init__(message)

class EasyMock(object):

    __mocked_props = {}

    def mock(self, obj, property_name, return_value=None):
        #backup methods
        self.backup_property(obj, property_name)
        #mock the function
        m = Mock()
        m.return_value = deepcopy(return_value)
        setattr(obj, property_name, m)
        return m

    def backup_property(self, obj, property_name):
        prop = getattr(obj, property_name)
        if not isinstance(prop, Mock):
            key = self.get_property_hash(obj, property_name)
            #save only the original function, not mocks when it's called for second time on the same obj#property
            if not key in self.__mocked_props:
                self.__mocked_props[key] = (obj, prop, property_name)

    def get_property_hash(self, obj, property_name):
        return str(obj) + "#" + property_name

    def restore_mocks(self):
        for key, (obj, prop, prop_name) in self.__mocked_props.iteritems():
            setattr(obj, prop_name, prop)


