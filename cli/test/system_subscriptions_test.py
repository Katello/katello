import unittest
import os

from cli_test_utils import CLIOptionTestCase, CLIActionTestCase
import test_data

import katello.client.core.system
from katello.client.core.system import Subscriptions

class RequiredCLIOptionsTests(CLIOptionTestCase):
    #requires: organization, system's name
    #optional: available

    def setUp(self):
        self.set_action(Subscriptions())
        self.mock_options()

    def test_missing_org_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['subscriptions'])

    def test_missing_name_generates_error(self):
        self.assertRaises(Exception, self.action.process_options, ['subscriptions', '--org=ACME'])

    def test_no_error_if_org_and_name_provided(self):
        self.action.process_options(['subscriptions', '--org=ACME', '--name=system'])
        self.assertEqual(len(self.action.optErrors), 0)

    def test_no_error_if_available_provided(self):
        self.action.process_options(['subscriptions', '--org=ACME', '--name=system', '--available'])
        self.assertEqual(len(self.action.optErrors), 0)


class SystemSubscriptionsTest(CLIActionTestCase):

    ORG_ID = 'some_org'
    SYS_NAME = 'system'
    SYS_ID = 12345

    def setUp(self):
        self.set_action(Subscriptions())
        self.set_module(katello.client.core.system)
        self.mock_printer()
        self.mock(self.action.api, 'systems_by_org', [{'uuid':self.SYS_ID}])
        self.mock(self.action.api, 'subscriptions', {'entitlements':[]})
        self.mock(self.action.api, 'available_pools', ('', ''))
        self.mock(self.module, 'get_system', {'uuid':self.SYS_ID})

    def test_it_calls_subscriptions_api(self):
        self.mock_options({'org': self.ORG_ID})
        self.mock_options({'name': self.SYS_NAME})
        self.run_action()
        self.action.api.subscriptions.assert_called_once_with(self.SYS_ID)

    def test_it_calls_subscriptions_api(self):
        self.mock_options({'org': self.ORG_ID})
        self.mock_options({'name': self.SYS_NAME})
        self.mock_options({'available': True})
        self.run_action()
        self.action.api.available_pools.assert_called_once_with(self.SYS_ID)

