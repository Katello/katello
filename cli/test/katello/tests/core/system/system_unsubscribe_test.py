import unittest
import os

from katello.tests.core.action_test_utils import CLIOptionTestCase, CLIActionTestCase

import katello.client.core.system
from katello.client.core.system import Unsubscribe

class RequiredCLIOptionsTests(CLIOptionTestCase):
    #requires: organization, system's name, one of (serial, entitlement, all)

    action = Unsubscribe()

    disallowed_options = [
        (),
        ('--org=ACME', ),
        ('--org=ACME', '--name=system', ),
        ('--org=ACME', '--name=system', '--all', '--serial=1', '--entitlement=1'),
    ]

    allowed_options = [
        ('--org=ACME', '--name=system', '--all'),
        ('--org=ACME', '--name=system', '--serial=1'),
        ('--org=ACME', '--name=system', '--entitlement=1'),
    ]


class SystemUnsubscribeTest(CLIActionTestCase):

    ORG_ID = 'some_org'
    SYS_NAME = 'system'
    SYS_ID = 12345
    ENT_ID = 23456
    SERIAL_ID = 34567

    def setUp(self):
        self.set_action(Unsubscribe())
        self.set_module(katello.client.core.system)
        self.mock_printer()
        self.mock(self.action.api, 'systems_by_org', [{'uuid':self.SYS_ID}])
        self.mock(self.action.api, 'unsubscribe', 0)
        self.mock(self.action.api, 'unsubscribe_by_serial', 0)
        self.mock(self.action.api, 'unsubscribe_all', 0)
        self.mock(self.module, 'get_system', {'uuid':self.SYS_ID})

    def test_it_calls_unsubscribe_api(self):
        self.mock_options({'org': self.ORG_ID})
        self.mock_options({'name': self.SYS_NAME})
        self.mock_options({'entitlement': self.ENT_ID})
        self.run_action()
        self.action.api.unsubscribe.assert_called_once_with(self.SYS_ID, self.ENT_ID)

    def test_it_calls_unsubscribe_by_serial(self):
        self.mock_options({'org': self.ORG_ID})
        self.mock_options({'name': self.SYS_NAME})
        self.mock_options({'serial': self.SERIAL_ID})
        self.run_action()
        self.action.api.unsubscribe_by_serial.assert_called_once_with(self.SYS_ID, self.SERIAL_ID)

    def test_it_calls_unsubscribe_all(self):
        self.mock_options({'org': self.ORG_ID})
        self.mock_options({'name': self.SYS_NAME})
        self.mock_options({'all': True})
        self.run_action()
        self.action.api.unsubscribe_all.assert_called_once_with(self.SYS_ID)
